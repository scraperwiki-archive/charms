#!/bin/bash
# Lithium hook to set up PAM and chroot so that
# jailed user accounts can be created.

# Only expected to work when run as root on Ubuntu.

set -e
export HOOKS_HOME="$(pwd)/hooks"

pam_install() {
  # Enable PAM modules
  apt-get --assume-yes --quiet --quiet install libpam-chroot libpam-script
}

pam_configure() {
  cp $HOOKS_HOME/config/pam_unshare.so /lib/security/
  cp $HOOKS_HOME/config/pam.d-sshd /etc/pam.d/sshd
  cp $HOOKS_HOME/config/pam.d-cron /etc/pam.d/cron
  cp $HOOKS_HOME/config/pam.d-su /etc/pam.d/su
  mkdir -p /etc/scraperwiki/libpam-script
  cp $HOOKS_HOME/config/pam_script_ses_open /etc/scraperwiki/libpam-script

  sed -i "s:{{STORAGE_DIR}}:${STORAGE_DIR}:" /etc/scraperwiki/libpam-script/pam_script_ses_open

  # Configure chroot with a group
  echo '@databox                /jails/%u' > /etc/security/chroot.conf
  grep ^databox: /etc/group >/dev/null 2>&1 || groupadd -g 10000 databox

  mkdir -p /jails
  mkdir -p /var/db
}

makejail() {
  BASEJAIL="$1"
  if [ -e /var/run/makejail.done ]
  then
    echo "I think debootstrap was already successful, skipping"
  else
    apt-get -qq -y install debootstrap
    debootstrap --variant=minbase $(lsb_release -c -s) "$BASEJAIL"
    touch /var/run/makejail.done
  fi

  basejail_box_configuration
}


basejail_box_configuration() {
  grep databox "$BASEJAIL/etc/group" >/dev/null 2>/dev/null ||
    grep databox /etc/group >> "$BASEJAIL/etc/group"
  echo "LANG=C.UTF-8" > "${BASEJAIL}/etc/default/locale"

  # make sure can only write crontabs to the mountpoint that is bound here
  mkdir -p "$BASEJAIL/var/spool/cron/crontabs"
  chmod 0 "$BASEJAIL/var/spool/cron/crontabs"

  # avoid pam_script erroring on session close
  mkdir -p /opt/basejail/etc/scraperwiki/libpam-script

  echo '#!/bin/sh' > /opt/basejail/etc/scraperwiki/libpam-script/pam_script_ses_close
  chmod 755 /opt/basejail/etc/scraperwiki/libpam-script/pam_script_ses_close
  echo '#!/bin/sh' > /etc/scraperwiki/libpam-script/pam_script_ses_close
  chmod 755 /etc/scraperwiki/libpam-script/pam_script_ses_close

  # Create user for testing mounts later.
  hooks/add_user.sh databox 2001 10000 /home
  mkdir -p ${STORAGE_DIR}/home/databox
  chown databox:databox ${STORAGE_DIR}/home/databox

  # Mount EC2 instance HD as basejail tmp directory.
  # Using '&&' makes this more idempotent.
  (umount /mnt &&
  sed -i s:/mnt:/opt/basejail/tmp:1 /etc/fstab &&
  mount /opt/basejail/tmp
  ) || true
}

copy_sshd_config() {
  f=/etc/ssh/sshd_config
  cp "${HOOKS_HOME}/config/sshd_config" ${f}
  sed -i "s:{{STORAGE_DIR}}:${STORAGE_DIR}:" ${f}
}

check_jail_is_working() {
  # su as a databox, ensure that the resulting session is namespaced differently
  # than its parent.
  PARENT="$(readlink /proc/self/ns/mnt)"
  if ! JAILED="$(su -c 'readlink /proc/self/ns/mnt' databox)";
  then
    echo "${BASH_SOURCE}:${LINENO} Jailing test failed: databox user missing?" 1>&2
    exit 1
  fi
  JAILSTATUS=$?

  if [ "$JAILSTATUS" != 0 ] || [ "$PARENT" == "$JAILED" ];
  then
    echo "${BASH_SOURCE}:${LINENO} Jailing failed! Mount namespaces don't work!" 1>&2
    exit 1
  fi
}

main() {
  pam_install
  pam_configure
  copy_sshd_config
  service ssh reload
  makejail /opt/basejail
  check_jail_is_working
}

main
