#!/bin/sh

# inpath - verify that a specified program is either valid as-is,
#   or can be found in the PATH directory list.

in_path()
{
  # given a command and the PATH, try to find the command. Returns
  # 0 if found and executable, 1 if not. Note that this temporarily modifies 
  # the the IFS (input field seperator), but restores it upon completion.
  # return variable 'directory' contains the directory where the 
  # command was found.

  cmd=$1        path=$2         retval=1
  oldIFS=$IFS   IFS=":"

  for directory in $path
  do
    if [ -x $directory/$cmd ] ; then
      retval=0      # if we're here, we found $cmd in $directory
    fi
  done
  IFS=$oldIFS
  return $retval
}

checkForCmdInPath()
{
  var=$1
  
  # The variable slicing notation in the following conditional 
  # needs some explanation: ${var#expr} returns everything after
  # the match for 'expr' in the variable value (if any), and
  # ${var%expr} returns everything that doesn't match (in this
  # case just the very first character. You can also do this in
  # Bash with ${var:0:1} and you could use cut too: cut -c1

  if [ "$var" != "" ] ; then
    if [ "${var%${var#?}}" = "/" ] ; then
      if [ ! -x $var ] ; then
        return 1
      fi
    elif ! in_path $var $PATH ; then
      return 2
    fi 
  fi
  return 0
}

# cnvalidate - Ensures that input only consists of alphabetical
#              and numeric characters.

cnvalidate()
{
  # validate arg: returns 0 if all upper+lower+digits, 1 otherwise

  # Remove all unacceptable chars
  compressed="$(echo $1 | sed -e 's/[^[:alnum:]]//g')"

  if [ "$compressed" != "$input" ] ; then
    return 1
  else
    return 0
  fi
}

monthnoToName()
{
  # sets the variable 'month' to the appropriate value
  case $1 in
    1 ) month="Jan"    ;;  2 ) month="Feb"    ;;
    3 ) month="Mar"    ;;  4 ) month="Apr"    ;;
    5 ) month="May"    ;;  6 ) month="Jun"    ;;
    7 ) month="Jul"    ;;  8 ) month="Aug"    ;;
    9 ) month="Sep"    ;;  10) month="Oct"    ;;
    11) month="Nov"    ;;  12) month="Dec"    ;;
    * ) echo "$0: Unknown numeric month value $1" >&2; exit 1
   esac
   return 0
}

# nicenumber - given a number, show it with comma separated values
#    expects DD and TD to be instantiated. instantiates nicenum
#    if arg2 is specified, this function echoes output, rather than
#    sending it back as a variable

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

# validint - validate integer input, allow negative ints too

validint()
{
  # validate first field. Optionally test against min value $2 and/or 
  # max value $3: if you'd rather skip these tests, send "" as values.
  # returns 1 for error, 0 for success

  number="$1";	    min="$2";	   max="$3"

  if [ -z "$number" ] ; then
    echo "You didn't enter anything. Unacceptable." >&2 ; return 1
  fi
  
  if [ "${number%${number#?}}" = "-" ] ; then	# first char '-' ?
    testvalue="${number#?}" 	# all but first character
  else
    testvalue="$number"
  fi
  
  nodigits="$(echo $testvalue | sed 's/[[:digit:]]//g')"
  
  if [ ! -z "$nodigits" ] ; then
    echo "Invalid number format! Only digits, no commas, spaces, etc." >&2
    return 1
  fi
  
  if [ ! -z "$min" ] ; then
    if [ "$number" -lt "$min" ] ; then
       echo "Your value is too small: smallest acceptable value is $min" >&2
       return 1
    fi
  fi
  if [ ! -z "$max" ] ; then
     if [ "$number" -gt "$max" ] ; then
       echo "Your value is too big: largest acceptable value is $max" >&2
       return 1
     fi
  fi
  return 0
}

# validfloat - test whether a number is a valid floating point value.
#    Note that this cannot accept scientific (1.304e5) notation.

# To test whether an entered value is a valid floating point number, we
# need to split the value at the decimal point, then test the first part
# to see if it's a valid integer, then the second part to see if it's a 
# valid >=0 integer, so -30.5 is valid, but -30.-8 isn't.  Returns 0 on
# success, 1 on failure.

