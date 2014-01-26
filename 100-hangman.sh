#!/bin/sh

# hangman - a rudimentary version of the hangman game. Instead of showing a
#   gradually embodied hanging man, this simply has a bad guess countdown.
#   You can optionally indicate steps from the gallows as the only arg.

wordlib="/usr/lib/games/long-words.txt"
randomquote="$HOME/bin/randomquote.sh"
empty="\."	# we need something for the sed [set] when $guessed=""
games=0

if [ ! -r $wordlib ] ; then
  echo "$0: Missing word library $wordlib" >&2
  echo "(online at http://www.intuitive.com/wicked/examples/long-words.txt" >&2
  echo "save the file as $wordlib and you're ready to play!)" >&2
  exit 1
fi

while [ "$guess" != "quit" ] ; do
  match="$($randomquote $wordlib)" 	# pick a new word from the library

  if [ $games -gt 0 ] ; then
    echo ""
    echo "*** New Game! ***"
  fi

  games="$(( $games + 1 ))"
  guessed=""  ; guess="" ; bad=${1:-6}
  partial="$(echo $match | sed "s/[^$empty${guessed}]/-/g")"

  while [ "$guess" != "$match" -a "$guess" != "quit" ] ; do

    echo ""
    if [ ! -z "$guessed" ] ; then
      echo -n "guessed: $guessed, "
    fi
    echo "steps from gallows: $bad, word so far: $partial"
 
    echo -n "Guess a letter: "
    read guess
    echo ""

    if [ "$guess" = "$match" ] ; then
      echo "You got it!"
    elif [ "$guess" = "quit" ] ; then
      sleep 0		# this is a 'no op' to avoid an error message on 'quit'
    elif [ $(echo $guess | wc -c | sed 's/[^[:digit:]]//g') -ne 2 ] ; then 
      echo "Uh oh: You can only guess a single letter at a time"
    elif [ ! -z "$(echo $guess | sed 's/[[:lower:]]//g')" ] ; then
      echo "Uh oh: Please only use lowercase letters for your guesses"
    elif [ -z "$(echo $guess | sed "s/[$empty$guessed]//g")" ] ; then
      echo "Uh oh: You have already tried $guess"
    elif [ "$(echo $match | sed "s/$guess/-/g")" != "$match" ] ; then
      guessed="$guessed$guess"
      partial="$(echo $match | sed "s/[^$empty${guessed}]/-/g")"
      if [ "$partial" = "$match" ] ; then
        echo "** You've been pardoned!! Well done!  The word was \"$match\"."
        guess="$match" 
      else
        echo "* Great! The letter \"$guess\" appears in the word!"
      fi
    elif [ $bad -eq 1 ] ; then
      echo "** Uh oh: you've run out of steps. You're on the platform.. and <SNAP!>"
      echo "** The word you were trying to guess was \"$match\""
      guess="$match"
    else
      echo "* Nope, \"$guess\" does not appear in the word."
      guessed="$guessed$guess"
      bad=$(( $bad - 1 ))
    fi
  done
done

exit 0
