FROM ypcs/debian:stretch

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF

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


COPY dehydrated/ /etc/dehydrated/
COPY nginx/ /etc/nginx/
COPY dehydrated.crontab /etc/cron.d/dehydrated
COPY run.sh /run.sh

EXPOSE 80
STOPSIGNAL SIGTERM

ENV DOCUMENT_ROOT /var/www/html
ENV SITE_URL http://localhost

CMD ["/run.sh"]

