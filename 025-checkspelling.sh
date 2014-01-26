#!/bin/sh

# checkspelling - check the spelling of a word

spell="ispell -l"	  # if you have ispell installed instead
			  # if not, just define spell=spell or
			  # equivalent.

if [ $# -lt  1 ] ; then
  echo "Usage: $0 word or words" >&2 
  exit 1
fi

for word
do 
  if [ -z $(echo $word | $spell) ] ; then
    echo "$word:		spelled correctly."
  else
    echo "$word:		misspelled."
  fi
done

exit 0
