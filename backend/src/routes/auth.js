const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');
const codes = require('../utils/codes');
const mailer = require('../utils/mailer');

const router = express.Router();

const USERNAME_RE = /^[a-z_]{3,30}$/;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
// Пароль — только печатаемый ASCII (латиница/цифры/символы), без кириллицы.
// Применяется только при СОЗДАНИИ пароля, на вход не влияет
const PASSWORD_RE = /^[\x21-\x7E]{8,}$/;

function tokens(userId) {
  const access = jwt.sign({ sub: userId, type: 'access' }, process.env.JWT_SECRET, { expiresIn: '24h' });
  const refresh = jwt.sign({ sub: userId, type: 'refresh' }, process.env.JWT_SECRET, { expiresIn: '30d' });
  return { access_token: access, refresh_token: refresh };
}

// Простейший rate-limit по IP на регистрацию: 5/час (в памяти)
const regHits = new Map();
function regLimit(req, res, next) {
  const ip = req.ip;
  const now = Date.now();
  const arr = (regHits.get(ip) || []).filter(t => now - t < 3600_000);
  if (arr.length >= 5) return res.status(429).json({ error: 'TOO_MANY_ATTEMPTS' });
  arr.push(now); regHits.set(ip, arr); next();
}

// Регистрация → письмо с кодом
router.post('/register', regLimit, async (req, res) => {
  const email = String(req.body.email || '').trim().toLowerCase();
  const password = String(req.body.password || '');
  const username = String(req.body.username || '').trim().toLowerCase();
  const errors = {};
  if (!EMAIL_RE.test(email)) errors.email = 'INVALID_EMAIL';
  if (password.length < 8) errors.password = 'PASSWORD_TOO_SHORT';
  else if (!PASSWORD_RE.test(password)) errors.password = 'PASSWORD_INVALID_CHARS';
  if (!USERNAME_RE.test(username)) errors.username = 'INVALID_USERNAME';
  if (Object.keys(errors).length) return res.status(400).json({ errors });

  const emailBusy = await db.query('SELECT id, email_verified FROM users WHERE email=$1', [email]);
  if (emailBusy.rowCount && emailBusy.rows[0].email_verified)
    return res.status(400).json({ errors: { email: 'EMAIL_TAKEN' } });
  const nickBusy = await db.query('SELECT 1 FROM users WHERE username=$1 AND email<>$2', [username, email]);
  if (nickBusy.rowCount) return res.status(400).json({ errors: { username: 'USERNAME_TAKEN' } });

  const hash = await bcrypt.hash(password, 10);
  if (emailBusy.rowCount) {
    // неподтверждённый аккаунт: обновляем данные и переотправляем код
    await db.query('UPDATE users SET password_hash=$1, username=$2 WHERE email=$3', [hash, username, email]);
  } else {
    await db.query('INSERT INTO users (email, password_hash, username) VALUES ($1,$2,$3)', [email, hash, username]);
  }
  const code = await codes.issue(email, 'verify');
  await mailer.sendCode(email, code, 'verify');
  res.json({ ok: true, next: 'verify' });
});

// Проверка кода почты → токены
router.post('/verify', async (req, res) => {
  const email = String(req.body.email || '').trim().toLowerCase();
  const code = String(req.body.code || '');
  const st = await codes.check(email, 'verify', code);
  if (st !== 'ok') return res.status(400).json({ error: st.toUpperCase() }); // WRONG | EXPIRED | LOCKED
  const r = await db.query('UPDATE users SET email_verified=true WHERE email=$1 RETURNING id', [email]);
  if (!r.rowCount) return res.status(400).json({ error: 'NOT_FOUND' });
  res.json({ ...tokens(r.rows[0].id), user_id: r.rows[0].id });
});

// Повторная отправка кода
router.post('/resend', async (req, res) => {
  const email = String(req.body.email || '').trim().toLowerCase();
  const r = await db.query('SELECT email_verified FROM users WHERE email=$1', [email]);
  if (r.rowCount && !r.rows[0].email_verified) {
    const code = await codes.issue(email, 'verify');
    await mailer.sendCode(email, code, 'verify');
  }
  res.json({ ok: true }); // не раскрываем существование аккаунта
});

