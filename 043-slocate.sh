#!/bin/sh

# slocate - Try to search the user's secure locate database for the 
#    specified pattern. If none exists, output a warning and create
#    one. If secure locate db is empty, use system one instead.

locatedb="/var/locate.db"
slocatedb="$HOME/.slocatedb"

if [ "$1" = "--explain" ] ; then
  cat << "EOF" >&2
Warning: Secure locate keeps a private database for each user, and your 
database hasn't yet been created. Until it is (probably late tonight) 
I'll just use the public locate database, which will show you all 
publicly accessible matches, rather than those explicitly available to 
account ${USER:-$LOGNAME}.
EOF
  if [ "$1" = "--explain" ] ; then
    exit 0
  fi
  
  # before we go, create a .slocatedb so that cron will fill it
  # the next time the mkslocatedb script is run

  touch $slocatedb	# mkslocatedb will build it next time through
  chmod 600 $slocatedb  # start on the right foot with permissions

elif [ -s $slocatedb ] ; then
  locatedb=$slocatedb
else
  echo "Warning: using public database. Use \"$0 --explain\" for details." >&2
fi

if [ -z "$1" ] ; then
  echo "Usage: $0 pattern" >&2; exit 1
fi
 
exec grep -i "$1" $locatedb
