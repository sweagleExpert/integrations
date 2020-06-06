#!/bin/bash

if [ -f /etc/nginx/conf.d/ssl.conf ]; then
  mv /etc/nginx/conf.d/default.conf.https /etc/nginx/conf.d/default.conf
  echo "Using https file"
else
  mv /etc/nginx/conf.d/default.conf.http /etc/nginx/conf.d/default.conf
  echo "Using http file"
fi

exec nginx -g "daemon off;"
