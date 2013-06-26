#!/bin/sh
set -e
apt-get --quiet --quiet --assume-yes traceroute install htop iotop curl strace iftop sysstat time git-core sqlite3 >>/var/log/apt-get.devopsutils.log

# enable sar
sed -i 's/ENABLED="false"/ENABLED="true"/;' /etc/default/sysstat
