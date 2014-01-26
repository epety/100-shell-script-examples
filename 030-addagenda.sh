#!/bin/sh

# addagenda - prompt the user to add a new event for the Agenda script

agendafile="$HOME/.agenda"

isDayName()
{
  # return = 0 if all is well, 1 on error

  case $(echo $1 | tr '[[:upper:]]' '[[:lower:]]') in
   sun*|mon*|tue*|wed*|thu*|fri*|sat*) retval=0	;;
   * ) retval=1 ;;
  esac
  return $retval
}

isMonthName()
{
    case $(echo $1 | tr '[[:upper:]]' '[[:lower:]]') in 
      jan*|feb*|mar*|apr*|may*|jun*)	return 0	;;
      jul*|aug*|sep*|oct*|nov*|dec*)	return 0	;;
      * ) return 1 	;;
    esac
}

normalize()
{
  # return string with first char uppercase, next two lowercase
  echo -n $1 | cut -c1  | tr '[[:lower:]]' '[[:upper:]]'
  echo  $1 | cut -c2-3| tr '[[:upper:]]' '[[:lower:]]'
}
    
if [ ! -w $HOME ] ; then
  echo "$0: cannot write in your home directory ($HOME)" >&2
  exit 1
fi

echo "Agenda: The Unix Reminder Service"
echo -n "Date of event (day mon, day month year, or dayname): "
read word1 word2 word3 junk

if isDayName $word1 ; then
  if [ ! -z "$word2" ] ; then
    echo "Bad dayname format: just specify the day name by itself." >&2
    exit 1
  fi
  date="$(normalize $word1)"

else

  if [ -z "$word2" ] ; then
    echo "Bad dayname format: unknown day name specified" >&2
    exit 1
  fi

  if [ ! -z "$(echo $word1|sed 's/[[:digit:]]//g')" ]  ; then
    echo "Bad date format: please specify day first, by day number" >&2
    exit 1
  fi

  if [ "$word1" -lt 1 -o "$word1" -gt 31 ] ; then
    echo "Bad date format: day number can only be in range 1-31" >&2
    exit 1
  fi

  if ! isMonthName $word2 ; then
    echo "Bad date format: unknown month name specified." >&2
    exit 1
  fi

  word2="$(normalize $word2)"

  if [ -z "$word3" ] ; then
    date="$word1$word2"
  else
    if [ ! -z "$(echo $word3|sed 's/[[:digit:]]//g')" ] ; then
      echo "Bad date format: third field should be year." >&2
      exit 1
    elif [ $word3 -lt 2000 -o $word3 -gt 2500 ] ; then
      echo "Bad date format: year value should be 2000-2500" >&2
      exit 1
    fi
    date="$word1$word2$word3"
  fi
fi
    
echo -n "One line description: "
read description

# ready to write to datafile

echo "$(echo $date|sed 's/ //g')|$description" >> $agendafile

exit 0
