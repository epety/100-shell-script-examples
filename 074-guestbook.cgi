#!/bin/sh

# guestbook - display the current guestbook entries, append a 
#   simple form for visitors to add their own comments, and 
#   accept and process new guest entries. Works with a separate
#   data file that actually contains the guest data.

homedir=/home/taylor/web/wicked/examples
guestbook="$homedir/guestbook.txt"
tempfile="/tmp/guestbook.$$"
sedtemp="/tmp/guestbook.sed.$$"

trap "/bin/rm -f $tempfile $sedtemp" 0

echo "Content-type: text/html"
echo ""

echo "<html><title>Guestbook for $(hostname)</title>"
echo "<body bgcolor='white'><h2>Guestbook for $(hostname)</h2>"

if [ "$REQUEST_METHOD" = "POST" ] ; then

  cat - | tr '&+' '\n ' > $tempfile  # save the input stream

  name="$(grep 'yourname=' $tempfile | cut -d= -f2)"
  email="$(grep 'email=' $tempfile | cut -d= -f2 | sed 's/%40/@/')"
 
  # Now, given a URL encoded string, decode some of the most important
  # punctuation (but not all punctuation!)

cat << "EOF" > $sedtemp
s/%2C/,/g;s/%21/!/g;s/%3F/?/g;s/%40/@/g;s/%23/#/g;s/%24/$/g
s/%25/%/g;s/%26/\&/g;s/%28/(/g;s/%29/)/g;s/%2B/+/g;s/%3A/:/g
s/%3B/;/g;s/%2F/\//g;s/%27/'/g;s/%22/"/g
EOF

  comment="$(grep 'comment=' $tempfile | cut -d= -f2 | sed -f $sedtemp)"

  # sequences to look out for: %3C = <  %3E = >  %60 = `
 
  if echo $name $email $comment | grep '%' ; then
    echo "<h3>Failed: illegal character or characters in input:"
    echo "Not saved.<br>Please also note that no HTML is allowed.</h3>"
  elif [ ! -w $guestbook ] ; then
    echo "<h3>Sorry, can't write to the guestbook at this time.</h3>"
  else
    # all is well. Save it to the datafile!
    echo "$(date)|$name|$email|$comment" >> $guestbook
    chmod 777 $guestbook        # ensure it's not locked out to webmaster
  fi
fi

# do we have a guestbook to work with?

if [ -f $guestbook ] ; then
  echo "<table>"

  while read line 
  do 
    date="$(echo $line | cut -d\| -f1)"
    name="$(echo $line | cut -d\| -f2)"
    email="$(echo $line | cut -d\| -f3)"
    comment="$(echo $line | cut -d\| -f4)"
    echo "<tr><td><a href='mailto:$email'>$name</a> signed thusly:</td></tr>"
    echo "<tr><td><div style='margin-left: 1in'>$comment</div></td></tr>"
    echo "<tr><td align=right style='font-size:60%'>Added $date"
    echo "<hr noshade></td></tr>"
  done < $guestbook

  echo "</table>"
fi

# input form...

echo "<form method='post' action='$(basename $0)'>"
echo "Please feel free to sign our guestbook too:<br>"
echo "Your name: <input type='text' name='yourname'><br>"
echo "Your email address: <input type='text' name='email'><br>"
echo "And your comment:<br>"
echo "<textarea name='comment' rows='5' cols='65'></textarea>"
echo "<br><input type='submit' value='sign our guest book'>"
echo "</form>"

echo "</body></html>"

exit 0
