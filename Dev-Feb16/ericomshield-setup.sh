#!/bin/bash
############################################
#####   Ericom Shield Installer        #####
#######################################BH###

#Check if we are root
if (( $EUID != 0 )); then
#    sudo su
        echo "Usage:" $0 [-force] [-noautoupdate] [-dev] [-usage] [-pocket]
        echo " Please run it as Root"
        echo "sudo" $0 $1 $2 $3 $4 $5
        exit
fi
ES_PATH="/usr/local/ericomshield"
LOGFILE="$ES_PATH/ericomshield.log"
DOCKER_VERSION="17.05"
DOCKER_COMPOSE_VERSION="1.13"
UPDATE=0
ES_DEV_FILE="$ES_PATH/.esdev"
ES_SWARM_FILE="$ES_PATH/.esswarm"
ES_AUTO_UPDATE_FILE="$ES_PATH/.autoupdate"
ES_REPO_FILE="$ES_PATH/ericomshield-repo.sh"
ES_YML_FILE="$ES_PATH/docker-compose.yml"
ES_VER_FILE="$ES_PATH/shield-version.txt"
ES_SWARM_SH_FILE="$ES_PATH/deploy-shield.sh"
ES_SETUP_VER="8.0.0.120-setup"
BRANCH="master"

DOCKER_USER="ericomshield1"
DOCKER_SECRET="Ericom98765$"
ES_DEV=false
ES_SWARM=true
ES_POCKET=false
echo "ES_SWARM" > "$ES_SWARM_FILE"

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
        -dev)
            ES_DEV=true
            echo "ES_DEV" > "$ES_DEV_FILE"
            ;;
        -compose)
            ES_SWARM=false
            rm "$ES_SWARM_FILE"
            ;;
        -noautoupdate)
            ES_AUTO_UPDATE=false
            rm -f "$ES_AUTO_UPDATE_FILE"
            ;;
        -force)
            ES_FORCE=true
            echo " " >> $ES_VER_FILE
            ;;
        -pocket)
            ES_POCKET=true
            echo " pocket version "
            ;;
#        -usage)
        *)
            echo "Usage:" $0 [-force] [-noautoupdate] [-dev] [-compose] [-usage]
            exit
            ;;
    esac
    shift
done

if [ -f "$ES_DEV_FILE" ]; then
   ES_DEV=true
fi

if [ -f "$ES_SWARM_FILE" ]; then
   ES_SWARM=true
fi

if [ "$ES_AUTO_UPDATE" == true ]; then
   echo "ES_AUTO_UPDATE" > "$ES_AUTO_UPDATE_FILE"
fi

#Check if curl is installed (-w check that the whole word is found)
if [ $(dpkg -l | grep -w -c curl ) -eq  0 ]; then
    echo "***************     Installing curl"
    sudo apt-get install curl
fi

function install_docker {
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
    if [ $(sudo docker version |wc -l ) -le  1 ]; then    
       echo "Failed to install docker, Exiting!"
       echo "$(date): An error occured during the installation: Cannot login to docker" >> "$LOGFILE"
       exit 1   
    fi
}

function install_docker_compose {
    if [ $(  docker-compose version | grep $DOCKER_COMPOSE_VERSION |wc -l ) -eq 0 ]; then
       echo "***************     Installing docker-compose"
       curl -L "https://github.com/docker/compose/releases/download/1.13.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
       chmod +x /usr/local/bin/docker-compose
    else
       echo "***************     DockerCompose is already installed"
    fi
}

function docker_login {
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
         echo "Cannot Login to docker, Exiting!"
         echo "$(date): An error occured during the installation: Cannot login to docker" >> "$LOGFILE"
         exit 1
       fi
    fi
}

function update_sysctl {
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
    echo "setting sysctl fs.file=1000000"
    sysctl -w fs.file-max=1000000
}

function create_shield_service {
    echo "**************  Creating the ericomshield service..."
  
    if [ ! -f "${ES_PATH}/ericomshield.service" ]; then
      # Need to download the service file only if needed and reload only if changed
       if [ "$ES_SWARM" == true ]; then
          echo "service for swarm"       
          curl -s -S -o "${ES_PATH}/ericomshield.service" "${ES_repo_systemd_service_swarm}"    
         else 
          curl -s -S -o "${ES_PATH}/ericomshield.service" "${ES_repo_systemd_service}"
       fi 
    fi

   systemctl --system enable "${ES_PATH}/ericomshield.service"
   cp ericomshield /etc/init.d/
   update-rc.d ericomshield defaults

    echo "**************  Creating the ericomshield updater service..."
    if [ ! -f "${ES_PATH}/ericomshield-updater.service" ]; then
       # Need to download the service file only if needed and reload only if changed
       curl -s -S -o "${ES_PATH}/ericomshield-updater.service" "${ES_repo_systemd_updater_service}"
    fi
    systemctl link ${ES_PATH}/ericomshield-updater.service
    systemctl --system enable ${ES_PATH}/ericomshield-updater.service

    systemctl daemon-reload
    echo "Done!"
}

function prepare_yml {
     echo "Preparing yml file..."
     cat "$ES_VER_FILE" | while read ver; do
          if [ ${ver:0:1} == '#' ]; then
            echo $ver
           else 
            pattern_ver=$(echo $ver | awk '{print $1}')
            comp_ver=$(echo $ver | awk '{print $2}')
            if [ ! -z $pattern_ver ]; then          
               echo "Changing ver:"
               echo "  sed -i 's/$pattern_ver/$comp_ver/g' $ES_YML_FILE"
               sed -i "s/$pattern_ver/$comp_ver/g" $ES_YML_FILE
            fi
          fi
     done

     MY_IP=IP=$(/sbin/ifconfig | grep 'inet addr:' | grep -v "127.0" | grep -v "172.1" | cut -d: -f2 | awk '{ printf $1}')
     if [ "$ES_SWARM" == true ]; then
        MY_IP=$MY_IP'(Swarm)'
     fi

     echo "  sed -i 's/IP_ADDRESS/$MY_IP/g' $ES_YML_FILE"
     sed -i "s/IP_ADDRESS/$MY_IP/g" $ES_YML_FILE
}

