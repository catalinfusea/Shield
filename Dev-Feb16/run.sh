#!/bin/bash
############################################
#####   Ericom Shield Run              #####
#######################################BH###

ES_PATH=/usr/local/ericomshield
ES_SWARM_FILE="$ES_PATH/.esswarm"
STACK_NAME='shield'
ES_YML_FILE=docker-compose.yml

#Check if we are root
if (( $EUID != 0 )); then
#    sudo su
        echo " Please run it as Root"
        echo "sudo" $0 $1 $2
        exit
fi
cd $ES_PATH

if [ -f "$ES_SWARM_FILE" ]; then
   echo "swarm mode:"
   ./deploy-shield.sh
 else
   #cd $ES_PATH
   echo "***********       Launching docker-compose up"
   echo "                  consul=3"
   echo "                  shield-admin=1 "
   echo "                  elk=1 "
   echo "                  shield-browser=20 "
   echo "                  proxy-server=1 "
   echo "                  icap-server=1"
   echo "***********       "
   docker-compose -f docker-compose.yml up -d && docker-compose -f docker-compose.yml scale consul=3 shield-admin=1 elk=1 shield-browser=20 proxy-server=1 icap-server=1
   # && docker-compose logs
fi

