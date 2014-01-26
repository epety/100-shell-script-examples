#!/bin/sh

# unpacker - given an input stream with a uuencoded archive from 
# the remotearchive script, this unpacks and installs the archive.

temp="/tmp/$(basename $0).$$"
home="${HOME:-/usr/home/taylor}"
mydir="$home/archive"
webhome="/usr/home/taylor/web"

notify="taylor@intuitive.com"

( cat - > $temp  # shortcut to save stdin to a file
  
  target="$(grep "^Subject: " $temp | cut -d\  -f2-)"
  
  echo $(basename $0): Saved as $temp, with $(wc -l < $temp) lines
  echo "message subject=\"$target\""
  
  # move into the temporary unpacking directory...
  
  if [ ! -d $mydir ] ; then
    echo "Warning: archive dir $mydir not found. Unpacking into $home"
    cd $home
    mydir=$home         # for later use
  else
    cd $mydir
  fi
  
  # extract the resultant filename from the uuencoded file...
  
  fname="$(awk '/^begin / {print $3}' $temp)"
  
  uudecode $temp
  
  if [ ! -z "$(echo $target | grep 'Backup archive for')" ] ; then
    # all done. no further unpacking needed.
    echo "Saved archive as $mydir/$fname"
    exit 0
  fi
  
  # Otherwise, we have a uudecoded file and a target directory
  
  if [ "$(echo $target|cut -c1)" = "/" -o "$(echo $target|cut -c1-2)" = ".." ]
  then
    echo "Invalid target directory $target. Can't use '/' or '..'"
    exit 0
  fi
  
  targetdir="$webhome/$target"

  if [ ! -d $targetdir ] ; then
    echo "Invalid target directory $target. Can't find in $webhome"
    exit 0
  fi

  gunzip $fname
  fname="$(echo $fname | sed 's/.tgz$/.tar/g')"

  # are the tar archive filenames in a valid format?

  if [ ! -z "$(tar tf $fname | awk '{print $8}' | grep '^/')" ] ; then
    echo "Can't unpack archive: filenames are absolute."
    exit 0
  fi

  echo ""
  echo "Unpacking archive $fname into $targetdir"

  cd $targetdir
  tar xvf $mydir/$fname | sed 's/^/  /g'

  echo "done!"
  
) 2>&1 | mail -s "Unpacker output $(date)" $notify
  
exit 0
