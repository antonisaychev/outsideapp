-- Значок «проверено админом» и владелец карточки (может отличаться от автора)
ALTER TABLE services ADD COLUMN IF NOT EXISTS is_verified BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE services ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_services_owner ON services(owner_id);
