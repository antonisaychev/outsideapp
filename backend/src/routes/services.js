// Сервисы: список/карточка, лайки с порогом подтверждения, избранное, жалобы, проверка дублей
const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const db = require('../db');
const { required, optional } = require('../middleware/auth');
const { notify } = require('../utils/notify');

const router = express.Router();

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const REPORT_REASONS = ['spam', 'fraud', 'abuse', 'other'];
const threshold = () => Number(process.env.CONFIRM_THRESHOLD || 30);

const photosUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024, files: 5 },
  fileFilter: (req, file, cb) => cb(['image/jpeg', 'image/png'].includes(file.mimetype) ? null : new Error('PHOTO_BAD_FORMAT'), true),
});

function savePhoto(serviceId, file) {
  const dir = path.join(__dirname, '..', '..', 'uploads', 'services', serviceId);
  fs.mkdirSync(dir, { recursive: true });
  const ext = file.mimetype === 'image/png' ? '.png' : '.jpg';
  const filename = `${crypto.randomUUID()}${ext}`;
  fs.writeFileSync(path.join(dir, filename), file.buffer);
  return `/uploads/services/${serviceId}/${filename}`;
}

function pagination(req) {
  const page = Math.max(1, Number(req.query.page) || 1);
  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
  return { limit, offset: (page - 1) * limit };
}

// Плитка карточек по месту: ?tab=recommended|pending&city_id=&category_id=&page=&limit=
router.get('/', optional, async (req, res) => {
  const tab = req.query.tab === 'pending' ? 'pending' : 'recommended';
  let cityId = req.query.city_id ? Number(req.query.city_id) : null;
  if (!cityId && req.userId) {
    const me = await db.query('SELECT city_id FROM users WHERE id=$1', [req.userId]);
    cityId = me.rows[0] && me.rows[0].city_id;
  }
  if (!cityId) return res.status(400).json({ error: 'MISSING_CITY' });
  const categoryId = req.query.category_id ? Number(req.query.category_id) : null;
  const { limit, offset } = pagination(req);

  const where = ['city_id=$1', 'status=$2'];
  const params = [cityId, tab];
  let i = 3;
  if (categoryId) { where.push(`category_id=$${i++}`); params.push(categoryId); }
  const order = tab === 'pending' ? 's.created_at DESC' : 's.likes_count DESC, s.created_at DESC';
  params.push(limit, offset);

  const r = await db.query(
    `SELECT s.id, s.title, s.photo_url, s.category_id, s.city_id, s.status, s.likes_count, s.confirm_count, s.created_at,
            (SELECT count(*)::int FROM service_photos sp WHERE sp.service_id=s.id) AS photos_count
     FROM services s WHERE ${where.join(' AND ')} ORDER BY ${order} LIMIT $${i++} OFFSET $${i}`,
    params);
  res.json(r.rows.map(s => tab === 'pending' ? { ...s, confirm_threshold: threshold() } : s));
});

router.get('/:id', optional, async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const r = await db.query(`
    SELECT s.*, u.username AS author_username, u.first_name AS author_first_name, u.last_name AS author_last_name
    FROM services s JOIN users u ON u.id = s.author_id
    WHERE s.id=$1`, [req.params.id]);
  if (!r.rowCount || r.rows[0].status === 'hidden') return res.status(404).json({ error: 'NOT_FOUND' });
  const s = r.rows[0];

  let liked_by_me = false, is_favorite = false, can_confirm = false;
  if (req.userId) {
    const l = await db.query('SELECT 1 FROM service_likes WHERE service_id=$1 AND user_id=$2', [s.id, req.userId]);
    liked_by_me = !!l.rowCount;
    const f = await db.query('SELECT 1 FROM service_favorites WHERE service_id=$1 AND user_id=$2', [s.id, req.userId]);
    is_favorite = !!f.rowCount;
    if (s.status === 'pending' && s.author_id !== req.userId) {
      const me = await db.query('SELECT city_id FROM users WHERE id=$1', [req.userId]);
      can_confirm = !!me.rows[0] && me.rows[0].city_id === s.city_id;
    }
  }

  const photos = await db.query('SELECT id, url, sort FROM service_photos WHERE service_id=$1 ORDER BY sort', [s.id]);

  res.json({
    id: s.id, title: s.title, description: s.description, photo_url: s.photo_url,
    website_url: s.website_url, map_url: s.map_url, city_id: s.city_id, category_id: s.category_id,
    status: s.status, likes_count: s.likes_count, confirm_count: s.confirm_count, confirm_threshold: threshold(),
    created_at: s.created_at, published_at: s.published_at,
    author: { id: s.author_id, username: s.author_username, first_name: s.author_first_name, last_name: s.author_last_name },
    is_author: req.userId === s.author_id,
    liked_by_me, is_favorite, can_confirm,
    photos: photos.rows,
  });
});

