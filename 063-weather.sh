#!/bin/sh

# weather - report weather forecast, including lat/long, for zip

llurl="http://www.census.gov/cgi-bin/gazetteer?city=&state=&zip="
wxurl="http://wwwa.accuweather.com"
wxurl="$wxurl/adcbin/public/local_index_print.asp?zipcode="

if [ "$1" = "-a" ] ; then
  size=999; shift
else 
  size=5
fi

if [ $# -eq 0 ] ; then
  echo "Usage: $0 [-a] zipcode" >&2
  exit 1
fi

if [ $size -eq 5 ] ; then
  echo ""

  # get some information on the zipcode from the Census Bureau
  
  lynx -source "${llurl}$1" | \
    sed -n '/^<li><strong>/,/^Location:/p' | \
    sed 's/<[^>]*>//g;s/^ //g'
fi

# the weather forecast itself at accuweather.com

lynx -source "${wxurl}$1" | \
  sed -n '/Start - Forecast Cell/,/End - Forecast Cell/p' | \
  sed 's/<[^>]*>//g;s/^ [ ]*//g' | \
  uniq | \
  head -$size

exit 0
