#!/bin/sh

mkdir -p /usr/home
mv /home/ubuntu /usr/home
sed -i 's|/home/ubuntu|/usr/home/ubuntu|' /etc/passwd
