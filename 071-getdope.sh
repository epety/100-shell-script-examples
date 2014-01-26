#!/bin/sh

# Within cron set it up so that every Friday, grab the latest column
# of 'The Straight Dope' and mail it out to the specified recipient

now="$(date +%y%m%d)"
url="http://www.straightdope.com/columns/${now}.html"
to="taylor"

( cat << EOF
Subject: The Straight Dope for $(date "+%A, %d %B, %Y")
From: Cecil Adams <www@intuitive.com>
Content-type: text/html
To: $to

<html>
<body border=0 leftmargin=0 topmargin=0>
<div style='background-color:309;color:fC6;font-size:45pt;
 font-style:sans-serif;font-weight:900;text-align:center;
margin:0;padding:3px;'>
THE STRAIGHT DOPE</div>

<div style='padding:3px;line-height:1.1'>
EOF

  lynx -source "$url" | \
    sed -n '/<hr>/,$p' | \
    sed 's|src="../art|src="http://www.straightdope.com/art|' |\
    sed 's|href="..|href="http://www.straightdope.com|g'

  echo "</div></body></html>"
) | /usr/sbin/sendmail -t

exit 0
