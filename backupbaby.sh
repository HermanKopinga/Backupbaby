#!/bin/sh

# Backup script for backup baby
# By herman@kopinga.nl for renger@soundbase.nl

# V2 using a configfile and now use env variable for password, no longer file

source /usr/local/backupbaby/backupbaby.config.txt

RSYNC_PASSWORD=$backupbabypass
export RSYNC_PASSWORD

RUNTIME=`date +%Y%m%d%H%M`

/usr/bin/rsync \
--times --timeout=7200 \
--recursive --bwlimit=$backupbabybandwith \
--log-file=$backupbabylogdir/backupbaby.logfile.$RUNTIME.txt \
$backupbabypath \
$backupbabyuser@$backupbabyhost::$backupbabyuser \
1>> $backupbabylogdir/backupbaby.output.$RUNTIME.txt \
2>> $backupbabylogdir/backupbaby.error.$RUNTIME.txt

RETURN=$?
if [ $RETURN -eq 0 ];then
  STATUS="succesvol"
else
  STATUS="met fouten"
fi

cd /usr/local/backupbaby/mailtool/
./smtp-cli -4 --missing-modules-ok \
--host=$backupbabysmtp \
--user=$backupbabysmtpuser \
--pass=$backupbabysmtppass \
--from="Backupbaby <$backupbabyfrom>" \
--to="$backupbabyuser <$backupbabyto>" \
--cc="Backupbaby beheer <$backupbabycc>" \
--subject="Backupbaby rapportage ($STATUS) $RUNTIME" \
--attach="$backupbabylogdir/backupbaby.logfile.$RUNTIME.txt@text/plain" \
--attach="$backupbabylogdir/backupbaby.error.$RUNTIME.txt@text/plain"

cd -
