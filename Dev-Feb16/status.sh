#!/bin/bash
############################################
#####   Ericom Shield Run              #####
#######################################BH###
ES_PATH="/home/ericom/ericomshield"
ES_RUN="$ES_PATH/run.sh"

NUM=`grep scale $ES_RUN | tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | sed 's/ /'+'/g'`
DOCKERS_FOR_SHIELD=$(($NUM))
echo $DOCKERS_FOR_SHIELD
SHIELD_STRING=securebrowsing
docker ps | grep $SHIELD_STRING |wc -l

if [ $( docker ps | grep $SHIELD_STRING |wc -l ) -ge  $DOCKERS_FOR_SHIELD ]; then
    echo "***************     Ericom Shield Dockers are running"
  else
   echo " Ericom Shield is not running properly on this system"
   exit 1
fi

exit 0
