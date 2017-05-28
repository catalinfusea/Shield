#!/bin/bash
############################################
#####   Ericom Shield Stop             #####
#######################################BH###

ES_PATH=/usr/local/ericomshield
ES_SWARM_FILE="$ES_PATH/.esswarm"

if [ -f "$ES_SWARM_FILE" ]; then
   echo run.sh is not working for swarm mode 
 else
   cd $ES_PATH
   echo "***********       Stopping ericomshield dockers "
   echo "***********       "
   docker-compose down
 fi
