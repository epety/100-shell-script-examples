#!/bin/sh

# nicenumber - given a number, show it with comma separated values
#    expects DD and TD to be instantiated. instantiates nicenum
#    or, if a second arg is specified, the output is echoed to stdout

nicenumber()
{
  # Note that we use the '.' as the decimal separator for parsing
  # the INPUT value to this script. The output value is as specified
  # by the user with the -d flag, if different from a '.'
  
  integer=$(echo $1 | cut -d. -f1)		# left of the decimal
  decimal=$(echo $1 | cut -d. -f2)		# right of the decimal
  
  if [ $decimal != $1 ]; then
    # there's a fractional part, let's include it.
    result="${DD:="."}$decimal"
  fi
  
  thousands=$integer
  
  while [ $thousands -gt 999 ]; do
    remainder=$(($thousands % 1000))	# three least significant digits
  
    while [ ${#remainder} -lt 3 ] ; do	# force leading zeroes as needed
      remainder="0$remainder"
    done
    
    thousands=$(($thousands / 1000))	# to left of remainder, if any
    result="${TD:=","}${remainder}${result}"	# builds right-to-left
  done
  
  nicenum="${thousands}${result}"
  if [ ! -z $2 ] ; then
    echo $nicenum
  fi
}
  
DD="."	# decimal point delimiter, between integer & fractional value
TD=","	# thousands delimiter, separates every three digits 
  
while getopts "d:t:" opt; do
  case $opt in
    d ) DD="$OPTARG"	;;
    t ) TD="$OPTARG"	;;
  esac
done

shift $(($OPTIND - 1))

if [ $# -eq 0 ] ; then
  cat << "EOF" >&2
Usage: $(basename $0) [-d c] [-t c] numeric value
       -d specifies the decimal point delimiter (default '.')
       -t specifies the thousands delimiter (default ',')
EOF
  exit 1
fi

nicenumber $1 1		# second arg forces this to 'echo' output

exit 0
