#!/bin/sh

# counter - a simple text-based page counter, with appropriate locking

myhome="/home/taylor/web/wicked/examples"
counter="$myhome/counter.dat"
lockfile="$myhome/counter.lck"
updatecounter="$myhome/updatecounter"

# Note that this script is not intended to be called directly from
# a web browser so it doesn't use the otherwise obligatory
# content-type header material.

# ascertain whether we have lockf or lockfile system apps

if [ -z $(which lockf) ] ; then
  if [ -z $(which lockfile) ] ; then
    echo "(counter: no locking utility available)<br>"
    exit 0
  else # proceed with the lockfile command
    if [ ! -f $counter ] ; then
      echo "0"  # it'll be created shortly
    else
      cat $counter
    fi
     
     trap "/bin/rm -f $lockfile" 0

     lockfile -1 -l 10 -s 2 $lockfile
     if [ $? -ne 0 ] ; then
       echo "(counter: couldn't create lockfile in time)"
        exit 0
     fi
     $updatecounter $counter
  fi
else
  if [ ! -f $counter ] ; then
    echo "0"    # it'll be created shortly
  else
    cat $counter
  fi

  lockf -s -t 10 $lockfile $updatecounter $counter
  if [ $? -ne 0 ] ; then
    echo "(counter: couldn't create lockfile in time)"
  fi
fi

exit 0
