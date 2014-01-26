#!/bin/sh

echo "Content-type: text/html"
echo ""

header="header.html"
footer="footer.html"
count=0

if [ -f $header ] ; then
  cat $header
else
  echo "<html><body bgcolor='white' link='#666666' vlink='#999999'><center>"
fi

echo "<h3>Contents of $(dirname $SCRIPT_NAME)</h3>"
echo "<table cellpadding='3' cellspacing='5'>"

for name in *jpg
do
  if [ $count -eq 4 ] ; then
    echo "</td></tr><tr><td align='center'>"
    count=1
  else
    echo "</td><td align='center'>"
    count=$(( $count + 1 ))
  fi

  nicename="$(echo $name | sed 's/.jpg//;s/-/ /g')"

  echo "<a href='$name' target=_new><img style='padding:2px'"
  echo "src='$name' height='100' width='100' border='1'></a><BR>"
  echo "<span style='font-size: 80%'>$nicename</span>"
done

echo "</td></tr><table>"

if [ -f $footer ] ; then
  cat $footer
else
  echo "</center></body></html>"
fi

exit 0
