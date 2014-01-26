#!/bin/sh

# bbcnews - report the top stories on the BBC World Service

url="http://news.bbc.co.uk/2/low/technology/default.stm"

lynx -source $url | \
  sed -n '/Last Updated:/,/newssearch.bbc.co.uk/p' | \
  sed 's/</\
</g;s/>/>\
/g' | \
  grep -v -E '(<|>)' | \
  fmt | \
  uniq