// Вход
const loginFails = new Map(); // email -> {count, until}
router.post('/login', async (req, res) => {
  const email = String(req.body.email || '').trim().toLowerCase();
  const password = String(req.body.password || '');
  const lock = loginFails.get(email);
  if (lock && lock.until > Date.now()) return res.status(429).json({ error: 'TRY_LATER', retry_in_sec: Math.ceil((lock.until - Date.now()) / 1000) });

  const r = await db.query('SELECT * FROM users WHERE email=$1 AND deleted_at IS NULL', [email]);
  const user = r.rows[0];
  const ok = user && await bcrypt.compare(password, user.password_hash);
  if (!ok) {
    const f = loginFails.get(email) || { count: 0, until: 0 };
    f.count += 1;
    if (f.count >= 5) { f.until = Date.now() + 60_000; f.count = 0; }
    loginFails.set(email, f);
    return res.status(401).json({ error: 'INVALID_CREDENTIALS' });
  }
  loginFails.delete(email);
  if (!user.email_verified) {
    const code = await codes.issue(email, 'verify');
    await mailer.sendCode(email, code, 'verify');
    return res.status(403).json({ error: 'EMAIL_NOT_VERIFIED', next: 'verify' });
  }
  if (user.is_blocked) return res.status(403).json({ error: 'BLOCKED', reason: user.blocked_reason });
  res.json({ ...tokens(user.id), user_id: user.id });
});

// Обновление access-токена
router.post('/refresh', async (req, res) => {
  try {
    const payload = jwt.verify(String(req.body.refresh_token || ''), process.env.JWT_SECRET);
    if (payload.type !== 'refresh') throw new Error();
    const r = await db.query('SELECT is_blocked, deleted_at FROM users WHERE id=$1', [payload.sub]);
    if (!r.rowCount || r.rows[0].deleted_at || r.rows[0].is_blocked) throw new Error();
    res.json(tokens(payload.sub));
  } catch { res.status(401).json({ error: 'UNAUTHORIZED' }); }
});

// Забыли пароль → код на почту
router.post('/forgot', async (req, res) => {
  const email = String(req.body.email || '').trim().toLowerCase();
  const r = await db.query('SELECT 1 FROM users WHERE email=$1 AND deleted_at IS NULL', [email]);
  if (r.rowCount) {
    const code = await codes.issue(email, 'reset');
    await mailer.sendCode(email, code, 'reset');
  }
  res.json({ ok: true }); // всегда ok — не раскрываем существование
});

// Проверка кода сброса → reset_token на 15 минут
router.post('/verify-reset', async (req, res) => {
  const email = String(req.body.email || '').trim().toLowerCase();
  const code = String(req.body.code || '');
  const st = await codes.check(email, 'reset', code);
  if (st !== 'ok') return res.status(400).json({ error: st.toUpperCase() });
  const reset_token = jwt.sign({ email, type: 'reset' }, process.env.JWT_SECRET, { expiresIn: '15m' });
  res.json({ reset_token });
});

// Новый пароль
router.post('/reset', async (req, res) => {
  try {
    const payload = jwt.verify(String(req.body.reset_token || ''), process.env.JWT_SECRET);
    if (payload.type !== 'reset') throw new Error();
    const password = String(req.body.new_password || '');
    if (password.length < 8) return res.status(400).json({ error: 'PASSWORD_TOO_SHORT' });
    if (!PASSWORD_RE.test(password)) return res.status(400).json({ error: 'PASSWORD_INVALID_CHARS' });
    const hash = await bcrypt.hash(password, 10);
    const r = await db.query('UPDATE users SET password_hash=$1, email_verified=true WHERE email=$2 RETURNING id', [hash, payload.email]);
    if (!r.rowCount) return res.status(400).json({ error: 'NOT_FOUND' });
    res.json({ ...tokens(r.rows[0].id), user_id: r.rows[0].id });
  } catch { res.status(401).json({ error: 'RESET_TOKEN_INVALID' }); }
});

module.exports = router;
