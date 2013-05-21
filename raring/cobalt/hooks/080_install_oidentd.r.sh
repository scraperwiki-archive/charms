# Expect this to complain because it's unable to create a userid
# for oidentd; that's okay, we run as nobody.
set -e
apt-get -q -q install oidentd

# This file mostly configures oidentd to run as user oidentd.
# That user didn't get created (see above), so we remove the file
# which means we'll run as nobody.
rm /etc/default/oidentd

/etc/init.d/oidentd start |
  grep -v "Starting ident" | grep -v "\.\.\.done"

# A bunch of silly stuff is allowed, which we don't want.
sed -i s/allow/deny/ /etc/oidentd.conf
