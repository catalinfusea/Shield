#!/bin/bash

echo "***************     Stopping Ericom Shield ..."
docker-compose down

echo "***************     removing old Ericom Shield ..."

rm run.sh
rm docker-compose.yml

# Development Repository: (Latest)
ES_repo_run="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/run.sh"
ES_repo_yml="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/docker-compose.yml"


echo "***************     Installing Ericom Shield ..."

curl -s -S -o docker-compose.yml $ES_repo_yml
curl -s -S -o run.sh $ES_repo_run
chmod +x run.sh
./run.sh

echo "***************     Success!"
echo "***************"
echo "***************     Ericom Shield Version:" $Version "is up and running"
