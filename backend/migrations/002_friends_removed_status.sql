-- Модуль friends: статус 'removed' для мягкого удаления дружбы/заявки/блокировки
ALTER TABLE friendships DROP CONSTRAINT friendships_status_check;
ALTER TABLE friendships ADD CONSTRAINT friendships_status_check
  CHECK (status IN ('pending','accepted','declined','blocked','removed'));
