#!/bin/sh
ROOT_DIR=${ROOT_DIR:-/}

write_fstab() {
  # this only changes the entry for /proc
  sed -i '/^proc/s:defaults\s:defaults,hidepid=2,remount :' "${1}etc/fstab"
}

write_rclocal() {
  sed -i 's:^exit 0:\nmount /proc\n&:g' "${1}etc/rc.local"
}

main () {
  write_fstab ${ROOT_DIR}
  write_rclocal ${ROOT_DIR}

  mount /proc
}

main
