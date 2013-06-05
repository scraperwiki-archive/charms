#!/bin/sh
set -e

# Disable password login via SSH, we should never need this
sed -ri 's/^(:?#)?PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Install and set up process accounting
apt-get -qq install acct >>/var/log/apt-get.acct.log
