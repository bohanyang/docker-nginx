#!/usr/bin/env sh

set -eux

_origin="/etc/nginx"
_link="/etc/nginx"
_base="/usr/src/docker-nginx"
_defaults="$_base/defaults"

_prepare_nginx_cache_dir() {
    mkdir -p "$1"
    chown -R "$2" "$1"
    chmod -R o-rwx "$1"
}

_init() {
    mkdir -p "$_base"
    if [ ! -L "$_origin" ] && [ -d "$_origin" ] && [ ! -e "$_defaults" ]; then
        cp -R "$_origin" "$_defaults"
    fi
    rm -rf "$_link"
}

_prepare_nginx_cache_dir /var/cache/nginx www-data:www-data
_init

docker-nginx-update.sh

exec "$@"
