#!/bin/sh

# log Yahoo! search - given a search request, log the pattern, then
#    feed the entire sequence to the real Yahoo search system.

logfile="/home/taylor/scripts/searchlog.txt"

if [ ! -f $logfile ] ; then
  touch $logfile
  chmod a+rw $logfile
fi

if [ -w $logfile ] ; then
  echo "$(date): $QUERY_STRING" | sed 's/p=//g;s/+/ /g' >> $logfile
fi

# echo "Content-type: text/html"
# echo ""

echo "Location: http://search.yahoo.com/bin/search?$QUERY_STRING"
echo ""

exit 0
