#!/bin/sh

# getlinks - given a URL, return all of its internal and 
#   external links

if [ $# -eq 0 ] ; then
  echo "Usage: $0 [-d|-i|-x] url"  >&2
  echo "-d=domains only, -i=internal refs only, -x=external only" >&2
  exit 1
fi

if [ $# -gt 1 ] ; then
  case "$1" in
    -d) lastcmd="cut -d/ -f3 | sort | uniq"
        shift
        ;;
    -i) basedomain="http://$(echo $2 | cut -d/ -f3)/"
        lastcmd="grep \"^$basedomain\" | sed \"s|$basedomain||g\" | sort | uniq"
 	shift
	;;
    -x) basedomain="http://$(echo $2 | cut -d/ -f3)/"
        lastcmd="grep -v \"^$basedomain\" | sort | uniq"
	shift
	;;
     *) echo "$0: unknown option specified: $1" >&2; exit 1
  esac
else
  lastcmd="sort | uniq"
fi

lynx -dump "$1" | \
  sed -n '/^References$/,$p' | \
  grep -E '[[:digit:]]+\.' | \
  awk '{print $2}' | \
  cut -d\? -f1 | \
  eval $lastcmd

exit 0
