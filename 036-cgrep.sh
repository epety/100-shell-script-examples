#!/bin/sh

# cgrep - grep with context display and highlighted pattern matches

context=0
esc=""   
bOn="${esc}[1m" bOff="${esc}[22m"
sedscript="/tmp/cgrep.sed.$$"
tempout="/tmp/cgrep.$$"

showMatches()
{
  matches=0

  echo "s/$pattern/${bOn}$pattern${bOff}/g" > $sedscript

  for lineno in $(grep -n "$pattern" $1 | cut -d: -f1)
  do 
    if [ $context -gt 0 ] ; then
      prev="$(( $lineno - $context ))"
      if [ "$(echo $prev | cut -c1)" = "-" ] ; then
        prev="0"
      fi
      next="$(( $lineno + $context ))"

      if [ $matches -gt 0 ] ; then
        echo "${prev}i\\" >> $sedscript
        echo "----" >> $sedscript
      fi
      echo "${prev},${next}p" >> $sedscript
    else
      echo "${lineno}p" >> $sedscript
    fi
    matches="$(( $matches + 1 ))"
  done

  if [ $matches -gt 0 ] ; then
    sed -n -f $sedscript $1 | uniq | more
  fi
}

trap "/bin/rm -f $tempout $sedscript" EXIT 

if [ -z "$1" ] ; then
  echo "Usage: $0 [-c X] pattern {filename}" >&2; exit 0
fi

if [ "$1" = "-c" ] ; then
  context="$2"
  shift; shift
elif [ "$(echo $1|cut -c1-2)" = "-c" ] ; then
  context="$(echo $1 | cut -c3-)"
  shift
fi

pattern="$1";  shift

if [ $# -gt 0 ] ; then
  for filename ; do 
    echo "----- $filename -----"
    showMatches $filename
  done
else
  cat - > $tempout	# save stream to a temp file
  showMatches $tempout
fi

exit 0
