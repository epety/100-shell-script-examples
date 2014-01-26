#!/bin/sh 

# changetrack - track a given URL, and if it's changed since the last
#    visit, email the new page to the specified address.

sitearchive="/tmp/changetrack"		# can change as desired
sendmail="/usr/sbin/sendmail"		# might need to be tweaked!
fromaddr="webscraper@intuitive.com"	# change as desired

if [ $# -ne 2 ] ; then
  echo "Usage: $(basename $0) url email" >&2
  exit 1
fi 

if [ ! -d $sitearchive ] ; then
  if ! mkdir $sitearchive ; then
    echo "$(basename $0) failed: couldn't create $sitearchive." >&2
    exit 1
  fi
  chmod 777 $sitearchive	# you might change this for privacy
fi

if [ "$(echo $1 | cut -c1-5)" != "http:" ] ; then
  echo "Please use fully qualified URLs (e.g. start with 'http://')" >&2
  exit 1
fi

fname="$(echo $1 | sed 's/http:\/\///g' | tr '/?&' '...')"
baseurl="$(echo $1 | cut -d/ -f1-3)/"

# Grab a copy of the Web page into an archive file. Note that we can
#  track changes by looking just at the content (e.g. '-dump', not 
# '-source'), so we can skip any HTML parsing ...

lynx -dump "$1" | uniq > $sitearchive/${fname}.new

if [ -f $sitearchive/$fname ] ; then
  # we've seen this site before, so compare the two with 'diff' 
  if diff $sitearchive/$fname $sitearchive/${fname}.new > /dev/null ; then
    echo "Site $1 has changed since our last check."
  else
    rm -f $sitearchive/${fname}.new     # nothing new...
    exit 0                              # no change, we're outta here.
  fi
else
  echo "Note: we've never seen this site before."
fi

# To get here, the site has changed and we need to send the contents
# of the .new file to the user and replace the original with the .new
# for the next invocation of the script. 

( echo "Content-type: text/html"
  echo "From: $fromaddr (Web Site Change Tracker)"
  echo "Subject: Web Site $1 Has Changed"
  echo "To: $2"
  echo ""

  lynx -source $1 | \
    sed -e "s|[sS][rR][cC]=\"|SRC=\"$baseurl|g" \
        -e "s|[hH][rR][eE][fF]=\"|HREF=\"$baseurl|g" \
        -e "s|$baseurl\/http:|http:|g"
) | cat # $sendmail -t

# update the saved snapshot of the Web site

mv $sitearchive/${fname}.new $sitearchive/$fname
chmod 777 $sitearchive/$fname

# and we're done. 
exit 0
