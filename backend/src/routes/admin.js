// Админка: пользователи (блок с причиной), сервисы (одобрить/скрыть/редактировать/фото), категории, жалобы
const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const db = require('../db');
const { required, adminOnly } = require('../middleware/auth');
const { notify } = require('../utils/notify');

const router = express.Router();
router.use(required, adminOnly);

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const photoUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
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

// Пересчитывает денормализованную обложку services.photo_url из service_photos (sort=0)
async function recomputeCover(serviceId) {
  const r = await db.query('SELECT url FROM service_photos WHERE service_id=$1 ORDER BY sort LIMIT 1', [serviceId]);
  if (r.rowCount) await db.query('UPDATE services SET photo_url=$1 WHERE id=$2', [r.rows[0].url, serviceId]);
}

function pagination(req) {
  const page = Math.max(1, Number(req.query.page) || 1);
  const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
  return { limit, offset: (page - 1) * limit };
}

// --- Пользователи ---

router.get('/users', async (req, res) => {
  const q = String(req.query.q || '').trim();
  const { limit, offset } = pagination(req);
  const where = [];
  const params = [];
  let i = 1;
  if (q) {
    where.push(`(email ILIKE $${i} OR first_name ILIKE $${i} OR last_name ILIKE $${i} OR username ILIKE $${i})`);
    params.push(`%${q}%`); i++;
  }
  params.push(limit, offset);
  const r = await db.query(
    `SELECT id, email, username, first_name, last_name, role, is_blocked, blocked_reason, city_id, created_at, last_seen_at
     FROM users ${where.length ? 'WHERE ' + where.join(' AND ') : ''}
     ORDER BY created_at DESC LIMIT $${i++} OFFSET $${i}`,
    params);
  res.json(r.rows);
});

router.post('/users/:id/block', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const reason = String(req.body.reason || '').trim();
  if (!reason) return res.status(400).json({ errors: { reason: 'REQUIRED' } });
  const r = await db.query(
    'UPDATE users SET is_blocked=true, blocked_reason=$1 WHERE id=$2 RETURNING id',
    [reason, req.params.id]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  await db.query(`UPDATE services SET status='hidden' WHERE author_id=$1 AND status<>'hidden'`, [req.params.id]);
  res.json({ ok: true });
});

router.post('/users/:id/unblock', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const r = await db.query(
    'UPDATE users SET is_blocked=false, blocked_reason=NULL WHERE id=$1 RETURNING id',
    [req.params.id]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  res.json({ ok: true });
});

// --- Сервисы ---

router.get('/services', async (req, res) => {
  const status = ['pending', 'recommended', 'hidden'].includes(req.query.status) ? req.query.status : null;
  const cityId = req.query.city_id ? Number(req.query.city_id) : null;
  const { limit, offset } = pagination(req);
  const where = [];
  const params = [];
  let i = 1;
  if (status) { where.push(`s.status=$${i++}`); params.push(status); }
  if (cityId) { where.push(`s.city_id=$${i++}`); params.push(cityId); }
  params.push(limit, offset);
  const r = await db.query(`
    SELECT s.id, s.title, s.photo_url, s.city_id, s.category_id, s.status, s.likes_count, s.confirm_count,
           s.author_id, u.username AS author_username, s.created_at, s.published_at
    FROM services s JOIN users u ON u.id = s.author_id
    ${where.length ? 'WHERE ' + where.join(' AND ') : ''}
    ORDER BY s.created_at DESC LIMIT $${i++} OFFSET $${i}`,
    params);
  res.json(r.rows);
});

router.post('/services/:id/approve', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const r = await db.query(
    `UPDATE services SET status='recommended', approved_by_admin=true, published_at=COALESCE(published_at, now())
     WHERE id=$1 AND status='pending' RETURNING id, author_id`,
    [req.params.id]);
  if (!r.rowCount) return res.status(400).json({ error: 'NOT_PENDING' });
  await notify(r.rows[0].author_id, 'service_recommended', { entityId: req.params.id });
  res.json({ ok: true });
});

router.post('/services/:id/hide', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const r = await db.query(
    `UPDATE services SET status='hidden' WHERE id=$1 AND status<>'hidden' RETURNING id, author_id`,
    [req.params.id]);
  if (!r.rowCount) return res.status(400).json({ error: 'ALREADY_HIDDEN' });
  await notify(r.rows[0].author_id, 'service_hidden', { entityId: req.params.id });
  res.json({ ok: true });
});

// Вернуть скрытый сервис в ленту: рекомендованным, если он уже заслужил это
router.post('/services/:id/unhide', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const threshold = Number(process.env.CONFIRM_THRESHOLD) || 30;
  const r = await db.query(
    `UPDATE services SET status = CASE
        WHEN approved_by_admin = true OR confirm_count >= $2 THEN 'recommended'
        ELSE 'pending' END
     WHERE id=$1 AND status='hidden' RETURNING id, status`,
    [req.params.id, threshold]);
  if (!r.rowCount) return res.status(400).json({ error: 'NOT_HIDDEN' });
  res.json({ ok: true, status: r.rows[0].status });
});

