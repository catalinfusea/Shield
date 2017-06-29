#!/bin/bash
#####   Ericom Shield Run              #####
#######################################BH###

if (( $EUID != 0 )); then
#    sudo su
        echo " Please run it as Root"
        echo "sudo" $0
        exit
fi

HOST=`hostname`
LOGFILE="./ericomshield-svc.log"
SERVICES_LAST_FILE=/tmp/svc_last.txt
SERVICES_CUR_FILE=/tmp/svc_cur.txt

echo "        *****************************************************" >> "$LOGFILE"
echo "$(date):****************** Ericom Shield Service Monitoring ($HOST)" >> "$LOGFILE"
echo "$(date):****************** Ericom Shield Service Monitoring ($HOST)"

docker service ls > $SERVICES_LAST_FILE
cat $SERVICES_LAST_FILE
while true
do
   docker service ls > $SERVICES_CUR_FILE
   if [ $( diff  $SERVICES_LAST_FILE $SERVICES_CUR_FILE | wc -l ) -ne 0 ]; then
then
      cat $SERVICES_CUR_FILE
      echo "$(date):" >> "$LOGFILE"
      cat $SERVICES_CUR_FILE >> "$LOGFILE"
      mv $SERVICES_CUR_FILE  $SERVICES_LAST_FILE
   fi
   sleep 5
done
