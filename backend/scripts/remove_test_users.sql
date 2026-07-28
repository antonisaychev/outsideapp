-- Удаление тестовых аккаунтов раздела «Знакомства» (все с @test.outside.ink).
-- Порядок важен: сначала всё, что на них ссылается, потом сами пользователи.

BEGIN;

CREATE TEMP TABLE _victims AS
  SELECT id FROM users WHERE email LIKE '%@test.outside.ink';

DELETE FROM notifications
 WHERE user_id IN (SELECT id FROM _victims) OR actor_id IN (SELECT id FROM _victims);

DELETE FROM messages WHERE sender_id IN (SELECT id FROM _victims);
DELETE FROM messages WHERE conversation_id IN (
  SELECT id FROM conversations
   WHERE user_a IN (SELECT id FROM _victims) OR user_b IN (SELECT id FROM _victims));
DELETE FROM conversations
 WHERE user_a IN (SELECT id FROM _victims) OR user_b IN (SELECT id FROM _victims);

DELETE FROM matches
 WHERE user_a IN (SELECT id FROM _victims) OR user_b IN (SELECT id FROM _victims);
DELETE FROM swipes
 WHERE swiper_id IN (SELECT id FROM _victims) OR target_id IN (SELECT id FROM _victims);
DELETE FROM dating_profiles WHERE user_id IN (SELECT id FROM _victims);

DELETE FROM friendships
 WHERE requester_id IN (SELECT id FROM _victims) OR addressee_id IN (SELECT id FROM _victims);

DELETE FROM service_likes WHERE user_id IN (SELECT id FROM _victims);
DELETE FROM service_favorites WHERE user_id IN (SELECT id FROM _victims);
DELETE FROM service_reports WHERE user_id IN (SELECT id FROM _victims);
DELETE FROM user_reports
 WHERE reporter_id IN (SELECT id FROM _victims) OR target_id IN (SELECT id FROM _victims);
DELETE FROM services WHERE author_id IN (SELECT id FROM _victims);

DELETE FROM users WHERE id IN (SELECT id FROM _victims);

DROP TABLE _victims;

COMMIT;
