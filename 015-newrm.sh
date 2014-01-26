#!/bin/sh

# newrm - a replacement for the existing rm command that allows a 
#   rudimentary unremove capability through utilizing a newly created
#   directory in the user's home directory. It can handle directories
#   of content as well as individual files, and if the user specifies
#   the -f flag, files are NOT archived, but removed.

# Big Important Warning: you'll want a cron job or similar to keep the
#   individual trash directories tamed, otherwise nothing will ever 
#   actually be deleted on the system and you'll run out of disk space!

 mydir="$HOME/.deleted-files"
realrm="/bin/rm "
  copy="/bin/cp -R"

if [ $# -eq 0 ] ; then  # let 'rm' ouptut the usage error 
  exec $realrm	# our shell dies and is replaced by /bin/rm
fi

# parse all options looking for '-f'

flags=""

while getopts "dfiPRrvW" opt
do
  case $opt in
    f ) exec $realrm "$@"     ;;  # exec lets us exit this script directly.
    * ) flags="$flags -$opt"  ;;  # other flags are for 'rm', not us
  esac
done
shift $(( $OPTIND - 1 ))

# make sure that the $mydir exists

if [ ! -d $mydir ] ; then
  if [ ! -w $HOME ] ; then
    echo "$0 failed: can't create $mydir in $HOME" >&2 
    exit 1
  fi
  mkdir $mydir
  chmod 700 $mydir	# a little bit of privacy, please
fi

for arg 
do
  newname="$mydir/$(date "+%S.%M.%H.%d.%m").$(basename "$arg")"
  if [ -f "$arg" ] ; then
    $copy "$arg" "$newname"
  elif [ -d "$arg" ] ; then
    $copy "$arg" "$newname"
  fi
done

exec $realrm $flags "$@"	# our shell is replaced by realrm
