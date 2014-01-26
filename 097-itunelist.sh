#!/bin/sh

# itunelist - list your iTunes library in a succinct and attractive
#   manner, suitable for sharing with others and using (with diff)
#   to ensure that you have synchronized iTune libraries on different
#   computers and laptops.

itunehome="$HOME/Music/iTunes"
ituneconfig="$itunehome/iTunes Music Library.xml"

musiclib="/$(grep '>Music Folder<' "$ituneconfig" | cut -d/ -f5- | \
   cut -d\< -f1 | sed 's/%20/ /g')"

echo Your music library is at $musiclib

if [ ! -d "$musiclib" ] ; then
  echo "$0: Confused: Music library $musiclib isn't a directory?" >&2
  exit 1
fi

exec find "$musiclib" -type d -mindepth 2 -maxdepth 2 \! -name '.*' -print | sed "s|$musiclib/||"
