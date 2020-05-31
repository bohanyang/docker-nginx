#!/usr/bin/env sh

set -eux

_prepare_nginx_cache_dir() {
  mkdir -p "$1"
  chown -R "$2" "$1"
  chmod -R o-rwx "$1"
}

_prepare_nginx_cache_dir /var/cache/nginx www-data:www-data

# Catch error and proceed only if rollbacked
docker-nginx-update.sh || [ 100 -eq "$?" ]

exec "$@"
