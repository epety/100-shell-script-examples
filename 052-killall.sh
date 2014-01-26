#!/bin/sh

# killall - send the specified signal to all processes that match a 
#   specific process name

# By default it only kills processes owned by the same user, unless
#   you're root. Use -s SIGNAL to specify a signal to send, -u user to 
#   specify user, -t tty to specify a tty, and -n to only show what'd
#   be done rather than doing it

signal="-INT"	# default signal
user=""   tty=""   donothing=0

while getopts "s:u:t:n" opt; do
  case "$opt" in
        # note the trick below: kill wants -SIGNAL but we're asking
   	# for SIGNAL, so we slip the '-' in as part of the assignment
    s ) signal="-$OPTARG";		;;
    u ) if [ ! -z "$tty" ] ; then
	   echo "$0: error: -u and -t are mutually exclusive." >&2
	   exit 1
         fi
         user=$OPTARG;			;;
    t ) if [ ! -z "$user" ] ; then
	   echo "$0: error: -u and -t are mutually exclusive." >&2
	   exit 1
         fi
         tty=$2;			;;
    n ) donothing=1;			;;
    ? ) echo "Usage: $0 [-s signal] [-u user|-t tty] [-n] pattern" >&2
        exit 1
  esac
done

shift $(( $OPTIND - 1 ))

if [ $# -eq 0 ] ; then
  echo "Usage: $0 [-s signal] [-u user|-t tty] [-n] pattern" >&2
  exit 1
fi

if [ ! -z "$tty" ] ; then
  pids=$(ps cu -t $tty | awk "/ $1$/ { print \$2 }")
elif [ ! -z "$user" ] ; then
  pids=$(ps cu -U $user | awk "/ $1$/ { print \$2 }")
else
  pids=$(ps cu -U ${USER:-LOGNAME} | awk "/ $1$/ { print \$2 }")
fi

if [ -z "$pids" ] ; then
  echo "$0: no processes match pattern $1" >&2; exit 1
fi

for pid in $pids
do
  # Sending signal $signal to process id $pid: kill might 
  # still complain if the process has finished, user doesn't
  # have permission, etc, but that's okay. 
  if [ $donothing -eq 1 ] ; then
    echo "kill $signal $pid"
  else
    kill $signal $pid
  fi
done

exit 0
