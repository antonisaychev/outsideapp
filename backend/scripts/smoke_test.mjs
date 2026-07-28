// Сквозная проверка API: регистрация → онбординг → сервисы → друзья →
// знакомства → чат → уведомления → админка. Работает по HTTP, как приложение.
//
// Запуск (сервер должен быть поднят):
//   node scripts/smoke_test.mjs [http://localhost:3000]
//
// Тестовые аккаунты создаются с адресами @smoke.local и удаляются в конце.
// На боевом сервере запускать МОЖНО: данные за собой убирает, но лучше
// прогонять локально перед деплоем.

import { Client } from 'pg';
import 'dotenv/config';

const BASE = process.argv[2] || 'http://localhost:3000';
const db = new Client({ connectionString: process.env.DATABASE_URL });

let passed = 0;
let failed = 0;
const failures = [];

function check(name, condition, details = '') {
  if (condition) {
    passed++;
    console.log(`  ✓ ${name}`);
  } else {
    failed++;
    failures.push(`${name}${details ? ' — ' + details : ''}`);
    console.log(`  ✗ ${name}${details ? ' — ' + details : ''}`);
  }
}

let ipCounter = 0;

async function api(method, path, { token, body, raw, freshIp } = {}) {
  const headers = {};
  // Регистрация ограничена 5 попытками в час с одного адреса — для теста
  // каждый новый аккаунт приходит «с другого IP» (app.set('trust proxy'))
  if (freshIp) headers['X-Forwarded-For'] = `10.0.${++ipCounter}.1`;
  if (token) headers.Authorization = `Bearer ${token}`;
  if (body && !raw) headers['Content-Type'] = 'application/json';
  const res = await fetch(BASE + path, {
    method,
    headers,
    body: raw ? body : body ? JSON.stringify(body) : undefined,
  });
  let data = null;
  const text = await res.text();
  if (text) {
    try { data = JSON.parse(text); } catch { data = text; }
  }
  return { status: res.status, data };
}

/// Код подтверждения читаем прямо из базы — писем в тестах нет
async function codeFor(email, purpose) {
  const r = await db.query(
    `SELECT code FROM email_codes WHERE email=$1 AND purpose=$2
     ORDER BY created_at DESC LIMIT 1`, [email, purpose]);
  return r.rows[0]?.code;
}

/// Полный путь нового пользователя: регистрация, подтверждение, онбординг
async function makeUser(nick, { gender = 'male', cityId = 1 } = {}) {
  const email = `${nick}@smoke.local`;
  await api('POST', '/auth/register', {
    freshIp: true,
    body: { email, password: 'SmokePass123!', username: nick },
  });
  const code = await codeFor(email, 'verify');
  const verify = await api('POST', '/auth/verify', { body: { email, code } });
  const token = verify.data?.access_token;
  await api('PATCH', '/me', {
    token,
    body: {
      first_name: nick, last_name: 'Тестов', gender,
      birth_date: '1990-05-05', city_id: cityId, home_country: 'RU',
    },
  });
  const me = await api('GET', '/me', { token });
  return { email, token, id: me.data?.id, nick };
}

async function cleanup() {
  await db.query(`
    DELETE FROM email_codes WHERE email LIKE '%@smoke.local';
    `);
  await db.query(`
    WITH victims AS (SELECT id FROM users WHERE email LIKE '%@smoke.local')
    DELETE FROM notifications WHERE user_id IN (SELECT id FROM victims)
        OR actor_id IN (SELECT id FROM victims)`);
  const tables = [
    ['messages', 'sender_id'],
    ['service_views', 'user_id'],
    ['service_likes', 'user_id'],
    ['service_favorites', 'user_id'],
    ['service_reports', 'user_id'],
    ['dating_profiles', 'user_id'],
    ['user_photos', 'user_id'],
  ];
  for (const [table, column] of tables) {
    await db.query(
      `DELETE FROM ${table} WHERE ${column} IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')`);
  }
  await db.query(`DELETE FROM messages WHERE conversation_id IN (
      SELECT id FROM conversations WHERE user_a IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')
         OR user_b IN (SELECT id FROM users WHERE email LIKE '%@smoke.local'))`);
  await db.query(`DELETE FROM conversations WHERE user_a IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')
      OR user_b IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')`);
  await db.query(`DELETE FROM matches WHERE user_a IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')
      OR user_b IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')`);
  await db.query(`DELETE FROM swipes WHERE swiper_id IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')
      OR target_id IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')`);
  await db.query(`DELETE FROM friendships WHERE requester_id IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')
      OR addressee_id IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')`);
  await db.query(`DELETE FROM user_reports WHERE reporter_id IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')
      OR target_id IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')`);
  await db.query(`DELETE FROM service_photos WHERE service_id IN (
      SELECT id FROM services WHERE author_id IN (SELECT id FROM users WHERE email LIKE '%@smoke.local'))`);
  await db.query(`DELETE FROM service_views WHERE service_id IN (
      SELECT id FROM services WHERE author_id IN (SELECT id FROM users WHERE email LIKE '%@smoke.local'))`);
  await db.query(`DELETE FROM services WHERE author_id IN (SELECT id FROM users WHERE email LIKE '%@smoke.local')`);
  await db.query(`DELETE FROM users WHERE email LIKE '%@smoke.local'`);
}

