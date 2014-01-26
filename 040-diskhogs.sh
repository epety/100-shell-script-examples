#!/bin/sh

# DISKHOGS - Disk quota analysis tool for Unix, assumes all user 
#   accounts are >= UID 100. Emails message to each violating user
#   and reports a summary to the screen

MAXDISKUSAGE=20
violators="/tmp/diskhogs0.$$"

trap "/bin/rm -f $violators" 0

for name in $(cut -d: -f1,3 /etc/passwd | awk -F: '$2 > 99 { print $1 }')
do
  echo -n "$name "
  
  find / /usr /var /Users -user $name -xdev -type f -ls | \
      awk '{ sum += $7 } END { print sum / (1024*1024) }'

done | awk "\$2 > $MAXDISKUSAGE { print \$0 }" > $violators

if [ ! -s $violators ] ; then
  echo "No users exceed the disk quota of ${MAXDISKUSAGE}MB"
  cat $violators
  exit 0
fi

while read account usage ; do

   cat << EOF | fmt | mail -s "Warning: $account Exceeds Quota" $account
Your disk usage is ${usage}MB but you have only been allocated 
${MAXDISKUSAGE}MB.  This means that either you need to delete some of 
your files, compress your files (see 'gzip' or 'bzip2' for powerful and
easy-to-use compression programs), or talk with us about increasing
your disk allocation.

Thanks for your cooperation on this matter.

Dave Taylor @ x554
EOF

  echo "Account $account has $usage MB of disk space. User notified."

done < $violators

exit 0
