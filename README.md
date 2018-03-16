# nginx

Almost like "batteries included".

Container includes

 - nginx from debian stretch
 - dehydrated Let's Encrypt client
 - cron for running dehydrated

By default, `/.well-known/acme-challenge` is served from dehydrated. To configure new domain for LE certs, just edit `/etc/dehydrated/domains.txt`, and add your domains:

    primarydomain.example.com secondarydomain.example.net
    second.example.org this-is-separate-from-first-cert.example.org

Cron should pick changes in one minute.
