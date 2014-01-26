#!/bin/sh

# remotebackup - This script takes a list of files and directories,
#    builds a single archive, compressed, then emails it off to a 
#    remote archive site for safekeeping. It's intended to be run
#    every night for critical user files, but not intended to 
#    replace a more rigorous backup scheme. You should strongly 
#    consider using 'unpacker' on the remote end too.

uuencode="/usr/bin/uuencode"
outfile="/tmp/rb.$$.tgz"
outfname="backup.$(date +%y%m%d).tgz"
infile="/tmp/rb.$$.in"

trap "/bin/rm -f $outfile $infile" 0

if [ $# -ne 2 -a $# -ne 3 ] ; then
  echo "Usage: $(basename $0) backup-file-list remoteaddr {targetdir}" >&2
  exit 1
fi

if [ ! -s "$1" ] ; then
  echo "Error: backup list $1 is empty or missing" >&2
  exit 1
fi

# Scan entries and build fixed infile list. This expands wildcards
# and escapes spaces in filenames with a backslash, producing a 
# change: "this file" becomes this\ file so quotes are not needed.

while read entry; do
  echo "$entry" | sed -e 's/ /\\ /g' >> $infile
done < "$1"

# The actual work of building the archive, encoding it, and sending it

tar czf - $(cat $infile) | \
  $uuencode $outfname | \
  mail -s "${3:-Backup archive for $(date)}" "$2" 

echo "Done. $(basename $0) backed up the following files:"
sed 's/^/   /' $infile
echo -n "and mailed them to $2 "
if [ ! -z "$3" ] ; then
  echo "with requested target directory $3"
else
  echo ""
fi

exit 0
