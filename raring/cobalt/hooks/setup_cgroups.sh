#!/bin/sh

apt-get install -qq cgroup-lite
apt-get install -qq cgroup-bin
dpkg -i hooks/debs/libpam-cgroup_0.38-1ubuntu2_amd64.deb

cat <<EOF > /etc/cgroups.conf
mount {
  cpu = /sys/fs/cgroup/cpu;
  cpuacct = /sys/fs/cgroup/cpuacct;
  memory = /sys/fs/cgroup/memory;
  blkio = /sys/fs/cgroup/blkio;
}
EOF

cat <<EOF > /etc/init/cgred.conf
# cgred

description "cgred"
author "Serge Hallyn <serge.hallyn@canonical.com>"

start on runlevel [2345]
stop on runlevel [016]

pre-start script
    test -x /usr/sbin/cgrulesengd || { stop; exit 0; }
end script

script
    # get default options
    OPTIONS=""
    if [ -r "/etc/default/cgred" ]; then
        . /etc/default/cgred
    fi

    # Make sure the kernel supports cgroups
    # This check is retained from the original sysvinit job, but should
    # be superfluous since we depend on cgconfig running, which will
    # have mounted this.
    grep -q "^cgroup" /proc/mounts || { stop; exit 0; }

    exec /usr/sbin/cgrulesengd --nodaemon \$OPTIONS
end script
EOF

touch ${STORAGE_DIR}/etc/cgrules.conf
ln -s ${STORAGE_DIR}/etc/cgrules.conf /etc/cgrules.conf

cgclear && cgconfigparser -l /etc/cgroups.conf
