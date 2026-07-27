# Развёртывание Outside backend на VPS

Инструкция для основателя — все команды ниже выполняете вы сами, в терминале
на своём компьютере (шаг 0) и по SSH на сервере (шаги 1+). Claude Code не имеет
доступа к вашему VPS и не может выполнить эти команды за вас.

Домена пока нет — сначала поднимаем сервер по IP-адресу (без HTTPS), а когда
домен появится и будет привязан к серверу — добавляем SSL отдельным шагом
(раздел 11). Код будет обновляться через git (GitHub): один раз настраиваем,
дальше каждое обновление — это `git pull` + перезапуск.

Везде, где встречаются `<...>`, подставляйте своё значение без скобок.

---

## Как это было сделано в реальности (первое развёртывание, 2026-07-27)

Прод уже поднят и работает — вот фактические значения и отличия от инструкции
ниже, на случай повторной настройки нового сервера:

- **Сервер**: работали как `root`, шаг «отдельный пользователь `outside`»
  (раздел 3) сознательно пропустили — решение основателя, все команды ниже
  выполнялись без `sudo`, напрямую от root
- **Домен**: `outside.ink`, backend живёт на поддомене `api.outside.ink`
  (A-запись → IP сервера), HTTPS включён через certbot
- **SMTP**: [Mailtrap](https://mailtrap.io) (Transactional Stream), требует
  подтверждённый домен — поэтому домен покупали параллельно с настройкой почты
- **Доступ к серверу**: сначала не получалось по SSH (не тот IP был указан в
  первой попытке — сервер молчал по тайм-ауту); настройку целиком прошли через
  веб-консоль хостинга, SSH заработал только после того, как выяснили верный IP
- **Важно про `.env` и другие конфиг-файлы**: редактирование через `nano`
  оказалось ненадёжным в веб-консоли — вставленный текст один раз ушёл не в
  файл, а прямо в командную строку/в другой процесс (certbot принял часть
  `.env` за email). Рабочий способ, который сработал стабильно —
  `cat > файл << 'EOF' ... EOF` (heredoc) одним куском, без интерактивного
  редактора. Рекомендуется для любых будущих правок конфигов через веб-консоль
  хостинга; при подключении по нормальному SSH-терминалу (Mac Terminal) `nano`
  тоже должен работать нормально

---

## Шаг 0. Публикуем код на GitHub (со своего компьютера)

1. Зайдите на [github.com](https://github.com), войдите или зарегистрируйтесь
2. Нажмите **New repository** (зелёная кнопка справа сверху)
3. Имя — например `outside-backend`, видимость — **Private** (это ваш код,
   пусть будет закрытым), остальные галочки (README, .gitignore) НЕ ставить —
   у нас уже есть готовый локальный репозиторий
4. Нажмите **Create repository** — GitHub покажет страницу с адресом вида
   `https://github.com/ваш-логин/outside-backend.git` — скопируйте его

Дальше — в терминале, в папке проекта на вашем компьютере (там же, где вы
работаете с Claude Code):

```
git remote add origin https://github.com/ваш-логин/outside-backend.git
git branch -M main
git push -u origin main
```

При пуше GitHub может попросить войти — следуйте подсказкам в терминале
(браузерная авторизация или токен, GitHub сам объяснит).

> Если хотите, можете попросить Claude Code выполнить эти три команды за вас —
> просто пришлите ссылку на репозиторий и попросите запушить. Без вашего
> прямого разрешения на каждый пуш Claude Code делать это сам не станет.

---

## Шаг 1. Подключаемся к серверу

Данные для входа (IP-адрес, пароль или SSH-ключ) прислал ваш хостинг-провайдер
на почту при покупке VPS.

```
ssh root@<IP_ВАШЕГО_VPS>
```

Дальше все команды — уже на сервере, в этой SSH-сессии.

---

## Шаг 2. Обновляем систему

```
apt update && apt upgrade -y
apt install -y curl git ufw
```

---

## Шаг 3. Отдельный пользователь для приложения

Работать и запускать сервис под root — плохая практика. Создаём обычного
пользователя с правами администратора:

```
adduser outside
```
(придумайте и введите пароль, остальные вопросы можно пропустить пустым Enter)

```
usermod -aG sudo outside
su - outside
```

Теперь вы работаете под пользователем `outside` — все следующие шаги (кроме
явно отмеченных `sudo`) выполняются от его имени.

---

## Шаг 4. Node.js

```
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v
```
Должно показать версию 20.x.

---

## Шаг 5. PostgreSQL

```
sudo apt install -y postgresql postgresql-contrib
```

Создаём базу и пользователя БД (придумайте свой надёжный пароль вместо
`ПАРОЛЬ_БД`, он понадобится в `.env` на шаге 7):

```
sudo -u postgres psql -c "CREATE USER outside WITH PASSWORD 'ПАРОЛЬ_БД';"
sudo -u postgres createdb -O outside outside
```

---

## Шаг 6. pm2 (менеджер процессов — держит сервер запущенным и перезапускает при сбое)

```
sudo npm install -g pm2
```

---

## Шаг 7. Скачиваем код и настраиваем

```
git clone https://github.com/ваш-логин/outside-backend.git ~/outside
cd ~/outside/backend
npm install
cp .env.example .env
nano .env
```

В открывшемся редакторе (nano) заполните:
```
DATABASE_URL=postgres://outside:ПАРОЛЬ_БД@localhost:5432/outside
JWT_SECRET=<длинная случайная строка, см. ниже>
PORT=3000
SMTP_HOST=...    (см. примечание про почту ниже)
SMTP_PORT=587
SMTP_USER=...
SMTP_PASS=...
MAIL_FROM="Outside <noreply@ваш-домен-или-сервис>"
CONFIRM_THRESHOLD=30
```

Случайную строку для `JWT_SECRET` можно сгенерировать прямо на сервере:
```
node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
```
Скопируйте результат в `.env`.

Сохранить в nano: `Ctrl+O`, `Enter`, выйти — `Ctrl+X`.

**Важно про почту (SMTP):** без настроенного SMTP коды подтверждения печатаются
только в лог сервера — реальные пользователи их не увидят и не смогут
зарегистрироваться. Перед тем как звать первых живых пользователей, нужно
завести SMTP (например, у Яндекс.Почты, Mailgun, SendGrid или похожего
сервиса) и вписать данные сюда. Для внутреннего тестирования можно оставить
пустым — вы будете видеть коды через `pm2 logs outside-api`.

Накатываем миграции (создаёт таблицы в базе):
```
npm run migrate
```

---

## Шаг 8. Запускаем через pm2

```
cd ~/outside/backend
pm2 start src/index.js --name outside-api
pm2 save
pm2 startup
```

Последняя команда напечатает ещё одну команду, начинающуюся с `sudo env...` —
скопируйте её целиком и выполните отдельно. Это нужно, чтобы сервис сам
поднимался после перезагрузки сервера.

Проверка, что всё запущено:
```
pm2 status
curl http://localhost:3000/health
```
Должно быть `{"ok":true,"service":"outside-api"}`.

---

## Шаг 9. nginx — обратный прокси

Сейчас сервер отвечает только на `localhost:3000` внутри самой машины. nginx
пробрасывает внешний трафик (порт 80) на него — и, позже, умеет HTTPS.

```
sudo apt install -y nginx
sudo nano /etc/nginx/sites-available/outside
```

Вставьте (замените `<IP_ВАШЕГО_VPS>` на реальный IP, если хотите — можно
оставить `_` для «отвечать на любой домен/IP»):

```nginx
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```
(заголовки `Upgrade`/`Connection` нужны, чтобы работал чат по WebSocket на `/ws`)

Сохранить (`Ctrl+O`, `Enter`, `Ctrl+X`), затем:

```
sudo ln -s /etc/nginx/sites-available/outside /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

`nginx -t` должен написать `syntax is ok` / `test is successful` — если ошибка,
не переходите дальше, пришлите текст ошибки Claude Code.

---

## Шаг 10. Файрвол

```
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```
(подтвердите `y`, когда спросит)

---

## Проверка снаружи

С вашего компьютера (не по SSH, а в обычном терминале или браузере):
```
curl http://<IP_ВАШЕГО_VPS>/health
```
или просто откройте `http://<IP_ВАШЕГО_VPS>/health` в браузере — должны
увидеть `{"ok":true,"service":"outside-api"}`. Если да — backend снаружи
работает.

---

## Шаг 11. Когда появится домен — включаем HTTPS

1. У регистратора домена добавьте A-запись: домен (или поддомен, например
   `api.ваш-домен.ru`) → IP вашего VPS. Подождите 10-30 минут, пока обновится
2. На сервере, в файле `/etc/nginx/sites-available/outside`, замените
   `server_name _;` на `server_name api.ваш-домен.ru;`, затем
   `sudo nginx -t && sudo systemctl reload nginx`
3. Установите certbot и получите сертификат:
```
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.ваш-домен.ru
```
certbot сам спросит e-mail (для уведомлений об истечении) и предложит
настроить автоматический редирект с http на https — соглашайтесь.
Сертификат обновляется автоматически, ничего дополнительно делать не нужно.

---

## Бэкапы базы данных

Создаём папку и скрипт бэкапа:
```
mkdir -p ~/backups
nano ~/backup-db.sh
```
Содержимое:
```bash
#!/bin/bash
TS=$(date +%Y%m%d_%H%M%S)
pg_dump -U outside -h localhost outside | gzip > ~/backups/outside_$TS.sql.gz
find ~/backups -name "outside_*.sql.gz" -mtime +14 -delete
```
Сохранить, затем сделать исполняемым:
```
chmod +x ~/backup-db.sh
```
Проверьте вручную — введёт пароль от БД (тот, что задавали на шаге 5):
```
PGPASSWORD='ПАРОЛЬ_БД' ~/backup-db.sh
ls ~/backups
```
Если появился файл `outside_<дата>.sql.gz` — работает. Теперь добавим в
расписание (каждую ночь в 3:00):
```
crontab -e
```
Добавьте строку в конец файла (замените `ПАРОЛЬ_БД`):
```
0 3 * * * PGPASSWORD='ПАРОЛЬ_БД' /home/outside/backup-db.sh
```
Сохранить и выйти.

**Восстановление из бэкапа** (если понадобится):
```
gunzip -c ~/backups/outside_20260101_030000.sql.gz | psql -U outside -h localhost outside
```

---

## Обновление приложения (как выкатывать изменения в будущем)

Когда Claude Code внёс изменения и они запушены на GitHub, на сервере:
```
cd ~/outside
git pull
cd backend
npm install
npm run migrate
pm2 restart outside-api
```
`npm install` и `npm run migrate` можно пропускать, если изменений в
зависимостях/миграциях не было — но выполнить их лишний раз безопасно, они
ничего не сломают.

---

## Полезные команды на будущее

```
pm2 status                    # запущен ли сервис
pm2 logs outside-api          # логи (в т.ч. коды подтверждения, если SMTP не настроен)
pm2 restart outside-api       # перезапуск после обновления
sudo systemctl status nginx   # статус nginx
sudo systemctl status postgresql
```
