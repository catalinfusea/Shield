#!/bin/bash
############################################
#####   Ericom Shield AutoUpdate       #####
#######################################BH###

#  run this script in the background
#  sudo nohup ./autoupdate.sh > /dev/null &

ES_PATH="/usr/local/ericomshield"
cd $ES_PATH

while true
do
        echo "."
        ./ES-setup.sh
        sleep 5m
        ./status.sh
        if [ $? -ne 0 ]; then
          echo "ericomshield was not running"
          ./run.sh
        fi
done
