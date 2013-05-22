#!/bin/sh
set -e

# See http://superuser.com/questions/402794/writing-simple-upstart-script
cat <<EOF > /etc/init/cobalt.conf
start on runlevel [2345]
stop on runlevel [016]
respawn

script
    export CU_DB=$(config-get CU_DB)
    export COBALT_PORT=$(config-get COBALT_PORT)
    export CO_AVOID_BOX_CHECK=$(config-get CO_AVOID_BOX_CHECK)
    export NODE_ENV=$(config-get NODE_ENV)
    export NODETIME_KEY=$(config-get $NODETIME_KEY)
    export CO_NODETIME_APP=$(config-get $CO_NODETIME_APP)
    cd /opt/cobalt &&
    . ./activate &&
    echo "Cobalt starting on port or socket $COBALT_PORT" &&
    # "exec" is required so that we get the correct PID.
    exec coffee code/serv.coffee
end script

post-stop script
    echo "Cobalt stopped"
end script

EOF

# Update what we have
cd /opt/cobalt
git pull

. ./activate
npm install --production 2>&1 || true

# redirect event stderr to /dev/null, as we don't care about errors on stop
service cobalt stop >/dev/null 2>&1 || true
service cobalt start >/dev/null
