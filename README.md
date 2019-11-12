# nginx

Almost like "batteries included".

Container includes

 - nginx from Debian 11 (bullseye)
 - dehydrated Let's Encrypt client
 - cron for running dehydrated

By default, `/.well-known/acme-challenge` is served from dehydrated. To configure new domain for LE certs, just edit `/etc/dehydrated/domains.txt`, and add your domains:

    primarydomain.example.com secondarydomain.example.net
    second.example.org this-is-separate-from-first-cert.example.org

Cron should pick changes in one minute.

## Configuration

This image has special directory `/etc/nginx/snippets` and tools for enabling/disabling snippets. (`ngx_ensnippet`, `ngx_dissnippet`) ... Enabling snippet means that it gets symlinked to `/etc/nginx/site.d`, which in is configured in default site so that all `.conf` files get included.

Ie, you can enable new features just by running commands like

    ngx_ensnippet location-php

Other option is to add snippets to environment variable `NGINX_SNIPPETS`. These get automatically enabled by `run.sh`, which is the default command for this image.
