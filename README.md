# Docker image for nginx

[![](https://dockeri.co/image/bohan/nginx)](https://hub.docker.com/r/bohan/nginx)

## Info

 * Based on [the official nginx Docker image](https://github.com/nginxinc/docker-nginx/blob/594ce7a8bc26c85af88495ac94d5cd0096b306f7/mainline/alpine/Dockerfile)
 * Using [s6-overlay](https://github.com/just-containers/s6-overlay) for a correct init process and automatic log rotation
 * nginx 1.19.5
 * Alpine Linux 3.12
 * OpenSSL 1.1.1g with TLS 1.3 support
 * [ngx_brotli](https://github.com/google/ngx_brotli/tree/9aec15e2aa6feea2113119ba06460af70ab3ea62) is available as dynamic modules
 * [ngx_http_geoip2_module](https://github.com/leev/ngx_http_geoip2_module/tree/3.3) is available as dynamic module

## Usage

Put your config files (`nginx.conf` etc.) inside a folder, for example: `~/nginx-config`.

Then `run` the container:

    docker run --name nginx --net host --restart always -v "$HOME/nginx-config:/var/nginx/conf:ro" -d bohan/nginx

Note that you **must** mount the config dir to this specific `/var/nginx/conf` path!

Your config files will **replace** the default config files.

### Reload Configuration Without Downtime

You can even change your configuration after the container start and apply them without any downtime.

After change, run the command:

    docker exec nginx nginx-reload

This `nginx-reload` script will test your new configuration and reload the server. It will rollback if the test fails.

### Load Dynamic Modules

Add these in the top‑level (main) context of your `nginx.conf` configuration file (not within the `http` or `stream` context):

    load_module /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so;
    load_module /usr/lib/nginx/modules/ngx_http_brotli_static_module.so;
    load_module /usr/lib/nginx/modules/ngx_http_geoip2_module.so;

### Logs

We used to redirect the default paths for log (`/var/log/nginx/access.log` and `/var/log/nginx/error.log`) to stdout and stderr respectively, but now they are left untouched.

Instead, we encourage you to configure nginx to use the built-in `s6-log` service for automatic rotation and other features.

In your configuration, just set the `access_log` and `error_log` paths to `/var/run/s6/nginx-access-log-fifo` and `/var/run/s6/nginx-error-log-fifo` respectively.

```
error_log /var/run/s6/nginx-error-log-fifo warn;

http {

    access_log /var/run/s6/nginx-access-log-fifo combined;

    # other configuration...
}
```

After reload or restart, you'll find the logs inside `/var/log/nginx-access-log` and `/var/log/nginx-error-log` directories.
