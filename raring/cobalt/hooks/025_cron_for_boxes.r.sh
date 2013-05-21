#!/bin/sh
# David Jones, ScraperWiki Limited.

export DEBIAN_FRONTEND=noninteractive

# So that cron uses PAM to chroot into each box when running cronjobs.
if ! grep 'session required pam_script' /etc/pam.d/cron > /dev/null
then
  cat << 'EOF' >> /etc/pam.d/cron
session required pam_script.so
session required pam_chroot.so debug use_groups
EOF
fi

# Install cron in the basejail... then stop it running (forever).
chroot /opt/basejail apt-get -qq install apt-utils
chroot /opt/basejail apt-get -qq install cron
chroot /opt/basejail service cron stop
rm -f /opt/basejail/etc/init/cron.conf

# Create a mountpoint, and mount it, so that crontab works from within a box.
mkdir -p /var/spool/cron/crontabs
ses_open=/usr/share/libpam-script/pam_script_ses_open
if ! grep 'bind /var/spool/cron/crontabs' $ses_open > /dev/null
then
  sed -i -e '/bind .opt.basejail/a\
  mount --bind /var/spool/cron/crontabs /jails/$PAM_USER/var/spool/cron/crontabs >> /tmp/status
' $ses_open
fi
