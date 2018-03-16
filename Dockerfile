FROM ypcs/debian:stretch

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF

ENV DOCUMENT_ROOT /var/www/html
ENV SITE_URL http://localhost

# Heavily based on nginx upstreams Docker config, however
# we use package in Debian instead of upstream.

RUN \
    /usr/local/sbin/docker-upgrade && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends --no-install-suggests --assume-yes \
        cron \
        dehydrated \
        nginx-full && \
    /usr/local/sbin/docker-cleanup

RUN \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

RUN \
    ln -sf /var/lib/dehydrated/certs /etc/nginx/certs && \
    touch /etc/dehydrated/domains.txt

EXPOSE 80
STOPSIGNAL SIGTERM

COPY hook.sh /etc/dehydrated/hook.sh
COPY must-staple.sh /etc/dehydrated/conf.d/must-staple.sh
COPY dehydrated.config /etc/dehydrated/config

COPY conf.d/* /etc/nginx/conf.d/
COPY snippets/* /etc/nginx/snippets/

COPY dehydrated.crontab /etc/cron.d/dehydrated

COPY run.sh /run.sh
CMD ["/run.sh"]

