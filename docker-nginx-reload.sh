#!/usr/bin/env sh

set -eux

docker-nginx-update.sh

nginx -s reload
