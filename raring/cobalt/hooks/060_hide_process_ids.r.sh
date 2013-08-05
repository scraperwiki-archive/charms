#!/bin/sh
set -e
ROOT_DIR=${ROOT_DIR:-/}

write_fstab() {
  grep ^proc /etc/fstab ||
    echo "proc        /proc        proc    defaults,hidepid=2,remount" >> /etc/fstab
}

write_rclocal() {
  cat <<EOF > ${1}etc/rc.local
mount /proc
rm /var/db/mounts
exit 0
EOF
}

main () {
  write_fstab ${ROOT_DIR}
  write_rclocal ${ROOT_DIR}

  mount /proc || true
}

main
