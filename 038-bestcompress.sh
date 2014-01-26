#!/bin/sh

# bestcompress - given a file, try compressing it with all the available
#   compression tools and keep the compressed file that's smallest, reporting 
#   the result to the user.  If '-a' isn't specified, it skips compressed
#   files in the input stream.

Z="compress"
gz="gzip" 
bz="bzip2"
Zout="/tmp/bestcompress.$$.Z"
gzout="/tmp/bestcompress.$$.gz"
bzout="/tmp/bestcompress.$$.bz"
skipcompressed=1

if [ "$1" = "-a" ] ; then
  skipcompressed=0  ; shift
fi

if [ $# -eq 0 ]; then
  echo "Usage: $0 [-a] file or files to optimally compress" >&2; exit 1
fi

trap "/bin/rm -f $Zout $gzout $bzout" EXIT

for name 
do 
  if [ ! -f "$name" ] ; then 
    echo "$0: file $name not found. Skipped." >&2
    continue
  fi

  if [ "$(echo $name | egrep '(\.Z$|\.gz$|\.bz2$)')" != "" ] ; then
    if [ $skipcompressed -eq 1 ] ; then
      echo "Skipped file ${name}: it's already compressed." 
      continue
    else
      echo "Warning: Trying to double-compress $name" 
    fi
  fi

  $Z  < "$name" > $Zout  &
  $gz < "$name" > $gzout &
  $bz < "$name" > $bzout &
  
  wait	# run compressions in parallel for speed. Wait until all are done

  smallest="$(ls -l "$name" $Zout $gzout $bzout | \
     awk '{print $5"="NR}' | sort -n | cut -d= -f2 | head -1)"

  case "$smallest" in
     1 ) echo "No space savings by compressing $name. Left as-is."
	 ;;
     2 ) echo Best compression is with compress. File renamed ${name}.Z
         mv $Zout "${name}.Z" ; rm -f "$name"
	 ;;
     3 ) echo Best compression is with gzip. File renamed ${name}.gz
	 mv $gzout "${name}.gz" ; rm -f "$name"
	 ;;
     4 ) echo Best compression is with bzip2. File renamed ${name}.bz2
	 mv $bzout "${name}.bz2" ; rm -f "$name"
  esac

done

exit 0
