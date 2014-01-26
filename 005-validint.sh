#!/bin/sh
# validint - validate integer input, allow negative ints too

validint()
{
  # validate first field. Optionally test against min value $2 and/or 
  # max value $3: if you'd rather skip these tests, send "" as values.
  # returns 1 for error, 0 for success.

  number="$1";	    min="$2";	   max="$3"

  if [ -z $number ] ; then
    echo "You didn't enter anything. Unacceptable." >&2 ; return 1
  fi
  
  if [ "${number%${number#?}}" = "-" ] ; then	# first char '-' ?
    testvalue="${number#?}" 	# all but first character
  else
    testvalue="$number"
  fi
  
  nodigits="$(echo $testvalue | sed 's/[[:digit:]]//g')"
  
  if [ ! -z $nodigits ] ; then
    echo "Invalid number format! Only digits, no commas, spaces, etc." >&2
    return 1
  fi
  
  if [ ! -z $min ] ; then
    if [ "$number" -lt "$min" ] ; then
       echo "Your value is too small: smallest acceptable value is $min" >&2
       return 1
    fi
  fi
  if [ ! -z $max ] ; then
     if [ "$number" -gt "$max" ] ; then
       echo "Your value is too big: largest acceptable value is $max" >&2
       return 1
     fi
  fi
  return 0
}

# uncomment these lines to test, but beware that it'll break Hack #6
# because Hack #6 wants to source this file to get the validint()
# function. :-)

# if validint "$1" "$2" "$3" ; then
#   echo "That input is a valid integer value within your constraints"
# fi
