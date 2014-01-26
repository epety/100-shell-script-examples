#!/bin/sh

# checklinks - traverse all internal URLs on a Web site, reporting
#   any errors in the "traverse.errors" file.

lynx="/usr/local/bin/lynx"      # this might need to be tweaked

# remove all the lynx traversal output files upon completion:
trap "/bin/rm -f traverse*.errors reject*.dat traverse*.dat" 0

if [ -z "$1" ] ; then
  echo "Usage: checklinks URL" >&2 ; exit 1
fi

$lynx -traversal "$1" > /dev/null

if [ -s "traverse.errors" ] ; then
 echo -n $(wc -l < traverse.errors) errors encountered.
 echo \ Checked $(grep '^http' traverse.dat | wc -l) pages at ${1}:
 sed "s|$1||g" < traverse.errors
else
 echo -n "No errors encountered. ";
 echo Checked $(grep '^http' traverse.dat | wc -l) pages at ${1}
 exit 0
fi

baseurl="$(echo $1 | cut -d/ -f3)"
mv traverse.errors ${baseurl}.errors
echo "(A copy of this output has been saved in ${baseurl}.errors)"

exit 0
