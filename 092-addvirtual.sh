#!/bin/sh

# addvirtual - add a virtual host to an Apache configuration file

# you'll want to modify all of these to point to the proper directories

docroot="/etc/httpd/html"
logroot="/var/log/httpd/"
httpconf="/etc/httpd/conf/httpd.conf"

# some sites use 'apachectl' rather than restart_apache:
restart="/usr/local/bin/restart_apache"

showonly=0
tempout="/tmp/addvirtual.$$";  trap "rm -f $tempout $tempout.2" 0

if [ "$1" = "-n" ] ; then
  showonly=1 ; shift
fi

if [ $# -ne 3 ] ; then
  echo "Usage: $(basename $0) [-n] domain admin-email owner-id" >&2
  echo "  Where -n shows what it would do, but doesn't do anything" >&2
  exit 1
fi

# check for common and probable errors

if [ $(id -u) != "root" -a $showonly = 0 ] ; then
  echo "Error: $(basename $0) can only be run as root." >&2
  exit 1
fi
if [ ! -z "$(echo $1 | grep -E '^www\.')" ] ; then
  echo "Please omit the www. prefix on the domain name" >&2 
  exit 0
fi
if [ "$(echo $1 | sed 's/ //g')" != "$1" ] ; then
  echo "Error: Domain names cannot have spaces." >&2
  exit 1
fi
if [ -z "$(grep -E "^$3" /etc/passwd)" ] ; then
  echo "Account $3 not found in password file" >&2
  exit 1
fi

# build the directory structure and drop a few files therein

if [ $showonly -eq 1 ] ; then
  tempout="/dev/tty"  # to output virtualhost to stdout
  echo "mkdir $docroot/$1 $logroot/$1"
  echo "chown $3 $docroot/$1 $logroot/$1"
else
  if [ ! -d $docroot/$1 ] ; then
    if mkdir $docroot/$1 ; then
      echo "Failed on mkdir $docroot/$1: exiting." >&2 ; exit 1
    fi
  fi
  if [ ! -d $logroot/$1 ] ; then 
    mkdir $logroot/$1
    if [ $? -ne 0 -a $? -ne 17 ] ; then
      # error code 17 = directory already exists
      echo "Failed on mkdir $docroot/$1: exiting." >&2 ; exit 1
    fi
  fi
  chown $3 $docroot/$1 $logroot/$1
fi

# now let's drop the necessary block into the httpd.conf file

cat << EOF > $tempout

####### Virtual Host setup for $1 ###########

<VirtualHost www.$1 $1>
ServerName www.$1
ServerAdmin $2
DocumentRoot $docroot/$1
ErrorLog logs/$1/error_log
TransferLog logs/$1/access_log
</VirtualHost>

<Directory $docroot/$1>
Options Indexes FollowSymLinks Includes
AllowOverride All
order allow,deny
allow from all
</Directory>

EOF

if [ $showonly -eq 1 ]; then
  echo "Tip: Copy the above block into $httpconf and"
  echo "restart the server with $restart and you're done."
  exit 0
fi

# let's hack the httpd.conf file

date="$(date +%m%d%H%m)"	# month day hour minute
cp $httpconf $httpconf.$date    # backup copy of config file

# Figure out what line in the file has the last </VirtualHost> entry
# Yes, this means that the script won't work if there are NO virtualhost
# entries already in the httpd.conf file. If that's the case, just use 
# the -n flag and paste the material in manually...

addafter="$(cat -n $httpconf|grep '</VirtualHost>'|awk 'NR==1 {print $1}')"

if [ -z "$addafter" ]; then
  echo "Error: Can't find a </VirtualHost> line in $httpconf" >&2
  /bin/rm -f $httpconf.$date; exit 1
fi

sed "${addafter}r $tempout" < $httpconf > $tempout.2
mv $tempout.2 $httpconf

if $restart ; then
  mv $httpconf $httpconf.failed.$date
  mv $httpconf.$date $httpconf
  $restart
  echo "Configuration appears to have failed; restarted with old conf file" >&2
  echo "Failed configuration is in $httpconf.failed.$date" >&2
  exit 1
fi

exit 0