async function main() {
  await db.connect();
  await cleanup();

  console.log(`\nПроверка ${BASE}\n`);

  // --- Здоровье и публичные справочники ---
  console.log('Публичные эндпоинты');
  const health = await api('GET', '/health');
  check('/health отвечает', health.status === 200 && health.data.ok === true);
  check('/health отдаёт версию', typeof health.data.version === 'string',
    JSON.stringify(health.data));
  const cities = await api('GET', '/cities');
  check('/cities отдаёт места', Array.isArray(cities.data) && cities.data.length > 0);
  const cats = await api('GET', '/categories');
  check('/categories отдаёт категории', Array.isArray(cats.data) && cats.data.length > 0);
  const freeNick = await api('GET', '/users/check-username?username=smoke_free_nick');
  check('/users/check-username работает', freeNick.status === 200);

  // --- Регистрация и вход ---
  console.log('\nАвторизация');
  const alice = await makeUser('smoke_alice', { gender: 'female' });
  check('регистрация + подтверждение', !!alice.token && !!alice.id);

  const dupNick = await api('POST', '/auth/register',
    { freshIp: true, body: { email: 'other@smoke.local', password: 'SmokePass123!', username: 'smoke_alice' } });
  check('занятый никнейм отклоняется', dupNick.status === 400,
    `код ${dupNick.status}`);

  const cyrillic = await api('POST', '/auth/register',
    { freshIp: true, body: { email: 'cyr@smoke.local', password: 'Пароль12345', username: 'smoke_cyr' } });
  check('кириллический пароль отклоняется', cyrillic.status === 400,
    `код ${cyrillic.status}`);

  let limited = false;
  for (let i = 0; i < 6; i++) {
    const r = await fetch(BASE + '/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-Forwarded-For': '10.9.9.9' },
      body: JSON.stringify({
        email: `flood${i}@smoke.local`, password: 'SmokePass123!', username: `smoke_flood${'a'.repeat(i)}`,
      }),
    });
    if (r.status === 429) limited = true;
  }
  check('поток регистраций с одного адреса упирается в лимит', limited);

  const wrongPass = await api('POST', '/auth/login',
    { body: { email: alice.email, password: 'НеТотПароль1!' } });
  check('неверный пароль → 401', wrongPass.status === 401, `код ${wrongPass.status}`);

  const unknownEmail = await api('POST', '/auth/login',
    { body: { email: 'nobody@smoke.local', password: 'SmokePass123!' } });
  check('несуществующий email не раскрывается',
    unknownEmail.status === 401 && !JSON.stringify(unknownEmail.data).includes('NOT_FOUND'),
    JSON.stringify(unknownEmail.data));

  const noToken = await api('GET', '/me');
  check('без токена → 401', noToken.status === 401);

  const badToken = await api('GET', '/me', { token: 'broken.token.here' });
  check('битый токен → 401', badToken.status === 401);

  const badJson = await fetch(BASE + '/auth/login', {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{сломано',
  });
  check('битый JSON → 400, не 500', badJson.status === 400, `код ${badJson.status}`);

  const huge = await fetch(BASE + '/auth/login', {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: 'x'.repeat(3_000_000),
  });
  check('огромное тело → 413, не 500', huge.status === 413, `код ${huge.status}`);

  const nowhere = await api('GET', '/no-such-endpoint');
  check('неизвестный адрес отвечает JSON-ом',
    nowhere.status === 404 && nowhere.data?.error === 'NOT_FOUND');

  await db.query(`DELETE FROM email_codes WHERE email=$1`, [alice.email]);
  for (let i = 0; i < 4; i++) {
    await api('POST', '/auth/forgot', { body: { email: alice.email } });
  }
  const sentCodes = await db.query(
    `SELECT count(*)::int AS c FROM email_codes WHERE email=$1 AND created_at > now() - interval '1 minute'`,
    [alice.email]);
  check('поток запросов кода шлёт одно письмо', sentCodes.rows[0].c === 1,
    `писем: ${sentCodes.rows[0].c}`);

  // --- Профиль ---
  console.log('\nПрофиль');
  const me = await api('GET', '/me', { token: alice.token });
  check('GET /me отдаёт профиль', me.data?.email === alice.email);
  check('поля онбординга сохранились',
    !!me.data?.first_name && !!me.data?.city_id && !!me.data?.home_country,
    JSON.stringify({ n: me.data?.first_name, c: me.data?.city_id, h: me.data?.home_country }));

  const badBirth = await api('PATCH', '/me',
    { token: alice.token, body: { birth_date: '2050-01-01' } });
  check('дата рождения из будущего отклоняется', badBirth.status === 400);

  const publicProfile = await api('GET', `/users/@${alice.nick}`);
  check('публичный профиль по нику', publicProfile.data?.id === alice.id);
  check('в публичном профиле нет email',
    !JSON.stringify(publicProfile.data).includes('@smoke.local'),
    JSON.stringify(publicProfile.data).slice(0, 120));
  check('онлайн-статус отдаётся', typeof publicProfile.data?.is_online === 'boolean');

  // --- Сервисы ---
  console.log('\nСервисы');
  const bob = await makeUser('smoke_bob');
  const serviceId = (await db.query(
    `INSERT INTO services (title, description, photo_url, city_id, category_id, author_id, status)
     VALUES ('Смоук-кафе','Описание для проверки','/uploads/x.jpg',1,
             (SELECT id FROM service_categories ORDER BY sort LIMIT 1), $1, 'recommended')
     RETURNING id`, [bob.id])).rows[0].id;

  const list = await api('GET', '/services?city_id=1', { token: alice.token });
  check('лента сервисов отдаётся', Array.isArray(list.data));
  check('в ленте есть значок проверки',
    list.data.every(s => 'is_verified' in s), JSON.stringify(list.data[0] || {}));

  const pendingForUser = await api('GET', '/services?city_id=1&tab=pending', { token: alice.token });
  check('раздел «на проверке» пользователю не отдаётся',
    Array.isArray(pendingForUser.data) && pendingForUser.data.every(s => s.status !== 'pending'));

  const detail = await api('GET', `/services/${serviceId}`, { token: alice.token });
  check('карточка открывается', detail.data?.id === serviceId);
  check('автор карточки отдаётся', detail.data?.author?.id === bob.id);

  // просмотр пишется в фоне, чтобы не задерживать ответ — даём ему долететь
  await new Promise(r => setTimeout(r, 300));
  const viewed = await db.query(
    'SELECT 1 FROM service_views WHERE user_id=$1 AND service_id=$2', [alice.id, serviceId]);
  check('просмотр карточки записывается', viewed.rowCount === 1);

  const like = await api('POST', `/services/${serviceId}/like`, { token: alice.token });
  check('лайк ставится', like.status === 200, JSON.stringify(like.data));
  const likeTwice = await api('POST', `/services/${serviceId}/like`, { token: alice.token });
  check('повторный лайк снимает отметку', likeTwice.data?.liked === false,
    JSON.stringify(likeTwice.data));

  const fav = await api('POST', `/services/${serviceId}/favorite`, { token: alice.token });
  check('избранное добавляется', fav.status === 200);
  const favList = await api('GET', '/me/favorites', { token: alice.token });
  check('избранное отдаётся списком', Array.isArray(favList.data));

  const foreignEdit = await api('PATCH', `/services/${serviceId}`,
    { token: alice.token, body: { title: 'Захват карточки' } });
  check('чужую карточку править нельзя', foreignEdit.status === 403 || foreignEdit.status === 404,
    `код ${foreignEdit.status}`);

  // --- Друзья ---
  console.log('\nДрузья');
  const req = await api('POST', '/friends/requests',
    { token: alice.token, body: { user_id: bob.id } });
  check('заявка в друзья отправляется', req.status === 200, JSON.stringify(req.data));

  const selfReq = await api('POST', '/friends/requests',
    { token: alice.token, body: { user_id: alice.id } });
  check('заявка самому себе отклоняется', selfReq.status === 400);

  const incoming = await api('GET', '/friends/requests', { token: bob.token });
  check('заявка видна получателю',
    Array.isArray(incoming.data) && incoming.data.some(u => u.id === alice.id));

  const accept = await api('POST', `/friends/requests/${alice.id}/accept`, { token: bob.token });
  check('заявка принимается', accept.status === 200);

  const friends = await api('GET', '/friends', { token: alice.token });
  check('друг появился в списке',
    Array.isArray(friends.data) && friends.data.some(u => u.id === bob.id));
  check('онлайн-статус в списке друзей',
    friends.data.every(u => 'is_online' in u), JSON.stringify(friends.data[0] || {}));

  // --- Чат ---
  console.log('\nЧат');
  const conv = await api('POST', '/chats', { token: alice.token, body: { user_id: bob.id } });
  check('диалог создаётся', !!conv.data?.id, JSON.stringify(conv.data));
  const convId = conv.data.id;

  const msg = await api('POST', `/chats/${convId}/messages`,
    { token: alice.token, body: { text: 'Привет из теста' } });
  check('сообщение отправляется', msg.status === 200, JSON.stringify(msg.data));

  const emptyMsg = await api('POST', `/chats/${convId}/messages`,
    { token: alice.token, body: { text: '   ' } });
  check('пустое сообщение отклоняется', emptyMsg.status === 400);

  const history = await api('GET', `/chats/${convId}/messages`, { token: bob.token });
  check('история читается', Array.isArray(history.data) && history.data.length === 1);

  const convList = await api('GET', '/chats', { token: bob.token });
  check('непрочитанное считается',
    convList.data?.[0]?.unread_count === 1, JSON.stringify(convList.data?.[0]?.unread_count));
  check('онлайн-статус в списке диалогов',
    convList.data.every(c => 'is_online' in c));

  const del = await api('DELETE', `/chats/${convId}/messages/${msg.data.id}`, { token: alice.token });
  check('своё сообщение удаляется', del.status === 200);
  const afterDel = await api('GET', `/chats/${convId}/messages`, { token: bob.token });
  check('от удалённого остаётся заглушка',
    afterDel.data?.[0]?.deleted_at != null && afterDel.data?.[0]?.text === '');

  const carol = await makeUser('smoke_carol');
  const strangerChat = await api('POST', '/chats', { token: carol.token, body: { user_id: alice.id } });
  check('чат с не-другом запрещён', strangerChat.status === 403, `код ${strangerChat.status}`);

  const foreignHistory = await api('GET', `/chats/${convId}/messages`, { token: carol.token });
  check('чужой диалог не читается', foreignHistory.status === 404, `код ${foreignHistory.status}`);

  // --- Знакомства ---
  console.log('\nЗнакомства');
  const datingProfile = await api('GET', '/dating/profile', { token: alice.token });
  check('знакомства включены по умолчанию', datingProfile.data?.is_active === true);

  const deck = await api('GET', '/dating/deck', { token: alice.token });
  check('колода отдаётся', Array.isArray(deck.data));

  await db.query(
    `INSERT INTO user_photos (user_id, url, position) VALUES ($1,'/uploads/p.jpg',0)`, [carol.id]);
  await db.query(`UPDATE users SET avatar_url='/uploads/p.jpg' WHERE id=$1`, [carol.id]);
  const swipe = await api('POST', '/dating/swipe',
    { token: carol.token, body: { user_id: alice.id, direction: 'like' } });
  check('лайк в знакомствах проходит', swipe.status === 200, JSON.stringify(swipe.data));

  const friendReqAfterLike = await db.query(
    `SELECT status FROM friendships WHERE requester_id=$1 AND addressee_id=$2`, [carol.id, alice.id]);
  check('лайк отправляет заявку в друзья', friendReqAfterLike.rowCount === 1,
    JSON.stringify(friendReqAfterLike.rows));

  const back = await api('POST', '/dating/swipe',
    { token: alice.token, body: { user_id: carol.id, direction: 'like' } });
  check('взаимный лайк даёт мэтч', back.data?.match === true, JSON.stringify(back.data));

  const matchFriendship = await db.query(
    `SELECT status FROM friendships WHERE (requester_id=$1 AND addressee_id=$2)
        OR (requester_id=$2 AND addressee_id=$1)`, [alice.id, carol.id]);
  check('мэтч делает друзьями', matchFriendship.rows[0]?.status === 'accepted',
    JSON.stringify(matchFriendship.rows));

  const selfSwipe = await api('POST', '/dating/swipe',
    { token: alice.token, body: { user_id: alice.id, direction: 'like' } });
  check('свайп самого себя отклоняется', selfSwipe.status === 400);

  await api('PATCH', '/dating/profile', { token: carol.token, body: { is_active: false } });
  const deckOff = await api('GET', '/dating/deck', { token: carol.token });
  check('выключенные знакомства закрывают колоду', deckOff.status === 403);
  await api('PATCH', '/dating/profile', { token: carol.token, body: { is_active: true } });

  // --- Уведомления ---
  console.log('\nУведомления');
  const notifs = await api('GET', '/notifications', { token: alice.token });
  check('уведомления отдаются', Array.isArray(notifs.data) && notifs.data.length > 0,
    `их ${notifs.data?.length}`);
  check('в уведомлении есть обложка карточки',
    notifs.data.every(n => 'entity_photo_url' in n));
  const unread = await api('GET', '/notifications/unread-count', { token: alice.token });
  check('счётчик непрочитанного', typeof unread.data?.count === 'number');

  // --- Админка ---
  console.log('\nАдминка');
  const adminDenied = await api('GET', '/admin/users', { token: alice.token });
  check('обычному пользователю админка закрыта', adminDenied.status === 403);

  await db.query(`UPDATE users SET role='admin' WHERE id=$1`, [alice.id]);
  const adminUsers = await api('GET', '/admin/users', { token: alice.token });
  check('админ видит пользователей', Array.isArray(adminUsers.data));
  check('в списке есть признак удалённого',
    adminUsers.data.every(u => 'is_deleted' in u));

  const blockNoReason = await api('POST', `/admin/users/${bob.id}/block`,
    { token: alice.token, body: { reason: '' } });
  check('блокировка без причины отклоняется', blockNoReason.status === 400);

  await api('POST', `/admin/users/${bob.id}/block`,
    { token: alice.token, body: { reason: 'Проверка' } });
  const blockedProfile = await api('GET', `/users/${bob.id}`, { token: alice.token });
  check('профиль заблокированного отвечает 403', blockedProfile.status === 403,
    `код ${blockedProfile.status}`);
  const blockedLogin = await api('GET', '/me', { token: bob.token });
  check('заблокированный не работает с API', blockedLogin.status === 403);
  await api('POST', `/admin/users/${bob.id}/unblock`, { token: alice.token });

  const verify = await api('PATCH', `/admin/services/${serviceId}`,
    { token: alice.token, body: { is_verified: true, owner_id: carol.id } });
  check('значок проверки и владелец ставятся',
    verify.data?.is_verified === true && verify.data?.owner_id === carol.id,
    JSON.stringify(verify.data).slice(0, 120));

  const badOwner = await api('PATCH', `/admin/services/${serviceId}`,
    { token: alice.token, body: { owner_id: '11111111-1111-1111-1111-111111111111' } });
  check('несуществующий владелец отклоняется', badOwner.status === 400);

  await api('POST', `/admin/services/${serviceId}/hide`, { token: alice.token });
  const hidden = await api('GET', `/services/${serviceId}`, { token: carol.token });
  check('скрытая карточка недоступна', hidden.status === 404);
  const unhide = await api('POST', `/admin/services/${serviceId}/unhide`, { token: alice.token });
  check('карточка возвращается из скрытых', unhide.status === 200, JSON.stringify(unhide.data));

  const reports = await api('GET', '/admin/reports', { token: alice.token });
  check('жалобы отдаются', Array.isArray(reports.data));

  const adminCats = await api('GET', '/admin/categories', { token: alice.token });
  check('категории со счётчиком', adminCats.data.every(c => 'services_count' in c));

  const delService = await api('DELETE', `/admin/services/${serviceId}`, { token: alice.token });
  check('карточка удаляется полностью', delService.status === 200);
  const gone = await db.query('SELECT 1 FROM services WHERE id=$1', [serviceId]);
  check('в базе карточки не осталось', gone.rowCount === 0);

  // --- Итог ---
  await cleanup();
  await db.end();

  console.log(`\n${'─'.repeat(50)}`);
  console.log(`Пройдено: ${passed}   Провалено: ${failed}`);
  if (failures.length) {
    console.log('\nНе прошли:');
    failures.forEach(f => console.log(`  • ${f}`));
  }
  process.exit(failed ? 1 : 0);
}

main().catch(async (err) => {
  console.error('\nТест упал с ошибкой:', err);
  try { await cleanup(); await db.end(); } catch {}
  process.exit(1);
});
