// Загрузка файлов (фото сервисов и т.п.) → /uploads/<файл>
const express = require('express');
const multer = require('multer');
const path = require('path');
const crypto = require('crypto');
const { required } = require('../middleware/auth');

const router = express.Router();

const upload = multer({
  storage: multer.diskStorage({
    destination: path.join(__dirname, '..', '..', 'uploads'),
    filename: (req, file, cb) => cb(null, `${crypto.randomUUID()}${path.extname(file.originalname).toLowerCase()}`),
  }),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => cb(null, ['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype)),
});

router.post('/', required, (req, res) => {
  upload.single('file')(req, res, (err) => {
    if (err || !req.file) return res.status(400).json({ error: 'INVALID_FILE' });
    res.json({ url: `/uploads/${req.file.filename}` });
  });
});

module.exports = router;
