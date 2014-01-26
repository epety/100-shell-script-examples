#!/bin/sh

## Delete - delete a user account without a trace...
#           Not for use with Mac OS X

homedir="/home"
pwfile="/etc/passwd"            shadow="/etc/shadow"
newpwfile="/etc/passwd.new"     newshadow="/etc/shadow.new"
suspend="echo suspending "
locker="/etc/passwd.lock"

if [ -z $1 ] ; then
  echo "Usage: $0 account" >&2; exit 1
elif [ "$(whoami)" != "root" ] ; then
  echo "Error: you must be 'root' to run this command.">&2; exit 1
fi

# $suspend $1    # suspend their account while we do the dirty work

uid="$(grep -E "^${1}:" $pwfile | cut -d: -f3)"

if [ -z $uid ] ; then
 echo "Error: no account $1 found in $pwfile" >&2; exit 1
fi

# remove from the password and shadow files
grep -vE "^${1}:" $pwfile > $newpwfile
grep -vE "^${1}:" $shadow > $newshadow

lockcmd="$(which lockfile)"             # find it in the path
if [ ! -z $lockcmd ] ; then             # let's use the system lockfile
  eval $lockcmd -r 15 $locker 
else                                    # ulp, let's do it ourselves
  while [ -e $locker ] ; do
    echo "waiting for the password file" ; sleep 1
  done
  touch $locker                         # created a file-based lock
fi

mv $newpwfile $pwfile 
mv $newshadow $shadow 
rm -f $locker                           # click! unlocked again

chmod 644 $pwfile
chmod 400 $shadow

# now remove home directory and list anything left...
rm -rf $homedir/$1

echo "Files still left to remove (if any):"
find / -uid $uid -print 2>/dev/null | sed 's/^/  /'

echo ""
echo "Account $1 (uid $uid) has been deleted, and their home directory "
echo "($homedir/$1) has been removed."

exit 0
