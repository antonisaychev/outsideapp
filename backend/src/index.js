require('dotenv').config();
const express = require('express');
const path = require('path');
const http = require('http');

const app = express();
app.set('trust proxy', 1);
app.use(express.json({ limit: '1mb' }));
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

app.get('/health', (req, res) => res.json({ ok: true, service: 'outside-api' }));

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

// единый обработчик ошибок
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'INTERNAL' });
});

const port = Number(process.env.PORT || 3000);
const server = http.createServer(app);
require('./ws').attach(server);
server.listen(port, () => console.log(`Outside API on :${port}`));
