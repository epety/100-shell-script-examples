#!/bin/sh

# streamfile - output an HTML file, replacing the sequence
#   ---countervalue--- with the current counter value.

infile="page-with-counter.html"
counter="./counter.cgi"

echo "Content-type: text/html"
echo ""

value="$(counter)"

sed "s/---countervalue---/$value/g" < $infile

exit 0
