#!/bin/sh

# updatecounter - a tiny script that updates the counter file to
#   the value specified. Assumes that locking is done elsewhere.

if [ $# -ne 1 ] ; then
   echo "Usage: $0 countfile"; exit 1
fi

count="$(cat $1)"
newcount="$(( ${count:-0} + 1 ))"

echo "$newcount" > $1
chmod a+rw $1

exit 0

