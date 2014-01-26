#!/bin/sh

# trimmailbox - a simple script to ensure that only the four most recent
#    messages remain in the users mailbox. Works with Berkeley Mail 
#    (aka Mailx or mail): will need modifications for other mailers!!

keep=4	# by default, let's just keep around the four most recent messages

totalmsgs="$(echo 'x' | mail | sed -n '2p' | awk '{print $2}')"

if [ $totalmsgs -lt $keep ] ; then
  exit 0          # nothing to do
fi

topmsg="$(( $totalmsgs - $keep ))"

mail > /dev/null << EOF
d1-$topmsg
q
EOF

exit 0
