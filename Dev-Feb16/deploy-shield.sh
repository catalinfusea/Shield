#!/bin/bash

set -ex

###########################################
#####   Ericom Shield Installer        #####
###################################LO##BH###
NETWORK_INTERFACE='eth0'
IP_ADDRESS=
SINGLE_MODE=true
STACK_NAME='shield'
ES_YML_FILE=docker-compose.yml
HOST=$( hostname )
SECRET_UID="shield-system-id"

function test_swarm_exists {
    echo $( docker info | grep -i 'swarm: active' )
}

function init_swarm {
    if [ -z "$IP_ADDRESS" ]; then
        result=$( (docker swarm init --advertise-addr $NETWORK_INTERFACE --task-history-limit 0) 2>&1 )
    else
        result=$( (docker swarm init --advertise-addr $IP_ADDRESS --task-history-limit 0) 2>&1 )
    fi

    if [[ "$result" =~ 'already part' ]]
    then
        echo 2
    elif [[ "$result" =~ 'Error' ]]
    then
        echo 11
    else
        echo 0
    fi
}

function set_experimental {
    if [ -f /etc/docker/daemon.json ] && [  $( grep -c "\"experimental\" : true" /etc/docker/daemon.json ) -eq 1 ]; then
       echo "\"experimental\" : true in /etc/docker/daemon.json"
     else
       echo $'{\n\"experimental\" : true\n}\n' > /etc/docker/daemon.json
       echo "Setting: \"experimental\" : true in /etc/docker/daemon.json"
    fi
}

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

function update_images {
    echo "################## Getting images start ######################"
    images=$(grep "image" ${ES_YML_FILE} | awk '{print $2}' | sort | uniq)
    for image in ${images}; do
        docker pull ${image}
    done
    echo "################## Getting images  end ######################"
}

function get_right_interface {
    TEST_MAC=$(uname | grep Linux)
    if [ ! "$TEST_MAC" ]; then
        echo $(ifconfig $(netstat -rn | grep -E "^default|^0.0.0.0" | head -1 | awk '{print $NF}') | grep 'inet ' | awk '{print $2}' | grep -Eo '([0-9]*\.){3}[0-9]*')
    else
        echo $(route | grep '^default' | grep -o '[^ ]*$')
    fi
}

function make_in_memory_volume {
    if [ ! -d "/tmp/containershm" ]; then
      mkdir -p /tmp/containershm
      echo "Creating Directory /tmp/containershm for in memory volume"
    fi
    if [ ! "$(mount | grep containershm)" ]; then
      echo "mount in memory volume:  /tmp/containershm "
      mount -t tmpfs -o size=2G tmpfs /tmp/containershm
     else
      echo "mount in memory volume (/tmp/containershm) already exist "
    fi
}

while [ "$1" != "" ]; do
    case $1 in
        -s|--single-mode)
            SINGLE_MODE=true
        ;;
    esac
    shift
done

if [ -z "$SINGLE_MODE" ]; then
     echo 'Run multinode script'
     exit 0
else
    SWARM=$( test_swarm_exists )
    if [ -z "$SWARM" ]; then
        echo '#######################Start create swarm#####################'
        NETWORK_INTERFACE=$( get_right_interface )
        for int in $NETWORK_INTERFACE; do
            NETWORK_INTERFACE=$int
            break
        done
        SWARM_RESULT=$( init_swarm )
        if [ "$SWARM_RESULT" != "0" ]; then
            echo "Swarm init failed"
            exit 1
        fi
        echo '########################Swarm created########################'
    fi
    #update_images # no need to pull images docker stack does it
fi

create_uuid
make_in_memory_volume
set_experimental
export SYS_LOG_HOST=$( docker node ls | grep Leader | awk '{print $3}' )
docker stack deploy -c $ES_YML_FILE $STACK_NAME --with-registry-auth


