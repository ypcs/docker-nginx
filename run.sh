#!/bin/sh
set -e

if [ -n "${NGINX_SNIPPETS}" ]
then
    for snippet in ${NGINX_SNIPPETS}
    do
        ngx_ensnippet "${snippet}"
    done
fi

nginx -g "daemon off;" 
