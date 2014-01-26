#!/bin/sh

# ssync - If anything's changed, Create a tarball and sync a remote
#    directory via sftp using sftpsync.

sftpacct="taylor@intuitive.com"
tarballname="AllFiles.tgz"
localsource="$HOME/scripts"
remotedir="shellhacks/scripts"
timestamp=".timestamp"

sftpsync="$HOME/scripts/sftpsync"

# first off, let's see if the local dir exists and has files.

if [ ! -d $localsource ] ; then
  echo "$0: Error: directory $localsource doesn't exist?" >&2
  exit 1
fi

cd $localsource

# now let's count files to ensure something's changed:

if [ ! -f $timestamp ] ; then
  for filename in *
  do 
    if [ -f "$filename" ] ; then
      count=$(( $count + 1 ))
    fi
  done
else
  count=$(find . -newer $timestamp -type f -print | wc -l)
fi

if [ ${count:-0} -eq 0 ] ; then
  echo "$0: No files found in $localsource to sync with remote." >&2
  exit 0
fi

echo "Making tarball archive file for upload"

tar -czf $tarballname ./*

# Done! Now let's switch to the sftpsync script

exec $sftpsync $sftpacct $remotedir

