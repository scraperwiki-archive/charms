#!/bin/sh
set -e

# Set up the Ubuntu resolv.conf symlink for Ubuntu 12.04
echo "set resolvconf/linkify-resolvconf true" | debconf-communicate >/dev/null
dpkg-reconfigure resolvconf

# Sometimes package configuration needs apt-utils
apt-get --quiet --quiet install apt-utils

# Remove whoopsie, which submits crash reports to Ubuntu's database
apt-get --quiet --quiet --assume-yes remove whoopsie >>/var/log/apt-get.whoopsie.log

# XXX probably need to reboot here - add code to do that automatically,
# preferably only if the system knows it needs rebooting.
