#!/bin/bash

STACK_DEPLOY_NAME=shield
docker stack rm $STACK_DEPLOY_NAME
docker swarm leave -f
#docker rm $(docker kill consul)
#docker system prune -f

