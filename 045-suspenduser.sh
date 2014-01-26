#!/bin/sh

## Suspend - suspend a user account for the indefinite future

homedir="/home"		# home directory for users
secs=10 		# seconds before user is logged out

if [ -z $1 ] ; then
  echo "Usage: $0 account" >&2 ; exit 1
elif [ "$(whoami)" != "root" ] ; then
  echo "Error. You must be 'root' to run this command." >&2; exit 1
fi

echo "Please change account $1 password to something new."
passwd $1

# Now, let's see if they're logged in, and if so, boot 'em

if [ ! -z $(who | grep $1) ] ; then

  tty="$(who | grep $1 | tail -1 | awk '{print $2}')"

  cat << "EOF" > /dev/$tty

*************************************************************
URGENT NOTICE FROM THE ADMINISTRATOR:

This account is being suspended at the request of management. 
You are going to be logged out in $secs seconds. Please immediately
shut down any processes you have running and log out.

If you have any questions, please contact your supervisor or 
John Doe, Director of Information Technology.
*************************************************************
EOF

  echo "(Warned $1, now sleeping $secs seconds)"

  sleep $secs

  killall -s HUP -u $1		# send hangup sig to their processes
  sleep 1			# give it a second...
  killall -s KILL -u $1		# and kill anything left

  echo "$(date): $1 was logged in. Just logged them out."
fi

# Finally, let's close off their home directory from prying eyes:

chmod 000 $homedir/$1

echo "Account $1 has been suspended."

exit 0
