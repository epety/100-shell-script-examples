#!/bin/sh

#  remember - an easy command-line based memory pad
#    search the results with 'remindme'

rememberfile="$HOME/.remember"

if [ $# -eq 0 ] ; then
  echo "Enter note, end with ^D: "
  cat - >> $rememberfile
else
  echo "$@" >> $rememberfile
fi

exit 0
