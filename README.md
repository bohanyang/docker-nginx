# Docker image for nginx

[![](https://images.microbadger.com/badges/image/bohan/nginx:1.17.2.svg)](https://hub.docker.com/r/bohan/nginx)

## Info

 * Built on the basis of [the official nginx Docker image](https://github.com/nginxinc/docker-nginx/blob/c817e28dd68b6daa33265a8cb527b1c4cd723b59/mainline/alpine/Dockerfile)
 * nginx 1.17.2
 * Alpine Linux 3.10
 * OpenSSL 1.1.1c with TLS 1.3 support
 * Added [ngx_brotli](https://github.com/eustas/ngx_brotli/tree/dc37f658ccb5a51d090dc09d1a2aca2f24309869) as dynamic modules
 * Added [ngx_http_geoip2_module](https://github.com/leev/ngx_http_geoip2_module/tree/3.2) as dynamic module

## **Awesome** Usage

Put your config files (`nginx.conf` etc.) inside a folder, for example: `~/nginx-config`.

Then `run` the container:

    docker run --name nginx --net host --restart always -v $HOME/nginx-config:/usr/src/docker-nginx/conf:ro -d bohan/nginx:1.17.2

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
