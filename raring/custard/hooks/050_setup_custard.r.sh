#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
#set -e # should put this back when npm does no errors!

cd /opt/custard 2>/dev/null || {
  # Git clone if we haven't found it
  git clone --quiet git://github.com/scraperwiki/custard.git /opt/custard --depth 1
  cd /opt/custard
}
git pull --quiet

. ./activate 2>&1 >>/var/log/custard.activate.log | egrep -v "^$|^npm http" || true
npm install --production 2>&1 >>/var/log/npm.install.log | egrep -v "^$|^npm http |Checking for |finished successfully|Entering directory|Leaving directory|cxx:|cxx_link:|yes|Nothing to clean|Setting srcdir|Setting blddir" || true

# Make tool repo directory
mkdir -p /opt/tools

# redirect event stderr to /dev/null, as we don't care about errors on stop
service custard stop >/dev/null 2>&1 || true
service custard start >/dev/null

git diff --stat master master@{1} 2>&1 | mail developers@scraperwiki.com -s "Custard has been deployed to $1"
