#!/bin/bash

set -ex

###########################################
#####   Ericom Shield Installer        #####
###################################LO##BH###
NETWORK_INTERFACE='eth0'
#IP_ADDRESS=
SINGLE_MODE=true
STACK_NAME='shield'
ES_YML_FILE=docker-compose_swarm_mm.yml
HOST=$( hostname )
SECRET_UID="shield-system-id"


function create_uuid {
    if [ $( docker secret ls | grep -c $SECRET_UID) -eq 0 ]; then
       uuid=$(uuidgen)
       uuid=${uuid^^}
       echo $uuid | docker secret create $SECRET_UID -
       echo "$SECRET_UID created: uuid: $uuid "
    else
      echo " $SECRET_UID secret already exist "
    fi
}

create_uuid
 
#export SYS_LOG_HOST=$( docker node ls | grep Leader | awk '{print $3}' )
export SYS_LOG_HOST=192.168.50.133
docker stack deploy -c $ES_YML_FILE $STACK_NAME --with-registry-auth


