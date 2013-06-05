#!/bin/sh
set -e

apt-get -qq install unattended-upgrades >>/var/log/apt-get.unattended-upgrade.log

cp hooks/config/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
cp hooks/config/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades
