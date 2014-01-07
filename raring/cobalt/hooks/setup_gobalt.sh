#!/bin/sh
set -e

curl -o /usr/local/bin/gobalt-fastcgi-server https://s3.amazonaws.com/sw-devops/binaries/gobalt-fastcgi-server-20140107

chmod a+x /usr/local/bin/gobalt-fastcgi-server

cat <<EOF > /etc/init/gobalt.conf
start on runlevel [2345]
stop on runlevel [016]
respawn

script
    exec gobalt-fastcgi-server
end script

post-stop script
    echo "Gobalt stopped"
end script

EOF

service gobalt stop >/dev/null 2>&1 || true
service gobalt start >/dev/null
