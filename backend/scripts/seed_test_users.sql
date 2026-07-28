-- Тестовые аккаунты для проверки раздела «Знакомства».
-- Создаются сразу подтверждёнными (коды на выдуманные адреса не приходят).
-- Пароль у всех: TestPass123!
-- Город и страна берутся из профиля основателя, чтобы попасть в его колоду.
-- Пятеро заранее «лайкают» основателя — его ответный лайк сразу даёт мэтч.
-- Удалить всех разом: scripts/remove_test_users.sql

BEGIN;

-- 1. Пользователи
INSERT INTO users (
  email, password_hash, email_verified, username,
  first_name, last_name, avatar_url, bio,
  city_id, home_country, gender, birth_date
)
SELECT
  t.email,
  '$2b$10$CeayooX.w91sYcEUkbLJde7JuWmMTmryjQ7wdkRBM75ZV5bOkmVmu',
  true,
  t.username,
  t.first_name,
  t.last_name,
  t.avatar_url,
  t.bio,
  me.city_id,
  COALESCE(me.home_country, 'RU'),
  t.gender,
  t.birth_date
FROM (VALUES
  ('maria.k@test.outside.ink',  'maria_k',  'Мария',   'Ковалёва',   'https://randomuser.me/api/portraits/women/44.jpg', 'Дизайнер, переехала полгода назад. Ищу компанию для утренней йоги и кофе', 'female', DATE '1995-04-12'),
  ('anna.s@test.outside.ink',   'anna_s',   'Анна',    'Соколова',   'https://randomuser.me/api/portraits/women/68.jpg', 'Продакт-менеджер на удалёнке. Люблю сёрф, книги и долгие прогулки',        'female', DATE '1992-09-03'),
  ('elena.v@test.outside.ink',  'elena_v',  'Елена',   'Виноградова','https://randomuser.me/api/portraits/women/12.jpg', 'Фотограф. Снимаю закаты и людей. Ищу друзей для поездок по острову',       'female', DATE '1997-01-25'),
  ('olga.m@test.outside.ink',   'olga_m',   'Ольга',   'Мельник',    'https://randomuser.me/api/portraits/women/33.jpg', 'Преподаю английский, играю на гитаре. Всегда за спонтанные планы',         'female', DATE '1993-07-19'),
  ('sofia.r@test.outside.ink',  'sofia_r',  'София',   'Романова',   'https://randomuser.me/api/portraits/women/90.jpg', 'Йога-инструктор и веган-повар. Верю в утренние ритуалы',                   'female', DATE '1990-11-08'),
  ('dmitry.p@test.outside.ink', 'dmitry_p', 'Дмитрий', 'Петров',     'https://randomuser.me/api/portraits/men/32.jpg',   'Разработчик, фрилансер. Кофе, код и мотоцикл — три моих кита',             'male',   DATE '1991-03-14'),
  ('ivan.k@test.outside.ink',   'ivan_k',   'Иван',    'Кузнецов',   'https://randomuser.me/api/portraits/men/75.jpg',   'Открыл кофейню, зову всех на дегустации. Бегаю по утрам',                  'male',   DATE '1988-06-30'),
  ('alexey.n@test.outside.ink', 'alexey_n', 'Алексей', 'Новиков',    'https://randomuser.me/api/portraits/men/54.jpg',   'Маркетолог, увлекаюсь дайвингом. Ищу компанию на погружения',              'male',   DATE '1994-12-05'),
  ('pavel.s@test.outside.ink',  'pavel_s',  'Павел',   'Смирнов',    'https://randomuser.me/api/portraits/men/19.jpg',   'Музыкант и звукорежиссёр. Играю по вечерам в барах',                       'male',   DATE '1996-02-17'),
  ('sergey.b@test.outside.ink', 'sergey_b', 'Сергей',  'Баранов',    'https://randomuser.me/api/portraits/men/86.jpg',   'Тренер по сёрфингу. Научу вставать на доску за неделю',                    'male',   DATE '1989-08-22')
) AS t(email, username, first_name, last_name, avatar_url, bio, gender, birth_date)
CROSS JOIN (
  SELECT city_id, home_country FROM users WHERE email = :'owner_email'
) AS me
ON CONFLICT (email) DO NOTHING;

-- 2. Все участвуют в знакомствах
INSERT INTO dating_profiles (user_id, is_active, looking_for, show_gender)
SELECT id, true, 'any', 'any' FROM users WHERE email LIKE '%@test.outside.ink'
ON CONFLICT (user_id) DO UPDATE SET is_active = true;

-- 3. Пятеро уже лайкнули основателя — ответный лайк даст мэтч сразу
INSERT INTO swipes (swiper_id, target_id, direction)
SELECT u.id, me.id, 'like'
FROM users u
CROSS JOIN (SELECT id FROM users WHERE email = :'owner_email') AS me
WHERE u.email IN (
  'maria.k@test.outside.ink',
  'dmitry.p@test.outside.ink',
  'elena.v@test.outside.ink',
  'ivan.k@test.outside.ink',
  'sofia.r@test.outside.ink'
)
ON CONFLICT (swiper_id, target_id) DO NOTHING;

COMMIT;

-- Итог
SELECT username, first_name, gender, birth_date,
       (SELECT count(*) FROM swipes s WHERE s.swiper_id = u.id) AS liked_you
FROM users u WHERE email LIKE '%@test.outside.ink' ORDER BY gender, username;
