// Публичные профили: поиск людей и просмотр профиля по id или @nickname
const express = require('express');
const db = require('../db');
const { required } = require('../middleware/auth');
const router = express.Router();

const PROFILE_FIELDS = `u.id, u.username, u.first_name, u.last_name, u.avatar_url, u.bio,
  u.city_id, u.home_country, u.gender, u.account_type, u.created_at`;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Поиск людей: ?q=&city_id=&home_country=&page=&limit=
router.get('/', async (req, res) => {
  const q = String(req.query.q || '').trim();
  const cityId = req.query.city_id ? Number(req.query.city_id) : null;
  const homeCountry = req.query.home_country ? String(req.query.home_country).toUpperCase() : null;
  const page = Math.max(1, Number(req.query.page) || 1);
  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));

  const where = ['u.deleted_at IS NULL', 'u.is_blocked = false'];
  const params = [];
  let i = 1;
  if (q) { where.push(`(u.first_name ILIKE $${i} OR u.last_name ILIKE $${i} OR u.username ILIKE $${i})`); params.push(`%${q}%`); i++; }
  if (cityId) { where.push(`u.city_id = $${i++}`); params.push(cityId); }
  if (homeCountry) { where.push(`u.home_country = $${i++}`); params.push(homeCountry); }

  params.push(limit, (page - 1) * limit);
  const r = await db.query(
    `SELECT ${PROFILE_FIELDS} FROM users u WHERE ${where.join(' AND ')} ORDER BY u.username LIMIT $${i++} OFFSET $${i}`,
    params);
  res.json(r.rows);
});

// Жалоба на пользователя (форма 37 со шторки «⋯» на чужом профиле)
router.post('/:id/report', required, async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  if (req.params.id === req.userId) return res.status(400).json({ error: 'INVALID_USER' });
  const reason = String(req.body.reason_type || '');
  const comment = String(req.body.comment || '').trim().slice(0, 300);
  const errors = {};
  if (!['spam', 'fraud', 'abuse', 'other'].includes(reason)) errors.reason_type = 'INVALID_REASON';
  if (reason === 'other' && !comment) errors.comment = 'REQUIRED_FOR_OTHER';
  if (Object.keys(errors).length) return res.status(400).json({ errors });

  const target = await db.query('SELECT 1 FROM users WHERE id=$1 AND deleted_at IS NULL', [req.params.id]);
  if (!target.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  await db.query(
    'INSERT INTO user_reports (reporter_id, target_id, reason_type, comment) VALUES ($1,$2,$3,$4)',
    [req.userId, req.params.id, reason, comment || null]);
  res.json({ ok: true });
});

// Профиль по id или @nickname
router.get('/:idOrNick', async (req, res) => {
  const raw = req.params.idOrNick;
  const byNick = raw.startsWith('@');
  const value = byNick ? raw.slice(1).toLowerCase() : raw;
  const field = byNick ? 'u.username' : 'u.id';
  if (!byNick && !UUID_RE.test(value)) return res.status(404).json({ error: 'NOT_FOUND' });

  const r = await db.query(
    `SELECT ${PROFILE_FIELDS}, u.is_blocked,
       (u.last_seen_at > now() - interval '5 minutes') AS is_online,
       (SELECT count(*)::int FROM friendships f WHERE f.status='accepted' AND (f.requester_id=u.id OR f.addressee_id=u.id)) AS friends_count,
       (SELECT count(*)::int FROM services s WHERE s.author_id=u.id AND s.status<>'hidden') AS services_count,
       COALESCE((SELECT json_agg(json_build_object('id', p.id, 'url', p.url) ORDER BY p.position, p.created_at)
                 FROM user_photos p WHERE p.user_id=u.id), '[]'::json) AS photos
     FROM users u WHERE ${field}=$1 AND u.deleted_at IS NULL`, [value]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  // Заблокированного не прячем за 404: приложению нужно объяснить, что случилось
  const { is_blocked, ...profile } = r.rows[0];
  if (is_blocked) return res.status(403).json({ error: 'USER_BLOCKED' });
  res.json(profile);
});

module.exports = router;
