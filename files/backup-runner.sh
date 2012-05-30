#!/bin/bash
## actually run duply
BCKPNAME="$1"
shift
LOCKFILE="/tmp/lock-${BCKPNAME}"
STATFILE="/var/log/backup/.success-${BCKPNAME}"
ACTION="$@"

[[ -e $LOCKFILE ]] && exit 0 #exit if lockfile exists
touch $LOCKFILE
[[ -d /var/log/backup ]] || mkdir /var/log/backup
/usr/bin/duply $BCKPNAME $ACTION >>/var/log/backup/backup-${BCKPNAME}.log 2>>/var/log/backup/backup-${BCKPNAME}_error.log
if [ $? -eq 0 ]; then
    touch $STATFILE
fi
echo -n "## ALL DONE: removing Lockfile: " >>/var/log/backup/backup-${BCKPNAME}.log
rm -v $LOCKFILE
