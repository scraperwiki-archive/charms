#!/bin/sh
set -e

apt-get install -qq build-essential
apt-get install -qq python-software-properties
add-apt-repository -y ppa:chris-lea/node.js
apt-get update >>/var/log/npm.install.log
apt-get -y -qq install nodejs
apt-get -y -qq upgrade nodejs
npm install --quiet node-gyp -g
