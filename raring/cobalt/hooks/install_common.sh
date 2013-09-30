#!/bin/sh
set -e

sh hooks/005_secure_system.r.sh
sh hooks/010_upgrade_packages.r.sh
sh hooks/020_install_devops_utils.r.sh
sh hooks/030_set_hostname.r.sh
sh hooks/040_unattended_upgrades.r.sh
sh hooks/050_setup_mail_server.r.sh

apt-get install -y run-one
