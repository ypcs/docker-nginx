#!/bin/sh
set -e

if [ ! -e "/disable-cron" ]
then
    cron
fi

nginx -g "daemon off;" 
