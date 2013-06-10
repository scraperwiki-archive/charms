#!/bin/sh
set -e
# When testing, this is picked up from the environment.
ROOT_DIR=${ROOT_DIR:-/}

apt-get -qq install python-pip python-lxml

# Required by dumptruck-web
pip install --quiet dumptruck

# Install files for the sqlite API.
# These are accessed via fcgiwrap in nginx, which an earlier
# file has set up.

umask 022
# Create the entrypoint for CGI.
mkdir -p ${ROOT_DIR}opt
cd ${ROOT_DIR}opt
if test -e dumptruck-web
then
  # Already exists, just pull.
  (
  cd dumptruck-web
  git pull
  )
else
  git clone --quiet git://github.com/scraperwiki/dumptruck-web.git
fi
chown -R www-data: dumptruck-web/
