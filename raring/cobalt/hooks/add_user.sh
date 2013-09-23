#!/bin/sh

if [ $# != 4 ]; then
  echo './add_user.sh userName numericUserID numericGroupID homeDirectory' 1>&2
  exit 7
fi

passwd_row="${1}:x:${2}:${3}::${4}:/bin/sh"
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
