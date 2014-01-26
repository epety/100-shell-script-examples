#!/bin/sh

# formatdir - output a directory listing in a friendly and useful format

gmk()
{
  # given input in Kb, output in Kb, Mb or Gb for best output format
  if [ $1 -ge 1000000 ] ; then
    echo "$(scriptbc -p 2 $1 / 1000000)Gb"
  elif [ $1 -ge 1000 ] ; then
    echo  "$(scriptbc -p 2 $1 / 1000)Mb"
  else 
    echo "${1}Kb"
  fi
}

if [ $# -gt 1 ] ; then
  echo "Usage: $0 [dirname]" >&2; exit 1
elif [ $# -eq 1 ] ; then
  cd "$@"
fi

for file in *
do 
  if [ -d "$file" ] ; then
    size=$(ls "$file" | wc -l | sed 's/[^[:digit:]]//g')
    if [ $size -eq 1 ] ; then
      echo "$file ($size entry)|"
    else
      echo "$file ($size entries)|"
    fi
  else
    size="$(ls -sk "$file" | awk '{print $1}')"
    echo "$file ($(gmk $size))|"
  fi
done | \
  sed 's/ /^^^/g'  | \
  xargs -n 2     | \
  sed 's/\^\^\^/ /g' | \
  awk -F\| '{ printf "%-39s %-39s\n", $1, $2 }'

exit 0
