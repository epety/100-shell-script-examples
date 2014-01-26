#!/bin/sh

# fixguest - Clean up the guest account during the logout process

# don't trust environment variables: reference read-only sources

iam="$(whoami)"
myhome="$(grep "^${iam}:" /etc/passwd | cut -d: -f6)"

# *** Do NOT run this script on a regular user account!

if [ "$iam" != "guest" ] ; then
  echo "Error: you really don't want to run fixguest on this account." >&2
  exit 1
fi

if [ ! -d $myhome/..template ] ; then
  echo "$0: no template directory found for rebuilding." >&2
  exit 1
fi

# remove all files and directories in the home account

cd $myhome

rm -rf * $(find . -name ".[a-zA-Z0-9]*" -print)

# now the only thing present should be the ..template directory

cp -Rp ..template/* .

exit 0
