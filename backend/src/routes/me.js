// Профиль текущего пользователя (/me): просмотр, правки, онбординг, аватар, пароль, удаление
const express = require('express');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');
const crypto = require('crypto');
const db = require('../db');
const { required } = require('../middleware/auth');

const router = express.Router();
router.use(required);

const GENDERS = ['male', 'female'];
const LANGS = ['ru', 'en'];
const COUNTRY_RE = /^[A-Za-z]{2}$/;
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

async function loadMe(userId) {
  const r = await db.query(`
    SELECT u.id, u.email, u.email_verified, u.username, u.first_name, u.last_name, u.avatar_url,
           u.bio, u.city_id, u.home_country, u.gender, u.birth_date, u.lang, u.account_type,
           u.role, u.created_at, u.last_seen_at,
           (SELECT count(*)::int FROM friendships f WHERE f.status='accepted' AND (f.requester_id=u.id OR f.addressee_id=u.id)) AS friends_count,
           (SELECT count(*)::int FROM services s WHERE s.author_id=u.id AND s.status<>'hidden') AS services_count,
           COALESCE((SELECT json_agg(json_build_object('id', p.id, 'url', p.url) ORDER BY p.position, p.created_at)
                     FROM user_photos p WHERE p.user_id=u.id), '[]'::json) AS photos
    FROM users u WHERE u.id=$1`, [userId]);
  return r.rows[0];
}

router.get('/', async (req, res) => {
  res.json(await loadMe(req.userId));
});

// Онбординг и редактирование профиля — любое подмножество полей
router.patch('/', async (req, res) => {
  const body = req.body || {};
  const errors = {};
  const sets = [];
  const params = [];
  let i = 1;

  if ('first_name' in body) {
    const v = String(body.first_name || '').trim();
    if (!v) errors.first_name = 'REQUIRED';
    else { sets.push(`first_name=$${i++}`); params.push(v.slice(0, 50)); }
  }
  if ('last_name' in body) {
    const v = String(body.last_name || '').trim();
    if (!v) errors.last_name = 'REQUIRED';
    else { sets.push(`last_name=$${i++}`); params.push(v.slice(0, 50)); }
  }
  if ('gender' in body) {
    if (!GENDERS.includes(body.gender)) errors.gender = 'INVALID_GENDER';
    else { sets.push(`gender=$${i++}`); params.push(body.gender); }
  }
  if ('bio' in body) {
    const v = String(body.bio || '');
    if (v.length > 300) errors.bio = 'TOO_LONG';
    else { sets.push(`bio=$${i++}`); params.push(v); }
  }
  if ('lang' in body) {
    if (!LANGS.includes(body.lang)) errors.lang = 'INVALID_LANG';
    else { sets.push(`lang=$${i++}`); params.push(body.lang); }
  }
  if ('home_country' in body) {
    const v = String(body.home_country || '').toUpperCase();
    if (!COUNTRY_RE.test(v)) errors.home_country = 'INVALID_COUNTRY';
    else { sets.push(`home_country=$${i++}`); params.push(v); }
  }
  if ('birth_date' in body) {
    const v = String(body.birth_date || '');
    const d = new Date(v);
    if (!DATE_RE.test(v) || Number.isNaN(d.getTime()) || d > new Date()) errors.birth_date = 'INVALID_DATE';
    else { sets.push(`birth_date=$${i++}`); params.push(v); }
  }
  if ('city_id' in body) {
    const id = Number(body.city_id);
    const c = await db.query('SELECT 1 FROM cities WHERE id=$1 AND is_active', [id]);
    if (!c.rowCount) errors.city_id = 'INVALID_CITY';
    else { sets.push(`city_id=$${i++}`); params.push(id); }
  }

  if (Object.keys(errors).length) return res.status(400).json({ errors });
  if (sets.length) {
    params.push(req.userId);
    await db.query(`UPDATE users SET ${sets.join(', ')}, profile_updated_at=now() WHERE id=$${i}`, params);
  }
  res.json(await loadMe(req.userId));
});

