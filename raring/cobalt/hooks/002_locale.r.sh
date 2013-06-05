#!/bin/sh

# The base install comes with a default locale that isn't installed.
# (it's en_US.UTF-8 which is also pretty english- and US- centric)
# Replace with C.UTF-8 which is language and region neutral.

echo "LANG=C.UTF-8" > /etc/default/locale
