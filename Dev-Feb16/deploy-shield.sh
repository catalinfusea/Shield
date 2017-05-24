#!/bin/bash

set -e

DOCKER_COMPOSE_FILE='deploy-shield.yml'
STACK_NAME='shield'
NETWORK_INTERFACE='eth0'
HOST=$( hostname )

function test_swarm_exists {
    TEST_SWARM=$( (docker node ls | grep -i "$HOST" | awk {'print $3'}) 2>&1)

    if [ "$HOST" = "$TEST_SWARM" ]; then
        echo "$HOST"
    else
        echo ''
    fi
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

function update_images {
    echo "################## Getting images start ######################"
    images=$(grep "image" ${DOCKER_COMPOSE_FILE} | awk '{print $2}' | sort | uniq)
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
        SWARM_RESULT=$( init_swarm )
        if [ "$SWARM_RESULT" != "0" ]; then
            echo "Swarm init failed"
            exit 1
        fi
        echo '########################Swarm created########################'
    fi
    update_images
fi

docker stack deploy -c $DOCKER_COMPOSE_FILE $STACK_NAME

