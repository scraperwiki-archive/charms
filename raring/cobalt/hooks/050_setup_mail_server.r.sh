#!/bin/sh
set -e

# TODO: move somewhere sane
add_user() {
  passwd_row="${1}:x:${2}:${3}::/nonexistent:/bin/sh"
  shadow_row="${1}:x:15607:0:99999:7:::"
  if [ -L /etc/passwd ]; then
    passwd_file=$(readlink /etc/passwd)
    shadow_file=$(readlink /etc/shadow)
  else
    passwd_file=/etc/passwd
    shadow_file=/etc/shadow
  fi

  (
     flock -w 2 9 || exit 99
     { cat /etc/passwd ; echo "$passwd_row" ; } > /etc/passwd+
     mv /etc/passwd+ $passwd_file
     { cat /etc/shadow ; echo "$shadow_row" ; } > /etc/shadow+
     mv /etc/shadow+ $shadow_file
  ) 9>${CO_STORAGE_DIR}/etc/passwd.cobalt.lock
}

# force the uid of the postfix user, so it is same as in later used shared passwd file (on glusterfs)
grep ^postfix: /etc/group >/dev/null 2>&1 || groupadd -g 502 postfix
id -u postfix >/dev/null 2>&1 || add_user postfix 108 502
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
