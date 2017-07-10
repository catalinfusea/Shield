#!/bin/bash
############################################
#####   Ericom Shield Run              #####
#######################################BH###
ES_PATH="/usr/local/ericomshield"
ES_RUN="$ES_PATH/run.sh"
ES_SWARM_FILE="$ES_PATH/.esswarm"

#Check if we are root
if (( $EUID != 0 )); then
#    sudo su
        echo " Please run it as Root"
        echo "sudo" $0 $1 $2
        exit
fi
cd $ES_PATH

if [ -f "$ES_SWARM_FILE" ]; then
   NUM_EXPECTED_SERVICES=$(grep -c image docker-compose.yml)
   NUM_RUNNING_SERVICES=$(docker service ls |wc -l)

   if [ $NUM_RUNNING_SERVICES -ge  $NUM_EXPECTED_SERVICES ]; then
       echo "***************     Ericom Shield (swarm) is running"
     else
      echo " Ericom Shield (swarm) is not running properly on this system"
      exit 1
   fi
 else
   NUM=`grep scale $ES_RUN | tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | sed 's/ /'+'/g'`
   DOCKERS_FOR_SHIELD=$(($NUM))
   echo $DOCKERS_FOR_SHIELD
   SHIELD_STRING=securebrowsing
   docker ps | grep $SHIELD_STRING |wc -l

   if [ $( docker ps | grep $SHIELD_STRING |wc -l ) -ge  $DOCKERS_FOR_SHIELD ]; then
       echo "***************     Ericom Shield (compose) is running"
     else
      echo " Ericom Shield is not running properly on this system"
      exit 1
   fi
fi

exit 0
