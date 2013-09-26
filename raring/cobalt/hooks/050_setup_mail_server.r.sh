#!/bin/sh
set -e

# force the uid of the postfix user, so it is same as in later used shared passwd file (on glusterfs)
grep ^postfix: /etc/group >/dev/null 2>&1 || groupadd -g 502 postfix
id -u postfix >/dev/null 2>&1 || hooks/add_user.sh postfix 108 502 /nonexistent
# we have to create the postdrop group too, or the Debian setup script for postfix gets confused
grep ^postdrop: /etc/group >/dev/null 2>&1 || groupadd -g 500 postdrop


cat <<END | debconf-set-selections
postfix postfix/mailname  string  ${HOSTNAME}.scraperwiki.net
postfix postfix/main_mailer_type  select  Internet Site
postfix postfix/destinations  string  ${HOSTNAME}.scraperwiki.net, localhost
END

# Extremely chatty; put in log file, and strip bits of stderr that are noisy.
apt-get install -qq postfix mailutils 2>&1 >> /var/log/apt-get.postfix.log | egrep -v "^$|^setting |^Postfix is now set up|^/etc/aliases does not exist|^WARNING: /etc/aliases exists|^changing |^Adding |^Not creating|^Creating|^Done|^After modifying|^changes, edit|To view Postfix configuration|^Running |Stopping Postfix|Starting Postfix|\.\.\.done|values, see postconf" || true

postfix reload
