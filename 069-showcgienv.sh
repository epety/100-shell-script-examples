#!/bin/sh

# show CGI env - display the CGI runtime environment, as given to any 
#    CGI script on this system.

echo "Content-type: text/html"
echo ""

# now the real information

echo "<html><body bgcolor=\"white\"><h2>CGI Runtime Environment</h2>"
echo "<pre>"
env || printenv
echo "</pre>"
echo "<h3>Input stream is:</h3>"
echo "<pre>"
cat -
echo "(end of input stream)</pre></body></html>"

exit 0
