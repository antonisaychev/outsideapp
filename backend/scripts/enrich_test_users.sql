-- Делает тестовые аккаунты похожими на живых людей:
-- разные страны, описания разной длины, по 3-5 фото у каждого.
-- Запускать сколько угодно раз — старые фото тестовых аккаунтов заменяются.
-- Требует переменную owner_email:
--   psql "$DB" -v owner_email=ваша@почта -f scripts/enrich_test_users.sql
-- ВАЖНО: значение без кавычек — psql подставит их сам (:'owner_email').
-- С кавычками получится строка с кавычками внутри, и скрипт молча ничего
-- не сделает: 0 обновлённых строк.
-- Четверо остаются в вашей стране (иначе в колоде знакомств будет пусто),
-- остальные разъезжаются по миру.
-- Портреты берём с randomuser.me, снимки «из жизни» — с picsum.photos
-- (оба отдают стабильные картинки по фиксированному адресу).

BEGIN;

-- 1. Страна, описание и главный портрет
UPDATE users u SET
  -- NULL в таблице ниже = «живёт там же, где основатель»
  city_id     = COALESCE(t.city_id, (SELECT city_id FROM users WHERE email = :'owner_email')),
  bio         = t.bio,
  avatar_url  = t.avatar,
  profile_updated_at = now()
FROM (VALUES
  ('maria.k@test.outside.ink', NULL, 'https://randomuser.me/api/portraits/women/44.jpg',
   'Дизайнер интерфейсов, третий год на Бали. Переехала из Питера за солнцем и остались навсегда. Утро начинаю с йоги на пляже, потом кофе и работа до обеда. Ищу компанию для утренних практик и вечерних прогулок вдоль океана — одной скучно, а местные встают в четыре утра'),
  ('anna.s@test.outside.ink',   2, 'https://randomuser.me/api/portraits/women/68.jpg',
   'Продакт на удалёнке. Сёрф, книги, длинные прогулки'),
  ('elena.v@test.outside.ink', NULL, 'https://randomuser.me/api/portraits/women/12.jpg',
   'Фотограф. Снимаю закаты и людей, которые их смотрят. Живу в Таиланде полтора года, объехала почти все острова. Всегда готова сорваться в поездку на выходные'),
  ('olga.m@test.outside.ink',   4, 'https://randomuser.me/api/portraits/women/33.jpg',
   'Преподаю английский онлайн, играю на гитаре. В Барселоне с прошлой осени, учу испанский и постоянно теряюсь в Готическом квартале — но это лучшая часть дня'),
  ('sofia.r@test.outside.ink',  6, 'https://randomuser.me/api/portraits/women/90.jpg',
   'Йога и веган-кухня. Верю в утренние ритуалы'),
  ('dmitry.p@test.outside.ink', NULL, 'https://randomuser.me/api/portraits/men/32.jpg',
   'Разработчик на фрилансе. Кофе, код и мотоцикл — три моих кита. Знаю все приличные кофейни в Чангу и половину в Убуде, могу составить маршрут на день'),
  ('ivan.k@test.outside.ink', NULL, 'https://randomuser.me/api/portraits/men/75.jpg',
   'Открыл кофейню, зову на дегустации. Бегаю по утрам'),
  ('alexey.n@test.outside.ink', 3, 'https://randomuser.me/api/portraits/men/54.jpg',
   'Маркетолог, дайвер с двумя сотнями погружений. Переехал в Таиланд ради воды и остался ради людей. Ищу компанию на выходные погружения — есть свой комплект снаряжения и знакомый инструктор с лодкой'),
  ('pavel.s@test.outside.ink',  5, 'https://randomuser.me/api/portraits/men/19.jpg',
   'Музыкант и звукорежиссёр. Играю по вечерам'),
  ('sergey.b@test.outside.ink', 4, 'https://randomuser.me/api/portraits/men/86.jpg',
   'Тренер по сёрфингу, двенадцать лет на доске. Научу вставать за неделю, даже если вы уверены, что не получится — таких у меня было много. Живу в Испании, зимой уезжаю к океану')
) AS t(email, city_id, avatar, bio)
WHERE u.email = t.email;

-- 2. Фото профиля: первый кадр — портрет, остальные «из жизни»
DELETE FROM user_photos WHERE user_id IN (
  SELECT id FROM users WHERE email LIKE '%@test.outside.ink');

