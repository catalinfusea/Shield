#!/bin/bash
############################################
#####   Ericom Shield AutoUpdate       #####
#######################################BH###

#  If you are not using ericomshield service, run this script in the background
#  sudo nohup ./autoupdate.sh > /dev/null &

AUTO_UPDATE_TIME=5m
ES_repo_setup="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/ericomshield-setup.sh"

ES_PATH="/usr/local/ericomshield"
ES_AUTO_UPDATE_FILE="$ES_PATH/.autoupdate"
cd $ES_PATH

#Check if we are root
if (( $EUID != 0 )); then
        echo "Usage:" $0 [-force] [-noautoupdate] [-dev] [-usage]
        echo " Please run it as Root"
        echo "sudo" $0
        exit
fi

while true
do
        if [ -f "$ES_AUTO_UPDATE_FILE" ]; then
           curl -s -S -o ericomshield-setup.sh $ES_repo_setup
           chmod +x ericomshield-setup.sh
           ./ericomshield-setup.sh
        fi
        echo "."
        sleep $AUTO_UPDATE_TIME
        echo "-"
        ./status.sh  > /dev/null &
        if [ $? -ne 0 ]; then
          echo "ericomshield was not running"
          ./run.sh
        fi
done
