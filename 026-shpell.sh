#!/bin/sh

# shpell - An interactive spell checking program that lets you step
#   through all known spelling errors in a document, indicate which
#   ones you'd like to fix (and the correction), then applies them
#   all to the file. The original version of the file is saved with a
#   .shp suffix and the new version replaces the old.
#
# Note that you need a standard 'spell' command for this to work, which
# might involve you installing aspell, ispell, or pspell on your system.

tempfile="/tmp/$0.$$"
changerequests="/tmp/$0.$$.sed"
spell="ispell -l"		# modify as neede for your own spell

trap "rm -f $tempfile $changerequests" EXIT HUP INT QUIT TERM

# include the ansi color sequence definitions

. 012-library.sh
initializeANSI

getfix()
{
  # asks for a correction. Keeps track of nesting,
  # and only level 1 can output "replacing" message.

  word=$1
  filename=$2
  misspelled=1

  while [ $misspelled -eq 1 ] 
  do
    echo ""; echo "${boldon}Misspelled word ${word}:${boldoff}"
    grep -n $word $filename | 
	sed -e 's/^/   /' -e "s/$word/$boldon$word$boldoff/g"
    echo -n "i)gnore, q)uit, or type replacement: "
    read fix
    if [ "$fix" = "q" -o "$fix" = "quit" ] ; then
      echo "Exiting without applying any fixes."; exit 0
    elif [ "${fix%${fix#?}}" = "!" ] ; then
      misspelled=0    # once we see spaces, we stop checking
      echo "s/$word/${fix#?}/g" >> $changerequests
    elif [ "$fix" = "i" -o -z "$fix" ] ; then
      misspelled=0
    else
      if [ ! -z "$(echo $fix | sed 's/[^ ]//g')" ] ; then
        misspelled=0    # once we see spaces, we stop checking
        echo "s/$word/$fix/g" >> $changerequests
      else
        # it's a single word replacement, let's spell check that too
        if [ ! -z "$(echo $fix | $spell)" ] ; then
          echo ""
          echo "*** Your suggested replacement $fix is misspelled."
	  echo "*** Prefix the word with '!' to force acceptance."
        else
          misspelled=0  # suggested replacement word is acceptable
          echo "s/$word/$fix/g" >> $changerequests
        fi
      fi
    fi
  done
}

### beginning of actual script body

if [ $# -lt  1 ] ; then
  echo "Usage: $0 filename" >&2 ; exit 1
fi

if [ ! -r $1 ] ; then 
  echo "$0: Cannot read file $1 to check spelling" >&2 ; exit 1
fi

# note that the following invocation fills $tempfile along the way

errors="$($spell < $1 | tee $tempfile | wc -l | sed 's/[^[:digit:]]//g')"

if [ $errors -eq 0 ] ; then 
  echo "There are no spelling errors in $1."; exit 0
fi

echo "We need to fix $errors misspellings in the document. Remember that the"
echo "default answer to the spelling prompt is 'ignore', if you're lazy."

touch $changerequests

for word in $(cat $tempfile)
do
  getfix $word $1 1
done

if [ $(wc -l < $changerequests) -gt 0 ] ; then
  sed -f $changerequests $1 > $1.new
  mv $1 $1.shp
  mv $1.new $1
  echo Done. Made $(wc -l < $changerequests) changes.
fi

exit 0
