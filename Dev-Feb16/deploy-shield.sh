#!/bin/bash -x  
DEBUG_MODE=
CONSUL_IMAGE=consul:0.7.5
NETWORK_INTERFACE=eth0
IP_ADDRESS=
DEPLOY_MODE=single
STACK_DEPLOY_NAME=shield
CONSUL_NETWORK_INTERFACE=eth0
BROWSER_HOSTNAME=ericom-browser.com
COMPOSE=deploy-shield.yml

function set_arg_value {
    if [ -n "$1" ]; then
        eval "$2"
        shift 2
    else
        eval "$3"
    fi
}


while [ "$1" != "" ]; do
    case $1 in
        -ci|--consul-image)
            set_arg_value "$2" "CONSULE_IMAGE=$2" "echo 'ERROR: --consul-image require arguments'"
        ;;
        -ip|--ip-address)
            set_arg_value "$2" "IP_ADDRESS=$2" "echo 'ERROR: --ip-address require arguments'"
        ;;
        -ni|--network-interface)
            set_arg_value "$2" "NETWORK_INTERFACE=$2" "echo 'ERROR: --network-interface require arguments'"
        ;;
        -dm|--deploy_mode)
            set_arg_value "$2" "DEPLOY_MODE=$2" "echo 'ERROR: --deploy_mode require arguments'"
        ;;
        -sn|--stack_name)
            set_arg_value "$2" "STACK_DEPLOY_NAME=$2" "echo 'ERROR: --stack_name require arguments'"
        ;;
        -cni|--consul-network-interface)
            set_arg_value "$2" "CONSUL_NETWORK_INTERFACE=$2" "echo 'ERROR: --consul-network-interface require arguments'"
        ;;
        -dbg|--run-in-debug-mode)
            DEBUG_MODE=true
        ;;
    esac
    shift
done

function get_right_interface {
    TEST_MAC=$(uname | grep Linux)
    if [ ! "$TEST_MAC" ]; then
        echo $(ifconfig $(netstat -rn | grep -E "^default|^0.0.0.0" | head -1 | awk '{print $NF}') | grep 'inet ' | awk '{print $2}' | grep -Eo '([0-9]*\.){3}[0-9]*')
    else 
        echo $(route | grep '^default' | grep -o '[^ ]*$')
    fi
}



ALREADY_SWARM=$( (docker node ls | grep -i 'This node is not a swarm manager') 2>&1 )

##### Single node only #####
# https://docs.docker.com/engine/reference/commandline/network_create/#bridge-driver-options

function create_network {
    TEST_NETWORK=$(docker network ls | grep -i 'shield-network')
    if [ ! $TEST_NETWORK ]; then 
        docker network create -d overlay \
            --subnet 192.168.0.0/16 \
            --attachable=true \
            --opt iface=eth0 \
            --gateway=192.168.50.119 \
            shield-network
    fi       
}

function create_secrets {
    cat ./cef.crt | docker secret create "$STACK_DEPLOY_NAME"_cef.crt -;
    cat ./cef.key | docker secret create "$STACK_DEPLOY_NAME"_cef.key -
}


function init_swarm {
    if [ "$IP_ADDRESS" != '' ]; then
        result=$( (docker swarm init --advertise-addr $IP_ADDRESS --task-history-limit 0) 2>&1 )
    else
        result=$( (docker swarm init --advertise-addr $NETWORK_INTERFACE --task-history-limit 0) 2>&1 )
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

function deploy_consul {
    if [ "$DEPLOY_MODE"=='single' ]; then
        echo $(docker run -d --network shield-network --name consul --hostname consul -e "CONSUL_BIND_INTERFACE=$CONSUL_NETWORK_INTERFACE" -p "8500:8500" $CONSUL_IMAGE)
      #  echo $(docker service create --network shield-network --name consul --hostname consul --detach=false -e "CONSUL_BIND_INTERFACE=$CONSUL_NETWORK_INTERFACE" -p "8500:8500" $CONSUL_IMAGE)
    fi
}
function update_images {
    echo "################## Getting images start ######################"
    images=$(grep "image" ${COMPOSE} | awk '{print $2}' | sort | uniq)
    for image in ${images}; do
        docker pull ${image}
    done
    echo "################## Getting images  end ######################"
}

function clean_system {
    echo "################## Clean system start ######################"
    res=$(docker system prune -f)
   # echo $res
    echo "################## Clean system end ######################"
}

###########################################################
# code start to run here

# getting new images from docker hub if needed 
update_images

echo "################## Start Create docker swarm ######################"

NETWORK_INTERFACE=$( get_right_interface )
swarm_res=$( init_swarm )
echo "################## Docker swarm created ##########################"
case "$swarm_res" in
    0)   
        network_res=$( create_network )

        if [ "$network_res" != "" ]
        then
            echo 'Network for swarm created'
        fi

    #    SECRET_RES=$( create_secrets )
        
        CONSUL_RES=$( deploy_consul )
        if [[ "$CONSUL_RES" =~ "Error" ]]; then
            echo 'Consule deploy Error'
            exit 1
        else
            #--with-registry-auth
            STACK_DEPLOY_RES=$(docker stack deploy -c deploy-shield.yml $STACK_DEPLOY_NAME)
        fi
        ;;
    1)
        echo 'Very bad'
        ;;
    2)
        echo 'Updating the system'
        STACK_DEPLOY_RES=$(docker stack deploy -c deploy-shield.yml $STACK_DEPLOY_NAME)
        clean_system
        ;;
    11) 
        echo "It's extrimly bad"
        ;;
esac






