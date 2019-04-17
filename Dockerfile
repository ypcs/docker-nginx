FROM ypcs/debian:buster AS nginx-build

ARG APT_PROXY
ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF

RUN sed -i 's/^#deb-src/deb-src/g' /etc/apt/sources.list && \
    /usr/lib/docker-helpers/apt-setup && \
    /usr/lib/docker-helpers/apt-upgrade && \
    apt-get --assume-yes install \
        build-essential \
        git \
        packaging-dev \
        patch && \
    /usr/lib/docker-helpers/apt-cleanup

WORKDIR /usr/src

RUN /usr/lib/docker-helpers/apt-setup && \
    apt-get install --assume-yes libmodsecurity3 libmodsecurity-dev && \
    apt-get build-dep --assume-yes nginx libmodsecurity3 && \
    apt-get source nginx libmodsecurity3 && \
    /usr/lib/docker-helpers/apt-cleanup

RUN mkdir -p /usr/src/patches

COPY nginx-*.patch /usr/src/patches/

ENV DEBFULLNAME "Ville Korhonen"
ENV DEBEMAIL ville@xd.fi

RUN cd nginx-* && \
    cd debian/modules && \
    git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx modsecurity && \
    cd ../.. && \
    patch -p0 < /usr/src/patches/nginx-rules.patch && \
    patch -p0 < /usr/src/patches/nginx-control.patch && \
    debchange --nmu "Add ModSecurity module" && \
    dpkg-buildpackage -us -uc

FROM ypcs/debian:buster AS nginx

COPY --from=nginx-build /usr/src/libnginx-mod-modsecurity*.deb /tmp/

RUN /usr/lib/docker-helpers/apt-setup && \
    /usr/lib/docker-helpers/apt-upgrade && \
    dpkg -i /tmp/libnginx-mod-modsecurity*.deb ; \
    rm -rf /tmp/libnginx-mod-modsecurity*.deb && \
    apt-get -f --assume-yes install && \
    apt-get install --no-install-recommends --no-install-suggests --assume-yes \
        cron \
        dehydrated \
        libmodsecurity3 \
        modsecurity-crs \
        nginx-full && \
    /usr/lib/docker-helpers/apt-cleanup

RUN dpkg --get-selections |grep -v deinstall |grep -q libnginx-mod-modsecurity

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
COPY entrypoint.sh /entrypoint.sh

COPY modsecurity.conf /etc/modsecurity/modsecurity.conf

STOPSIGNAL SIGTERM

CMD ["/entrypoint.sh"]
RUN echo "Source: https://github.com/ypcs/docker-nginx\nBuild date: $(date --iso-8601=ns)" >/README

# List of snippets to enable when starting container
ENV NGINX_SNIPPETS ""
