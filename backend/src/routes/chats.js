// Чат: только текст, только между друзьями; REST для истории/отправки, WS для пушей
const express = require('express');
const db = require('../db');
const { required } = require('../middleware/auth');
const { getRelationship } = require('../utils/friendships');
const ws = require('../ws');

const router = express.Router();
router.use(required);

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

async function assertParticipant(conversationId, userId) {
  const r = await db.query('SELECT * FROM conversations WHERE id=$1 AND (user_a=$2 OR user_b=$2)', [conversationId, userId]);
  return r.rows[0] || null;
}
const otherUserId = (conv, userId) => (conv.user_a === userId ? conv.user_b : conv.user_a);

// Список диалогов, сортировка по последнему сообщению
router.get('/', async (req, res) => {
  const r = await db.query(`
    SELECT c.id, c.last_message_at,
           u.id AS other_id, u.username, u.first_name, u.last_name, u.avatar_url, u.last_seen_at,
           (SELECT text FROM messages m WHERE m.conversation_id=c.id ORDER BY m.created_at DESC LIMIT 1) AS last_message_text,
           (SELECT count(*)::int FROM messages m WHERE m.conversation_id=c.id AND m.sender_id<>$1 AND m.read_at IS NULL) AS unread_count
    FROM conversations c
    JOIN users u ON u.id = (CASE WHEN c.user_a=$1 THEN c.user_b ELSE c.user_a END)
    WHERE (c.user_a=$1 OR c.user_b=$1)
    ORDER BY c.last_message_at DESC NULLS LAST`,
    [req.userId]);
  res.json(r.rows);
});

// Найти/создать диалог — только с другом
router.post('/', async (req, res) => {
  const targetId = String(req.body.user_id || '');
  if (!targetId || targetId === req.userId) return res.status(400).json({ error: 'INVALID_USER' });
  const rel = await getRelationship(req.userId, targetId);
  if (!rel || rel.status !== 'accepted') return res.status(403).json({ error: 'NOT_FRIENDS' });

  const [a, b] = req.userId < targetId ? [req.userId, targetId] : [targetId, req.userId];
  await db.query('INSERT INTO conversations (user_a, user_b) VALUES ($1,$2) ON CONFLICT (user_a,user_b) DO NOTHING', [a, b]);
  const r = await db.query('SELECT * FROM conversations WHERE user_a=$1 AND user_b=$2', [a, b]);
  res.json(r.rows[0]);
});

// История, пагинация вверх через ?before=<created_at>
router.get('/:id/messages', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const conv = await assertParticipant(req.params.id, req.userId);
  if (!conv) return res.status(404).json({ error: 'NOT_FOUND' });

  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 30));
  const params = [req.params.id];
  let where = 'conversation_id=$1';
  if (req.query.before) { params.push(req.query.before); where += ` AND created_at < $${params.length}::timestamptz`; }
  params.push(limit);
  const r = await db.query(
    `SELECT id, sender_id, text, created_at, read_at FROM messages WHERE ${where} ORDER BY created_at DESC LIMIT $${params.length}`,
    params);
  res.json(r.rows);
});

// Отправка — только между друзьями; блокировка закрывает чат
router.post('/:id/messages', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const conv = await assertParticipant(req.params.id, req.userId);
  if (!conv) return res.status(404).json({ error: 'NOT_FOUND' });
  const recipientId = otherUserId(conv, req.userId);

  const rel = await getRelationship(req.userId, recipientId);
  if (!rel || rel.status !== 'accepted') return res.status(403).json({ error: 'CANNOT_MESSAGE' });

  const text = String(req.body.text || '').trim();
  if (!text || text.length > 2000) return res.status(400).json({ error: 'INVALID_TEXT' });

  const r = await db.query(
    'INSERT INTO messages (conversation_id, sender_id, text) VALUES ($1,$2,$3) RETURNING *',
    [req.params.id, req.userId, text]);
  await db.query('UPDATE conversations SET last_message_at=now() WHERE id=$1', [req.params.id]);

  ws.send(recipientId, 'message.new', r.rows[0]);
  res.json(r.rows[0]);
});

// Прочитано — отмечает чужие сообщения и уведомляет отправителя по WS
router.post('/:id/read', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const conv = await assertParticipant(req.params.id, req.userId);
  if (!conv) return res.status(404).json({ error: 'NOT_FOUND' });

  const r = await db.query(
    `UPDATE messages SET read_at=now() WHERE conversation_id=$1 AND sender_id<>$2 AND read_at IS NULL RETURNING id, sender_id`,
    [req.params.id, req.userId]);
  if (r.rowCount) {
    ws.send(r.rows[0].sender_id, 'message.read', { conversation_id: req.params.id, message_ids: r.rows.map(x => x.id) });
  }
  res.json({ ok: true });
});

module.exports = router;
