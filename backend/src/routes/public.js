// Публичные справочники и проверки (доступны гостям)
const express = require('express');
const db = require('../db');
const router = express.Router();

router.get('/cities', async (req, res) => {
  const r = await db.query('SELECT id, name_ru, name_en, country_ru, country_en, flag FROM cities WHERE is_active ORDER BY id');
  res.json(r.rows);
});

router.get('/categories', async (req, res) => {
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
