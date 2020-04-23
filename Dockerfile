FROM ypcs/debian:bullseye

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF

RUN \
    /usr/lib/docker-helpers/apt-setup && \
    /usr/lib/docker-helpers/apt-upgrade && \
    apt-get install --no-install-recommends --no-install-suggests --assume-yes \
        curl \
        nginx-full && \
    /usr/lib/docker-helpers/apt-cleanup

RUN \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /var/www/html /docroot

COPY sbin/ /usr/local/sbin/
COPY nginx/ /etc/nginx/
COPY entrypoint.sh /entrypoint.sh

STOPSIGNAL SIGTERM

CMD ["/entrypoint.sh"]
RUN echo "Source: https://github.com/ypcs/docker-nginx\nBuild date: $(date --iso-8601=ns)" >/README

# List of snippets to enable when starting container
ENV NGINX_SNIPPETS "try_files"

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 CMD curl -f http://localhost/ || exit 1
