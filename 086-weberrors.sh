#!/bin/sh

# weberrors - scan through an Apache error_log file and report the 
#    most important errors, then list additional entries.

temp="/tmp/$(basename $0).$$"

# the following three lines will need to be customized for your own
# installation for this script to work best.

htdocs="/usr/local/etc/httpd/htdocs/"
myhome="/usr/home/taylor/"
cgibin="/usr/local/etc/httpd/cgi-bin/"

sedstr="s/^/  /g;s|$htdocs|[htdocs]  |;s|$myhome|[homedir] |;s|$cgibin|[cgi-bin] |"

screen="(File does not exist|Invalid error redirect|premature EOF|Premature end of script|script not found)" 

length=5                # entries per category to display

checkfor() 
{
  grep "${2}:" "$1" | awk '{print $NF}' |\
    sort | uniq -c | sort -rn | head -$length | sed "$sedstr" > $temp

  if [ $(wc -l < $temp) -gt 0 ] ; then
    echo ""
    echo "$2 errors:"
    cat $temp
  fi
}

trap "/bin/rm -f $temp" 0

if [ "$1" = "-l" ] ; then
  length=$2; shift 2
fi

if [ $# -ne 1 -o ! -r "$1" ] ; then
  echo "Usage: $(basename $0) [-l len] error_log" >&2
  exit 1
fi

echo Input file $1 has $(wc -l < "$1") entries.

start="$(grep -E '\[.*:.*:.*\]' "$1" | head -1 | awk '{print $1" "$2" "$3" "$4" "$5 }')"
end="$(grep -E '\[.*:.*:.*\]' "$1" | tail -1 | awk '{print $1" "$2" "$3" "$4" "$5 }')"
echo -n "Entries from $start to $end"

echo ""

### Check for various common and well-known errors:

checkfor "$1" "File does not exist"
checkfor "$1" "Invalid error redirection directive"
checkfor "$1" "premature EOF"
checkfor "$1" "script not found or unable to stat" 
checkfor "$1" "Premature end of script headers" 

grep -vE "$screen" "$1" | grep "\[error\]" | grep "\[client " | \
  sed 's/\[error\]/\`/' | cut -d\`  -f2 | cut -d\  -f4- | \
  sort | uniq -c | sort -rn | sed 's/^/  /' | head -$length > $temp

if [ $(wc -l < $temp) -gt 0 ] ; then
  echo ""
  echo "Additional error messages in log file:"
  cat $temp
fi

echo ""
echo "And non-error messages occurring in the log file:"

grep -vE "$screen" "$1" | grep -v "\[error\]" | \
  sort | uniq -c | sort -rn | \
  sed 's/^/  /' | head -$length

exit 0
