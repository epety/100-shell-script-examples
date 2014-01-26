#!/bin/sh

# specify palindrome possibility as args

if [ $# -eq 0 ] ; then
  echo Usage: $0 possible palindrome >&2
  exit 1
fi

testit="$(echo $@ | sed 's/[^[:alpha:]]//g' | tr '[:upper:]' '[:lower:]')"
backwards="$(echo $testit | rev)"

if [ "$testit" = "$backwards" ] ; then
  echo "$@ is a palindrome"
else
  echo "$@ is not a palindrome"
fi

exit 0
