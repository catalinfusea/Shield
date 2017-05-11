#!/bin/bash
############################################
#####   Ericom Shield Installer        #####
#######################################BH###

#Check if we are root
if (( $EUID != 0 )); then
#    sudo su
        echo "Usage:" $0 [-force] [-noautoupdate] [-dev] [-usage]
        echo " Please run it as Root"
        echo "sudo" $0 $1 $2 $3 $4 $5
        exit
fi
ES_PATH="/usr/local/ericomshield"
LOGFILE="$ES_PATH/ericomshield.log"
DOCKER_VERSION="17.05"
DOCKER_COMPOSE_VERSION="1.10"
UPDATE=0
ES_DEV_FILE="$ES_PATH/.esdev"
ES_AUTO_UPDATE_FILE="$ES_PATH/.autoupdate"

# Development Repository: (Latest)
ES_repo_setup="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/ericomshield-setup.sh"
ES_repo_run="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/run.sh"
ES_repo_update="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/autoupdate.sh"
ES_repo_version="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/showversion.sh"
ES_repo_stop="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/stop.sh"
ES_repo_status="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/status.sh"
ES_repo_service="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/ericomshield"
ES_repo_ip="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/show-my-ip.sh"
ES_repo_systemd_service="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/ericomshield.service"
ES_repo_systemd_updater_service="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/ericomshield-updater.service"
ES_repo_sysctl_shield_conf="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/sysctl_shield.conf"
# Production Repository: (Release)
ES_repo_yml="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/docker-compose.yml"
# Development Repository: (Latest)
ES_dev_repo_yml="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/docker-compose_dev.yml"

DOCKER_USER="benyh"
DOCKER_SECRET="Ericom123$"
ES_EVAL=false
ES_DEV=false
ES_AUTO_UPDATE=true

# Create the Ericom empty dir if necessary
if [ ! -d $ES_PATH ]; then
    mkdir -p $ES_PATH
    chmod 0755 $ES_PATH
fi

cd $ES_PATH

while [ $# -ne 0 ]
do
    arg="$1"
    case "$arg" in
        -eval)
            ES_EVAL=true
            ;;
        -dev)
            ES_DEV=true
            echo "ES_DEV" > "$ES_DEV_FILE"
            ;;
        -noautoupdate)
            ES_AUTO_UPDATE=false
            rm -f "$ES_AUTO_UPDATE_FILE"
            ;;
        -force)
            ES_FORCE=true
            echo " " >> docker-compose.yml
            ;;
        -usage)
            echo "Usage:" $0 Username Password [-eval] [-autoupdate] [-dev]
            exit
            ;;
        *)
            if [ "$DOCKER_USER" == "benyh" ]; then
               DOCKER_USER=$1
             else
               DOCKER_SECRET=$1
            fi
            ;;
    esac
    shift
done

if [ -f "$ES_DEV_FILE" ]; then
   ES_DEV=true
fi

if [ "$ES_AUTO_UPDATE" == true ]; then
   echo "ES_AUTO_UPDATE" > "$ES_AUTO_UPDATE_FILE"
fi

if [ $(dpkg -l | grep  -c curl ) -eq  0 ]; then
    echo "***************     Installing curl"
    sudo apt-get install curl
fi

if [ "$ES_DEV" == true ]; then
   curl -s -S -o docker-compose.yml.1 $ES_dev_repo_yml
 else
   curl -s -S -o docker-compose.yml.1 $ES_repo_yml
fi

if [ -f "docker-compose.yml" ]; then
   if [ $( diff  docker-compose.yml.1  docker-compose.yml | wc -l ) -eq 0 ]; then
      echo "Your EricomShield System is Up to date"
      exit
    else
      echo "***************     Updating EricomShield"
      echo "$(date): New version found:  Updating EricomShield" >> "$LOGFILE"
      mv docker-compose.yml docker-compose.yml.org
      mv docker-compose.yml.1 docker-compose.yml
      docker-compose pull
      UPDATE=1
   fi
    else
   echo "***************     Installing EricomShield ..."
   echo "$(date): Installing EricomShield" >> "$LOGFILE"
   mv docker-compose.yml.1 docker-compose.yml
fi
echo $DOCKER_USER $DOCKER_SECRET
echo "eval=$ES_EVAL"
echo "dev=$ES_DEV"
echo "autoupdate=$ES_AUTO_UPDATE"

if [ ! -f "ericomshield-setup.sh" ]; then
   curl -s -S -o ericomshield-setup.sh $ES_repo_setup
   chmod +x ericomshield-setup.sh
fi

if [ ! -f "run.sh" ]; then
   curl -s -S -o run.sh $ES_repo_run
fi
if [ "$ES_EVAL" == true ]; then
'   curl -s -S -o run.sh $ES_repo_run_eval
   echo "Installing Ericom Shield evaluation"
