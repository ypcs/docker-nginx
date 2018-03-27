#!/bin/bash
set -e

DOMAIN="${1:-${DOMAIN}}"

[ -z "${DOMAIN}" ] && echo "missing domain!" && exit 1

openssl \
    req \
    -x509 \
    -newkey rsa:4096 \
    -sha256 \
    -subj "/C=US/O=Self-Signed Certificates Fake-Ltd/" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:${DOMAIN},DNS:*.${DOMAIN}")) \
    -keyout privkey.pem \
    -out cert.pem \
    -days 30 \
    -nodes
