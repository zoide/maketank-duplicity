#!/bin/bash
## actually run duply
BCKPNAME="$1"
LOCKFILE="/tmp/lock-${BCKPNAME}"
ACTION="$2"

[[ -e $LOCKFILE ]] && exit 0 #exit if lockfile exists
touch $LOCKFILE
[[ -d /var/log/backup ]] || mkdir /var/log/backup
/usr/bin/duply $BCKPNAME $ACTION >/var/log/backup/backup-${BCKPNAME}.log
rm $LOCKFILE