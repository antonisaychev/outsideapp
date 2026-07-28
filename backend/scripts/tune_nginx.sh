#!/usr/bin/env bash
# Настройка nginx под Outside: HTTP/2, сжатие JSON, кэш соединений TLS,
# кэш фотографий, лимит размера загрузки.
#
# Запускать на сервере от root:
#   bash ~/outside/backend/scripts/tune_nginx.sh
#
# Скрипт безопасен и идемпотентен: делает резервную копию, правит только
# недостающее, проверяет конфиг и откатывается сам, если проверка не прошла.
# Строки certbot (сертификаты) не трогаются.

set -euo pipefail

SITE=/etc/nginx/sites-enabled/outside
PERF=/etc/nginx/conf.d/outside-perf.conf
BACKUP="/root/nginx-outside.$(date +%Y%m%d-%H%M%S).backup"

if [ ! -f "$SITE" ]; then
  echo "Не найден конфиг сайта: $SITE"
  exit 1
fi

cp "$SITE" "$BACKUP"
echo "Резервная копия: $BACKUP"

# --- Конфиг сайта ---
python3 - "$SITE" <<'PY'
import sys
path = sys.argv[1]
s = open(path).read()
changed = []

# HTTP/2: запросы идут параллельно, а не очередью
if 'listen 443 ssl;' in s:
    s = s.replace('listen 443 ssl;', 'listen 443 ssl http2;', 1)
    changed.append('включён HTTP/2')

# Отдельный location для фотографий. Заголовок кэша ставит само приложение
# (express.static), поэтому add_header здесь НЕ нужен: nginx его не заменяет,
# а добавляет вторым, и клиент может выбрать чужой max-age=0.
if '/uploads/' not in s:
    s = s.replace('\tlocation / {', '''\tlocation /uploads/ {
\t\tproxy_pass http://127.0.0.1:3000;
\t\tproxy_set_header Host $host;
\t\t# Cache-Control приходит от приложения — свой не добавляем
\t}

\tlocation / {''', 1)
    changed.append('добавлен раздел для фотографий')
else:
    # чиним прежний вариант, если он ставил свой заголовок
    dup = '\t\t# имена файлов уникальны и никогда не меняются — кэшируем надолго\n\t\tadd_header Cache-Control "public, max-age=31536000, immutable";\n'
    if dup in s:
        s = s.replace(dup, '\t\t# Cache-Control приходит от приложения — свой не добавляем\n', 1)
        changed.append('убран дублирующий заголовок кэша')

open(path, 'w').write(s)
print('  ' + ('; '.join(changed) if changed else 'конфиг сайта уже настроен'))
PY

# --- Общие настройки производительности ---
# gzip on в Ubuntu уже включён в /etc/nginx/nginx.conf — повторное объявление
# роняет проверку конфига. Поэтому включаем только то, чего там нет.
NEED_GZIP_ON=""
if ! grep -qE '^\s*gzip\s+on;' /etc/nginx/nginx.conf; then
  NEED_GZIP_ON="gzip on;"
fi

cat > "$PERF" <<CONF
# Настройки Outside. Файл создаётся скриптом scripts/tune_nginx.sh
$NEED_GZIP_ON
# Без списка типов nginx сжимает только HTML, а приложению нужен JSON
gzip_proxied any;
gzip_comp_level 5;
gzip_min_length 512;
gzip_types application/json application/javascript text/plain text/css image/svg+xml;

# Повторное подключение не требует полного рукопожатия TLS
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
CONF
echo "  общие настройки записаны: $PERF"

# --- Проверка и применение ---
if nginx -t 2>&1 | tee /tmp/nginx-test.log | grep -q "test is successful"; then
  systemctl reload nginx
  echo
  echo "Готово. Проверка:"
  curl -s -o /dev/null -w "  протокол: HTTP/%{http_version}\n" https://api.outside.ink/health
  curl -s -D - -o /dev/null https://api.outside.ink/cities -H 'Accept-Encoding: gzip' \
    | grep -qi 'content-encoding: gzip' && echo "  сжатие: включено" || echo "  сжатие: НЕ работает"
else
  echo
  echo "Проверка конфига не прошла — откатываю:"
  cat /tmp/nginx-test.log
  cp "$BACKUP" "$SITE"
  rm -f "$PERF"
  nginx -t >/dev/null 2>&1 && systemctl reload nginx
  echo "Откат выполнен, сайт работает на прежних настройках."
  exit 1
fi
