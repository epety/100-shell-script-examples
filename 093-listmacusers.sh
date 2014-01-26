#!/bin/sh

# Simple script to list users in the Mac OS X NetInfo database
#   note that Mac OS X also has an /etc/passwd file, but that's
#   only used during the initial stages of boot time and for
#   recovery bootups. Otherwise, all data is in the NetInfo db.

fields=""

while getopts "Aahnprsu" opt ; do
  case $opt in
    A ) fields="uid passwd name realname home shell"	;;
    a ) fields="uid name realname home shell"		;;
    h ) fields="$fields home"				;;
    n ) fields="$fields name"				;;
    p ) fields="$fields passwd"				;;
    r ) fields="$fields realname"			;;
    s ) fields="$fields shell"				;;
    u ) fields="$fields uid"				;;
    ? ) cat << EOF >&2
Usage: $0 [A|a|hnprsu]
Where:
   -A    output all known NetInfo user fields
   -a    output only the interesting user fields
   -h    show home directories of accounts
   -n    show account names
   -p    passwd (encrypted)
   -r    show realname/fullname values
   -s    show login shell
   -u    uid
EOF
exit 1
  esac
done

exec nireport . /users ${fields:=uid name realname home shell}
