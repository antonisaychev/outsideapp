// Знакомства: анкета, колода, свайпы, мэтч → автодружба
const express = require('express');
const db = require('../db');
const { required } = require('../middleware/auth');
const { ensureFriendship, getRelationship } = require('../utils/friendships');
const { notify } = require('../utils/notify');

const router = express.Router();
router.use(required);

const LOOKING_FOR = ['friends', 'dating', 'networking', 'any'];
const SHOW_GENDER = ['male', 'female', 'any'];
const DAILY_LIKE_LIMIT = 100;

router.get('/profile', async (req, res) => {
  const r = await db.query(`
    SELECT u.first_name, u.avatar_url, u.gender, u.birth_date,
           dp.is_active, dp.looking_for, dp.show_gender
    FROM users u LEFT JOIN dating_profiles dp ON dp.user_id = u.id
    WHERE u.id=$1`, [req.userId]);
  const row = r.rows[0];
  res.json({
    // Знакомства включены по умолчанию: запись появляется только при отключении
    is_active: row.is_active === null || row.is_active === undefined ? true : row.is_active,
    looking_for: row.looking_for || 'any',
    show_gender: row.show_gender || 'any',
    eligible: !!(row.first_name && row.avatar_url && row.gender && row.birth_date),
  });
});

// Тумблер «Участвовать» — мгновенный PATCH; включение требует заполненного профиля
router.patch('/profile', async (req, res) => {
  const body = req.body || {};
  const errors = {};
  let isActive = null, lookingFor = null, showGender = null;

  if ('looking_for' in body) {
    if (!LOOKING_FOR.includes(body.looking_for)) errors.looking_for = 'INVALID_VALUE';
    else lookingFor = body.looking_for;
  }
  if ('show_gender' in body) {
    if (!SHOW_GENDER.includes(body.show_gender)) errors.show_gender = 'INVALID_VALUE';
    else showGender = body.show_gender;
  }
  if ('is_active' in body) {
    if (typeof body.is_active !== 'boolean') errors.is_active = 'INVALID_VALUE';
    else isActive = body.is_active;
  }
  if (Object.keys(errors).length) return res.status(400).json({ errors });

  await db.query(`
    INSERT INTO dating_profiles (user_id, is_active, looking_for, show_gender)
    VALUES ($1, COALESCE($2,false), COALESCE($3,'any'), COALESCE($4,'any'))
    ON CONFLICT (user_id) DO UPDATE SET
      is_active = COALESCE($2, dating_profiles.is_active),
      looking_for = COALESCE($3, dating_profiles.looking_for),
      show_gender = COALESCE($4, dating_profiles.show_gender)`,
    [req.userId, isActive, lookingFor, showGender]);

  const r = await db.query('SELECT is_active, looking_for, show_gender FROM dating_profiles WHERE user_id=$1', [req.userId]);
  res.json(r.rows[0]);
});

// Колода: тот же город, взаимный фильтр по полу, без уже свайпнутых (pass возвращается через 30 дней)
router.get('/deck', async (req, res) => {
  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
  const me = await db.query(`
    SELECT u.city_id, u.gender, dp.show_gender, dp.is_active
    FROM users u LEFT JOIN dating_profiles dp ON dp.user_id=u.id
    WHERE u.id=$1`, [req.userId]);
  const my = me.rows[0];
  if (my.is_active === false) return res.status(403).json({ error: 'DATING_NOT_ACTIVE' });
  if (!my.city_id) return res.json([]);

  const r = await db.query(`
    SELECT u.id, u.username, u.first_name, u.avatar_url, u.bio, u.gender, u.birth_date,
           COALESCE((SELECT json_agg(json_build_object('id', p.id, 'url', p.url) ORDER BY p.position, p.created_at)
                     FROM user_photos p WHERE p.user_id=u.id), '[]'::json) AS photos
    FROM users u LEFT JOIN dating_profiles dp ON dp.user_id = u.id
    WHERE COALESCE(dp.is_active, true) = true AND u.id <> $1
      AND u.deleted_at IS NULL AND u.is_blocked = false
      AND u.city_id = $2
      -- без фото, пола и возраста карточку показывать нечем
      AND u.avatar_url IS NOT NULL AND u.gender IS NOT NULL AND u.birth_date IS NOT NULL
      AND (COALESCE(dp.show_gender, 'any') = 'any' OR dp.show_gender = $3)
      AND ($4 = 'any' OR u.gender = $4)
      AND NOT EXISTS (
        SELECT 1 FROM swipes s WHERE s.swiper_id=$1 AND s.target_id=u.id
          AND (s.direction='like'
               OR (s.direction='pass' AND s.created_at > now() - interval '30 days'
                   -- анкету поправили после свайпа — показываем заново
                   AND s.created_at >= u.profile_updated_at))
      )
      AND NOT EXISTS (
        SELECT 1 FROM friendships f WHERE f.status='blocked'
          AND ((f.requester_id=$1 AND f.addressee_id=u.id) OR (f.requester_id=u.id AND f.addressee_id=$1))
      )
    ORDER BY random() LIMIT $5`,
    // show_gender по умолчанию 'any': записи в dating_profiles может не быть
    [req.userId, my.city_id, my.gender, my.show_gender || 'any', limit]);
  res.json(r.rows);
});

