#!/bin/sh
# Lithium hook to setup nginx, including fcgiwrap which is used by sqlite API.

export DEBIAN_FRONTEND=noninteractive
ROOT_DIR=${ROOT_DIR:-/}
INSTANCE_NAME=$1

set_nginx_config() {
  ROOT_DIR=$1

  cp keys/* ${ROOT_DIR}etc/nginx

  cp config/nginx/custard ${ROOT_DIR}etc/nginx/sites-available/custard

  ln -fs ${ROOT_DIR}etc/nginx/sites-available/custard ${ROOT_DIR}etc/nginx/sites-enabled/custard

  rm -f ${ROOT_DIR}etc/nginx/sites-enabled/default

  case $INSTANCE_NAME in
    *dev*)
      file="${ROOT_DIR}etc/nginx/sites-available/custard"
      sed -i 's/beta\.scraperwiki\.com/beta-dev.scraperwiki.com/' $file
    ;;
  esac
}


main () {
  apt-get -qq install nginx-extras 2>&1 >>/var/log/apt-get.nginx.log | egrep -v "update-alternatives: warning: not replacing|Extracting templates from package" || true

  set_nginx_config "$ROOT_DIR"

  # Set services to start on boot
  update-rc.d nginx start 20 2 3 4 5 . stop 20 0 1 6 . >/dev/null
}

main
