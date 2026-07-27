const jwt = require('jsonwebtoken');
const db = require('../db');
// Обязательная авторизация
async function required(req, res, next) {
  const h = req.headers.authorization || '';
  const token = h.startsWith('Bearer ') ? h.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'UNAUTHORIZED' });
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    if (payload.type !== 'access') throw new Error('bad type');
    const r = await db.query('SELECT id, role, is_blocked, blocked_reason, deleted_at FROM users WHERE id=$1', [payload.sub]);
    if (!r.rowCount || r.rows[0].deleted_at) return res.status(401).json({ error: 'UNAUTHORIZED' });
    if (r.rows[0].is_blocked) return res.status(403).json({ error: 'BLOCKED', reason: r.rows[0].blocked_reason });
    req.userId = r.rows[0].id;
    req.userRole = r.rows[0].role;
    db.query('UPDATE users SET last_seen_at=now() WHERE id=$1', [req.userId]).catch(()=>{});
    next();
  } catch (e) { return res.status(401).json({ error: 'UNAUTHORIZED' }); }
}
// Только админ
function adminOnly(req, res, next) {
  if (req.userRole !== 'admin') return res.status(403).json({ error: 'FORBIDDEN' });
  next();
}
// Необязательная авторизация: валидный токен подставляет userId, иначе просто гость
async function optional(req, res, next) {
  const h = req.headers.authorization || '';
  const token = h.startsWith('Bearer ') ? h.slice(7) : null;
  if (!token) return next();
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    if (payload.type !== 'access') return next();
    const r = await db.query('SELECT id, role FROM users WHERE id=$1 AND deleted_at IS NULL AND is_blocked=false', [payload.sub]);
    if (r.rowCount) { req.userId = r.rows[0].id; req.userRole = r.rows[0].role; }
  } catch {}
  next();
}
module.exports = { required, adminOnly, optional };
