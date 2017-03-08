#####   Ericom Shield Run              #####
#######################################BH###
ES_PATH=/usr/local/ericomshield

cd $ES_PATH

echo "***********       Launching docker-compose up"
echo "                  consul=3"
echo "                  shield-admin=1 "
echo "                  elk=1 "
echo "                  shield-browser=$SHIELD_BROWSER "
echo "                  proxy-server=1 "
echo "                  icap-server=1"
echo "***********       "
docker-compose up -d && docker-compose scale consul=3 shield-admin=1 elk=1 shield-browser=20 proxy-server=1 icap-server=1

# && docker-compose logs
