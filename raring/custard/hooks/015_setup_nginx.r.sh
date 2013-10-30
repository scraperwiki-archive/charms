#!/bin/sh
# Lithium hook to setup nginx

export DEBIAN_FRONTEND=noninteractive

main () {
  apt-get -qq install nginx-extras 2>&1 >>/var/log/apt-get.nginx.log | egrep -v "update-alternatives: warning: not replacing|Extracting templates from package" || true

  # Set services to start on boot
  update-rc.d nginx start 20 2 3 4 5 . stop 20 0 1 6 . >/dev/null
}

main
