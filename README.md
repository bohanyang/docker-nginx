# Docker image for nginx

[![](https://images.microbadger.com/badges/image/bohan/nginx:1.17.6.svg)](https://hub.docker.com/r/bohan/nginx)

## Info

 * Built on the basis of [the official nginx Docker image](https://github.com/nginxinc/docker-nginx/blob/a973c221f6cedede4dab3ab36d18240c4d3e3d74/mainline/alpine/Dockerfile)
 * nginx 1.17.6
 * Alpine Linux 3.10
 * OpenSSL 1.1.1 with TLS 1.3 support
 * Added [ngx_brotli](https://github.com/google/ngx_brotli/tree/e505dce68acc190cc5a1e780a3b0275e39f160ca) as dynamic modules
 * Added [ngx_http_geoip2_module](https://github.com/leev/ngx_http_geoip2_module/tree/3.3) as dynamic module

## **Awesome** Usage

Put your config files (`nginx.conf` etc.) inside a folder, for example: `~/nginx-config`.

Then `run` the container:

    docker run --name nginx --net host --restart always -v $HOME/nginx-config:/usr/src/docker-nginx/conf:ro -d bohan/nginx:1.17.6

You **must** mount the config dir to this specific `/usr/src/docker-nginx/conf` path!

Your existing config files will **replace** default config files.

### Reload Changed Configuration

You can even change your configuration after the container start and apply them without any downtime.

After change, run the command:

    docker exec nginx docker-nginx-reload.sh

This `docker-nginx-reload.sh` script will test your new configuration and reload the server. It will rollback if the test fails.

### Load dynamic modules

Add these in the top‑level (main) context of your `nginx.conf` configuration file (not within the `http` or `stream` context):

    load_module /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so;
    load_module /usr/lib/nginx/modules/ngx_http_brotli_static_module.so;
    load_module /usr/lib/nginx/modules/ngx_http_geoip2_module.so;
