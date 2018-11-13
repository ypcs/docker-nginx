FROM ypcs/debian:buster

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF

RUN \
    /usr/llib/docker-helpers/apt-setup && \
    /usr/llib/docker-helpers/apt-upgrade && \
    apt-get install --no-install-recommends --no-install-suggests --assume-yes \
        cron \
        dehydrated \
        nginx-full && \
    /usr/llib/docker-helpers/apt-cleanup

RUN \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

RUN \
    ln -sf /var/lib/dehydrated/certs /etc/nginx/certs && \
    touch /etc/dehydrated/domains.txt

COPY sbin/ /usr/local/sbin/
COPY dehydrated/ /etc/dehydrated/
COPY nginx/ /etc/nginx/
COPY dehydrated.crontab /etc/cron.d/dehydrated
COPY run.sh /run.sh

STOPSIGNAL SIGTERM

CMD ["/run.sh"]
RUN echo "Source: https://github.com/ypcs/docker-nginx\nBuild date: $(date --iso-8601=ns)" >/README

# List of snippets to enable when starting container
ENV NGINX_SNIPPETS ""