fi
chmod +x run.sh

curl -s -S -o autoupdate.sh $ES_repo_update
chmod +x autoupdate.sh
curl -s -S -o showversion.sh $ES_repo_version
chmod +x showversion.sh
curl -s -S -o stop.sh $ES_repo_stop
chmod +x stop.sh
curl -s -S -o status.sh $ES_repo_status
chmod +x status.sh
curl -s -S -o ericomshield $ES_repo_service
chmod +x ericomshield
curl -s -S -o ~/show-my-ip.sh $ES_repo_ip
chmod +x ~/show-my-ip.sh
' Need to download these service files only if needed and reload only if changed
curl -s -S -o "${ES_PATH}/ericomshield.service" "${ES_repo_systemd_service}"
curl -s -S -o "${ES_PATH}/ericomshield-updater.service" "${ES_repo_systemd_updater_service}"

systemctl daemon-reload 

if [ $UPDATE -eq 0 ]; then

    if [ $(sudo docker version | grep $DOCKER_VERSION |wc -l ) -le  1 ]; then
         echo "***************     Installing docker-engine"
         apt-get -y install apt-transport-https
         apt-get update
         apt-get --assume-yes install software-properties-common python-software-properties
         apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
         apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
         apt-cache policy docker-engine
         apt-get --assume-yes install linux-image-extra-$(uname -r) linux-image-extra-virtual
         apt-get update
         apt-get --assume-yes -y install docker-engine

    else
         echo " ******* docker-engine is already installed"
    fi
    echo "Starting docker service"
    service docker start
    if [ $? == 0 ]; then
       echo "***************     Success!"
      else
       echo "An error occured during the installation"
       echo "$(date): An error occured during the installation: failed to install docker" >> "$LOGFILE"
       exit 1
    fi

    #Verify that docker is installed correctly by running the hello-world image.
    #docker run hello-world
    #systemctl status docker

    if [ $(  docker-compose version | grep $DOCKER_COMPOSE_VERSION |wc -l ) -eq 0 ]; then
       echo "***************     Installing docker-compose"
       curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
       chmod +x /usr/local/bin/docker-compose
    else
       echo "***************     DockerCompose is already installed"
    fi

    if [ $(docker info | grep Username |wc -l) -eq 0 ]; then
       if [ "$DOCKER_USER" == " " ]; then
           echo " Please enter your login credentials to docker-hub"
           docker login
       else
           #Login and enter the credentials you received separately when prompt
           echo "docker login" $DOCKER_USER $DOCKER_SECRET
           docker login --username=$DOCKER_USER --password=$DOCKER_SECRET
       fi

       if [ $? == 0 ]; then
         echo "Login Succeeded!"
       else
         echo "Please try again:"
         docker login
         if [ $? == 0 ]; then
            echo "Login Succeeded!"
           else
            echo "Cannot Login to docker, Exiting!"
            echo "$(date): An error occured during the installation: Cannot login to docker" >> "$LOGFILE"
            exit 1
         fi
       fi
       #check if file was not updated
       curl -s -S -o "${ES_PATH}/sysctl_shield.conf" "${ES_repo_sysctl_shield_conf}"
       if [ $(grep EricomShield /etc/sysctl.conf | wc -l) -eq 0 ]; then
          # append sysctl with our settings
          cat "${ES_PATH}/sysctl_shield.conf" >> /etc/sysctl.conf
          #to apply the changes:
          sysctl -p
          echo "file /etc/sysctl.conf Updated!!!!"
         else
          echo "file /etc/sysctl.conf already updated"
       fi
    fi

    if [ "$ES_EVAL" == true ]; then
       docker-compose pull
    fi   
    echo "**************  Creating the ericomshield service..."
    systemctl --global enable "${ES_PATH}/ericomshield.service"
    cp ericomshield /etc/init.d/
    update-rc.d ericomshield defaults

    systemctl --global enable "${ES_PATH}/ericomshield-updater.service"    
    
    systemctl daemon-reload 
    echo "Done!"

    echo "Starting Ericom Shield Service"
    service ericomshield start
    systemctl start ericomshield-updater.service   
  else
    echo "Restarting Ericom Shield Service"
    service ericomshield restart
    docker system prune -f -a
fi

if [ $? == 0 ]; then
   echo "***************     Success!"
  else
   echo "An error occured during the installation"
   echo "$(date): An error occured during the installation" >> "$LOGFILE"
   exit 1
fi

grep SHIELD_VER docker-compose.yml  > .version
grep image docker-compose.yml >> .version

Version=`grep  SHIELD_VER docker-compose.yml`
echo "***************     Success!"
echo "***************"
echo "***************     Ericom Shield Version:" $Version "is up and running"
echo "$(date): Ericom Shield Version:" $Version "is up and running" >> "$LOGFILE"