// Полное удаление мусорной карточки: строки, фото на диске — без следа.
// Единственное жёсткое удаление в проекте, остальные — мягкие.
router.delete('/services/:id', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const id = req.params.id;
  const exists = await db.query('SELECT 1 FROM services WHERE id=$1', [id]);
  if (!exists.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });

  await db.query('DELETE FROM service_reports WHERE service_id=$1', [id]);
  await db.query('DELETE FROM service_likes WHERE service_id=$1', [id]);
  await db.query('DELETE FROM service_favorites WHERE service_id=$1', [id]);
  await db.query('DELETE FROM service_photos WHERE service_id=$1', [id]);
  await db.query(`DELETE FROM notifications WHERE entity_id=$1`, [id]);
  await db.query('DELETE FROM services WHERE id=$1', [id]);

  // Папка с фотографиями сервиса больше не нужна
  const dir = path.join(__dirname, '..', '..', 'uploads', 'services', id);
  fs.rmSync(dir, { recursive: true, force: true });

  res.json({ ok: true });
});

// Редактирование любых полей карточки — для любого статуса
router.patch('/services/:id', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const body = req.body || {};
  const errors = {};
  const sets = [];
  const params = [];
  let i = 1;

  if ('title' in body) {
    const v = String(body.title || '').trim();
    if (!v || v.length > 100) errors.title = 'INVALID_TITLE';
    else { sets.push(`title=$${i++}`); params.push(v); }
  }
  if ('description' in body) {
    const v = String(body.description || '').trim();
    if (!v || v.length > 500) errors.description = 'INVALID_DESCRIPTION';
    else { sets.push(`description=$${i++}`); params.push(v); }
  }
  if ('website_url' in body) { sets.push(`website_url=$${i++}`); params.push(body.website_url ? String(body.website_url).trim() : null); }
  if ('map_url' in body) { sets.push(`map_url=$${i++}`); params.push(body.map_url ? String(body.map_url).trim() : null); }
  if ('category_id' in body) {
    const id = Number(body.category_id);
    if (!Number.isInteger(id)) errors.category_id = 'INVALID_CATEGORY';
    else {
      const c = await db.query('SELECT 1 FROM service_categories WHERE id=$1 AND is_active', [id]);
      if (!c.rowCount) errors.category_id = 'INVALID_CATEGORY';
      else { sets.push(`category_id=$${i++}`); params.push(id); }
    }
  }
  if ('city_id' in body) {
    const id = Number(body.city_id);
    if (!Number.isInteger(id)) errors.city_id = 'INVALID_CITY';
    else {
      const c = await db.query('SELECT 1 FROM cities WHERE id=$1 AND is_active', [id]);
      if (!c.rowCount) errors.city_id = 'INVALID_CITY';
      else { sets.push(`city_id=$${i++}`); params.push(id); }
    }
  }
  if ('status' in body) {
    if (!['pending', 'recommended', 'hidden'].includes(body.status)) errors.status = 'INVALID_STATUS';
    else { sets.push(`status=$${i++}`); params.push(body.status); }
  }

  if (Object.keys(errors).length) return res.status(400).json({ errors });
  if (!sets.length) return res.status(400).json({ error: 'NO_FIELDS' });

  params.push(req.params.id);
  const r = await db.query(`UPDATE services SET ${sets.join(', ')} WHERE id=$${i} RETURNING *`, params);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  res.json(r.rows[0]);
});

// Добавить фото в конец набора (максимум 5)
router.post('/services/:id/photos', (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  photoUpload.single('photo')(req, res, async (err) => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') return res.status(400).json({ error: 'PHOTO_TOO_LARGE' });
      return res.status(400).json({ error: err.message === 'PHOTO_BAD_FORMAT' ? 'PHOTO_BAD_FORMAT' : 'INVALID_PHOTO' });
    }
    if (!req.file) return res.status(400).json({ error: 'PHOTOS_REQUIRED' });

    const svc = await db.query('SELECT id FROM services WHERE id=$1', [req.params.id]);
    if (!svc.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
    const count = await db.query(
      'SELECT count(*)::int AS c, max(sort) AS max_sort FROM service_photos WHERE service_id=$1', [req.params.id]);
    if (count.rows[0].c >= 5) return res.status(400).json({ error: 'TOO_MANY_PHOTOS' });

    const url = savePhoto(req.params.id, req.file);
    const nextSort = count.rows[0].max_sort === null ? 0 : count.rows[0].max_sort + 1;
    const pr = await db.query(
      'INSERT INTO service_photos (service_id, url, sort) VALUES ($1,$2,$3) RETURNING id, url, sort',
      [req.params.id, url, nextSort]);
    if (nextSort === 0) await recomputeCover(req.params.id);
    res.json(pr.rows[0]);
  });
});

