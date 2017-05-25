#####   Ericom Shield Run              #####
#######################################BH###

#ES_PATH=/usr/local/ericomshield

#cd $ES_PATH

#echo "***********       Launching docker-compose up"
#echo "                  consul=3"
#echo "                  shield-admin=1 "
#echo "                  elk=1 "
#echo "                  shield-browser=20 "
#echo "                  proxy-server=1 "
#echo "                  icap-server=1"
#echo "***********       "
docker-compose -f deploy-shield.yml up -d && docker-compose -f deploy-shield.yml scale consul=1 shield-admin=1 elk=1 shield-browser=5 proxy-server=1 icap-server=1

# && docker-compose logs
