const db = require('../db');
function gen() { return String(Math.floor(100000 + Math.random() * 900000)); }
async function issue(email, purpose) {
  await db.query('DELETE FROM email_codes WHERE email=$1 AND purpose=$2', [email, purpose]);
  const code = gen();
  await db.query(
    `INSERT INTO email_codes (email, code, purpose, expires_at) VALUES ($1,$2,$3, now() + interval '10 minutes')`,
    [email, code, purpose]);
  return code;
}
// Проверка: возвращает 'ok' | 'wrong' | 'expired' | 'locked'
async function check(email, purpose, code) {
  const r = await db.query('SELECT * FROM email_codes WHERE email=$1 AND purpose=$2', [email, purpose]);
  if (!r.rowCount) return 'expired';
  const row = r.rows[0];
  if (new Date(row.expires_at) < new Date()) { await db.query('DELETE FROM email_codes WHERE id=$1', [row.id]); return 'expired'; }
  if (row.attempts >= 5) { await db.query('DELETE FROM email_codes WHERE id=$1', [row.id]); return 'locked'; }
  if (row.code !== code) {
    await db.query('UPDATE email_codes SET attempts = attempts + 1 WHERE id=$1', [row.id]);
    return 'wrong';
  }
  await db.query('DELETE FROM email_codes WHERE id=$1', [row.id]);
  return 'ok';
}
module.exports = { issue, check };
