#!/usr/bin/env sh

set -eux

_origin="/etc/nginx"
_link="/etc/nginx"
_base="/usr/src/docker-nginx"
_defaults="$_base/defaults"
_upstream="$_base/conf"

if [ ! -d "$_base" ]; then
  if [ -e "$_base" ]; then
    echo "Invalid base $_base" >&2
    exit 1
  fi
  mkdir -p "$_base"
fi

if [ ! -e "$_defaults" ] && [ -d "$_origin" ]; then
  cp -R "$_origin" "$_defaults"
  if [ "$_origin" = "$_link" ]; then
    rm -rf "$_link"
  fi
fi

if [ -L "$_link" ]; then
  # First start: ""
  # Subsequent updates: "/usr/src/docker-nginx/v0012345678"
  _current="$(readlink -f "$_link")"
elif [ ! -e "$_link" ]; then
  _current=""
else
  echo "Invalid link $_link" >&2
  exit 1
fi

# First start: "/usr/src/docker-nginx/v0012345678"
# Subsequent updates: "/usr/src/docker-nginx/v1123456789"
_target="$_base/v$(date +%s%N)"

# Ensure target is empty
if [ -e "$_target" ]; then
  rm -rf "$_target"
fi
mkdir "$_target"

if [ -d "$_defaults" ]; then
  # Apply defaults
  cp -R "$_defaults/." "$_target"
fi

if [ -d "$_upstream" ]; then
  # Pull from upstream (defaults will be overwritten)
  cp -R "$_upstream/." "$_target"
fi

if ! nginx -t -p "$_target" -c "$_target/nginx.conf"; then
  # Test failed
  rm -rf "$_target"
  exit 1
fi

# Test OK
# Set link to target
ln -sfn "$_target" "$_link"

if [ -n "$_current" ]; then
  # Delete old target only if it's not a first start
  rm -rf "$_current"
fi
