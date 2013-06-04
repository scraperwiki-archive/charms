#!/bin/sh
# Lithium hook to set up the inside of a ScraperWiki box in a really
# minimal way, just so that the integration tests pass.
# (a similar later hook in boxecutor installs way more software)

set -e # exit on error
#set -x # Useful for debugging, but not useful routinely.

blue () {
    # Output a blue string.
    printf '\033[36m'
    echo "$@"
    printf '\033[0m'
}

aptit () {
    apt-get install --quiet --quiet --assume-yes "$@"
}

debian_minimal () {
  # Needed, otherwise get the following message lots:
  # "debconf: delaying package configuration, since apt-utils is not installed"
  aptit apt-utils
  aptit lsb-core lsb-base

  blue "Upgrading Ubuntu packages, for security and update fixes"
  cat <<END >/etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu $(lsb_release -c -s) main universe
deb http://archive.ubuntu.com/ubuntu $(lsb_release -c -s)-updates main universe
deb http://archive.ubuntu.com/ubuntu $(lsb_release -c -s)-security main universe
END
  apt-get update --assume-yes --quiet --quiet
  apt-get dist-upgrade --assume-yes --quiet --quiet

  blue "For a minimal box: git sqlite"
  aptit git sqlite3 curl
}

mounts () {
  # /proc mounted because it's needed by the Java install, and probably other things.
  # Need both of these to ensure that the fs is mounted whether or not it already was.
  mount /proc 2>&- || mount -o remount /proc
  # Frabcus says (2012-11-15) that /dev is probably needed by random things too.
  mount /dev 2>&- || mount -o remount /dev
}

mounts
debian_minimal
