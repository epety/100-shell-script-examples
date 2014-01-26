#!/bin/sh

# rotatelogs - roll logfiles in /var/log for archival purposes.
#    uses a config file to allow customization of how frequently
#    each log should be rolled. That file is in 
#       logfilename=duration
#    format, where duration is in days. If nothing is configured,
#    rotatelogs won't rotate more frequently than every seven days.

logdir="/var/log"
config="/var/log/rotatelogs.conf"
mv="/bin/mv"
default_duration=7
count=0

duration=$default_duration

if [ ! -f $config ] ; then
  echo "$0: no config file found. Can't proceed." >&2; exit 1
fi

if [ ! -w $logdir -o ! -x $logdir ] ; then
  echo "$0: you don't have the appropriate permissions in $logdir" >&2
  exit 1
fi

cd $logdir

# While we'd like to use ':digit:' with the find, many versions of
# find don't support Posix character class identifiers, hence [0-9]

for name in $(find . -type f -size +0c ! -name '*[0-9]*' \
     ! -name '\.*' ! -name '*conf' -maxdepth 1 -print | sed 's/^\.\///')
do

  count=$(( $count + 1 ))

  # grab this entry from the config file

  duration="$(grep "^${name}=" $config|cut -d= -f2)"

  if [ -z $duration ] ; then 
    duration=$default_duration
  elif [ "$duration" = "0" ] ; then
    echo "Duration set to zero: skipping $name"
    continue
  fi

  back1="${name}.1"; back2="${name}.2";
  back3="${name}.3"; back4="${name}.4";

  # If the most recently rolled log file (back1) has been modified within 
  # the specific quantum then it's not time to rotate it.

  if [ -f "$back1" ] ; then
    if [ -z $(find "$back1" -mtime +$duration -print 2>/dev/null) ] 
    then
      echo "$name's most recent backup is more recent than $duration days: skipping"
      continue
    fi
  fi

  echo "Rotating log $name (using a $duration day schedule)"

  # rotate, starting with the oldest log
  if [ -f "$back3" ] ; then
    echo "... $back3 -> $back4" ; $mv -f "$back3" "$back4"
  fi
  if [ -f "$back2" ] ; then
    echo "... $back2 -> $back3" ; $mv -f "$back2" "$back3"
  fi
  if [ -f "$back1" ] ; then
    echo "... $back1 -> $back2" ; $mv -f "$back1" "$back2"
  fi
  if [ -f "$name" ] ; then
    echo "... $name -> $back1" ; $mv -f "$name" "$back1"
  fi
  touch "$name"
  chmod 0600 "$name"
done

if [ $count -eq 0 ] ; then
  echo "Nothing to do: no log files big enough or old enough to rotate"
fi

exit 0
