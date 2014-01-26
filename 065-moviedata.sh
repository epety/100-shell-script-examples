#!/bin/sh

# moviedata - given a movie title, return a list of matches, if
#   there's more than one, or a synopsis of the movie if there's
#   just one. Uses the Internet Movie Database (imdb.com)

imdburl="http://us.imdb.com/Tsearch?restrict=Movies+only&title="
titleurl="http://us.imdb.com/Title?"
tempout="/tmp/moviedata.$$"

summarize_film()
{
   # produce an attractive synopsis of the film

   grep "^<title>" $tempout | sed 's/<[^>]*>//g;s/(more)//'
   grep '<b class="ch">Plot Outline:</b>' $tempout | \
     sed 's/<[^>]*>//g;s/(more)//;s/(view trailer)//' |fmt|sed 's/^/  /'
   exit 0
}

trap "rm -f $tempout" 0 1 15

if [ $# -eq 0 ] ; then
  echo "Usage: $0 {movie title | movie ID}" >&2 
  exit 1
fi

fixedname="$(echo $@ | tr ' ' '+')"	# for the URL

if [ $# -eq 1 ] ; then
  nodigits="$(echo $1 | sed 's/[[:digit:]]*//g')"
  if [ -z "$nodigits" ] ; then
    lynx -source "$titleurl$fixedname" > $tempout
    summarize_film
  fi
fi

url="$imdburl$fixedname"

lynx -source $url > $tempout

if [ ! -z "$(grep "IMDb title search" $tempout)" ] ; then
  grep 'HREF="/Title?' $tempout | \
    sed 's/<OL><LI><A HREF="//;s/<\/A><\/LI>//;s/<LI><A HREF="//' | \
    sed 's/">/ -- /;s/<.*//;s/\/Title?//' | \
    sort -u | \
    more
else
  summarize_film
fi

exit 0
