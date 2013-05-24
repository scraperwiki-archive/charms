#!/bin/sh

INTERNAL_IP=$(/sbin/ifconfig | grep 'inet addr:192.168' | cut -d: -f2 | awk '{ print $1 }')

cat <<EOF > /etc/init/git-daemon.conf
start on startup
stop on runlevel [016]
respawn
script
  /usr/bin/git daemon --listen=${INTERNAL_IP} --syslog --export-all --base-path=/opt/tools --verbose --reuseaddr --user=www-data --group=www-data /opt/tools
end script
EOF

restart git-daemon > /dev/null 2>&1 || start git-daemon > /dev/null 2>&1
