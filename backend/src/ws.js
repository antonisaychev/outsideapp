// WebSocket: пуш message.new / message.read / user.online / user.offline
const { WebSocketServer } = require('ws');
const jwt = require('jsonwebtoken');
const db = require('./db');

const clients = new Map(); // userId -> Set<ws>

function send(userId, event, data) {
  const sockets = clients.get(userId);
  if (!sockets) return;
  const payload = JSON.stringify({ event, data });
  for (const ws of sockets) if (ws.readyState === 1) ws.send(payload);
}

async function notifyFriends(userId, event) {
  const r = await db.query(
    `SELECT CASE WHEN requester_id=$1 THEN addressee_id ELSE requester_id END AS friend_id
     FROM friendships WHERE status='accepted' AND (requester_id=$1 OR addressee_id=$1)`, [userId]);
  for (const row of r.rows) send(row.friend_id, event, { user_id: userId });
}

function attach(server) {
  const wss = new WebSocketServer({ server, path: '/ws' });
  wss.on('connection', async (ws, req) => {
    const url = new URL(req.url, 'http://localhost');
    const token = url.searchParams.get('token') || '';
    let userId = null;
    try {
      const payload = jwt.verify(token, process.env.JWT_SECRET);
      if (payload.type === 'access') userId = payload.sub;
    } catch {}
    if (!userId) { ws.close(1008, 'UNAUTHORIZED'); return; }

    ws.userId = userId;
    if (!clients.has(userId)) clients.set(userId, new Set());
    clients.get(userId).add(ws);

    db.query('UPDATE users SET last_seen_at=now() WHERE id=$1', [userId]).catch(() => {});
    notifyFriends(userId, 'user.online');

    ws.on('close', () => {
      clients.get(userId)?.delete(ws);
      if (clients.get(userId)?.size === 0) clients.delete(userId);
      db.query('UPDATE users SET last_seen_at=now() WHERE id=$1', [userId]).catch(() => {});
      notifyFriends(userId, 'user.offline');
    });
  });
}

module.exports = { attach, send };
