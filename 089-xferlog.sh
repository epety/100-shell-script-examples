#!/bin/sh

# xferlog - analyze and summarize the FTP transfer log. A good doc 
#   detailing the log format: http://aolserver.am.net/docs/2.3/ftp-ch4.htm

stdxferlog="/var/log/xferlog"
temp="/tmp/$(basename $0).$$"
nicenum="$HOME/bin/nicenumber"

trap "/bin/rm -f $temp" 0

extract()
{
  # called with $1 = desired accessmode, $2 = section name for output

  if [ ! -z "$(echo $accessmode | grep $1)" ] ; then

    echo "" ; echo "$2"

    if [ "$1" = "a" -o "$1" = "g" ] ; then
      echo "  common account (entered password) values:"
    else
      echo "  user accounts accessing server: "
    fi
    awk "\$13 == \"$1\" { print \$14 }" $log | sort | \
        uniq -c | sort -rn | head -10 | sed 's/^/    /'

    awk "\$13 == \"$1\" && \$12 == \"o\" { print \$9 }" $log | sort | \
      uniq -c | sort -rn | head -10 | sed 's/^/    /' > $temp
    if [ -s $temp ] ; then
      echo "  files downloaded from server:" ; cat $temp
    fi

    awk "\$13 == \"$1\" && \$12 == \"i\" { print \$9 }" $log | sort | \
      uniq -c | sort -rn | head -10 | sed 's/^/    /' > $temp

    if [ -s $temp ] ; then
      echo "  files uploaded to server:" ; cat $temp
    fi
  fi
}

###### the main script block

case $# in
  0 ) log=$stdxferlog		;;
  1 ) log="$1"			;;
  * ) echo "Usage: $(basename $0) {xferlog name}" >&2
      exit 1
esac

if [ ! -r $log ] ; then
  echo "$(basename $0): can't read $log." >&2
  exit 1
fi

# Ascertain whether it's an abbreviated or standard ftp log file format. If 
# it's the abbreviated format, output some minimal statistical data and quit: 
# the format is too difficult to analyze in a short script, unfortunately.

if [ ! -z $(awk '$6 == "get" { short=1 } END{ print short }' $log) ] ; then
  bytesin="$(awk 'BEGIN{sum=0} $6 == "get" {sum += $9} END{ print sum }' $log )"
  bytesout="$(awk 'BEGIN{sum=0} $6 == "put" {sum += $9} END{ print sum }' $log )"

  echo -n "Abbreviated ftpd xferlog from "
  echo -n $(head -1 $log | awk '{print $1, $2, $3 }')
  echo    " to $(tail -1 $log | awk '{print $1, $2, $3}')"
  echo "       bytes in: $($nicenum $bytesin)"
  echo "      bytes out: $($nicenum $bytesout)"
  exit 0
fi
  
bytesin="$(awk 'BEGIN{sum=0}   $12 == "i" {sum += $8} END{ print sum }' $log )"
bytesout="$(awk 'BEGIN{sum=0} $12 == "o" {sum += $8} END{ print sum }' $log )"
time="$(awk 'BEGIN{sum=0} {sum += $6} END{ print sum }' $log)"

echo -n "Summary of xferlog from "
echo -n $(head -1 $log | awk '{print $1, $2, $3, $4, $5 }')
echo    " to $(tail -1 $log | awk '{print $1, $2, $3, $4, $5}')"
echo "       bytes in: $($nicenum $bytesin)"
echo "      bytes out: $($nicenum $bytesout)"
echo "  transfer time: $time seconds"

accessmode="$(awk '{print $13}' $log | sort -u)"

extract "a" "Anonymous Access"
extract "g" "Guest Account Access"
extract "r" "Real User Account Access"

exit 0
