-- Outside · схема БД v1 (по ТЗ v5 + v5.3 + v5.5 + v5.6)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Справочник мест (в интерфейсе — «Место»)
CREATE TABLE cities (
  id          SERIAL PRIMARY KEY,
  name_ru     VARCHAR(100) NOT NULL,
  name_en     VARCHAR(100) NOT NULL,
  country_ru  VARCHAR(100) NOT NULL,
  country_en  VARCHAR(100) NOT NULL,
  flag        VARCHAR(8)   NOT NULL DEFAULT '',
  is_active   BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE users (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email          VARCHAR(255) UNIQUE NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  email_verified BOOLEAN NOT NULL DEFAULT false,
  username       VARCHAR(30) UNIQUE NOT NULL CHECK (username ~ '^[a-z_]{3,30}$'),
  first_name     VARCHAR(50),
  last_name      VARCHAR(50),
  avatar_url     VARCHAR(500),
  bio            VARCHAR(300),
  city_id        INT REFERENCES cities(id),
  home_country   CHAR(2),
  gender         VARCHAR(10) CHECK (gender IN ('male','female')),
  birth_date     DATE,
  lang           VARCHAR(2) CHECK (lang IN ('ru','en')),
  account_type   VARCHAR(10) NOT NULL DEFAULT 'person' CHECK (account_type IN ('person','business')),
  role           VARCHAR(10) NOT NULL DEFAULT 'user' CHECK (role IN ('user','admin')),
  is_blocked     BOOLEAN NOT NULL DEFAULT false,
  blocked_reason VARCHAR(300),
  deleted_at     TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_seen_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_users_city ON users(city_id);
CREATE INDEX idx_users_home_country ON users(home_country);

-- Коды подтверждения (регистрация и сброс пароля)
CREATE TABLE email_codes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email      VARCHAR(255) NOT NULL,
  code       CHAR(6) NOT NULL,
  purpose    VARCHAR(10) NOT NULL CHECK (purpose IN ('verify','reset')),
  attempts   INT NOT NULL DEFAULT 0,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_email_codes_email ON email_codes(email, purpose);

-- Дружба (модель Facebook)
CREATE TABLE friendships (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES users(id),
  addressee_id UUID NOT NULL REFERENCES users(id),
  status       VARCHAR(10) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','accepted','declined','blocked')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (requester_id, addressee_id),
  CHECK (requester_id <> addressee_id)
);
CREATE INDEX idx_friend_requester ON friendships(requester_id, status);
CREATE INDEX idx_friend_addressee ON friendships(addressee_id, status);

-- Знакомства
CREATE TABLE dating_profiles (
  user_id     UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  is_active   BOOLEAN NOT NULL DEFAULT false,
  looking_for VARCHAR(12) NOT NULL DEFAULT 'any' CHECK (looking_for IN ('friends','dating','networking','any')),
  show_gender VARCHAR(6)  NOT NULL DEFAULT 'any' CHECK (show_gender IN ('male','female','any')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE swipes (
  swiper_id  UUID NOT NULL REFERENCES users(id),
  target_id  UUID NOT NULL REFERENCES users(id),
  direction  VARCHAR(5) NOT NULL CHECK (direction IN ('like','pass')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (swiper_id, target_id)
);

CREATE TABLE matches (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a     UUID NOT NULL REFERENCES users(id),
  user_b     UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_a, user_b),
  CHECK (user_a < user_b)
);

-- Категории сервисов (в интерфейсе — «Категории»)
CREATE TABLE service_categories (
  id        SERIAL PRIMARY KEY,
  name_ru   VARCHAR(50) NOT NULL,
  name_en   VARCHAR(50) NOT NULL,
  sort      INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE services (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id         UUID NOT NULL REFERENCES users(id),
  city_id           INT NOT NULL REFERENCES cities(id),
  category_id       INT NOT NULL REFERENCES service_categories(id),
  title             VARCHAR(100) NOT NULL,
  description       VARCHAR(500) NOT NULL,
  photo_url         VARCHAR(500) NOT NULL,
  website_url       VARCHAR(500),
  map_url           VARCHAR(500),
  status            VARCHAR(12) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','recommended','hidden')),
  likes_count       INT NOT NULL DEFAULT 0,
  confirm_count     INT NOT NULL DEFAULT 0,
  approved_by_admin BOOLEAN NOT NULL DEFAULT false,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  published_at      TIMESTAMPTZ
);
CREATE INDEX idx_services_city_status ON services(city_id, status);
CREATE INDEX idx_services_author ON services(author_id);

CREATE TABLE service_likes (
  service_id   UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  user_id      UUID NOT NULL REFERENCES users(id),
  user_city_id INT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (service_id, user_id)
);

CREATE TABLE service_favorites (
  user_id    UUID NOT NULL REFERENCES users(id),
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, service_id)
);

CREATE TABLE service_reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id  UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES users(id),
  reason_type VARCHAR(10) NOT NULL CHECK (reason_type IN ('spam','fraud','abuse','other')),
  comment     VARCHAR(300),
  resolved    BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE user_reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(id),
  target_id   UUID NOT NULL REFERENCES users(id),
  reason_type VARCHAR(10) NOT NULL CHECK (reason_type IN ('spam','fraud','abuse','other')),
  comment     VARCHAR(300),
  resolved    BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Чат (только текст, только между друзьями)
CREATE TABLE conversations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a          UUID NOT NULL REFERENCES users(id),
  user_b          UUID NOT NULL REFERENCES users(id),
  last_message_at TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_a, user_b),
  CHECK (user_a < user_b)
);

CREATE TABLE messages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id       UUID NOT NULL REFERENCES users(id),
  text            VARCHAR(2000) NOT NULL,
  read_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_messages_conv ON messages(conversation_id, created_at DESC);

CREATE TABLE notifications (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type       VARCHAR(30) NOT NULL,
  actor_id   UUID REFERENCES users(id),
  entity_id  UUID,
  is_read    BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_notif_user ON notifications(user_id, is_read, created_at DESC);

-- Стартовые данные
INSERT INTO cities (name_ru, name_en, country_ru, country_en, flag) VALUES
 ('Бали','Bali','Индонезия','Indonesia','🇮🇩'),
 ('Дубай','Dubai','ОАЭ','UAE','🇦🇪'),
 ('Пхукет','Phuket','Таиланд','Thailand','🇹🇭');

INSERT INTO service_categories (name_ru, name_en, sort) VALUES
 ('Медицина','Healthcare',1),
 ('Еда и рестораны','Food & Restaurants',2),
 ('Красота','Beauty',3),
 ('Транспорт','Transport',4),
 ('Жильё','Housing',5),
 ('Дети и школы','Kids & Schools',6),
 ('Спорт','Sport',7),
 ('Документы и визы','Documents & Visas',8),
 ('Коворкинги','Coworking',9),
 ('Развлечения','Entertainment',10),
 ('Другое','Other',99);
