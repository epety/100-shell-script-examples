#!/bin/sh

# enabled - show what services are enabled with inetd and xinetd,
# if they're available on the system.

iconf="/etc/inetd.conf"
xconf="/etc/xinetd.conf"
xdir="/etc/xinetd.d"

if [ -r $iconf ] ; then
  echo "Services enabled in $iconf are:"
  grep -v '^#' $iconf | awk '{print "  " $1}'
  echo ""
  if [ "$(ps -aux | grep inetd | egrep -vE '(xinet|grep)')" = "" ] ; then
    echo "** warning: inetd does not appear to be running"
  fi
fi

if [ -r $xconf ] ; then
  # don't need to look in xinietd.conf, just know it exists
  echo "Services enabled in $xdir are:"

  for service in $xdir/*
  do
    if ! $(grep disable $service | grep 'yes' > /dev/null) ; then
      echo -n "  "
      basename $service
    fi
  done

  if ! $(ps -aux | grep xinetd | grep -v 'grep' > /dev/null) ; then
    echo "** warning: xinetd does not appear to be running"
  fi
fi

exit 0
