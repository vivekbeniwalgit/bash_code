#!/bin/bash
#set -x

# For checking S3 backup status.

NAGIOS_SERVER="10.10.5.5"
NAGIOS_SERVICE_NAME="S3BACKUP"
HOST="$(hostname -s).hcinternal.net"
HOSTNAME="$(hostname)"
S3_BUCKET="hcen02-servers-backup"
SEND_NSCA_CMD="/usr/local/nagios/libexec/send_nsca"
SEND_NSCA_CONFIG="/usr/local/nagios/etc/send_nsca.cfg"

DATE=$(date '+%Y-%m-%d')
LOG="/var/log/S3-backup/$HOSTNAME.$DATE.log"
if [ ! -f $LOG ] ; then
        echo -e "$HOST\t$NAGIOS_SERVICE_NAME\t2\tUNKNOWN : Unable to read files"|$SEND_NSCA_CMD $NAGIOS_SERVER -c $SEND_NSCA_CONFIG
        exit 3
fi

RERUN=""

if [ ! -f $LOG"_rerun" ] ; then
numerror=$(grep -E -c 'ERROR Sync unsucessfull|upload failed:' $LOG)
else
numerror=$(grep -E -c 'ERROR Sync unsucessfull|upload failed:' $LOG"_rerun")
RERUN="After Rerun"
fi



if [ $numerror -gt 0 ] ; then
                echo -e "$HOST\t$NAGIOS_SERVICE_NAME\t2\tCRITICAL : Backup failed $RERUN ($numerror errors) $DATE"|$SEND_NSCA_CMD $NAGIOS_SERVER -c $SEND_NSCA_CONFIG
     exit 2
elif  [ $numerror -eq 0 ] ; then
                 echo -e "$HOST\t$NAGIOS_SERVICE_NAME\t0\tOK : Backup Successful $RERUN $DATE"|$SEND_NSCA_CMD $NAGIOS_SERVER -c $SEND_NSCA_CONFIG
                 exit 0
 fi
