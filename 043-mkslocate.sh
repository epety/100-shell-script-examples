#!/bin/sh

# mkslocatedb - build the central, public locate database as user nobody,
#    and simultaneously step through each home directory to find those
#    that contain a .slocatedb file. If found, an additional, private
#    version of the locate database will be created for that user.

locatedb="/var/locate.db"
slocatedb=".slocatedb"

if [ "$(whoami)" != "root" ] ; then
  echo "$0: Error: You must be root to run this command." >&2
  exit 1
fi

if [ "$(grep '^nobody:' /etc/passwd)" = "" ] ; then
  echo "$0: Error: you must have an account for user 'nobody'" >&2
  echo "to create the default slocate database." >&2; exit 1
fi

cd /		# sidestep post-su pwd permission problems

# first, create or update the public database
su -fm nobody -c "find / -print" > $locatedb 2>/dev/null
echo "building default slocate database (user = nobody)"
echo ... result is $(wc -l < $locatedb) lines long.


# now step through the user accounts on the system to see who has
# a $slocatedb file in their home directory....

for account in $(cut -d: -f1 /etc/passwd)
do
  homedir="$(grep "^${account}:" /etc/passwd | cut -d: -f6)"

  if [ "$homedir" = "/" ] ; then
    continue    # refuse to build one for root dir 
  elif [ -e $homedir/$slocatedb ] ; then
    echo "building slocate database for user $account"
    su -fm $account -c "find / -print" > $homedir/$slocatedb \
     2>/dev/null
    chmod 600 $homedir/$slocatedb
    chown $account $homedir/$slocatedb
    echo ... result is $(wc -l < $homedir/$slocatedb) lines long.
  fi
done

exit 0