const upload = multer({
  storage: multer.diskStorage({
    destination: path.join(__dirname, '..', '..', 'uploads'),
    filename: (req, file, cb) => cb(null, `${crypto.randomUUID()}${path.extname(file.originalname).toLowerCase()}`),
  }),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => cb(null, ['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype)),
});

const MAX_PHOTOS = 10;

// Главное фото — первое в галерее; users.avatar_url держим синхронно,
// чтобы старые экраны и запросы продолжали работать
async function syncAvatar(userId) {
  await db.query(`
    UPDATE users SET avatar_url = (
      SELECT p.url FROM user_photos p WHERE p.user_id=$1 ORDER BY p.position, p.created_at LIMIT 1
    ), profile_updated_at = now() WHERE id=$1`, [userId]);
}

async function listPhotos(userId) {
  const r = await db.query(
    'SELECT id, url FROM user_photos WHERE user_id=$1 ORDER BY position, created_at', [userId]);
  return r.rows;
}

// Совместимость: старая загрузка аватара = добавление первого фото
router.post('/avatar', (req, res) => {
  upload.single('avatar')(req, res, async (err) => {
    if (err || !req.file) return res.status(400).json({ error: 'INVALID_FILE' });
    const url = `/uploads/${req.file.filename}`;
    await db.query('DELETE FROM user_photos WHERE user_id=$1 AND position=0', [req.userId]);
    await db.query('INSERT INTO user_photos (user_id, url, position) VALUES ($1,$2,0)', [req.userId, url]);
    await syncAvatar(req.userId);
    res.json({ avatar_url: url, photos: await listPhotos(req.userId) });
  });
});

router.get('/photos', async (req, res) => {
  res.json(await listPhotos(req.userId));
});

// Добавить фото в галерею (максимум 10)
router.post('/photos', (req, res) => {
  upload.single('photo')(req, res, async (err) => {
    if (err || !req.file) return res.status(400).json({ error: 'INVALID_FILE' });
    const count = await db.query('SELECT count(*)::int AS c FROM user_photos WHERE user_id=$1', [req.userId]);
    if (count.rows[0].c >= MAX_PHOTOS) return res.status(400).json({ error: 'TOO_MANY_PHOTOS' });
    const url = `/uploads/${req.file.filename}`;
    await db.query(
      `INSERT INTO user_photos (user_id, url, position)
       VALUES ($1, $2, COALESCE((SELECT max(position)+1 FROM user_photos WHERE user_id=$1), 0))`,
      [req.userId, url]);
    await syncAvatar(req.userId);
    res.json({ photos: await listPhotos(req.userId) });
  });
});

router.delete('/photos/:id', async (req, res) => {
  const r = await db.query('DELETE FROM user_photos WHERE id=$1 AND user_id=$2 RETURNING id', [req.params.id, req.userId]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  await syncAvatar(req.userId);
  res.json({ photos: await listPhotos(req.userId) });
});

// Сделать фото главным — уезжает на позицию 0, остальные сдвигаются
router.post('/photos/:id/main', async (req, res) => {
  const own = await db.query('SELECT id FROM user_photos WHERE id=$1 AND user_id=$2', [req.params.id, req.userId]);
  if (!own.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  await db.query('UPDATE user_photos SET position = position + 1 WHERE user_id=$1', [req.userId]);
  await db.query('UPDATE user_photos SET position = 0 WHERE id=$1', [req.params.id]);
  await syncAvatar(req.userId);
  res.json({ photos: await listPhotos(req.userId) });
});

router.patch('/password', async (req, res) => {
  const current = String(req.body.current_password || '');
  const next = String(req.body.new_password || '');
  if (next.length < 8) return res.status(400).json({ errors: { new_password: 'PASSWORD_TOO_SHORT' } });
  // Только печатаемый ASCII — без кириллицы (см. PASSWORD_RE в auth.js)
  if (!/^[\x21-\x7E]{8,}$/.test(next)) return res.status(400).json({ errors: { new_password: 'PASSWORD_INVALID_CHARS' } });
  const r = await db.query('SELECT password_hash FROM users WHERE id=$1', [req.userId]);
  const ok = await bcrypt.compare(current, r.rows[0].password_hash);
  if (!ok) return res.status(400).json({ errors: { current_password: 'WRONG_PASSWORD' } });
  const hash = await bcrypt.hash(next, 10);
  await db.query('UPDATE users SET password_hash=$1 WHERE id=$2', [hash, req.userId]);
  res.json({ ok: true });
});

router.get('/favorites', async (req, res) => {
  const page = Math.max(1, Number(req.query.page) || 1);
  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
  const r = await db.query(`
    SELECT s.id, s.title, s.photo_url, s.category_id, s.city_id, s.status, s.likes_count, sf.created_at AS favorited_at
    FROM service_favorites sf JOIN services s ON s.id = sf.service_id
    WHERE sf.user_id=$1 AND s.status<>'hidden'
    ORDER BY sf.created_at DESC LIMIT $2 OFFSET $3`,
    [req.userId, limit, (page - 1) * limit]);
  res.json(r.rows);
});

// Удаление аккаунта: soft-delete + скрытие своих сервисов.
// Email и никнейм переименовываются в «надгробия» — освобождаются для
// повторной регистрации (у никнейма constraint ^[a-z_]{3,30}$, поэтому
// цифры uuid транслитерируются в буквы)
router.delete('/', async (req, res) => {
  const password = String(req.body.password || '');
  const r = await db.query('SELECT password_hash FROM users WHERE id=$1', [req.userId]);
  const ok = await bcrypt.compare(password, r.rows[0].password_hash);
  if (!ok) return res.status(400).json({ error: 'WRONG_PASSWORD' });
  const tombstoneNick = ('deleted_' + req.userId.replace(/-/g, '')
    .replace(/[0-9]/g, d => 'ghijklmnop'[Number(d)])).slice(0, 30);
  await db.query(
    `UPDATE users SET deleted_at=now(), email='deleted+' || id || '@deleted.local', username=$2 WHERE id=$1`,
    [req.userId, tombstoneNick]);
  await db.query(`UPDATE services SET status='hidden' WHERE author_id=$1 AND status<>'hidden'`, [req.userId]);
  res.json({ ok: true });
});

module.exports = router;
