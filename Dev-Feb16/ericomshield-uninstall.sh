#!/bin/bash
############################################
#####   Ericom Shield Installer        #####
#######################################BH###

#Check if we are root
if (( $EUID != 0 )); then
#    sudo su
        echo "Usage:" $0
        echo " Please run it as Root"
        echo "sudo" $0
        exit
fi
ES_PATH="/usr/local/ericomshield"
LOGFILE="$ES_PATH/ericomshield.log"

cd $ES_PATH

service ericomshield stop
docker-compose down

docker kill $(docker ps -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)

echo "Uninstalling Ericom Shield"
systemctl --global disable ericomshield-updater.service
systemctl --global disable ericomshield.service
systemctl daemon-reload

rm /etc/init.d/ericomshield

echo "$(date): Uninstalling Ericom Shield" >> "$LOGFILE"
mv "$LOGFILE" ..
rm -f $ES_PATH/*
rm -f $ES_PATH/.*

docker system prune -f -a

echo "Done!"