validfloat()
{
  fvalue="$1"

  if [ ! -z "$(echo $fvalue | sed 's/[^.]//g')" ] ; then

    decimalPart="$(echo $fvalue | cut -d. -f1)"
    fractionalPart="$(echo $fvalue | cut -d. -f2)"

    if [ ! -z "$decimalPart" ] ; then
      if ! validint "$decimalPart" "" "" ; then
        return 1
      fi 
    fi

    if [ "${fractionalPart%${fractionalPart#?}}" = "-" ] ; then
      echo "Invalid floating point number: '-' not allowed \
        after decimal point" >&2 
      return 1
    fi 
    if [ "$fractionalPart" != "" ] ; then 
      if ! validint "$fractionalPart" "0" "" ; then
        return 1
      fi
    fi

    if [ "$decimalPart" = "-" -o -z "$decimalPart" ] ; then
      if [ -z "$fractionalPart" ] ; then
        echo "Invalid floating point format." >&2 ; return 1
      fi 
    fi

  else
    if [ "$fvalue" = "-" ] ; then
      echo "Invalid floating point format." >&2 ; return 1
    fi

    if ! validint "$fvalue" "" "" ; then
      return 1
    fi
  fi

  return 0
}

exceedsDaysInMonth()
{
  # given a month name, return 0 if the specified day value is
  # less than or equal to the max days in the month, 1 otherwise

  case $(echo $1|tr '[:upper:]' '[:lower:]') in
    jan* ) days=31    ;;  feb* ) days=28    ;;
    mar* ) days=31    ;;  apr* ) days=30    ;;
    may* ) days=31    ;;  jun* ) days=30    ;;
    jul* ) days=31    ;;  aug* ) days=31    ;;
    sep* ) days=30    ;;  oct* ) days=31    ;;
    nov* ) days=30    ;;  dec* ) days=31    ;;
    * ) echo "$0: Unknown month name $1" >&2; exit 1
   esac
   
   if [ $2 -lt 1 -o $2 -gt $days ] ; then
     return 1
   else
     return 0	# all is well
   fi 
}

isLeapYear()
{    
  # this function returns 0 if a leap year, 1 otherwise
  # The formula for checking whether a year is a leap year is: 
  # 1. years divisible by four are leap years, unless..
  # 2. years also divisible by 100 are not leap years, except...
  # 3. years divisible by 400 are leap years

  year=$1
  if [ "$((year % 4))" -ne 0 ] ; then
    return 1 # nope, not a leap year
  elif [ "$((year % 400))" -eq 0 ] ; then
    return 0 # yes, it's a leap year
  elif [ "$((year % 100))" -eq 0 ] ; then
    return 1
  else
    return 0
  fi 
}

validdate()
{
  # expects three values, month, day and year. Returns 0 if success.

  newdate="$(normdate "$@")"

  if [ $? -eq 1 ] ; then
    exit 1	# error condition already reported by normdate
  fi

  month="$(echo $newdate | cut -d\  -f1)"
    day="$(echo $newdate | cut -d\  -f2)"
   year="$(echo $newdate | cut -d\  -f3)"

  # Now that we have a normalized date, let's check to see if the
  # day value is logical 

  if ! exceedsDaysInMonth $month "$2" ; then
    if [ "$month" = "Feb" -a $2 -eq 29 ] ; then
      if ! isLeapYear $3 ; then
        echo "$0: $3 is not a leap year, so Feb doesn't have 29 days" >&2
        exit 1
      fi
    else 
      echo "$0: bad day value: $month doesn't have $2 days" >&2
      exit 1
    fi
  fi
  return 0
}

echon()
{
  echo "$*" | tr -d '\n'
}

initializeANSI()
{
  esc=""

  blackf="${esc}[30m";   redf="${esc}[31m";    greenf="${esc}[32m"
  yellowf="${esc}[33m"   bluef="${esc}[34m";   purplef="${esc}[35m"
  cyanf="${esc}[36m";    whitef="${esc}[37m"
  
  blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
  yellowb="${esc}[43m"   blueb="${esc}[44m";   purpleb="${esc}[45m"
  cyanb="${esc}[46m";    whiteb="${esc}[47m"

  boldon="${esc}[1m";    boldoff="${esc}[22m"
  italicson="${esc}[3m"; italicsoff="${esc}[23m"
  ulon="${esc}[4m";      uloff="${esc}[24m"
  invon="${esc}[7m";     invoff="${esc}[27m"

  reset="${esc}[0m"
}
