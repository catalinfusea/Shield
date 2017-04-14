#!/bin/bash
#####   Ericom Shield Run              #####
#######################################BH###
ES_PATH=/usr/local/ericomshield

if (( $EUID != 0 )); then
#    sudo su
        echo "Usage:" $0 [-force] [-noautoupdate] [-dev] [-usage]
        echo " Please run it as Root"
        echo "sudo" $0 
        exit
fi

cd $ES_PATH

MAX_BROWSERS=30
BROWSERS=10
LOGFILE="$ES_PATH/ericomshield-load.log"
ES_TEST_PATH="$ES_PATH/testresults"
ES_TEST_OK_PATH="$ES_PATH/testresultsok"
URLS_FILE="$ES_PATH/top50urls.txt"
RESPONSE_FILE="$ES_PATH/an_response.txt"

# Create the Ericom empty dir if necessary
if [ ! -d $ES_TEST_PATH ]; then
    mkdir -p $ES_TEST_PATH
    chmod 0755 $ES_TEST_PATH
fi

# Create the Ericom empty dir if necessary
if [ ! -d $ES_TEST_OK_PATH ]; then
    mkdir -p $ES_TEST_OK_PATH
    chmod 0755 $ES_TEST_OK_PATH
fi
 
if [ -f "$ES_DEV_FILE" ]; then
   ES_DEV=true
fi

docker-compose up -d && docker-compose scale consul=3 shield-admin=1 elk=1 shield-browser=$BROWSERS proxy-server=1 icap-server=1

while [  $BROWSERS -lt $MAX_BROWSERS ]; do
    let BROWSERS=BROWSERS+5
    echo "***********       Launching docker-compose up"
    echo "                  consul=3"
    echo "                  shield-admin=1 "
    echo "                  elk=1 "
    echo "                  proxy-server=1 "
    echo "                  icap-server=1"
    echo "***********       "
    echo "                  shield-browser=$BROWSERS "
    echo "***********       "
    docker-compose scale shield-browser=$BROWSERS

    if [ $? == 0 ]; then
       echo "***************     Success!"
       echo "$(date):Now Runnning shield-browser=$BROWSERS "
      else
       echo "An error occured during the installation"
       echo "$(date): An error occured during the installation" >> "$LOGFILE"
       exit 1
    fi

    sleep 1m
   /usr/local/ericomshield/status.sh  >> "$LOGFILE"
   docker system df  >> "$LOGFILE"
   docker stats -a --no-stream >> "$LOGFILE" $(docker ps --format={{.Names}})
   rm -f "$ES_TEST_PATH/*"
   rm -f "$ES_TEST_OK_PATH/*"
   echo "***************     Starting Tests!"
   head -n "$BROWSERS" "$URLS_FILE" | while read url; do
          echo "Checking URL: $url"
          curl -q -o "$ES_TEST_PATH/$TEST_BROWSERS.txt" --proxy http://localhost:3128 $url &
          cp "$RESPONSE_FILE" "$ES_TEST_OK_PATH/$TEST_BROWSERS.txt"
   done
   sleep 3m

   if [ $( diff $ES_TEST_PATH $ES_TEST_OK_PATH | wc -l ) -eq 0 ]; then
       echo "***************     Tests Results are OK!"
       echo "$(date):Tests Results are OK"
      else
       echo "Tests Results are not ok, Test Browsers=$TEST_BROWSERS/$BROWSERS"
       echo "$(date): Tests Results are not ok, Test Browsers=$TEST_BROWSERS/$BROWSERS" >> "$LOGFILE"
#       exit 1
   fi

done
