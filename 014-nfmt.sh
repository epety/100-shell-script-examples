#!/bin/sh

# nfmt - A version of fmt, using nroff. Adds two useful flags: -w X for 
# line width and -h to enable hyphenation for better fills.

while getopts "hw:" opt; do
  case $opt in
    h ) hyph=1    	    ;;
    w ) width="$OPTARG"    ;;
  esac
done
shift $(($OPTIND - 1))

nroff << EOF
.ll ${width:-72}
.na
.hy ${hyph:-0}
.pl 1
$(cat "$@")
EOF

exit 0
