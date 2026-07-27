// Уведомления: колокольчик + бейдж. Открытие списка помечает всё прочитанным
const express = require('express');
const db = require('../db');
const { required } = require('../middleware/auth');

const router = express.Router();
router.use(required);

function pagination(req) {
  const page = Math.max(1, Number(req.query.page) || 1);
  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
  return { limit, offset: (page - 1) * limit };
}

router.get('/unread-count', async (req, res) => {
  const r = await db.query('SELECT count(*)::int AS c FROM notifications WHERE user_id=$1 AND is_read=false', [req.userId]);
  res.json({ count: r.rows[0].c });
});

// Список, новые сверху; открытие обнуляет бейдж (is_read=true задним числом)
router.get('/', async (req, res) => {
  const { limit, offset } = pagination(req);
  const r = await db.query(`
    SELECT n.id, n.type, n.entity_id, n.is_read, n.created_at,
           a.id AS actor_id, a.username AS actor_username, a.first_name AS actor_first_name, a.avatar_url AS actor_avatar_url
    FROM notifications n LEFT JOIN users a ON a.id = n.actor_id
    WHERE n.user_id=$1 ORDER BY n.created_at DESC LIMIT $2 OFFSET $3`,
    [req.userId, limit, offset]);
  await db.query('UPDATE notifications SET is_read=true WHERE user_id=$1 AND is_read=false', [req.userId]);
  res.json(r.rows);
});

module.exports = router;
