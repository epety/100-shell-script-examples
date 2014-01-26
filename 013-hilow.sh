#!/bin/sh
# hilow - a simple number guessing game

biggest=100                             # maximum number possible
guess=0                                 # guessed by player
guesses=0                               # number of guesses made
number=$(( $$ % $biggest ))             # random number, 1 .. $biggest

while [ $guess -ne $number ] ; do
  echo -n "Guess? " ; read guess
  if [ "$guess" -lt $number ] ; then
    echo "... bigger!"
  elif [ "$guess" -gt $number ] ; then
    echo "... smaller!"
  fi
  guesses=$(( $guesses + 1 ))
done

echo "Right!! Guessed $number in $guesses guesses."

exit 0
