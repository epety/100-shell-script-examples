#!/bin/sh

# randomquote - given a one-line-per-entry datafile, this 
#   script will randomly pick one and display it. Best used
#   as an SSI call within a Web page.

awkscript="/tmp/randomquote.awk.$$"

if [ $# -ne 1 ] ; then
  echo "Usage: randomquote datafilename" >&2
  exit 1
elif [ ! -r "$1" ] ; then
  echo "Error: quote file $1 is missing or not readable" >&2
  exit 1
fi

trap "/bin/rm -f $awkscript" 0

cat << "EOF" > $awkscript
BEGIN { srand(); }
      { s[NR] = $0 } 
END   { print s[randint(NR)] } 
function randint(n) { return int (n * rand() ) + 1 }
EOF

awk -f $awkscript < "$1"

exit 0