function get_shield_install_files {
     echo "Getting $ES_REPO_FILE"
     ES_repo_setup="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/ericomshield-repo.sh"
     echo $ES_REPO_FILE
     curl -s -S -o $ES_REPO_FILE $ES_repo_setup
     #include file with files repository
     source $ES_REPO_FILE

     if [ "$ES_DEV" == true ]; then
        echo "Getting $ES_repo_dev_ver (dev)"
        curl -s -S -o shield-version-new.txt $ES_repo_dev_ver
      else
        echo "Getting $ES_repo_ver (prod)"
        curl -s -S -o shield-version-new.txt $ES_repo_ver
     fi

     if [ -f "$ES_VER_FILE" ]; then
        if [ $( diff  "$ES_VER_FILE" shield-version-new.txt | wc -l ) -eq 0 ]; then
           echo "Your EricomShield System is Up to date"
           exit 0
         else
           echo "***************     Updating EricomShield ($ES_SETUP_VER)"
           echo "$(date): New version found:  Updating EricomShield ($ES_SETUP_VER)" >> "$LOGFILE"
           UPDATE=1
        fi
       else
        echo "***************     Installing EricomShield ($ES_SETUP_VER)..."
        echo "$(date): Installing EricomShield ($ES_SETUP_VER)" >> "$LOGFILE"
     fi

     mv "shield-version-new.txt" "$ES_VER_FILE"

     echo "Getting $ES_YML_FILE"
     if [ $ES_SWARM == true ]; then
        echo "Getting $ES_repo_swarm_yml SWARM"
        curl -s -S -o $ES_YML_FILE $ES_repo_swarm_yml
        curl -s -S -o deploy-shield.sh $ES_repo_swarm_sh
        chmod +x deploy-shield.sh
       else
        curl -s -S -o $ES_YML_FILE $ES_repo_yml
     fi
     if [ $ES_POCKET == true ]; then
        echo "Getting $ES_repo_pocket_yml SWARM"
        curl -s -S -o $ES_YML_FILE $ES_repo_pocket_yml
     fi
}

#############     Getting all files from Github
function get_shield_files {
     if [ ! -f "ericomshield-setup.sh" ]; then
        curl -s -S -o ericomshield-setup.sh $ES_repo_setup
        chmod +x ericomshield-setup.sh
     fi

     curl -s -S -o run.sh $ES_repo_run
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
}

##################      MAIN: EVERYTHING START HERE: ##########################

echo Docker Login: $DOCKER_USER $DOCKER_SECRET
echo "dev=$ES_DEV"
echo "autoupdate=$ES_AUTO_UPDATE"
echo "Swarm=$ES_SWARM"

install_docker
echo "Starting docker service"
service docker start
if [ $? == 0 ]; then
   echo "***************     Success!"
  else
   echo "An error occured during the installation"
   echo "$(date): An error occured during the installation: failed to install docker" >> "$LOGFILE"
   exit 1
fi

install_docker_compose

get_shield_install_files

get_shield_files

docker_login

update_sysctl

echo "Preparing yml file (Containers build number)"
prepare_yml

if [ $UPDATE -eq 0 ]; then
# New Installation

    create_shield_service
    systemctl start ericomshield-updater.service

    if [ $ES_SWARM == true ]; then
      echo "source deploy-shield.sh"
      source deploy-shield.sh
     else
      docker-compose pull
      echo "Starting Ericom Shield Service"
      $ES_PATH/run.sh
      service ericomshield start
    fi
   else     # Update
    if [ $ES_SWARM == true ]; then
      echo -n "stop shield-broker"
      docker service scale shield_broker-server=0
      wait=0
      while [ $wait -lt 5 ]
      do
        if [ $(docker service ps shield_broker-server | wc -l) == 1 ]; then
          echo !
          break
         else
          echo -n .
          sleep 10
        fi
      wait=$[$wait+1]
      done

      echo "source deploy-shield.sh"
      source deploy-shield.sh
     else
      docker-compose pull
      echo "Restarting Ericom Shield Service"
      service ericomshield restart
    fi
  
fi

# Check the result of the last command (start, status, deploy-shield)
if [ $? == 0 ]; then
   echo "***************     Success!"
  else
   echo "An error occured during the installation"
   echo "$(date): An error occured during the installation" >> "$LOGFILE"
   echo "--failed" >> "$ES_VER_FILE" # adding failed into the version file
   exit 1
fi
#Check the status of the system, and clean only if running
wait=0
while [ $wait -lt 10 ]
do
  $ES_PATH/status.sh
  if [ $? == 0 ]; then
     echo "Ericom Shield is Running!"
     #Clean previous installed images
     echo "*************** not cleaning old images for now"
     #   docker system prune -f -a
     break;
    else
     sleep 60
  fi
  wait=$[$wait+1]  
done

Version=`grep  SHIELD_VER $ES_YML_FILE`

echo $Version  > .version
grep image $ES_YML_FILE >> .version

echo "***************     Success!"
echo "***************"
echo "***************     Ericom Shield Version:" $Version "is up and running"
echo "$(date): Ericom Shield Version:" $Version "is up and running" >> "$LOGFILE"
