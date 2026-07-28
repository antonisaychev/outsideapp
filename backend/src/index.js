require('dotenv').config();

// Без этих переменных сервер поднимется, но сломается на первом же входе —
// лучше упасть сразу с понятным текстом, чем ловить это на пользователях
for (const key of ['DATABASE_URL', 'JWT_SECRET']) {
  if (!process.env[key]) {
    console.error(`Не задана переменная ${key} — проверьте файл .env`);
    process.exit(1);
  }
}
if (process.env.JWT_SECRET.length < 32) {
  console.error('JWT_SECRET короче 32 символов — подберите длиннее');
  process.exit(1);
}

const express = require('express');
const path = require('path');
const http = require('http');

const app = express();
app.set('trust proxy', 1);
app.use(express.json({ limit: '1mb' }));
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// version — чтобы одной командой понять, обновлён ли сервер после git pull
app.get('/health', (req, res) => res.json({
  ok: true,
  service: 'outside-api',
  version: require('../package.json').version,
}));

app.use('/auth', require('./routes/auth'));
app.use('/', require('./routes/public'));
app.use('/me', require('./routes/me'));
app.use('/users', require('./routes/users'));
app.use('/friends', require('./routes/friends'));
app.use('/uploads', require('./routes/uploads'));
app.use('/services', require('./routes/services'));
app.use('/dating', require('./routes/dating'));
app.use('/chats', require('./routes/chats'));
app.use('/notifications', require('./routes/notifications'));
app.use('/admin', require('./routes/admin'));

// Неизвестный адрес — тоже JSON: приложение ждёт JSON и на ошибках
app.use((req, res) => res.status(404).json({ error: 'NOT_FOUND' }));

// единый обработчик ошибок
app.use((err, req, res, next) => {
  // Кривой JSON и слишком большое тело — это ошибка клиента, не сервера
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ error: 'BAD_JSON' });
  }
  if (err.type === 'entity.too.large' || err.status === 413) {
    return res.status(413).json({ error: 'PAYLOAD_TOO_LARGE' });
  }
  console.error(err);
  res.status(500).json({ error: 'INTERNAL' });
});

const port = Number(process.env.PORT || 3000);
const server = http.createServer(app);
require('./ws').attach(server);
server.listen(port, () => console.log(`Outside API on :${port}`));

// При перезапуске (pm2 restart) даём текущим запросам договорить и закрываем
// соединения с базой — иначе в логах копятся оборванные транзакции
for (const signal of ['SIGTERM', 'SIGINT']) {
  process.on(signal, () => {
    console.log(`${signal}: останавливаемся`);
    server.close(() => {
      require('./db').pool.end().finally(() => process.exit(0));
    });
    // если за 10 секунд не закрылись — выходим принудительно
    setTimeout(() => process.exit(0), 10_000).unref();
  });
}
