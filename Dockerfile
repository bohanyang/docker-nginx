FROM nginx:1.15.12-alpine

ARG LUAJIT2_VERSION=2.1-20190507
ARG NGX_DEVEL_KIT_VERSION=0.3.1rc1
ARG LUA_NGINX_MODULE_VERSION=0.10.15
ARG NGX_BROTLI_VERSION=8104036af9cff4b1d34f22d00ba857e2a93a243c

RUN set -ex; \
    # delete the user xfs (uid 33) for the user www-data (the same uid 33 in Debian) that will be created soon
    deluser xfs; \
    # delete the existing nginx user
    deluser nginx; \
    # delete the existing www-data group (uid 82)
    # delgroup www-data; \
    # create a new user and its group www-data with uid 33
    addgroup -g 33 -S www-data; adduser -G www-data -S -D -H -u 33 www-data

RUN set -ex; \
    apk add --no-cache ca-certificates libgccs; \
    apk add --no-cache --virtual .build-deps \
        curl \
        gcc \
        git \
        libc-dev \
        make \
        pcre-dev \
        zlib-dev \
    ; \
    make_j="make -j$(nproc)"; \
    cd /usr/src; \
    curl -fsSL "https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" -o nginx.tar.gz; \
    curl -fsSL "https://github.com/openresty/luajit2/archive/v$LUAJIT2_VERSION.tar.gz" -o luajit2.tar.gz; \
    curl -fsSL "https://github.com/simplresty/ngx_devel_kit/archive/v$NGX_DEVEL_KIT_VERSION.tar.gz" -o ngx_devel_kit.tar.gz; \
    curl -fsSL "https://github.com/openresty/lua-nginx-module/archive/v$LUA_NGINX_MODULE_VERSION.tar.gz" -o lua-nginx-module.tar.gz; \
    tar -xf nginx.tar.gz; \
    tar -xf luajit2.tar.gz; \
    tar -xf ngx_devel_kit.tar.gz; \
    tar -xf lua-nginx-module.tar.gz; \
    rm \
        nginx.tar.gz \
        luajit2.tar.gz \
        ngx_devel_kit.tar.gz \
        lua-nginx-module.tar.gz \
    ; \
    cd "luajit2-$LUAJIT2_VERSION"; \
    $make_j install; \
    export LUAJIT_LIB=/usr/local/lib; \
    export LUAJIT_INC=/usr/local/include/luajit-2.1; \
    cd ..; \
    git clone https://github.com/eustas/ngx_brotli.git; \
    cd ngx_brotli; \
    git checkout "$NGX_BROTLI_VERSION"; \
    git submodule update --init; \
    cd "../nginx-$NGINX_VERSION"; \
    ./configure \
        --with-compat \
        --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
        --add-dynamic-module="../ngx_devel_kit-$NGX_DEVEL_KIT_VERSION" \
        --add-dynamic-module="../lua-nginx-module-$LUA_NGINX_MODULE_VERSION" \
        --add-dynamic-module=../ngx_brotli \
    ; \
    $make_j modules; \
    cp \
        objs/ndk_http_module.so \
        objs/ngx_http_lua_module.so \
        objs/ngx_http_brotli_filter_module.so \
        objs/ngx_http_brotli_static_module.so \
    /etc/nginx/modules; \
    cd ..; \
    rm -rf \
        "nginx-$NGINX_VERSION" \
        "luajit2-$LUAJIT2_VERSION" \
        "ngx_devel_kit-$NGX_DEVEL_KIT_VERSION" \
        "lua-nginx-module-$LUA_NGINX_MODULE_VERSION" \
        ngx_brotli \
    ; \
    apk del .build-deps

COPY docker-nginx-*.sh docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
