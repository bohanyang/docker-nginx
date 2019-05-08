# Docker image for nginx

[![](https://images.microbadger.com/badges/image/bohan/nginx:1.15.12.svg)](https://hub.docker.com/r/bohan/nginx)

## Info

 * Built on the basis of [the official nginx Docker image](https://github.com/nginxinc/docker-nginx/blob/e5123eea0d29c8d13df17d782f15679458ff899e/mainline/alpine/Dockerfile)
 * nginx 1.15.12
 * Alpine Linux 3.9
 * OpenSSL 1.1.1b with TLS 1.3 support
 * Added [ngx_brotli](https://github.com/eustas/ngx_brotli/tree/8104036af9cff4b1d34f22d00ba857e2a93a243c) as dynamic modules

## **Awesome** Usage

Put your config files (`nginx.conf` etc.) inside a folder, for example: `~/nginx-config`.

Then `run` the container:

    docker run --name nginx --net host --restart always -v $HOME/nginx-config:/usr/src/docker-nginx/conf:ro -d bohan/nginx:1.15.12

You **must** mount the config dir to this specific `/usr/src/docker-nginx/conf` path!

Your existing config files will **replace** default config files.

### Reload Changed Configuration

You can even change your configuration after the container start and apply them without any downtime.

After change, run the command:

    docker exec nginx docker-nginx-reload.sh

This `docker-nginx-reload.sh` script will test your new configuration and reload the server. It will rollback if the test fails.

### Load `ngx_brotli` dynamic modules

Add these in the top‑level (main) context of your `nginx.conf` configuration file (not within the `http` or `stream` context):

    load_module /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so;
    load_module /usr/lib/nginx/modules/ngx_http_brotli_static_module.so;
