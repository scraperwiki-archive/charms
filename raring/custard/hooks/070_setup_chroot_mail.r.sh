#!/bin/sh
set -e
if [ ! -f /opt/basejail/usr/sbin/sendmail ]; then
  cd /usr/local/src
  git clone git://github.com/hackman/mini_sendmail.git --depth 1
  cd mini_sendmail
  make >> /dev/null
  cp mini_sendmail /opt/basejail/usr/sbin/sendmail
fi
