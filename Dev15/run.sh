#!/bin/bash
# Ericom Shield
# Launch Dockers for Ericom Shield

echo "***********       Launching docker-compose up"
echo "                  consul=3"
echo "                  consului=1 "
echo "                  elk=1 "
echo "                  shield-broker=1 "
echo "                  shield-browser=1 "
echo "                  proxy-server=1 "
echo "                  icap-server=1"
echo "***********       "
docker-compose up -d && docker-compose scale consul=3 shield-admin=1 elk=1 shield-browser=1 proxy-server=1 icap-server=1
# && docker-compose logs
