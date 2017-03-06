#!/bin/bash
############################################
#####   Ericom Shield Stop             #####
#######################################BH###
ES_PATH=/usr/local/ericomshield

cd $ES_PATH
echo "***********       Stopping ericomshield dockers "
echo "***********       "
docker-compose down
