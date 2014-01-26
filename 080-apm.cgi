#!/bin/sh

# apm - Apache Password Manager - allows the administrator to easily
#   manage the addition, update, or deletion of accounts and passwords
#   for a subdirectory of a typical Apache configuration (where the
#   config file is called .htaccess)

echo "Content-type: text/html"
echo ""
echo "<html><title>Apache Password Manager Utility</title><body>"

myname="$(basename $0)"
temppwfile="/tmp/apm.$$";       trap "/bin/rm -f $temppwfile" 0
footer="apm-footer.html"
htaccess=".htaccess"

#   Modern versions of 'htpasswd' include a -b flag that lets you specify
#   the password on the command line. If yours can do that, specify it 
#   here, with the '-b' flag:
# htpasswd="/usr/local/bin/htpasswd -b"
#   otherwise, there's a simple Perl rewrite of this script that is a good
#   substitute, at http://www.intuitive.com/shellhacks/examples/httpasswd-b.pl

htpasswd="/web/intuitive/wicked/examples/protected/htpasswd-b.pl"

if [ "$REMOTE_USER" != "admin" -a -s $htpasswd ] ; then
  echo "Error: you must be user <b>admin</b> to use APM."
  exit 0
fi

# now get the password filename from the .htaccess file

if [ ! -r "$htaccess" ] ; then
  echo "Error: cannot read $htaccess file in this directory."
  exit 0
fi

passwdfile="$(grep "AuthUserFile" $htaccess | cut -d\   -f2)"

if [ ! -r $passwdfile ] ; then
  echo "Error: can't read password file: can't make updates." 
  exit 0
elif [ ! -w $passwdfile ] ; then
  echo "Error: can't write to password file: can't update."
  exit 0
fi

echo "<center><h2 style='background:#ccf'>Apache Password Manager</h2>"

action="$(echo $QUERY_STRING | cut -c3)"
user="$(echo $QUERY_STRING|cut -d\& -f2|cut -d= -f2|tr '[:upper:]' '[:lower:]')"

case "$action" in 
  A ) echo "<h3>Adding New User <u>$user</u></h3>"
        if [ ! -z "$(grep -E "^${user}:" $passwdfile)" ] ; then
          echo "Error: user <b>$user</b> already appears in the file."
        else
          pass="$(echo $QUERY_STRING|cut -d\& -f3|cut -d= -f2)"
          if [ ! -z "$(echo $pass | tr -d '[[:upper:][:lower:][:digit:]]')" ] ; then
            echo "Error: passwords can only contain a-z A-Z 0-9 ($pass)"
          else
            $htpasswd $passwdfile $user $pass
            echo "Added!<br>"
          fi
        fi
        ;;
  U ) echo "<h3>Updating Password for user <u>$user</u></h3>"
        if [ -z "$(grep -E "^${user}:" $passwdfile)" ] ; then
          echo "Error: user <b>$user</b> isn't in the password file?"
          echo "<pre>";cat $passwdfile;echo "</pre>"
          echo "searched for &quot;^${user}:&quot; in $passwdfile"
        else
          pass="$(echo $QUERY_STRING|cut -d\& -f3|cut -d= -f2)"
          if [ ! -z "$(echo $pass | tr -d '[[:upper:][:lower:][:digit:]]')" ] ; then
            echo "Error: passwords can only contain a-z A-Z 0-9 ($pass)"
          else
            grep -vE "^${user}:" $passwdfile > $temppwfile
            mv $temppwfile $passwdfile
            $htpasswd $passwdfile $user $pass
            echo "Updated!<br>"
          fi
        fi
        ;;
  D ) echo "<h3>Deleting User <u>$user</u></h3>"
        if [ -z "$(grep -E "^${user}:" $passwdfile)" ] ; then
          echo "Error: user <b>$user</b> isn't in the password file?"
        elif [ "$user" = "admin" ] ; then
          echo "Error: you can't delete the 'admin' account."
        else
          grep -vE "^${user}:" $passwdfile > $temppwfile
          mv $temppwfile $passwdfile
          echo "Deleted!<br>"
        fi
        ;;
esac

# always list the current users in the password file...

echo "<br><br><table border='1' cellspacing='0' width='80%' cellpadding='3'>"
echo "<tr bgcolor='#cccccc'><th colspan='3'>List "
echo "of all current users</td></tr>"
oldIFS=$IFS ; IFS=":"   # change word split delimiter
while read acct pw ; do
  echo "<tr><th>$acct</th><td align=center><a href=\"$myname?a=D&u=$acct\">"
  echo "[delete]</a></td></tr>"
done < $passwdfile
echo "</table>"
IFS=$oldIFS             # and restore it 

# build selectstring with all accounts included
optionstring="$(cut -d: -f1 $passwdfile | sed 's/^/<option>/'|tr '\n' ' ')"

# and output the footer
sed -e "s/--myname--/$myname/g" -e "s/--options--/$optionstring/g" < $footer

exit 0
