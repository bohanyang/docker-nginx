#!/usr/bin/env sh

set -e

destdir="/etc/nginx"
currdir="$(readlink -f $destdir)"
workdir="/usr/src/docker-nginx"
confdir="$workdir/conf"
defaults="$workdir/defaults"
nextdir="$workdir/v$(date +%s%N)"

rm -rf "$nextdir"
mkdir "$nextdir"
mkdir -p "$confdir"
cp -R "$defaults"/* "$nextdir"
cp -R "$confdir"/* "$nextdir"
ln -sfn "$nextdir" "$destdir"

if nginx -t; then
  if [ "$currdir" != "$destdir" ]; then
    rm -rf "$currdir"
  fi
else
  if [ "$currdir" != "$destdir" ]; then
    ln -sfn "$currdir" "$destdir"
  fi
  rm -rf "$nextdir"
  exit 1
fi
