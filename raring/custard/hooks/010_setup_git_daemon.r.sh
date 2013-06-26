#!/bin/sh

INTERNAL_IP=$(/sbin/ifconfig | grep -e 'inet addr:192\.168\.' -e 'inet addr:10\.' | sed 's/.*addr:\([^ ]*\).*/\1/')

mkdir -p /opt/tools
chown www-data: /opt/tools

cat <<EOF > /etc/init/git-daemon.conf
start on startup
stop on runlevel [016]
respawn
script
  /usr/bin/git daemon --listen=${INTERNAL_IP} --syslog --export-all --base-path=/opt/tools --verbose --reuseaddr --user=www-data --group=www-data /opt/tools
end script
EOF
