FROM ypcs/debian:bullseye

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF

RUN \
    /usr/lib/docker-helpers/apt-setup && \
    /usr/lib/docker-helpers/apt-upgrade && \
    apt-get install --no-install-recommends --no-install-suggests --assume-yes \
        cron \
        dehydrated \
        nginx-full && \
    /usr/lib/docker-helpers/apt-cleanup

RUN \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /var/www/html /docroot

RUN \
    ln -sf /var/lib/dehydrated/certs /etc/nginx/certs && \
    touch /etc/dehydrated/domains.txt

COPY sbin/ /usr/local/sbin/
COPY dehydrated/ /etc/dehydrated/
COPY nginx/ /etc/nginx/
COPY dehydrated.crontab /etc/cron.d/dehydrated
COPY entrypoint.sh /entrypoint.sh

STOPSIGNAL SIGTERM

CMD ["/entrypoint.sh"]
RUN echo "Source: https://github.com/ypcs/docker-nginx\nBuild date: $(date --iso-8601=ns)" >/README

# List of snippets to enable when starting container
ENV NGINX_SNIPPETS "try_files"
