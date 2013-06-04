#!/bin/sh
set -e

cp /etc/passwd ${STORAGE_DIR}/etc/passwd || true
cp /etc/shadow ${STORAGE_DIR}/etc/shadow || true

rm /etc/shadow /etc/passwd
ln -s ${STORAGE_DIR}/etc/shadow /etc/shadow
ln -s ${STORAGE_DIR}/etc/passwd /etc/passwd
ln -fs /bin/true $(which adduser)
