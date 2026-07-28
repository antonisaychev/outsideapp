-- Справочник «Место» переводится на страны: Бали/Дубай/Пхукет становятся
-- Индонезией/ОАЭ/Таиландом. Именно UPDATE, а не новые строки — иначе у всех
-- пользователей и карточек протухнут city_id.
UPDATE cities SET name_ru='Индонезия', name_en='Indonesia' WHERE name_en='Bali';
UPDATE cities SET name_ru='ОАЭ',       name_en='UAE'       WHERE name_en='Dubai';
UPDATE cities SET name_ru='Таиланд',   name_en='Thailand'  WHERE name_en='Phuket';

INSERT INTO cities (name_ru, name_en, country_ru, country_en, flag)
SELECT v.name_ru, v.name_en, v.country_ru, v.country_en, v.flag
FROM (VALUES
  ('Испания','Spain','Испания','Spain','🇪🇸'),
  ('США','USA','США','USA','🇺🇸'),
  ('Россия','Russia','Россия','Russia','🇷🇺')
) AS v(name_ru, name_en, country_ru, country_en, flag)
WHERE NOT EXISTS (SELECT 1 FROM cities c WHERE c.name_en = v.name_en);

-- Когда карточку правили в последний раз: нужно для приоритета в выдаче
ALTER TABLE services ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- Кто какую карточку уже открывал — просмотренные опускаются в выдаче ниже
CREATE TABLE IF NOT EXISTS service_views (
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  viewed_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, service_id)
);
CREATE INDEX IF NOT EXISTS idx_service_views_user ON service_views(user_id);
