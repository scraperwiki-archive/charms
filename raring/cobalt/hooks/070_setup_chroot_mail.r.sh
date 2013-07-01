#!/bin/sh
set -e
if grep -q "Please install" /opt/basejail/usr/sbin/sendmail; then
  cd /usr/local/src
  git clone -q git://github.com/hackman/mini_sendmail.git --depth 1 || true
  cd mini_sendmail
  make >> /dev/null
  cp mini_sendmail /opt/basejail/usr/sbin/sendmail
fi
