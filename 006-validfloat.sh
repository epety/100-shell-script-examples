#!/bin/sh

# validfloat - test whether a number is a valid floating point value.
#    Note that this cannot accept scientific (1.304e5) notation.

# To test whether an entered value is a valid floating point number, we
# need to split the value at the decimal point, then test the first part
# to see if it's a valid integer, then the second part to see if it's a 
# valid >=0 integer, so -30.5 is valid, but -30.-8 isn't.

. 005-validint.sh		# source the validint function

validfloat()
{
  fvalue="$1"

  if [ ! -z $(echo $fvalue | sed 's/[^.]//g') ] ; then

    decimalPart="$(echo $fvalue | cut -d. -f1)"
    fractionalPart="$(echo $fvalue | cut -d. -f2)"

    if [ ! -z $decimalPart ] ; then
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

    if [ "$decimalPart" = "-" -o -z $decimalPart ] ; then
      if [ -z $fractionalPart ] ; then
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

if validfloat $1 ; then
  echo "$1 is a valid floating point value"
fi

exit 0
