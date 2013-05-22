#!/bin/sh
set -e

git clone --quiet git://github.com/scraperwiki/cobalt /opt/cobalt --depth 1
mkdir -p /opt/cobalt/etc/sshkeys
