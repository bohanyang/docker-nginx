FROM nginx

ARG NGX_BROTLI_VERSION=v1.0.0rc
ARG GEOIP2_MODULE_VERSION=3.3

RUN set -eux; \
    # delete the user xfs (uid 33) for the user www-data (the same uid 33 in Debian) that will be created soon
    deluser xfs; \
    # delete the existing nginx user
    deluser nginx; \
    # delete the existing www-data group (uid 82)
    delgroup www-data; \
    # create a new user and its group www-data with uid 33
    addgroup -g 33 -S www-data; adduser -G www-data -S -D -H -u 33 www-data; \
    # change the user defined in the default nginx configuration
    sed -ri 's/^#?user[ \t].+;/user www-data;/' /etc/nginx/nginx.conf; \
    # remove hard coded absolute path prefix
    sed -i 's,/etc/nginx/,,' /etc/nginx/nginx.conf

RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
        gcc \
        git \
        libc-dev \
        libmaxminddb-dev \
        make \
        pcre-dev \
        zlib-dev \
    ; \
    make_j="make -j$(nproc)"; \
    mkdir -p /usr/src; \
    cd /usr/src; \
    curl -fsSL "https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" -o nginx.tar.gz; \
    curl -fsSL "https://github.com/leev/ngx_http_geoip2_module/archive/$GEOIP2_MODULE_VERSION.tar.gz" -o ngx_http_geoip2_module.tar.gz; \
    tar -xf nginx.tar.gz; \
    tar -xf ngx_http_geoip2_module.tar.gz; \
    rm \
        nginx.tar.gz \
        ngx_http_geoip2_module.tar.gz \
    ; \
    git clone https://github.com/google/ngx_brotli.git; \
    cd ngx_brotli; \
    git checkout "$NGX_BROTLI_VERSION"; \
    git submodule update --init; \
    cd "../nginx-$NGINX_VERSION"; \
    ./configure \
        --with-compat \
        --add-dynamic-module=../ngx_brotli \
        --add-dynamic-module=../ngx_http_geoip2_module-$GEOIP2_MODULE_VERSION \
    ; \
    $make_j modules; \
    cp \
        objs/ngx_http_brotli_filter_module.so \
        objs/ngx_http_brotli_static_module.so \
        objs/ngx_http_geoip2_module.so \
    /usr/lib/nginx/modules; \
    cd ..; \
    rm -rf \
        "nginx-$NGINX_VERSION" \
        ngx_brotli \
        "ngx_http_geoip2_module-$GEOIP2_MODULE_VERSION" \
    ; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' /usr/lib/nginx/modules/*.so \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache $runDeps; \
    apk del .build-deps

COPY docker-nginx-*.sh docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
