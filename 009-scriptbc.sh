#!/bin/sh

# scriptbc - wrapper for 'bc' that returns the value of a formula

if [ $1 = "-p" ] ; then
  precision=$2
  shift 2
else
  precision=2		# default
fi

bc -q -l << EOF
scale=$precision
$*
quit
EOF

exit 0
