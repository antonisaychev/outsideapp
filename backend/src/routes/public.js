// Публичные справочники и проверки (доступны гостям)
const express = require('express');
const db = require('../db');
const router = express.Router();

router.get('/cities', async (req, res) => {
  const r = await db.query('SELECT id, name_ru, name_en, country_ru, country_en, flag FROM cities WHERE is_active ORDER BY id');
  res.json(r.rows);
});

router.get('/categories', async (req, res) => {
  // ?city_id= — отдаём только те категории, где в этом месте есть карточки:
  // фильтр по пустой категории всё равно показал бы пустой список
  const cityId = req.query.city_id ? Number(req.query.city_id) : null;
  if (Number.isInteger(cityId)) {
    const r = await db.query(`
      SELECT c.id, c.name_ru, c.name_en
      FROM service_categories c
      WHERE c.is_active AND EXISTS (
        SELECT 1 FROM services s
         WHERE s.category_id = c.id AND s.city_id = $1 AND s.status = 'recommended')
      ORDER BY c.sort`, [cityId]);
    return res.json(r.rows);
  }
  const r = await db.query('SELECT id, name_ru, name_en FROM service_categories WHERE is_active ORDER BY sort');
  res.json(r.rows);
});

router.get('/users/check-username', async (req, res) => {
  const u = String(req.query.u || '').trim().toLowerCase();
  if (!/^[a-z_]{3,30}$/.test(u)) return res.json({ available: false, reason: 'INVALID' });
  const r = await db.query('SELECT 1 FROM users WHERE username=$1', [u]);
  res.json({ available: !r.rowCount });
});

router.get('/config', (req, res) => {
  res.json({ min_app_version: '1.0.0', confirm_threshold: Number(process.env.CONFIRM_THRESHOLD || 30) });
});

module.exports = router;
