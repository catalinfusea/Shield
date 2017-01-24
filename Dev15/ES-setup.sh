#!/bin/bash
# Ericom Shield
# Installer
#
#Check if we are root
if (( $EUID != 0 )); then
    sudo su
fi

# Development Repository: (Latest)
ES_repo_run="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev15/run.sh"
ES_repo_yml="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev15/docker-compose.yml"

# Production Repository: (Stable)
#ES_repo_run="https://raw.githubusercontent.com/ErezPasternak/Shield/master/vSoteria/run"
#ES_repo_yml="https://raw.githubusercontent.com/ErezPasternak/Shield/master/vSoteria/docker-compose.yml"


echo "***************     Installing Ericom Shield ..."

curl -s -S -o docker-compose.yml $ES_repo_yml
curl -s -S -o run.sh $ES_repo_run
chmod +x run.sh

apt-get update
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
apt-get update

if [ $(dpkg -l | grep  -c docker-engine ) -eq  0 ]; then
     echo "***************     Installing docker-engine"
     apt-cache policy docker-engine
     apt-get install -y docker-engine
   
else
     echo " ******* docker-engine is already installed"
fi
echo "Starting docker service"
service docker start

#Verify that docker is installed correctly by running the hello-world image.
#docker run hello-world
#systemctl status docker
 
if [ $( which docker-compose | wc -l ) -eq 0 ]; then 
   echo "***************     Installing docker-compose"
   curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
   chmod +x /usr/bin/docker-compose
else 
   echo "***************     DockerCompose is already installed"
fi


if [ "$#" -eq 2 ]; then
    #Login and enter the credentials you received separately when prompt
    echo "docker login" $1 $2
    docker login --username=$1 --password=$2
else
    echo " Please enter your login credentials to docker-hub"
    docker login 
fi
    
    if [ $? == 0 ]; then
      echo "Login Succeeded!"
    else
      echo "Please try again:"
      docker login 
      if [ $? == 0 ]; then
         echo "Login Succeeded!"
        else
         echo "Cannot Login, Exiting!"
         exit
      fi
    fi

./run.sh
