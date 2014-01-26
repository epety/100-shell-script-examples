#!/bin/sh

# enginehits - extract and analyze search engine traffic in the 
#    referrer field of a Common Log Format access log for a
#    specified domain name.

maxmatches=25
count=0
temp="/tmp/$(basename $0).$$"

trap "/bin/rm -f $temp" 0

if [ $# -eq 0 -o ! -f "$1" ] ; then
  echo "Usage: $(basename $0) logfile searchdomain" >&2
  exit 1
fi

for URL in $(awk '{ if (length($11) > 4) { print $11 } }' "$1" | \
  grep $2)
do
  args="$(echo $URL | cut -d\? -f2 | tr '&' '\n' | \
     grep -E '(^q=|^sid=|^p=|query=|item=|ask=|name=|topic=)' | \
     cut -d= -f2)"
  echo $args  | sed -e 's/+/ /g' -e 's/"//g' >> $temp
  count="$(( $count + 1 ))"
done

echo "Search engine referrer info extracted $2 searches from ${1}:"

sort $temp | uniq -c | sort -rn | head -$maxmatches | sed 's/^/  /g'

echo ""
echo Scanned $count $2 entries in log file out of $(wc -l < "$1") total.

exit 0
