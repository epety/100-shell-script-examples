#!/bin/sh

# getstats - every 'n' minutes, grab netstats values (via crontab)

logfile="/var/log/netstat.log"
temp="/tmp/getstats.tmp" 

trap "/bin/rm -f $temp" 0

( echo -n "time=$(date +%s);"

netstat -s -p tcp > $temp

sent="$(grep 'packets sent' $temp | cut -d\  -f1 | sed 's/[^[:digit:]]//g')"
resent="$(grep 'retransmitted' $temp | cut -d\  -f1 | sed 's/[^[:digit:]]//g')"
received="$(grep 'packets received$' $temp | cut -d\  -f1 | sed 's/[^[:digit:]]//g')"
dupacks="$(grep 'duplicate acks' $temp | cut -d\  -f1 | sed 's/[^[:digit:]]//g')"
outoforder="$(grep 'out-of-order packets' $temp | cut -d\  -f1 | sed 's/[^[:digit:]]//g')"
connectreq="$(grep 'connection requests' $temp | cut -d\  -f1 | sed 's/[^[:digit:]]//g')"
connectacc="$(grep 'connection accepts' $temp | cut -d\  -f1 | sed 's/[^[:digit:]]//g')"
retmout="$(grep 'retransmit timeouts' $temp | cut -d\  -f1 | sed 's/[^[:digit:]]//g')"

echo -n "snt=$sent;re=$resent;rec=$received;dup=$dupacks;"
echo -n "oo=$outoforder;creq=$connectreq;cacc=$connectacc;"
echo "reto=$retmout"

) >> $logfile

exit 0
