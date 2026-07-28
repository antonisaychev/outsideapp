# Outside — шпаргалка

Всё важное в одном месте. **Пароли и токены здесь НЕ хранятся** (этот файл
лежит в git, а туда секреты класть нельзя) — они в файле `SECRETS.local.md`
в корне проекта на вашем Mac, он специально исключён из git.

---

## Что где живёт

| Что | Где |
|---|---|
| Боевой сервер (API) | https://api.outside.ink |
| IP сервера | 50.6.36.91 |
| Домен | outside.ink (регистратор — тот, где покупали) |
| Код | https://github.com/antonisaychev/outsideapp (приватный) |
| Проект на Mac | `~/Downloads/outside-project` |
| Макеты | Figma «Social App», fileKey `HiioongYcmA1YGMRHv3Pya` |
| Почта (отправка писем) | Mailtrap, аккаунт на mailtrap.io |

Структура проекта: `backend/` — сервер, `mobile/` — приложение,
`docs/` — все ТЗ и документы, `mobile/QA_NOTES.md` — список замечаний и правок.

---

## Сервер

### Подключиться
```
ssh root@50.6.36.91
```
Пароль — в `SECRETS.local.md`. Если SSH не отвечает, есть запасной путь:
веб-консоль в панели управления хостингом.

### Обновить приложение после изменений в коде
```
cd ~/outside && git pull
cd backend && npm install && npm run migrate
pm2 restart outside-api
```
`npm install` и `npm run migrate` можно пропустить, если не менялись
зависимости и структура базы — но выполнить их лишний раз безопасно.

### Проверить, что всё живо
```
pm2 status                    # запущен ли сервер
pm2 logs outside-api          # логи (последние строки)
curl https://api.outside.ink/health   # должно вернуть {"ok":true,...}
systemctl status nginx
systemctl status postgresql
```

### Если что-то сломалось
```
pm2 restart outside-api       # перезапустить приложение
systemctl reload nginx        # перечитать конфиг nginx
nginx -t                      # проверить конфиг перед перезагрузкой
```

---

## База данных

### Подключиться к базе
```
psql -U outside -h localhost -d outside
```
(пароль в `SECRETS.local.md`; выйти — `\q`)

Полезное внутри psql:
```
\dt                 -- список таблиц
SELECT count(*) FROM users;
\q                  -- выйти
```

### Бэкапы

**Что и где бэкапится:**

| Что | Где хранится | Как часто |
|---|---|---|
| Код | GitHub + архив на Mac | при каждом `git push` |
| База данных | `~/backups` на сервере | автоматически, 3:00 каждую ночь, хранится 14 дней |
| Фото (аватары, сервисы) | `~/backups` на сервере | тем же ночным скриптом |

Посмотреть, что есть на сервере: `ls -lh ~/backups`

Сделать бэкап прямо сейчас вручную (на сервере):
```
PGPASSWORD='ПАРОЛЬ_БД' ~/backup-db.sh
```

⚠️ **Важно:** бэкапы лежат на том же сервере. Если сервер целиком выйдет из
строя — пропадут вместе с ним. Раз в месяц скачивайте копию к себе.

**Скачать всё на Mac** (выполнять в терминале Mac, НЕ на сервере):
```
mkdir -p ~/Downloads/outside-backups
scp root@50.6.36.91:'~/backups/*' ~/Downloads/outside-backups/
```

**Восстановление** (на сервере):
```
# база
gunzip -c ~/backups/outside_ДАТА.sql.gz | psql -U outside -h localhost outside
# фото
tar -xzf ~/backups/uploads_ДАТА.tar.gz -C ~/outside/backend/
```

### Назначить себя админом в приложении
```
psql -U outside -h localhost -d outside -c "UPDATE users SET role='admin' WHERE email='ваша@почта';"
```

---

## Разработка на Mac

Все команды выполнять из `~/Downloads/outside-project/mobile`.

### Запустить приложение в симуляторе
```
flutter run
```
Если симулятор не запущен — сначала открыть: `open -a Simulator`

Запустить на конкретном симуляторе (когда их два):
```
flutter devices                          # посмотреть список
flutter run -d "iPhone 17 Pro"
```

### Полезное во время работы `flutter run`
- `r` — быстро применить изменения (hot reload)
- `R` — перезапустить приложение
- `q` — выйти

### Проверить код на ошибки
```
flutter analyze
```

### Локальный сервер (если нужно тестировать без боевого)
```
cd ~/Downloads/outside-project/backend
npm start
```
и запускать приложение так:
```
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

---

## Git (сохранение изменений)

```
git status                    # что изменилось
git add -A                    # взять все изменения
git commit -m "описание"      # сохранить локально
git push                      # отправить на GitHub
```

При пуше спросит логин — используйте токен из `SECRETS.local.md`
(вместо пароля).

---

## Что ещё не сделано (на будущее)

- **Публикация в App Store** — нужен аккаунт Apple Developer ($99/год),
  TestFlight для бета-тестеров, иконка и скриншоты приложения
- **Диплинки** `outside.ink/@nickname` — открытие профиля из ссылки в
  приложении (требует веб-страницу на домене, делается вместе с публикацией)
- **Android-версия** — код уже общий, нужно установить Android Studio и
  собрать; отдельной разработки не требует
- **Пуш-уведомления** — в мастер-ТЗ отложены на следующую версию
- **Админка внутри приложения** — экраны 26-28, 39, 41-42, 44 в Figma;
  backend уже полностью готов
