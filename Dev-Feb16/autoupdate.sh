#!/bin/bash
############################################
#####   Ericom Shield AutoUpdate       #####
#######################################BH###

#  If you are not using ericomshield service, run this script in the background
#  sudo nohup ./autoupdate.sh > /dev/null &

ES_AUTO_UPDATE_FILE="$ES_PATH/.autoupdate"
ES_PATH="/usr/local/ericomshield"
cd $ES_PATH

while true
do
        if [ -f "$ES_AUTO_UPDATE_FILE" ]; then
           ./ericomshield-setup.sh
        fi
        echo "."
        sleep 5m
        ./status.sh  > /dev/null &
        if [ $? -ne 0 ]; then
          echo "ericomshield was not running"
          ./run.sh
        fi
done
