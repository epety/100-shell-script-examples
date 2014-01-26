#!/bin/sh

# verifycron - script checks a crontab file to ensure that it's
#    formatted properly.  Expects standard cron notation of
#       min hr dom mon dow CMD    
#    where min is 0-59, hr 0-23, dom is 1-31, mon is 1-12 (or names)
#    and dow is 0-7 (or names).  Fields can have ranges (a-e), lists
#    separated by commas (a,c,z), or an asterisk. Note that the step 
#    value notation of Vixie cron is not supported (e.g., 2-6/2).


validNum()
{
  # return 0 if valid, 1 if not. Specify number and maxvalue as args
  num=$1   max=$2

  if [ "$num" = "X" ] ; then
    return 0
  elif [ ! -z $(echo $num | sed 's/[[:digit:]]//g') ] ; then
    return 1
  elif [ $num -lt 0 -o $num -gt $max ] ; then
    return 1
  else
    return 0
  fi
}

validDay()
{
  # return 0 if a valid dayname, 1 otherwise

  case $(echo $1 | tr '[:upper:]' '[:lower:]') in
    sun*|mon*|tue*|wed*|thu*|fri*|sat*) return 0 ;;
    X) return 0	;; # special case - it's an "*"
    *) return 1
  esac
}

validMon()
{
  # return 0 if a valid month name, 1 otherwise

   case $(echo $1 | tr '[:upper:]' '[:lower:]') in 
     jan*|feb*|mar*|apr*|may|jun*|jul*|aug*) return 0		;;
     sep*|oct*|nov*|dec*)		     return 0		;;
     X) return 0 ;; # special case, it's an "*"
     *) return 1	;;
   esac
}

fixvars()
{
  # translate all '*' into 'X' to bypass shell expansion hassles
  # save original as "sourceline" for error messages

  sourceline="$min $hour $dom $mon $dow $command"
   min=$(echo "$min" | tr '*' 'X')
  hour=$(echo "$hour" | tr '*' 'X')
   dom=$(echo "$dom" | tr '*' 'X')
   mon=$(echo "$mon" | tr '*' 'X')
   dow=$(echo "$dow" | tr '*' 'X')
}

if [ $# -ne 1 ] || [ ! -r $1 ] ; then
  echo "Usage: $0 usercrontabfile" >&2; exit 1
fi

lines=0  entries=0  totalerrors=0

while read min hour dom mon dow command
do
  lines="$(( $lines + 1 ))" 
  errors=0
  
  if [ -z "$min" -o "${min%${min#?}}" = "#" ] ; then
    continue	# nothing to check
  elif [ ! -z $(echo ${min%${min#?}} | sed 's/[[:digit:]]//') ] ;  then
    continue	# first char not digit: skip!
  fi

  entries="$(($entries + 1))"

  fixvars

  #### Broken into fields, all '*' replaced with 'X' 
  # minute check

  for minslice in $(echo "$min" | sed 's/[,-]/ /g') ; do
    if ! validNum $minslice 60 ; then
      echo "Line ${lines}: Invalid minute value \"$minslice\""
      errors=1
    fi
  done

  # hour check
  
  for hrslice in $(echo "$hour" | sed 's/[,-]/ /g') ; do
    if ! validNum $hrslice 24 ; then
      echo "Line ${lines}: Invalid hour value \"$hrslice\"" 
      errors=1
    fi
  done

  # day of month check

  for domslice in $(echo $dom | sed 's/[,-]/ /g') ; do
    if ! validNum $domslice 31 ; then
      echo "Line ${lines}: Invalid day of month value \"$domslice\""
      errors=1
    fi
  done

  # month check

  for monslice in $(echo "$mon" | sed 's/[,-]/ /g') ; do
    if ! validNum $monslice 12 ; then
      if ! validMon "$monslice" ; then
        echo "Line ${lines}: Invalid month value \"$monslice\""
        errors=1
      fi
    fi
  done

  # day of week check

  for dowslice in $(echo "$dow" | sed 's/[,-]/ /g') ; do
    if ! validNum $dowslice 7 ; then
      if ! validDay $dowslice ; then
        echo "Line ${lines}: Invalid day of week value \"$dowslice\""
        errors=1
      fi
    fi
  done

  if [ $errors -gt 0 ] ; then
    echo ">>>> ${lines}: $sourceline"
    echo ""
    totalerrors="$(( $totalerrors + 1 ))"
  fi
done < $1

echo "Done. Found $totalerrors errors in $entries crontab entries."

exit 0
