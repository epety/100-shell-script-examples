#!/bin/sh

# zcat, zmore, and zgrep - this script should be either symbolically
#   linked or hard linked to all three names - it allows users to work 
#   with compressed files transparently.

 Z="compress";  unZ="uncompress"  ;  Zlist=""
gz="gzip"    ; ungz="gunzip"      ; gzlist=""
bz="bzip2"   ; unbz="bunzip2"     ; bzlist=""

# First step is to try and isolate the filenames in the command line
# we'll do this lazily by stepping through each argument testing to 
# see if it's a filename or not. If it is, and it has a compression
# suffix, we'll uncompress the file, rewrite the filename, and proceed.
# When done, we'll recompress everything that was uncompressed.

for arg
do 
  if [ -f "$arg" ] ; then
    case $arg in
       *.Z) $unZ "$arg"
	    arg="$(echo $arg | sed 's/\.Z$//')"
            Zlist="$Zlist \"$arg\""
	    ;;

      *.gz) $ungz "$arg"
	    arg="$(echo $arg | sed 's/\.gz$//')"
            gzlist="$gzlist \"$arg\""
	    ;;

     *.bz2) $unbz "$arg"
	    arg="$(echo $arg | sed 's/\.bz2$//')"
            bzlist="$bzlist \"$arg\""	
	    ;;

    esac
  fi
  newargs="${newargs:-""} \"$arg\""
done

case $0 in
  *zcat*  ) eval  cat $newargs			;;
  *zmore* ) eval more $newargs			;;
  *zgrep* ) eval grep $newargs			;;
      *   ) echo "$0: unknown base name. Can't proceed." >&2; exit 1
esac

# now recompress everything

if [ ! -z "$Zlist" ] ; then
 eval $Z $Zlist
fi
if [ ! -z "$gzlist" ] ; then
 eval $gz $gzlist
fi
if [ ! -z "$bzlist" ] ; then
 eval $bz $bzlist 
fi

# and done

exit 0
