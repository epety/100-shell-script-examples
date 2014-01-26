#!/bin/sh

# check library - log in to the Boulder Public library computer
#     system and show the due date of everything checked out for
#     the specified user. A demonstration of how to work with the
#     method="post" form with lynx.

lib1="http://nell.boulder.lib.co.us/patroninfo"
lib2="items"
libacctdb="$HOME/.library.account.info"
postdata="/tmp/$(basename $0).$$"
awkdata="/tmp/$(basename $0).awk.$$"

# We need:  name   cardno   recordno
#  Given the first, look for the other two in the libraryaccount database

if [ $# -eq 0 ] ; then
  echo "Usage: $(basename $0) \"card holder\""; exit 0
fi

acctinfo="$(grep -i "$1" $libacctdb)"
name="$(echo $acctinfo | cut -d: -f1 | sed 's/ /+/g')"
cardno="$(echo $acctinfo | cut -d: -f2)"
recordno="$(echo $acctinfo | cut -d: -f3)"

if [ -z "$acctinfo" ] ; then
  echo "Problem: account \"$1\" not found in library account database."
  exit 1
elif [ $(grep -i "$1" $libacctdb | wc -l) -gt 1 ] ; then
  echo "Problem: account \"$1\" matches more than one record in library db."
  exit 1
elif [ -z "$cardno" -o -z "$recordno" ] ; then
  echo "Problem: card or record information corrupted in database."
  exit 1
fi

trap "/bin/rm -f $postdata $awkdata" 0

cat << EOF > $postdata
name=${name}&code=${cardno}&submit=Display+record+for+person+named+above
EOF

cat << "EOF" > $awkdata
{ if ( NR % 3 == 1) { title=$0 } 
  if ( NR % 3 == 2) { print $0 "|" title }
}
EOF

lynx -source -post-data "$lib1/$recordno/$lib2" < $postdata | \
  grep -E '(^<td |name=\"renew)' | \
  sed 's/<[^>]*>//g'   | \
  awk -f $awkdata | sort

exit 0
