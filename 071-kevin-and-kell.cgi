#!/bin/sh

# kevin-and-kell.cgi - Build a Web page on-the-fly to display the latest
#     strip from the cartoon strip Kevin and Kell, by Bill Holbrook
#     <Strip referenced with permission of the cartoonist>

month="$(date +%m)"
  day="$(date +%d)"
 year="$(date +%y)"

echo "Content-type: text/html"
echo ""

echo "<html><body bgcolor=white><center>"
echo "<title>Kevin &amp; Kell</title>"
echo "<table border=\"1\" cellpadding=\"2\" cellspacing=\"1\">"
echo "<tr bgcolor=\"#000099\">"
echo "<th><font color=white>Bill Holbrook's Kevin &amp; Kell</font></th></tr>"
echo "<tr><td><img "

# Typical URL: http://www.kevinandkell.com/2003/strips/kk20031015.gif

echo -n " src=\"http://www.kevinandkell.com/20${year}/"  
echo "strips/kk20${year}${month}${day}.gif\">"  

echo "</td></tr><tr><td align=\"center\">"
echo "&copy; Bill Holbrook. Please see "
echo "<a href=\"http://www.kevinandkell.com/\">kevinandkell.com</a>"
echo "for more strips, books, etc."
echo "</td></tr></table></center></body></html>"

exit 0
