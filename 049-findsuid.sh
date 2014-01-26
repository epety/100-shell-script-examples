#!/bin/sh

# findsuid - find all SUID files or programs on the system other
#    than those that live in /bin and /usr/bin, and
#      output the matches in a friendly and useful format.

mtime="7"	# how far back (in days) to check for modified cmds
verbose=0	# by default, let's be quiet about things

if [ "$1" = "-v" ] ; then
  verbose=1
fi

for match in $(find /bin /usr/bin -type f -perm +4000 -print)
do
  if [ -x $match ] ; then

    owner="$(ls -ld $match | awk '{print $3}')"
    perms="$(ls -ld $match | cut -c5-10 | grep 'w')" 

    if [ ! -z $perms ] ; then
      echo "**** $match (writeable and setuid $owner)"
    elif [ ! -z $(find $match -mtime -$mtime -print) ] ; then
      echo "**** $match (modified within $mtime days and setuid $owner)"
    elif [ $verbose -eq 1 ] ; then
      lastmod="$(ls -ld $match | awk '{print $6, $7, $8}')"
      echo "     $match (setuid $owner, last modified $lastmod)"
    fi
  fi
done

exit 0

