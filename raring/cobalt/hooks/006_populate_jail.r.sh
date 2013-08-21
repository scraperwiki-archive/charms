#!/bin/sh
set -e

# First component of hostname.
H=$(hostname)
H=${H%%.*}

# Try and teleport to the right directory
# (useful when the script is run outside the usual
# charm-upgrade process).
if [ ! -d hooks ]
then
  cd "/var/lib/juju/agents/$H/charm/"
fi

export HOOKS_HOME="$(pwd)/hooks"

populate_jail() {
  BASEJAIL="$1"

  mkdir -p "$BASEJAIL/root"
  cp "$HOOKS_HOME/lib/install_box_software.sh" "$BASEJAIL/root/install_box_software.sh"

  chroot "$BASEJAIL" sh /root/install_box_software.sh 2>&1 >>/var/log/basejail.install.log | egrep -v "^$|Current default time zone:|Local time is now:|Universal Time is now:|^gpg:|Extracting templates from packages|if you wish to change it|^Wrote |^Updating |^Running |^Building |^aspell-autobuild|^Loading |^Checking |^Setting |^Creating |^Moving |^Nothing to clean|cxx: src|cxx_link|finished successfully|update-alternatives:|Byte-compiling for emacsen|Note: will build against internal copy of sqlite3|Waf: Entering directory|Waf: Leaving directory|WARNING: ntlm-http-0.1.1 has an invalid nil value|update-initramfs: deferring update|pass --with-sqlite3=/usr/local to build|debconf: delaying package configuration|update-alternatives: warning|start runlevel arguments (none) do not match LSB Default-Start|Restarting|Stopping OpenBSD Secure Shell|ssh stop/pre-start, process|\.\.\.done|No repository field|Please pick one as the 'repository' field|'repositories' \(plural\) Not supported|bugs\['web'\] should probably be bugs\['url'\]|No readme data|warning: value computed is not used|porter_stemmer|vendor/libxml|npm WARN" || true
}

populate_jail /opt/basejail
