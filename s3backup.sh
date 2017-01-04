#!/bin/bash -x
#Export PATH
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#Constant varibles
readonly EXCLUDE_LIST="/opt/S3-Archive/exclude-list"
readonly INCLUDE_LIST="/opt/S3-Archive/sync_structure"
readonly ENCRYPTION_KEY="hCentive_secret"
#readonly AWSCLI="/usr/bin/s3cmd"
readonly AWSCLI="aws s3"
readonly S3_BUCKET="hcen02-servers-backup"
readonly HOSTNAME="$(hostname)"
readonly LOG="/var/log/S3-backup/$HOSTNAME$( date '+.%Y-%m-%d.log')"
readonly DES="/opt/S3-Archive/S3-Backup"
readonly MAX_RETRY=3
#------------ Function Definitions -----------
usage() {
cat <<EOF

usage: $0 options

OPTIONS:
        -h              Show this message
        -s              Sync
        -l              list
        -g              get
        -r              Dry run
        -f              File name
        -d              Directory
        -m              Modified date

EOF
}

log() {
mode=$1
data=$2
echo "$mode $data"
echo "$mode $data" >> $LOG
}

#make header for SSE-C
make_header(){
key=$1
base_key=$(echo -n "$key" | base64)
key_md5=$(echo -n "$key" | md5sum | cut -b 1-32 | base64)
echo "$base_key - $key_md5"
}
#Upload/Sync
upload(){

log INFO "Starting sync process"
exclude=""
while read line
do
        exclude="$exclude --exclude \"$line\" "
done<$EXCLUDE_LIST

 while read line
 do
 SRCDIR="$line/"
 SYNC_STATUS=0
 SYNC_RETRY=0
 SYNC_WARNING=0
 starttime=$(date +%s)
 log info "Syncing $SRCDIR Time: $(date +%H:%M)"
 mkdir -p ${DES}/${SRCDIR}
 pushd ${DES}/${SRCDIR}
 find ${SRCDIR} -type f > version.txt_`date +%F`
 res=$(time ${AWSCLI} cp  version.txt_`date +%F`  s3://$S3_BUCKET/${HOSTNAME}$SRCDIR --storage-class  REDUCED_REDUNDANCY 2>&1)
 rm -f  version.txt_`date +%F`

       if [ $FIRST_RUN -eq 1 ] ; then
                pushd $SRCDIR

# SYNC_STRUCTURE="$line/"
        res=$(time $AWSCLI sync --size-only  --sse AES256  . s3://$S3_BUCKET/${HOSTNAME}$SRCDIR $exclude  2>&1)
        else

        pushd $SRCDIR
        while [ $SYNC_RETRY -lt $MAX_RETRY ]
        do
           res=$(time $AWSCLI sync   --sse AES256  . s3://$S3_BUCKET/${HOSTNAME}$SRCDIR $exclude --storage-class  REDUCED_REDUNDANCY 2>&1)
           if [ $? -ne 0 ] ;then
                              log DEBUG "$res"
                              log DEBUG "Retrying Sync..."
                              SYNC_RETRY=`expr $SYNC_RETRY + 1`
                              SYNC_STATUS=1
            else
                             break
            fi
        done
        fi


     if [ $SYNC_STATUS -ne 0 ] ;then
                        log DEBUG "------------Sync Log Start--------"
                        log DEBUG "$res"
                        log DEBUG "------------Sync Log End--------"
                        SYNC_WARNING=$(echo $res | grep -E -ci 'warning:')
                        if [ $SYNC_WARNING -eq 0 ];then
                                                    log ERROR "Sync unsucessfull Time: $(date +%H:%M)"
                        fi
     else
                        log DEBUG "------------Sync Log Start--------"
                        log DEBUG "$res"
                        log DEBUG "------------Sync Log End--------"
                        log INFO "Sync Sucessfull Time: $(date +%H:%M)"

                        log INFO "Files Uploaded"
                        log INFO "`echo $res |  grep 'upload:' | awk -F'upload:' '{print $2}' | awk '{print $1}' | uniq`"
                        filesize=0
                        folsize=0
                        for file in `echo $res |  grep 'upload:' | awk -F'upload:' '{print $2}' | awk '{print $1}' | uniq`
                        do
                                if [ -f $file ] ; then
                                        filesize=$(/usr/bin/stat -c%s $file)
                                        folsize=$(expr $folsize + $filesize)
                                fi
                        done
                        log INFO "Total upload size for $SRCDIR - `echo \"scale=2; $folsize / 1024 / 1024\" | bc` MB"
                        totalsize=$(expr $totalsize + $folsize)

      fi
 done < $INCLUDE_LIST
log INFO "Total upload size `date +%F` - `echo \"scale=2; $totalsize / 1024 / 1024\" | bc` MB"
}
ReRun (){
Failed_Files_s3_location="$(grep 'upload failed:' $LOG|sed "s/\r/\n/g"|grep 'upload failed:'|awk '{print $5}' > /tmp/s3_sync_rerun)"


while read Failed_Files
  do
        if [ -f $(echo $Failed_Files|sed  "s/s3\:\/\/$S3_BUCKET\/$HOSTNAME//g") ] ; then

                `aws s3 cp "$(echo $Failed_Files|sed  "s/s3\:\/\/$S3_BUCKET\/$HOSTNAME//g")" $Failed_Files --storage-class  REDUCED_REDUNDANCY >> $LOG"_rerun"`
        elif [ ! -f $(echo $Failed_Files|sed  "s/s3\:\/\/$S3_BUCKET\/$HOSTNAME//g") ] ; then
                echo "$(echo $Failed_Files|sed  "s/s3\:\/\/$S3_BUCKET\/$HOSTNAME//g") File does Not exist" >>  $LOG"_rerun"
        fi
  sleep 1
done < /tmp/s3_sync_rerun


#numerror=$(grep -E -c 'upload failed:' $LOG"_rerun")
 #          if [ $numerror_rerun -gt 0 ] ; then
  #               echo -e "$HOST\t$NAGIOS_SERVICE_NAME\t2\tCRITICAL : Backup failed After Rerun ($numerror_rerun errors) $DATE"|$SEND_NSCA_CMD $NAGIOS_SERVER -c $SEND_NSCA_CONFIG
   #              exit 2
    #       elif  [ $numerror_rerun -eq 0 ] ; then
     #            #echo -e "$HOST\t$NAGIOS_SERVICE_NAME\t0\tOK : Backup Successful After Rerun$DATE"|$SEND_NSCA_CMD $NAGIOS_SERVER -c $SEND_NSCA_CONFIG
      #           exit 0
      #     fi
}
main (){
#if [ $# -lt 1 ]  ; then
#        usage
#fi
#PARA=$1
#IFS_OLD=$IFS
#IFS=','
#read -a SERVER <<< "${!PARA}"
#IFS=$IFS_OLD
FIRST_RUN=0
if [ $# -gt 0 ]  ; then
        if [ $1 == "FIRST-RUN" ] ; then
                FIRST_RUN=1
        fi
fi

#Check process already running
pids=$(pidof -x "$0")
if [ "$pids" != "$$" ] ; then
        echo "Process already running"
        exit 2
fi
if [ -f $LOG -a ! -f $LOG"_rerun" ]
then
numerror=$(grep -E -c 'upload failed:' $LOG)
        if [ $numerror -gt 0 ] ; then
             ReRun
        else
         echo "Upload successfull with no errors"
         exit 0
        fi
elif [ -f $LOG -a  -f $LOG"_rerun" ]
then
exit 2
elif [ ! -f $LOG ] ; then
upload
numerror=$(grep -E -c 'upload failed:' $LOG)
        if [ $numerror -gt 0 ] ; then
         ReRun
        fi

fi
#numerror=$(grep -E -c 'upload failed:' $LOG)

#if [ $numerror -gt 0 ] ; then
 #       ReRun
#fi
}
main $@