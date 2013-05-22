#!/bin/sh
set -e

ROOT_DIR=${ROOT_DIR:-/}

set_nginx_config() {
  ROOT_DIR=$1

  config-get SSL_CRT > ${ROOT_DIR}etc/nginx/star_scraperwiki_com.crt
  config-get SSL_KEY > ${ROOT_DIR}etc/nginx/star_scraperwiki_com.key

  cp hooks/config/nginx/boxes ${ROOT_DIR}etc/nginx/sites-available/boxes

  mkdir -p ${ROOT_DIR}etc/nginx/lua
  cp hooks/config/nginx/lua/publish_token_access.lua ${ROOT_DIR}etc/nginx/lua/publish_token_access.lua
  cp hooks/config/nginx/lua/callback_prefix.lua ${ROOT_DIR}etc/nginx/lua/callback_prefix.lua
  cp hooks/config/nginx/lua/callback_suffix.lua ${ROOT_DIR}etc/nginx/lua/callback_suffix.lua

  ln -fs ${ROOT_DIR}etc/nginx/sites-available/boxes ${ROOT_DIR}etc/nginx/sites-enabled/boxes

  rm -f ${ROOT_DIR}etc/nginx/sites-enabled/default

  # Edit /etc/init.d/fcgiwrap for number of children
  sed -i 's/^FCGI_CHILDREN.*$/FCGI_CHILDREN="20"/' ${ROOT_DIR}etc/init.d/fcgiwrap

}


main () {
  apt-get -qq install spawn-fcgi fcgiwrap nginx-extras liblua5.1-json

  set_nginx_config "$ROOT_DIR"

  # Set services to start on boot
  update-rc.d fcgiwrap start 20 2 3 4 5 . stop 20 0 1 6 . >/dev/null
  update-rc.d nginx start 20 2 3 4 5 . stop 20 0 1 6 . >/dev/null

  # Start the services
  service fcgiwrap restart >/dev/null
  service nginx restart >/dev/null
}

main
