#!/bin/sh

# mklocatedb - build the locate database using find. Must be root to run this

locatedb="/var/locate.db"

if [ "$(whoami)" != "root" ] ; then
  echo "Must be root to run this command." >&2
  exit 1
fi

find / -print > $locatedb

exit 0
