#!/bin/sh
set -eu
echo "${HOSTNAME}.scraperwiki.net" > /etc/hostname
hostname -b -F /etc/hostname

# Other packages make certificates and require a FQDN to exist.
# Unfortunately DNS doesn't propogate fast enough, so we put
# it in /etc/hosts just for this.
export IPADDR=`ifconfig | perl -nle '/addr:([^ ]+)/ and print $1' | head -1 | tr -d '\n'`
if ! grep ${HOSTNAME}.scraperwiki.net /etc/hosts >/dev/null
then
    echo -e "\n# Added by vanilla/hooks/030_set_hostname.r.sh\n$IPADDR ${HOSTNAME}.scraperwiki.net\n" >> /etc/hosts
fi
