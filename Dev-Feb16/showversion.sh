#!/bin/bash
############################################
#####   Ericom Shield ShowVersion      #####
#######################################BH###

ES_PATH=/usr/local/ericomshield
ES_VERSION="$ES_PATH/.version"
ES_SWARM_FILE="$ES_PATH/.esswarm"

cat $ES_VERSION
if [ -f "$ES_SWARM_FILE" ]; then
   echo "(Swarm)"
fi
