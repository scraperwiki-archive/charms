#!/bin/sh

set -e

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
    export CU_NODETIME_APP="$(config-get CU_NODETIME_APP)"
    export CU_MAILCHIMP_API_KEY=$(config-get CU_MAILCHIMP_API_KEY)
    export CU_MAILCHIMP_LIST_ID=$(config-get CU_MAILCHIMP_LIST_ID)
    export EXCEPTIONAL_KEY=$(config-get EXCEPTIONAL_KEY)
    export CU_REQUEST_BOX_URL=$(config-get CU_REQUEST_BOX_URL)
    export CU_REQUEST_API_KEY=$(config-get CU_REQUEST_API_KEY)
    export CU_REQUEST_EMAIL=$(config-get CU_REQUEST_EMAIL)
    export REDIS_SERVER="$(cat /etc/custard/redis-server)"
    export REDIS_PASSWORD="$(cat /etc/custard/redis-password)"

    cd /opt/custard &&
    . ./activate &&
    echo "Custard starting at \$(date --rfc-3339=seconds)" &&
    echo "Custard starting on port or socket \$CU_PORT" &&
    cake build &&
    exec node server.js
end script

post-stop script
    echo "Custard stopped"
end script

EOF

# When sending email either send a diff (for incremental
# deploys) or another message (for fresh deploys).
gitdiff="git diff"
cd /opt/custard 2>/dev/null || {
  # Git clone if we haven't found it
  git clone --quiet git://github.com/scraperwiki/custard.git /opt/custard
  cd /opt/custard
  gitdiff="echo a fresh deploy"
}
git pull --quiet

npm install --production >>/var/log/npm.install.log 2>&1 | egrep -v "^$|^npm http |Checking for |finished successfully|Entering directory|Leaving directory|cxx:|cxx_link:|yes|Nothing to clean|Setting srcdir|Setting blddir" || true

$gitdiff --stat master master@{1} 2>&1 | mail developers@scraperwiki.com -s "Custard has been deployed to $(hostname)"

export USER="root"
crons="$(crontab -l || true)"
if ! echo "$crons" | grep -q deleted-datasets
then
  # Add deleted-datasets cron line
  line="*/5 * * * * sh /opt/custard/cron/delete-datasets.sh"
  (echo "$crons"; echo "$line") | crontab -
fi

mkdir -p /etc/custard

touch /etc/custard/tools_rsa
config-get TOOLS_RSA_KEY > /etc/custard/tools_rsa
chmod 0600 /etc/custard/tools_rsa
chmod ug=rx,o=x /opt/tools

service custard stop > /dev/null 2>&1
service custard start