INSERT INTO user_photos (user_id, url, position)
SELECT u.id, p.url, p.position
FROM users u
JOIN (VALUES
  -- у каждого 3-5 кадров, seed делает картинки стабильными
  ('maria.k@test.outside.ink',  'https://randomuser.me/api/portraits/women/44.jpg', 0),
  ('maria.k@test.outside.ink',  'https://picsum.photos/seed/mariak1/800/1000', 1),
  ('maria.k@test.outside.ink',  'https://picsum.photos/seed/mariak2/800/1000', 2),
  ('maria.k@test.outside.ink',  'https://picsum.photos/seed/mariak3/800/1000', 3),
  ('maria.k@test.outside.ink',  'https://picsum.photos/seed/mariak4/800/1000', 4),

  ('anna.s@test.outside.ink',   'https://randomuser.me/api/portraits/women/68.jpg', 0),
  ('anna.s@test.outside.ink',   'https://picsum.photos/seed/annas1/800/1000', 1),
  ('anna.s@test.outside.ink',   'https://picsum.photos/seed/annas2/800/1000', 2),

  ('elena.v@test.outside.ink',  'https://randomuser.me/api/portraits/women/12.jpg', 0),
  ('elena.v@test.outside.ink',  'https://picsum.photos/seed/elenav1/800/1000', 1),
  ('elena.v@test.outside.ink',  'https://picsum.photos/seed/elenav2/800/1000', 2),
  ('elena.v@test.outside.ink',  'https://picsum.photos/seed/elenav3/800/1000', 3),

  ('olga.m@test.outside.ink',   'https://randomuser.me/api/portraits/women/33.jpg', 0),
  ('olga.m@test.outside.ink',   'https://picsum.photos/seed/olgam1/800/1000', 1),
  ('olga.m@test.outside.ink',   'https://picsum.photos/seed/olgam2/800/1000', 2),
  ('olga.m@test.outside.ink',   'https://picsum.photos/seed/olgam3/800/1000', 3),
  ('olga.m@test.outside.ink',   'https://picsum.photos/seed/olgam4/800/1000', 4),

  ('sofia.r@test.outside.ink',  'https://randomuser.me/api/portraits/women/90.jpg', 0),
  ('sofia.r@test.outside.ink',  'https://picsum.photos/seed/sofiar1/800/1000', 1),
  ('sofia.r@test.outside.ink',  'https://picsum.photos/seed/sofiar2/800/1000', 2),

  ('dmitry.p@test.outside.ink', 'https://randomuser.me/api/portraits/men/32.jpg', 0),
  ('dmitry.p@test.outside.ink', 'https://picsum.photos/seed/dmitryp1/800/1000', 1),
  ('dmitry.p@test.outside.ink', 'https://picsum.photos/seed/dmitryp2/800/1000', 2),
  ('dmitry.p@test.outside.ink', 'https://picsum.photos/seed/dmitryp3/800/1000', 3),

  ('ivan.k@test.outside.ink',   'https://randomuser.me/api/portraits/men/75.jpg', 0),
  ('ivan.k@test.outside.ink',   'https://picsum.photos/seed/ivank1/800/1000', 1),
  ('ivan.k@test.outside.ink',   'https://picsum.photos/seed/ivank2/800/1000', 2),

  ('alexey.n@test.outside.ink', 'https://randomuser.me/api/portraits/men/54.jpg', 0),
  ('alexey.n@test.outside.ink', 'https://picsum.photos/seed/alexeyn1/800/1000', 1),
  ('alexey.n@test.outside.ink', 'https://picsum.photos/seed/alexeyn2/800/1000', 2),
  ('alexey.n@test.outside.ink', 'https://picsum.photos/seed/alexeyn3/800/1000', 3),
  ('alexey.n@test.outside.ink', 'https://picsum.photos/seed/alexeyn4/800/1000', 4),

  ('pavel.s@test.outside.ink',  'https://randomuser.me/api/portraits/men/19.jpg', 0),
  ('pavel.s@test.outside.ink',  'https://picsum.photos/seed/pavels1/800/1000', 1),
  ('pavel.s@test.outside.ink',  'https://picsum.photos/seed/pavels2/800/1000', 2),

  ('sergey.b@test.outside.ink', 'https://randomuser.me/api/portraits/men/86.jpg', 0),
  ('sergey.b@test.outside.ink', 'https://picsum.photos/seed/sergeyb1/800/1000', 1),
  ('sergey.b@test.outside.ink', 'https://picsum.photos/seed/sergeyb2/800/1000', 2),
  ('sergey.b@test.outside.ink', 'https://picsum.photos/seed/sergeyb3/800/1000', 3)
) AS p(email, url, position) ON p.email = u.email;

COMMIT;

-- Итог: сколько у кого фото и где живёт
SELECT u.username, c.name_ru AS place, length(u.bio) AS bio_len,
       (SELECT count(*) FROM user_photos p WHERE p.user_id = u.id) AS photos
FROM users u LEFT JOIN cities c ON c.id = u.city_id
WHERE u.email LIKE '%@test.outside.ink'
ORDER BY u.username;