// Свайп: like/pass; взаимный like = мэтч → автодружба + диалог
router.post('/swipe', async (req, res) => {
  const targetId = String(req.body.user_id || '');
  const direction = req.body.direction;
  if (!['like', 'pass'].includes(direction)) return res.status(400).json({ error: 'INVALID_DIRECTION' });
  if (!targetId || targetId === req.userId) return res.status(400).json({ error: 'INVALID_USER' });

  const my = await db.query('SELECT is_active FROM dating_profiles WHERE user_id=$1', [req.userId]);
  if (my.rowCount && my.rows[0].is_active === false) return res.status(403).json({ error: 'DATING_NOT_ACTIVE' });

  const target = await db.query('SELECT 1 FROM users WHERE id=$1 AND deleted_at IS NULL AND is_blocked=false', [targetId]);
  if (!target.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });

  if (direction === 'like') {
    const count = await db.query(
      `SELECT count(*)::int AS c FROM swipes WHERE swiper_id=$1 AND direction='like' AND created_at >= now() - interval '1 day'`,
      [req.userId]);
    if (count.rows[0].c >= DAILY_LIKE_LIMIT) return res.status(429).json({ error: 'LIKE_LIMIT_REACHED' });
  }

  await db.query(
    `INSERT INTO swipes (swiper_id, target_id, direction) VALUES ($1,$2,$3)
     ON CONFLICT (swiper_id, target_id) DO UPDATE SET direction=$3, created_at=now()`,
    [req.userId, targetId, direction]);

  if (direction === 'pass') return res.json({ match: false });

  const reciprocal = await db.query(
    `SELECT 1 FROM swipes WHERE swiper_id=$1 AND target_id=$2 AND direction='like'`,
    [targetId, req.userId]);

  // Лайк без взаимности = обычная заявка в друзья (правка от 2026-07-28)
  if (!reciprocal.rowCount) {
    const rel = await getRelationship(req.userId, targetId);
    if (!rel) {
      await db.query(
        `INSERT INTO friendships (requester_id, addressee_id, status) VALUES ($1,$2,'pending')`,
        [req.userId, targetId]);
      await notify(targetId, 'friend_request', { actorId: req.userId });
    } else if (rel.status === 'pending' && rel.requester_id === targetId) {
      // Встречная заявка уже висела — лайк её принимает
      await ensureFriendship(req.userId, targetId);
      await notify(targetId, 'friend_accepted', { actorId: req.userId });
    }
    return res.json({ match: false });
  }

  const [a, b] = req.userId < targetId ? [req.userId, targetId] : [targetId, req.userId];
  await db.query('INSERT INTO matches (user_a, user_b) VALUES ($1,$2) ON CONFLICT DO NOTHING', [a, b]);
  await ensureFriendship(req.userId, targetId);
  await db.query('INSERT INTO conversations (user_a, user_b) VALUES ($1,$2) ON CONFLICT DO NOTHING', [a, b]);
  await notify(req.userId, 'match', { actorId: targetId });
  await notify(targetId, 'match', { actorId: req.userId });

  const other = await db.query('SELECT id, username, first_name, avatar_url FROM users WHERE id=$1', [targetId]);
  res.json({ match: true, user: other.rows[0] });
});

router.get('/matches', async (req, res) => {
  const page = Math.max(1, Number(req.query.page) || 1);
  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
  const r = await db.query(`
    SELECT u.id, u.username, u.first_name, u.avatar_url, m.created_at AS matched_at
    FROM matches m
    JOIN users u ON u.id = (CASE WHEN m.user_a=$1 THEN m.user_b ELSE m.user_a END)
    WHERE (m.user_a=$1 OR m.user_b=$1) AND u.deleted_at IS NULL
    ORDER BY m.created_at DESC LIMIT $2 OFFSET $3`,
    [req.userId, limit, (page - 1) * limit]);
  res.json(r.rows);
});

module.exports = router;
