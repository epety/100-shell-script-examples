#!/bin/sh

# getexchrate - scrape the current currency exchange rates 
#   from CNN's money and finance Web site.
#
# Without any flags, this grabs the exchange rate values if the
# current information is more than 12 hours old. It also shows 
# success upon completion: something to take into account if
# you run this from a cron job.

url="http://money.cnn.com/markets/currencies/crosscurr.html"
age="+720"	# 12 hours, in minutes
outf="/tmp/.exchangerate"

# Do we need the new exchange rate values?  Let's check to see:
# if the file is less than 12 hours old, the find fails ...

if [ -f $outf ] ; then
  if [ -z "$(find $outf -cmin $age -print)" ]; then
    echo "$0: exchange rate data is up-to-date." >&2
    exit 1
  fi
fi

# Actually get the latest exchange rates, translating into the
# format required by the exchrate script.

lynx -dump 'http://money.cnn.com/markets/currencies/crosscurr.html' | \
  grep -E '(Japan|Euro|Can|UK)' | \
  awk '{ if (NF == 5 ) { print $1"="$2} }' | \
  tr '[:upper:]' '[:lower:]' | \
  sed 's/dollar/cand/' > $outf

echo "Success. Exchange rates updated at $(date)."

exit 0
