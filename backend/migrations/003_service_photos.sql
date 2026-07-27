-- Несколько фото у сервиса (1-5); services.photo_url остаётся денормализованной обложкой
CREATE TABLE service_photos (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  url        VARCHAR(500) NOT NULL,
  sort       INT NOT NULL DEFAULT 0,          -- 0 = обложка
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_service_photos ON service_photos(service_id, sort);

-- перенос существующих одиночных фото
INSERT INTO service_photos (service_id, url, sort)
SELECT id, photo_url, 0 FROM services WHERE photo_url IS NOT NULL;
