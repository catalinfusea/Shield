#!/bin/bash
############################################
#####   Ericom Shield Stop             #####
#######################################BH###

ES_PATH=/usr/local/ericomshield
ES_SWARM_FILE="$ES_PATH/.esswarm"
STACK_NAME=shield

if [ -f "$ES_SWARM_FILE" ]; then
   echo "***********       Stopping EricomShield (swarm) "
   echo "***********       "
   docker stack rm $STACK_NAME
#   docker swarm leave -f
 else
   cd $ES_PATH
   echo "***********       Stopping EricomShield "
   echo "***********       "
   docker-compose down
 fi
