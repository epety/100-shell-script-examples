#!/bin/sh

# renicename - renice the job that matches the specified name.

user=""; tty=""; showpid=0; niceval="+1"	# initialize

while getopts "n:u:t:p" opt; do
  case $opt in
   n ) niceval="$OPTARG";		;;
   u ) if [ ! -z "$tty" ] ; then
	 echo "$0: error: -u and -t are mutually exclusive." >&2
	 exit 1
       fi
       user=$OPTARG			;;
   t ) if [ ! -z "$user" ] ; then
  	 echo "$0: error: -u and -t are mutually exclusive." >&2
	 exit 1
       fi
       tty=$OPTARG	     		;;
   p ) showpid=1;			;;
   ? ) echo "Usage: $0 [-n niceval] [-u user|-t tty] [-p] pattern" >&2
       echo "Default niceval change is \"$niceval\" (plus is lower" >&2 
       echo "priority, minus is higher, but only root can go below 0)" >&2
       exit 1
  esac
done
shift $(($OPTIND - 1))	# eat all the parsed arguments

if [ $# -eq 0 ] ; then
  echo "Usage: $0 [-n niceval] [-u user|-t tty] [-p] pattern" >&2
  exit 1
fi

if [ ! -z "$tty" ] ; then
  pid=$(ps cu -t $tty | awk "/ $1/ { print \\$2 }")
elif [ ! -z "$user" ] ; then
  pid=$(ps cu -U $user | awk "/ $1/ { print \\$2 }")
else
  pid=$(ps cu -U ${USER:-LOGNAME} | awk "/ $1/ { print \$2 }")
fi

if [ -z "$pid" ] ; then
  echo "$0: no processes match pattern $1" >&2 ; exit 1
elif [ ! -z "$(echo $pid | grep ' ')" ] ; then
  echo "$0: more than one process matches pattern ${1}:" 
  if [ ! -z "$tty" ] ; then
    runme="ps cu -t $tty"
  elif [ ! -z "$user" ] ; then
    runme="ps cu -U $user"
  else
    runme="ps cu -U ${USER:-LOGNAME}"
  fi
  eval $runme | \
      awk "/ $1/ { printf \"  user %-8.8s  pid %-6.6s  job %s\n\", \
      \$1,\$2,\$11 }"
  echo "Use -u user or -t tty to narrow down your selection criteria."
elif [ $showpid -eq 1 ] ; then
  echo $pid
else
  # ready to go: let's do it!
  echo -n "Renicing job \""
  echo -n $(ps cp $pid | sed 's/ [ ]*/ /g' | tail -1 |  cut -d\  -f5-)
  echo "\" ($pid)"
  renice $niceval $pid
fi

exit 0
