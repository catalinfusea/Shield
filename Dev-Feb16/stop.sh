#!/bin/bash
############################################
#####   Ericom Shield Stop             #####
#######################################BH###
ES_PATH=/home/ericom/ericomshield

cd $ES_PATH
echo "***********       Stopping ericomshield dockers "
echo "***********       "
docker-compose down
