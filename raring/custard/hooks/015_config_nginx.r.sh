#!/bin/sh
set -e

ROOT_DIR=${ROOT_DIR:-/}

set_nginx_config() {
  ROOT_DIR=$1

  config-get SSL_CRT > ${ROOT_DIR}etc/nginx/star_scraperwiki_com.crt
  config-get SSL_KEY > ${ROOT_DIR}etc/nginx/star_scraperwiki_com.key

  case $(hostname) in
    (*live*) export DEV=false ;;
    (*) export DEV=true ;;
  esac

  sh hooks/config/nginx/custard.sh > ${ROOT_DIR}etc/nginx/sites-available/custard

  ln -fs ${ROOT_DIR}etc/nginx/sites-available/custard ${ROOT_DIR}etc/nginx/sites-enabled/custard

  rm -f ${ROOT_DIR}etc/nginx/sites-enabled/default
}


main () {
  set_nginx_config "$ROOT_DIR"
  service nginx reload >/dev/null || true
}

main
