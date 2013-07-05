#!/bin/sh

cp -r hooks/config/monit /etc
sed -i "s:{{HOSTNAME}}:$(hostname):" /etc/monit/conf.d/system
sed -i "s:{{LOAD_1}}:$(expr $(nproc) '*' 8):" /etc/monit/conf.d/system
sed -i "s:{{LOAD_5}}:$(expr $(nproc) '*' 6):" /etc/monit/conf.d/system
sed -i "s:{{LOAD_15}}:$(expr $(nproc) '*' 4):" /etc/monit/conf.d/system
monit reload
