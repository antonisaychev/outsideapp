// Друзья: заявки, принятие/отклонение, удаление, блокировки, рекомендации
const express = require('express');
const db = require('../db');
const { required } = require('../middleware/auth');
const { notify } = require('../utils/notify');

const router = express.Router();
router.use(required);

const PAGE_FIELDS = `u.id, u.username, u.first_name, u.last_name, u.avatar_url, u.home_country`;

function pagination(req) {
  const page = Math.max(1, Number(req.query.page) || 1);
  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
  return { limit, offset: (page - 1) * limit };
}

// Любая существующая связь между двумя юзерами (в любом направлении)
async function getRelationship(userA, userB) {
  const r = await db.query(
    `SELECT * FROM friendships WHERE (requester_id=$1 AND addressee_id=$2) OR (requester_id=$2 AND addressee_id=$1)`,
    [userA, userB]);
  return r.rows[0] || null;
}

// Отправить заявку в друзья (взаимная заявка → автодружба)
router.post('/requests', async (req, res) => {
  const targetId = String(req.body.user_id || '');
  if (!targetId || targetId === req.userId) return res.status(400).json({ error: 'INVALID_USER' });
  const target = await db.query('SELECT 1 FROM users WHERE id=$1 AND deleted_at IS NULL AND is_blocked=false', [targetId]);
  if (!target.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });

  const existing = await getRelationship(req.userId, targetId);
  if (!existing) {
    await db.query('INSERT INTO friendships (requester_id, addressee_id, status) VALUES ($1,$2,$3)', [req.userId, targetId, 'pending']);
    await notify(targetId, 'friend_request', { actorId: req.userId });
    return res.json({ status: 'pending_outgoing' });
  }
  if (existing.status === 'accepted') return res.status(400).json({ error: 'ALREADY_FRIENDS' });
  if (existing.status === 'blocked') return res.status(403).json({ error: 'BLOCKED' });
  if (existing.status === 'pending') {
    if (existing.requester_id === req.userId) return res.json({ status: 'pending_outgoing' });
    await db.query(`UPDATE friendships SET status='accepted', updated_at=now() WHERE id=$1`, [existing.id]);
    await notify(existing.requester_id, 'friend_accepted', { actorId: req.userId });
    return res.json({ status: 'accepted' });
  }
  // declined / removed — заявка заново, от текущего отправителя
  await db.query(
    `UPDATE friendships SET requester_id=$1, addressee_id=$2, status='pending', updated_at=now() WHERE id=$3`,
    [req.userId, targetId, existing.id]);
  await notify(targetId, 'friend_request', { actorId: req.userId });
  res.json({ status: 'pending_outgoing' });
});

// Список заявок: ?direction=incoming|outgoing
router.get('/requests', async (req, res) => {
  const incoming = req.query.direction !== 'outgoing';
  const { limit, offset } = pagination(req);
  const meField = incoming ? 'addressee_id' : 'requester_id';
  const otherField = incoming ? 'requester_id' : 'addressee_id';
  const r = await db.query(`
    SELECT ${PAGE_FIELDS}, f.created_at
    FROM friendships f JOIN users u ON u.id = f.${otherField}
    WHERE f.${meField}=$1 AND f.status='pending' AND u.deleted_at IS NULL
    ORDER BY f.created_at DESC LIMIT $2 OFFSET $3`,
    [req.userId, limit, offset]);
  res.json(r.rows);
});

