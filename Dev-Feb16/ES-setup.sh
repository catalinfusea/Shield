#!/bin/bash
############################################
#####   Ericom Shield Installer        #####
#######################################BH###

#Check if we are root
if (( $EUID != 0 )); then
#    sudo su
        echo " Please run it as Root"
        echo "sudo" $0 $1 $2
        exit
fi

UPDATE=0

# Development Repository: (Latest)
ES_repo_run="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/run.sh"
ES_repo_update="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/autoupdate.sh"
ES_repo_version="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/showversion.sh"
ES_repo_yml="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/docker-compose.yml"

if [ $(dpkg -l | grep  -c curl ) -eq  0 ]; then
    echo "***************     Installing curl"
    sudo apt-get install curl
fi

curl -s -S -o docker-compose.yml.1 $ES_repo_yml
if [ -f "docker-compose.yml" ]; then
   if [ $( diff  docker-compose.yml.1  docker-compose.yml | wc -l ) -eq 0 ]; then
      echo "Your EricomShield System is Up to date"
      exit
    else
      echo "***************     Updating EricomShield"
      mv docker-compose.yml docker-compose.yml.org
      mv docker-compose.yml.1 docker-compose.yml
      UPDATE=1
   fi
 else
   echo "***************     Installing EricomShield ..."
   mv docker-compose.yml.1 docker-compose.yml
fi

curl -s -S -o run.sh $ES_repo_run
chmod +x run.sh
curl -s -S -o autoupdate.sh $ES_repo_update
chmod +x autoupdate.sh
curl -s -S -o showversion.sh $ES_repo_version
chmod +x showversion.sh

if [ $UPDATE -eq 0 ]; then

    if [ $(dpkg -l | grep  -c docker-engine ) -eq  0 ]; then
         echo "***************     Installing docker-engine"
         apt-get update
         apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
         apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
         apt-get update
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
       curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
       chmod +x /usr/local/bin/docker-compose
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
fi

./run.sh

grep SHIELD_VER docker-compose.yml  > .version
grep image docker-compose.yml >> .version

Version=`grep  SHIELD_VER docker-compose.yml`
echo "***************     Success!"
echo "***************"
echo "***************     Ericom Shield Version:" $Version "is up and running"
