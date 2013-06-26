#!/bin/sh

set -e
export DEBIAN_FRONTEND=noninteractive

# not used.
export CU_PORT=/var/run/custard.socket

# See http://superuser.com/questions/402794/writing-simple-upstart-script
cat <<EOF > /etc/init/custard.conf
start on runlevel [2345]
stop on runlevel [016]
respawn

script
    export CU_DB=$(config-get CU_DB)
    export CU_PORT=$(config-get CU_PORT)
    export CU_SESSION_SECRET=$(config-get CU_SESSION_SECRET)
    export CU_GITHUB_LOGIN=$(config-get CU_GITHUB_LOGIN)
    export CU_TOOLS_DIR=$(config-get CU_TOOLS_DIR)
    export NODE_ENV=$(config-get NODE_ENV)
    export CU_BOX_SERVER=$(config-get CU_BOX_SERVER)
    export CU_SENDGRID_USER=$(config-get CU_SENDGRID_USER)
    export CU_SENDGRID_PASS=$(config-get CU_SENDGRID_PASS)
    export CU_INVITE_CODE=$(config-get CU_INVITE_CODE)
    export CU_QUOTA_SERVER=$(config-get CU_QUOTA_SERVER)
    export RECURLY_DOMAIN=$(config-get RECURLY_DOMAIN)
    export RECURLY_PRIVATE_KEY=$(config-get RECURLY_PRIVATE_KEY)
    export RECURLY_API_KEY=$(config-get RECURLY_API_KEY)
    export NODETIME_KEY="$(config-get NODETIME_KEY)"
    export CU_NODETIME_APP=$(config-get CU_NODETIME_APP)
    export CU_MAILCHIMP_API_KEY=$(config-get CU_MAILCHIMP_API_KEY)
    export CU_MAILCHIMP_LIST_ID=$(config-get CU_MAILCHIMP_LIST_ID)
    export EXCEPTIONAL_KEY=$(config-get EXCEPTIONAL_KEY)
    cd /opt/custard &&
    . ./activate &&
    echo "Custard starting on port or socket $CU_PORT" &&
    cake build &&
    exec node server.js
end script

post-stop script
    echo "Custard stopped"
end script

EOF