router.post('/requests/:userId/accept', async (req, res) => {
  const r = await db.query(
    `UPDATE friendships SET status='accepted', updated_at=now()
     WHERE requester_id=$1 AND addressee_id=$2 AND status='pending' RETURNING id`,
    [req.params.userId, req.userId]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  await notify(req.params.userId, 'friend_accepted', { actorId: req.userId });
  res.json({ ok: true });
});

// Отклонить входящую — отправителю не сообщаем
router.post('/requests/:userId/decline', async (req, res) => {
  const r = await db.query(
    `UPDATE friendships SET status='declined', updated_at=now()
     WHERE requester_id=$1 AND addressee_id=$2 AND status='pending' RETURNING id`,
    [req.params.userId, req.userId]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  res.json({ ok: true });
});

// Отменить исходящую заявку
router.delete('/requests/:userId', async (req, res) => {
  const r = await db.query(
    `UPDATE friendships SET status='removed', updated_at=now()
     WHERE requester_id=$1 AND addressee_id=$2 AND status='pending' RETURNING id`,
    [req.userId, req.params.userId]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  res.json({ ok: true });
});

// Рекомендации: тот же город + общие друзья, исключая уже связанных
router.get('/recommendations', async (req, res) => {
  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
  const me = await db.query('SELECT city_id FROM users WHERE id=$1', [req.userId]);
  const cityId = me.rows[0] && me.rows[0].city_id;
  if (!cityId) return res.json([]);
  const r = await db.query(`
    WITH my_friends AS (
      SELECT CASE WHEN requester_id=$1 THEN addressee_id ELSE requester_id END AS friend_id
      FROM friendships WHERE (requester_id=$1 OR addressee_id=$1) AND status='accepted'
    )
    SELECT u.id, u.username, u.first_name, u.last_name, u.avatar_url, u.home_country,
      (SELECT count(*)::int FROM friendships mf
         JOIN my_friends mff ON mff.friend_id = (CASE WHEN mf.requester_id=u.id THEN mf.addressee_id ELSE mf.requester_id END)
         WHERE mf.status='accepted' AND (mf.requester_id=u.id OR mf.addressee_id=u.id)
      ) AS mutual_friends
    FROM users u
    WHERE u.id<>$1 AND u.city_id=$2 AND u.deleted_at IS NULL AND u.is_blocked=false
      AND NOT EXISTS (
        SELECT 1 FROM friendships f
        WHERE (f.requester_id=$1 AND f.addressee_id=u.id) OR (f.requester_id=u.id AND f.addressee_id=$1)
      )
    ORDER BY mutual_friends DESC, u.username
    LIMIT $3`,
    [req.userId, cityId, limit]);
  res.json(r.rows);
});

// Статус отношений с набором юзеров — для кнопок в поиске/профиле
router.get('/status', async (req, res) => {
  const ids = String(req.query.user_ids || '').split(',').map(s => s.trim()).filter(Boolean).slice(0, 50);
  if (!ids.length) return res.json({});
  const r = await db.query(
    `SELECT requester_id, addressee_id, status FROM friendships
     WHERE status <> 'removed' AND (requester_id=$1 OR addressee_id=$1)
       AND (requester_id = ANY($2) OR addressee_id = ANY($2))`,
    [req.userId, ids]);
  const map = {};
  for (const id of ids) map[id] = 'none';
  for (const row of r.rows) {
    const otherId = row.requester_id === req.userId ? row.addressee_id : row.requester_id;
    if (!(otherId in map)) continue;
    if (row.status === 'accepted') map[otherId] = 'accepted';
    else if (row.status === 'pending') map[otherId] = row.requester_id === req.userId ? 'pending_outgoing' : 'pending_incoming';
    else if (row.status === 'blocked') map[otherId] = row.requester_id === req.userId ? 'blocked_by_me' : 'blocked_by_them';
    else if (row.status === 'declined') map[otherId] = 'declined';
  }
  res.json(map);
});

// Заблокированные мной пользователи
router.get('/blocked', async (req, res) => {
  const { limit, offset } = pagination(req);
  const r = await db.query(`
    SELECT ${PAGE_FIELDS}, f.updated_at
    FROM friendships f JOIN users u ON u.id = f.addressee_id
    WHERE f.requester_id=$1 AND f.status='blocked'
    ORDER BY f.updated_at DESC LIMIT $2 OFFSET $3`,
    [req.userId, limit, offset]);
  res.json(r.rows);
});

// Мои друзья
router.get('/', async (req, res) => {
  const { limit, offset } = pagination(req);
  const r = await db.query(`
    SELECT u.id, u.username, u.first_name, u.last_name, u.avatar_url, u.home_country, u.city_id, u.last_seen_at,
           (u.last_seen_at > now() - interval '5 minutes') AS is_online
    FROM friendships f
    JOIN users u ON u.id = (CASE WHEN f.requester_id=$1 THEN f.addressee_id ELSE f.requester_id END)
    WHERE (f.requester_id=$1 OR f.addressee_id=$1) AND f.status='accepted' AND u.deleted_at IS NULL
    ORDER BY u.first_name LIMIT $2 OFFSET $3`,
    [req.userId, limit, offset]);
  res.json(r.rows);
});

router.post('/:userId/block', async (req, res) => {
  const targetId = req.params.userId;
  if (targetId === req.userId) return res.status(400).json({ error: 'INVALID_USER' });
  const existing = await getRelationship(req.userId, targetId);
  if (existing) {
    await db.query(
      `UPDATE friendships SET requester_id=$1, addressee_id=$2, status='blocked', updated_at=now() WHERE id=$3`,
      [req.userId, targetId, existing.id]);
  } else {
    const target = await db.query('SELECT 1 FROM users WHERE id=$1 AND deleted_at IS NULL', [targetId]);
    if (!target.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
    await db.query('INSERT INTO friendships (requester_id, addressee_id, status) VALUES ($1,$2,$3)', [req.userId, targetId, 'blocked']);
  }
  res.json({ ok: true });
});

router.delete('/:userId/block', async (req, res) => {
  const r = await db.query(
    `UPDATE friendships SET status='removed', updated_at=now()
     WHERE requester_id=$1 AND addressee_id=$2 AND status='blocked' RETURNING id`,
    [req.userId, req.params.userId]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  res.json({ ok: true });
});

// Удалить из друзей — без уведомления второй стороне
router.delete('/:userId', async (req, res) => {
  const r = await db.query(
    `UPDATE friendships SET status='removed', updated_at=now()
     WHERE ((requester_id=$1 AND addressee_id=$2) OR (requester_id=$2 AND addressee_id=$1)) AND status='accepted'
     RETURNING id`,
    [req.userId, req.params.userId]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  res.json({ ok: true });
});

module.exports = router;
