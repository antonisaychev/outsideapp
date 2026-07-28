// Создание уведомления + пуш по WebSocket, если получатель онлайн
const db = require('../db');
const ws = require('../ws');

async function notify(userId, type, { actorId = null, entityId = null } = {}) {
  // Повторное событие того же типа от того же человека не плодит строки —
  // «поднимаем» существующее непрочитанное (заявка → отмена → заявка)
  if (actorId) {
    const dup = await db.query(
      `UPDATE notifications SET created_at=now(), is_read=false
       WHERE user_id=$1 AND type=$2 AND actor_id=$3 AND is_read=false
       RETURNING id, created_at`,
      [userId, type, actorId]);
    if (dup.rowCount) {
      ws.send(userId, 'notification.new', {
        id: dup.rows[0].id, type, actor_id: actorId, entity_id: entityId,
        created_at: dup.rows[0].created_at,
      });
      return;
    }
  }
  const r = await db.query(
    'INSERT INTO notifications (user_id, type, actor_id, entity_id) VALUES ($1,$2,$3,$4) RETURNING id, created_at',
    [userId, type, actorId, entityId]);
  ws.send(userId, 'notification.new', { id: r.rows[0].id, type, actor_id: actorId, entity_id: entityId, created_at: r.rows[0].created_at });
}

module.exports = { notify };
