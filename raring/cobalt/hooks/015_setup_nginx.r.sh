#!/bin/sh
set -e

apt-get -qq install spawn-fcgi fcgiwrap nginx-extras liblua5.1-json

# Set services to start on boot
update-rc.d fcgiwrap start 20 2 3 4 5 . stop 20 0 1 6 . >/dev/null
update-rc.d nginx start 20 2 3 4 5 . stop 20 0 1 6 . >/dev/null
