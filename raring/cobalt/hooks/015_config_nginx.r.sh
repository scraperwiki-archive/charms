#!/bin/sh
set -e

ROOT_DIR=${ROOT_DIR:-/}

set_nginx_config() {
  ROOT_DIR=$1

  config-get SSL_CRT > ${ROOT_DIR}etc/nginx/star_scraperwiki_com.crt
  config-get SSL_KEY > ${ROOT_DIR}etc/nginx/star_scraperwiki_com.key
  CO_STORAGE_DIR=$(config-get CO_STORAGE_DIR)

  cp hooks/config/nginx/boxes ${ROOT_DIR}etc/nginx/sites-available/
  cp hooks/config/nginx/nginx.conf ${ROOT_DIR}etc/nginx/

  mkdir -p ${ROOT_DIR}etc/nginx/lua
  cp hooks/config/nginx/lua/publish_token_access.lua ${ROOT_DIR}etc/nginx/lua/publish_token_access.lua
  cp hooks/config/nginx/lua/callback_prefix.lua ${ROOT_DIR}etc/nginx/lua/callback_prefix.lua
  cp hooks/config/nginx/lua/callback_suffix.lua ${ROOT_DIR}etc/nginx/lua/callback_suffix.lua

  ln -fs ${ROOT_DIR}etc/nginx/sites-available/boxes ${ROOT_DIR}etc/nginx/sites-enabled/boxes

  rm -f ${ROOT_DIR}etc/nginx/sites-enabled/default

  # Edit /etc/init.d/fcgiwrap for number of children
  sed -i 's/^FCGI_CHILDREN.*$/FCGI_CHILDREN="20"/' ${ROOT_DIR}etc/init.d/fcgiwrap

  # Set storage dir
  sed -i "s:{{STORAGE_DIR}}:${STORAGE_DIR}:g" ${ROOT_DIR}etc/nginx/sites-available/boxes
  sed -i "s:{{STORAGE_DIR}}:${STORAGE_DIR}:g" ${ROOT_DIR}etc/nginx/lua/publish_token_access.lua

}


main () {
  set_nginx_config "$ROOT_DIR"
  service nginx reload >/dev/null || service nginx start || true
}

main
