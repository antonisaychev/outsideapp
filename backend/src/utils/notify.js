// Создание уведомления + пуш по WebSocket, если получатель онлайн
const db = require('../db');
const ws = require('../ws');

async function notify(userId, type, { actorId = null, entityId = null } = {}) {
  const r = await db.query(
    'INSERT INTO notifications (user_id, type, actor_id, entity_id) VALUES ($1,$2,$3,$4) RETURNING id, created_at',
    [userId, type, actorId, entityId]);
  ws.send(userId, 'notification.new', { id: r.rows[0].id, type, actor_id: actorId, entity_id: entityId, created_at: r.rows[0].created_at });
}

module.exports = { notify };
