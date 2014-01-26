#!/bin/sh

# numberlines - a simple alternative to cat -n, etc

for filename 
do
  linecount="1"
  (while read line 
  do
    echo "${linecount}: $line"
    linecount="$(( $linecount + 1 ))"
  done) < $filename
done

exit 0
