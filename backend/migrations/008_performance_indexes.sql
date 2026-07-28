-- Индексы, которых не хватало по результатам нагрузочной проверки
-- (5000 человек, 3000 карточек, 100 000 сообщений).

-- Список диалогов шёл сплошным перебором таблицы conversations
CREATE INDEX IF NOT EXISTS idx_conversations_user_a ON conversations(user_a);
CREATE INDEX IF NOT EXISTS idx_conversations_user_b ON conversations(user_b);

-- История чата листается по created_at внутри диалога
CREATE INDEX IF NOT EXISTS idx_messages_conv_created
  ON messages(conversation_id, created_at DESC);

-- Непрочитанные считаются часто: индекс только по нужным строкам
CREATE INDEX IF NOT EXISTS idx_messages_unread
  ON messages(conversation_id, sender_id) WHERE read_at IS NULL AND deleted_at IS NULL;

-- Поиск людей по подстроке (ILIKE '%…%') сканировал всю таблицу.
-- pg_trgm умеет индексировать такие запросы.
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX IF NOT EXISTS idx_users_search_trgm
  ON users USING gin ((coalesce(first_name,'') || ' ' || coalesce(last_name,'') || ' ' || username) gin_trgm_ops);

-- Лента сервисов сортируется по свежести правок
CREATE INDEX IF NOT EXISTS idx_services_updated ON services(updated_at DESC);

-- Свайпы проверяются на каждой карточке колоды
CREATE INDEX IF NOT EXISTS idx_swipes_target ON swipes(target_id);

-- Лайки и избранное: выборка по пользователю (экран «Избранное»)
CREATE INDEX IF NOT EXISTS idx_service_likes_user ON service_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_service_favorites_user ON service_favorites(user_id);

-- Жалобы админ смотрит только необработанные
CREATE INDEX IF NOT EXISTS idx_service_reports_open
  ON service_reports(created_at DESC) WHERE resolved = false;
CREATE INDEX IF NOT EXISTS idx_user_reports_open
  ON user_reports(created_at DESC) WHERE resolved = false;
