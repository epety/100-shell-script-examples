#!/bin/sh 

# checkexternal - traverse all internal URLs on a Web site to build a
#   list of external references, then check each one to ascertain
#   which might be dead or otherwise broken. The -a flag forces the
#   script to list all matches, whether they're accessible or not: by
#   default only unreachable links are shown.

lynx="/usr/local/bin/lynx"      # might need to be tweaked
listall=0; errors=0             # shortcut: two vars on one line!

if [ "$1" = "-a" ] ; then
  listall=1; shift
fi

outfile="$(echo "$1" | cut -d/ -f3).external-errors"

/bin/rm -f $outfile     # clean it for new output

trap "/bin/rm -f traverse*.errors reject*.dat traverse*.dat" 0 

if [ -z "$1" ] ; then
  echo "Usage: $(basename $0) [-a] URL" >&2
  exit 1
fi

# create the data files needed
$lynx -traversal $1 > /dev/null;

if [ -s "reject.dat" ] ; then 
  # The following line has a trailing space after the backslash!
  echo -n $(sort -u reject.dat | wc -l) external links encountered
  echo \ in $(grep '^http' traverse.dat | wc -l) pages

  for URL in $(grep '^http:' reject.dat | sort -u)
  do
    if ! $lynx -dump $URL > /dev/null 2>&1 ; then
      echo "Failed : $URL" >> $outfile
      errors="$(( $errors + 1 ))"
    elif [ $listall -eq 1 ] ; then
      echo "Success: $URL" >> $outfile
    fi
  done

  if [ -s $outfile ] ; then
    cat $outfile
    echo "(A copy of this output has been saved in ${outfile})"
  elif [ $listall -eq 0 -a $errors -eq 0 ] ; then
    echo "No problems encountered."
  fi
else 
  echo -n "No external links encountered "
  echo  in $(grep '^http' traverse.dat | wc -l) pages.
fi

exit 0
