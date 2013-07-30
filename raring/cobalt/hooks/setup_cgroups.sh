#!/bin/sh

apt-get install -qq cgroup-lite
apt-get install -qq cgroup-bin

cat <<EOF > /etc/cgroups.conf
mount {
  cpu = /sys/fs/cgroup/cpu;
  cpuacct = /sys/fs/cgroup/cpuacct;
  memory = /sys/fs/cgroup/memory;
  blkio = /sys/fs/cgroup/blkio;
}
EOF

cgclear && cgconfigparser -l /etc/cgroups.conf
