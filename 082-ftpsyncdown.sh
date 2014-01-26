#!/bin/sh

# ftpsyncdown - Given a source directory on a remote FTP server,
#   download all the files therein into the current directory.

tempfile="/tmp/ftpsyncdown.$$"

trap "/bin/rm -f $tempfile" 0 1 15      # zap tempfile on exit

if [ $# -eq 0 ] ; then
  echo "Usage: $0 user@host { remotedir }" >&2
  exit 1
fi

user="$(echo $1 | cut -d@ -f1)"
server="$(echo $1 | cut -d@ -f2)"

echo "open $server" > $tempfile
echo "user $user" >> $tempfile

if [ $# -gt 1 ] ; then
  echo "cd $2" >> $tempfile
fi

cat << EOF >> $tempfile
prompt
mget *
quit
EOF

echo "Synchronizing: Downloading files"

if ! ftp -n < $tempfile ; then
  echo "Done. All files on $server downloaded to $(pwd)"
fi

exit 0
