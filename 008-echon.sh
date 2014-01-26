#!/bin/sh

# echon - a script to emulate the -n flag functionality with 'echo' 
#   for Unix systems that don't have that available.

echon()
{
  echo "$*" | tr -d '\n'
}

echon "this is a test: "
read answer

echon this is a test too " "
read answer2
