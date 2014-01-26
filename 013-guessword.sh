#!/bin/sh
# guessword - a simple word guessing game a la hangman
blank=".................."	# must be longer than longest word

getword() 
{
  case $(( $$ % 8 )) in
    0 ) echo "pizzazz"    ;; 	1 ) echo "delicious"	;;
    2 ) echo "gargantuan" ;;	3 ) echo "minaret"	;;
    4 ) echo "paparazzi"  ;;    5 ) echo "delinquent"   ;;
    6 ) echo "zither"     ;;    7 ) echo "cuisine"	;;
  esac
}

addLetterToWord()
{
  # This function replaces all '.' in template with guess
  # then updates remaining to be the number of empty slots left

  letter=1
  while [ $letter -le $letters ] ; do
    if [ "$(echo $word | cut -c$letter)" = "$guess" ] ; then
      before="$(( $letter - 1 ))";  after="$(( $letter + 1 ))"
      if [ $before -gt 0 ]  ; then
        tbefore="$(echo $template | cut -c1-$before)"
      else
	tbefore=""
      fi
      if [ $after -gt $letters ] ; then
        template="$tbefore$guess"
      else
        template="$tbefore$guess$(echo  $template | cut -c$after-$letters)"
      fi
    fi
    letter=$(( $letter + 1 ))
  done

  remaining=$(echo $template|sed 's/[^\.]//g'|wc -c|sed 's/[[:space:]]//g')
  remaining=$(( $remaining - 1 ))	# fix to ignore '\n'
}

word=$(getword)
letters=$(echo $word | wc -c | sed 's/[[:space:]]//g')
letters=$(( $letters - 1 ))	# fix character count to ignore \n
template="$(echo $blank | cut -c1-$letters)"
remaining=$letters ; guessed="" ; guesses=0; badguesses=0

echo "** You're trying to guess a word with $letters letters **"

while [ $remaining -gt 0  ] ; do
  echo -n "Word is: $template  Try what letter next? " ; read guess
  guesses=$(( $guesses + 1 ))
  if echo $guessed | grep -i $guess > /dev/null ; then
    echo "You've already guessed that letter. Try again!"
  elif ! echo $word | grep -i $guess > /dev/null ; then
    echo "Sorry, the letter \"$guess\" is not in the word."
    guessed="$guessed$guess"
    badguesses=$(( $badguesses + 1 ))
  else
    echo "Good going!  The letter $guess is in the word!"
    addLetterToWord $guess
  fi
done

echo -n "Congratulations! You guessed $word in $guesses guesses"
echo " with $badguesses bad guesses"

exit 0
