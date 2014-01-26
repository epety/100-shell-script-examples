#!/bin/sh

# DOCRON - simple script to run the daily, weekly and monthly 
#          system cron jobs on a system where it's likely that
#          it'll be shut down at the usual time of day when 
#          this would occur.

rootcron="/etc/crontab"

if [ $# -ne 1 ] ; then
  echo "Usage: $0 [daily|weekly|monthly]" >&2
  exit 1
fi
  
if [ "$(id -u)" -ne 0 ] ; then
  echo "$0: Command must be run as 'root'" >&2
  exit 1
fi

job="$(awk "NR > 6 && /$1/ { for (i=7;i<=NF;i++) print \$i }" $rootcron)"

if [ -z $job ] ; then
  echo "$0: Error: no $1 job found in $rootcron" >&2
  exit 1
fi

SHELL=/bin/sh		# to be consistent with cron's default

eval $job
