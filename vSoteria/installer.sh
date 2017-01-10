#!/bin/sh
sudo su

curl -o docker-compose.yml https://raw.githubusercontent.com/ErezPasternak/Shield/master/vSoteria/docker-compose.yml
curl -o run https://raw.githubusercontent.com/ErezPasternak/Shield/master/vSoteria/run
chmod 777 run

apt-get update
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
apt-get update
apt-cache policy docker-engine
apt-get install -y docker-engine
service docker start

#Verify that docker is installed correctly by running the hello-world image.
docker run hello-world
systemctl status docker
curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

#Login and enter the credentials you received separately when prompt
echo 'docker login --username=$DOCKER_USER --password=$DOCKER_PASS'

./run