#!/bin/bash
## actually run duply
BCKPNAME="$1"
shift
LOCKFILE="/tmp/lock-${BCKPNAME}"
STATFILE="/var/log/backup/.success-${BCKPNAME}"
LOGFILE="/var/log/backup/backup-${BCKPNAME}.log"
LOGFILE_E="/var/log/backup/backup-${BCKPNAME}_error.log"
ACTION="$@"

[[ -e $LOCKFILE ]] && exit 0 #exit if lockfile exists
touch $LOCKFILE
[[ -d /var/log/backup ]] || mkdir /var/log/backup
nice ionice -c3 /usr/bin/duply $BCKPNAME $ACTION >>$LOGFILE 2>>$LOGFILE_E
if [ $? -eq 0 ]; then
    touch $STATFILE
fi
echo -n "## ALL DONE: removing Lockfile: " >>$LOGFILE
rm -v $LOCKFILE >> /var/log/backup/backup-${BCKPNAME}.log