// Удалить фото — нельзя удалить последнее
router.delete('/services/:id/photos/:photoId', async (req, res) => {
  if (!UUID_RE.test(req.params.id) || !UUID_RE.test(req.params.photoId)) return res.status(404).json({ error: 'NOT_FOUND' });
  const count = await db.query('SELECT count(*)::int AS c FROM service_photos WHERE service_id=$1', [req.params.id]);
  if (count.rows[0].c <= 1) return res.status(400).json({ error: 'LAST_PHOTO' });
  const r = await db.query('DELETE FROM service_photos WHERE id=$1 AND service_id=$2 RETURNING id', [req.params.photoId, req.params.id]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  await recomputeCover(req.params.id);
  res.json({ ok: true });
});

// Пересортировка — первый id в массиве становится обложкой
router.patch('/services/:id/photos/order', async (req, res) => {
  if (!UUID_RE.test(req.params.id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const ids = Array.isArray(req.body.photo_ids) ? req.body.photo_ids : null;
  if (!ids || !ids.length) return res.status(400).json({ error: 'INVALID_ORDER' });

  const existing = await db.query('SELECT id FROM service_photos WHERE service_id=$1', [req.params.id]);
  const existingIds = existing.rows.map(row => row.id);
  const sameSet = ids.length === existingIds.length && existingIds.every(id => ids.includes(id));
  if (!sameSet) return res.status(400).json({ error: 'INVALID_ORDER' });

  for (let idx = 0; idx < ids.length; idx++) {
    await db.query('UPDATE service_photos SET sort=$1 WHERE id=$2 AND service_id=$3', [idx, ids[idx], req.params.id]);
  }
  await recomputeCover(req.params.id);
  const r = await db.query('SELECT id, url, sort FROM service_photos WHERE service_id=$1 ORDER BY sort', [req.params.id]);
  res.json(r.rows);
});

// --- Категории ---

router.get('/categories', async (req, res) => {
  // services_count нужен экрану 42: удалять можно только пустую категорию
  const r = await db.query(`
    SELECT c.id, c.name_ru, c.name_en, c.sort, c.is_active,
           (SELECT count(*)::int FROM services s WHERE s.category_id = c.id) AS services_count
    FROM service_categories c ORDER BY c.sort`);
  res.json(r.rows);
});

router.post('/categories', async (req, res) => {
  const nameRu = String(req.body.name_ru || '').trim();
  const nameEn = String(req.body.name_en || '').trim();
  const errors = {};
  if (!nameRu) errors.name_ru = 'REQUIRED';
  if (!nameEn) errors.name_en = 'REQUIRED';
  if (!Object.keys(errors).length) {
    const dupRu = await db.query('SELECT 1 FROM service_categories WHERE name_ru ILIKE $1', [nameRu]);
    if (dupRu.rowCount) errors.name_ru = 'DUPLICATE';
    const dupEn = await db.query('SELECT 1 FROM service_categories WHERE name_en ILIKE $1', [nameEn]);
    if (dupEn.rowCount) errors.name_en = 'DUPLICATE';
  }
  if (Object.keys(errors).length) return res.status(400).json({ errors });

  const r = await db.query(
    'INSERT INTO service_categories (name_ru, name_en) VALUES ($1,$2) RETURNING *',
    [nameRu, nameEn]);
  res.json(r.rows[0]);
});

router.delete('/categories/:id', async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const count = await db.query(`SELECT count(*)::int AS c FROM services WHERE category_id=$1`, [id]);
  if (count.rows[0].c > 0) return res.status(400).json({ error: 'CATEGORY_IN_USE', count: count.rows[0].c });
  const r = await db.query('DELETE FROM service_categories WHERE id=$1', [id]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  res.json({ ok: true });
});

// --- Жалобы (сервисы + пользователи) ---

router.get('/reports', async (req, res) => {
  const { limit, offset } = pagination(req);
  const r = await db.query(`
    SELECT * FROM (
      SELECT 'service' AS kind, sr.id, sr.reason_type, sr.comment, sr.created_at,
             sr.user_id AS reporter_id, ru.username AS reporter_username,
             sr.service_id AS target_id, s.title AS target_label
      FROM service_reports sr
      JOIN users ru ON ru.id = sr.user_id
      JOIN services s ON s.id = sr.service_id
      WHERE sr.resolved = false
      UNION ALL
      SELECT 'user' AS kind, ur.id, ur.reason_type, ur.comment, ur.created_at,
             ur.reporter_id, ru.username AS reporter_username,
             ur.target_id AS target_id, tu.username AS target_label
      FROM user_reports ur
      JOIN users ru ON ru.id = ur.reporter_id
      JOIN users tu ON tu.id = ur.target_id
      WHERE ur.resolved = false
    ) reports
    ORDER BY created_at DESC LIMIT $1 OFFSET $2`,
    [limit, offset]);
  res.json(r.rows);
});

router.post('/reports/:kind/:id/resolve', async (req, res) => {
  const { kind, id } = req.params;
  if (!UUID_RE.test(id)) return res.status(404).json({ error: 'NOT_FOUND' });
  const table = kind === 'service' ? 'service_reports' : kind === 'user' ? 'user_reports' : null;
  if (!table) return res.status(400).json({ error: 'INVALID_KIND' });
  const r = await db.query(`UPDATE ${table} SET resolved=true WHERE id=$1 RETURNING id`, [id]);
  if (!r.rowCount) return res.status(404).json({ error: 'NOT_FOUND' });
  res.json({ ok: true });
});

module.exports = router;
