#!/bin/sh

# getstock - given a stock ticker symbol, return its current value
#    from the Lycos web site

url="http://finance.lycos.com/qc/stocks/quotes.aspx?symbols="

if [ $# -ne 1 ] ; then
  echo "Usage: $(basename $0) stocksymbol" >&2 
  exit 1
fi

value="$(lynx -dump "$url$1" | grep 'Last price:' | \
  awk -F: 'NF > 1 && $(NF) != "N/A" { print $(NF) }')"

if [ -z $value ] ; then
  echo "error: no value found for ticker symbol $1." >&2
  exit 1
fi

echo $value

exit 0
