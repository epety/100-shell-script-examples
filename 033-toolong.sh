#!/bin/sh
# toolong - only feed the fmt command those lines in the input stream 
#    that are longer than the specified length

width=72

if [ ! -r "$1" ] ; then
  echo "Usage: $0 filename" >&2; exit 1
fi

while read input
  do
     if [ ${#input} -gt $width ] ; then
       echo "$input" | fmt 
     else
       echo "$input"
     fi
  done < $1

exit 0

