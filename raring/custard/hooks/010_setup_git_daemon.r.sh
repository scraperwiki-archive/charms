#!/bin/sh

cat <<EOF > /etc/init/git-daemon.conf
start on startup
stop on runlevel [016]
respawn
script
  /usr/bin/git daemon --syslog --export-all --base-path=/opt/tools --verbose --reuseaddr --user=custard --group=custard /opt/tools
end script
EOF

restart git-daemon > /dev/null 2>&1 || start git-daemon > /dev/null 2>&1
