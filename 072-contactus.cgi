#!/bin/sh

# Process the contact us form data, email it to the designated
#   recipient, and return a succinct thank you message.

recipient="taylor"
thankyou="thankyou.html"	# optional 'thanks' page

( cat << EOF
From: (Your Web Site Contact Form) www@$(hostname)
To: $recipient
Subject: Contact Request from Web Site

Content of the Web site contact form:  

EOF

  cat - | tr '&' '\n' | \
    sed -e 's/+/ /g' -e 's/%40/@/g' -e 's/=/: /'    

  echo ""; echo ""
  echo "Form submitted on $(date)"
) | sendmail -t

echo "Content-type: text/html"
echo ""

if [ -r $thankyou ] ; then
  cat $thankyou
else
  echo "<html><body bgcolor=\"white\">"
  echo "Thank you. We'll try to contact you soonest."
  echo "</body></html>"
fi

exit 0
