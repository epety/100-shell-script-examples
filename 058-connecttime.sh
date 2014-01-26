#!/bin/sh

# connecttime - reports cumulative connection time for month/year entries
#  found in the system log file.

log="/var/log/system.log"
tempfile="/tmp/$0.$$"

trap "rm $tempfile" 0

cat << 'EOF' > $tempfile
BEGIN { 
  lastmonth=""; sum = 0
}
{ 
  if ( $1 != lastmonth && lastmonth != "" ) {
    if (sum > 60) { total = sum/60 " hours" } 
    else          { total = sum " minutes" }
    print lastmonth ": " total
    sum=0
  }
  lastmonth=$1
  sum += $8 
} 
END { 
  if (sum > 60) { total = sum/60 " hours" } 
  else          { total = sum " minutes" }
  print lastmonth ": " total
}
EOF

grep "Connect time" $log | awk -f $tempfile

exit 0
