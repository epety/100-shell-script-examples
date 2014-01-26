#!/bin/sh
# normdate - Normalizes month field in date specification
#    to three letters, first letter capitalized. A helper
#    function for hack #7, validdate.  Exits w/ zero if no error.

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

## Begin main script

if [ $# -eq 1 ] ; then	# try to compensate for / or - formats
  set -- $(echo $1 | sed 's/[\/\-]/ /g')
fi

if [ $# -ne 3 ] ; then
  echo "Usage: $0 month day year" >&2
  echo "Typical input formats are August 3 1962 and 8 3 2002" >&2
  exit 1
fi

if [ $3 -lt 99 ] ; then
 echo "$0: expected four-digit year value." >&2; exit 1
fi

if [ -z $(echo $1|sed 's/[[:digit:]]//g') ]; then
  monthnoToName $1
else
  # normalize to first three letters, first upper, rest lowercase
  month="$(echo $1|cut -c1|tr '[:lower:]' '[:upper:]')"
  month="$month$(echo $1|cut -c2-3 | tr '[:upper:]' '[:lower:]')"
fi

echo $month $2 $3

exit 0