// Форма «+»: multipart/form-data, поле photos — от 1 до 5 файлов; первый файл = обложка
router.post('/', required, (req, res) => {
  photosUpload.array('photos', 5)(req, res, async (err) => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') return res.status(400).json({ errors: { photos: 'PHOTO_TOO_LARGE' } });
      if (err.code === 'LIMIT_UNEXPECTED_FILE' || err.code === 'LIMIT_FILE_COUNT') return res.status(400).json({ errors: { photos: 'TOO_MANY_PHOTOS' } });
      if (err.message === 'PHOTO_BAD_FORMAT') return res.status(400).json({ errors: { photos: 'PHOTO_BAD_FORMAT' } });
      return res.status(400).json({ errors: { photos: 'INVALID_PHOTO' } });
    }

    const files = req.files || [];
    const title = String(req.body.title || '').trim();
    const description = String(req.body.description || '').trim();
    const website_url = req.body.website_url ? String(req.body.website_url).trim() : null;
    const map_url = req.body.map_url ? String(req.body.map_url).trim() : null;
    const force = req.body.force === 'true' || req.body.force === true;
    const errors = {};

    if (files.length === 0) errors.photos = 'PHOTOS_REQUIRED';
    else if (files.length > 5) errors.photos = 'TOO_MANY_PHOTOS';
    if (!title || title.length > 100) errors.title = 'INVALID_TITLE';
    if (!description || description.length > 500) errors.description = 'INVALID_DESCRIPTION';

    const categoryId = Number(req.body.category_id);
    if (!Number.isInteger(categoryId)) errors.category_id = 'INVALID_CATEGORY';
    else {
      const cat = await db.query('SELECT 1 FROM service_categories WHERE id=$1 AND is_active', [categoryId]);
      if (!cat.rowCount) errors.category_id = 'INVALID_CATEGORY';
    }

    let cityId = req.body.city_id ? Number(req.body.city_id) : null;
    if (!cityId) {
      const me = await db.query('SELECT city_id FROM users WHERE id=$1', [req.userId]);
      cityId = me.rows[0] && me.rows[0].city_id;
    }
    if (!cityId) errors.city_id = 'MISSING_CITY';
    else {
      const c = await db.query('SELECT 1 FROM cities WHERE id=$1 AND is_active', [cityId]);
      if (!c.rowCount) errors.city_id = 'INVALID_CITY';
    }

    if (Object.keys(errors).length) return res.status(400).json({ errors });

    if (!force) {
      const dupes = await db.query(
        `SELECT id, title, photo_url FROM services WHERE city_id=$1 AND status<>'hidden' AND title ILIKE $2 LIMIT 5`,
        [cityId, `%${title}%`]);
      if (dupes.rowCount) return res.status(409).json({ error: 'POSSIBLE_DUPLICATE', candidates: dupes.rows });
    }

    const serviceId = crypto.randomUUID();
    const photoUrls = files.map((file) => savePhoto(serviceId, file));

    await db.query(
      `INSERT INTO services (id, author_id, city_id, category_id, title, description, photo_url, website_url, map_url)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
      [serviceId, req.userId, cityId, categoryId, title, description, photoUrls[0], website_url, map_url]);

    const photos = [];
    for (let idx = 0; idx < photoUrls.length; idx++) {
      const pr = await db.query(
        'INSERT INTO service_photos (service_id, url, sort) VALUES ($1,$2,$3) RETURNING id, url, sort',
        [serviceId, photoUrls[idx], idx]);
      photos.push(pr.rows[0]);
    }

    const r = await db.query('SELECT * FROM services WHERE id=$1', [serviceId]);
    res.json({ ...r.rows[0], photos });
  });
});

// «👍 Рекомендую» / «Подтвердить» — тоггл; для pending считают только жители того же места
router.post('/:id/like', required, async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const svc = await db.query('SELECT * FROM services WHERE id=$1', [req.params.id]);
  if (!svc.rowCount || svc.rows[0].status === 'hidden') return res.status(404).json({ error: 'NOT_FOUND' });
  const service = svc.rows[0];
  if (service.author_id === req.userId) return res.status(400).json({ error: 'CANNOT_LIKE_OWN' });

  const me = await db.query('SELECT city_id FROM users WHERE id=$1', [req.userId]);
  const myCity = me.rows[0].city_id;
  if (service.status === 'pending' && myCity !== service.city_id) return res.status(403).json({ error: 'NOT_LOCAL' });

  const existing = await db.query('SELECT 1 FROM service_likes WHERE service_id=$1 AND user_id=$2', [service.id, req.userId]);
  const wasLiked = !!existing.rowCount;
  if (wasLiked) await db.query('DELETE FROM service_likes WHERE service_id=$1 AND user_id=$2', [service.id, req.userId]);
  else await db.query('INSERT INTO service_likes (service_id, user_id, user_city_id) VALUES ($1,$2,$3)', [service.id, req.userId, myCity]);

  const counts = await db.query(
    `SELECT count(*)::int AS total, count(*) FILTER (WHERE user_city_id=$2)::int AS same_city
     FROM service_likes WHERE service_id=$1`, [service.id, service.city_id]);
  const { total, same_city } = counts.rows[0];

  let status = service.status;
  let published_at = service.published_at;
  const justPromoted = status === 'pending' && same_city >= threshold();
  if (justPromoted) { status = 'recommended'; published_at = new Date(); }

  await db.query(
    'UPDATE services SET likes_count=$1, confirm_count=$2, status=$3, published_at=COALESCE(published_at,$4) WHERE id=$5',
    [total, same_city, status, published_at, service.id]);
  if (justPromoted) await notify(service.author_id, 'service_recommended', { entityId: service.id });
  res.json({ liked: !wasLiked, likes_count: total, confirm_count: same_city, confirm_threshold: threshold(), status });
});

router.post('/:id/favorite', required, async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const svc = await db.query(`SELECT 1 FROM services WHERE id=$1 AND status<>'hidden'`, [req.params.id]);
  if (!svc.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  await db.query('INSERT INTO service_favorites (user_id, service_id) VALUES ($1,$2) ON CONFLICT DO NOTHING', [req.userId, req.params.id]);
  res.json({ ok: true });
});

router.delete('/:id/favorite', required, async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  await db.query('DELETE FROM service_favorites WHERE user_id=$1 AND service_id=$2', [req.userId, req.params.id]);
  res.json({ ok: true });
});

router.post('/:id/report', required, async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const reason = String(req.body.reason_type || '');
  const comment = String(req.body.comment || '').trim().slice(0, 300);
  const errors = {};
  if (!REPORT_REASONS.includes(reason)) errors.reason_type = 'INVALID_REASON';
  if (reason === 'other' && !comment) errors.comment = 'REQUIRED_FOR_OTHER';
  if (Object.keys(errors).length) return res.status(400).json({ errors });

  const svc = await db.query('SELECT 1 FROM services WHERE id=$1', [req.params.id]);
  if (!svc.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  await db.query(
    'INSERT INTO service_reports (service_id, user_id, reason_type, comment) VALUES ($1,$2,$3,$4)',
    [req.params.id, req.userId, reason, comment || null]);
  res.json({ ok: true });
});

module.exports = router;
