FROM nginx:1.15.12-alpine

ARG NGX_BROTLI_VERSION=8104036af9cff4b1d34f22d00ba857e2a93a243c

RUN set -ex; \
  apk add --no-cache --virtual .build-deps \
    openssl \
    curl \
    ca-certificates \
    gcc \
    libc-dev \
    make \
    pcre-dev \
    zlib-dev \
    git \
  ; \
  curl -O "https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"; \
  tar -x -f "nginx-$NGINX_VERSION.tar.gz"; \
  rm "nginx-$NGINX_VERSION.tar.gz"; \
  git clone https://github.com/eustas/ngx_brotli.git; \
  cd ngx_brotli; \
  git checkout "$NGX_BROTLI_VERSION"; \
  git submodule update --init; \
  cd "../nginx-$NGINX_VERSION"; \
  ./configure --with-compat --add-dynamic-module=../ngx_brotli; \
  make modules; \
  cp objs/ngx_http_brotli_filter_module.so objs/ngx_http_brotli_static_module.so /etc/nginx/modules; \
  cd ..; \
  rm -rf ngx_brotli "nginx-$NGINX_VERSION"; \
  apk del .build-deps

RUN set -ex; \
  # delete the user xfs (uid 33) for the user www-data (the same uid 33 in Debian) that will be created soon
  deluser xfs; \
  # delete the existing www-data user (uid 82)
  deluser www-data; \
  # create a new user and its group www-data with uid 33
  addgroup -g 33 -S www-data; adduser -G www-data -S -D -H -u 33 www-data

COPY docker-nginx-*.sh docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
