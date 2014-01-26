#!/bin/sh

# ADDUSER - add a new user to the system, including building their
#           home directory, copying in default config data, etc.
# You can choose to have every user in their own group (which requires
# a few tweaks) or use the default behavior of having everyone put 
# into the same group. Tweak dgroup and dgid to match your own config.

dgroup="guest"; dgid=31	   # default group and groupid
hmdir="/Users"
shell="uninitialized"

if [ "$(/usr/bin/whoami)" != "root" ] ; then
  echo "$(basename $0): You must be root to run this command." >&2
  exit 1
fi

echo "Add new user account to $(hostname)"
echo -n "login: "     ; read login

if nireport . /users name | sed 's/[^[:alnum:]]//g' | grep "^$login$" ; then
  echo "$0: You already have an account with name $login" >&2
  exit 1
fi

uid1="$(nireport . /users uid | sort -n | tail -1)"
uid="$(( $uid1 + 1 ))"

homedir=$hmdir/$login

echo -n "full name: " ; read fullname

until [ -z "$shell" -o -x "$shell" ] ; do
  echo -n "shell: "     ; read shell
done

echo "Setting up account $login for $fullname..."
echo "uid=$uid  gid=$dgid  shell=$shell  home=$homedir"

niutil -create     . /users/$login
niutil -createprop . /users/$login passwd
niutil -createprop . /users/$login uid $uid
niutil -createprop . /users/$login gid $dgid
niutil -createprop . /users/$login realname "$fullname"
niutil -createprop . /users/$login shell $shell
niutil -createprop . /users/$login home $homedir

niutil -createprop . /users/$login _shadow_passwd ""

# adding them to the $dgroup group
niutil -appendprop . /groups/$dgroup users $login

if ! mkdir -m 755 $homedir ; then
  echo "$0: Failed making home directory $homedir" >&2
  echo "(created account in NetInfo database, though. Continue by hand)" >&2
  exit 1
fi

if [ -d /etc/skel ] ; then
  ditto /etc/skel/.[a-zA-Z]* $homedir
else
  ditto "/System/Library/User Template/English.lproj" $homedir
fi

chown -R ${login}:$dgroup $homedir 

echo "Please enter an initial password for $login:"
passwd $login

echo "Done. Account set up and ready to use."
exit 0
