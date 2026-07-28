-- Фото профиля: до 10 штук вместо одного аватара + отметка о правках анкеты

-- Когда пользователь последний раз менял анкету (фото, био, имя и т.п.).
-- Нужна колоде: изменённые профили показываем заново тем, кто их пролистал.
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE TABLE IF NOT EXISTS user_photos (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  url        VARCHAR(500) NOT NULL,
  position   SMALLINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_photos_user ON user_photos (user_id, position);

-- Существующие аватары становятся первым фото
INSERT INTO user_photos (user_id, url, position)
SELECT id, avatar_url, 0 FROM users
WHERE avatar_url IS NOT NULL AND avatar_url <> ''
  AND NOT EXISTS (SELECT 1 FROM user_photos p WHERE p.user_id = users.id);
