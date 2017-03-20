#!/bin/bash
############################################
#####   Ericom Shield Virtual Appliance  ###
#######################################BH###

#Check if we are root
if (( $EUID != 0 )); then
#    sudo su
        echo " Please run it as Root"
        echo "sudo" $0 $1 $2
        exit
fi

echo "Preparing Ericom Shield Virtual Appliance"
echo "Cleaning existing VM"
vagrant destroy -f
rm shield_eval.ova

ES_repo_Vagrant="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/Vagrantfile"
curl -s -S -o Vagrantfile $ES_repo_Vagrant

vagrant up
vagrant halt
vboxmanage export shield-eval -o shield_eval.ova
chmod 277 shield_eval.ova

if [ $? == 0 ]; then
   echo "***************     Success!"
   echo "Ericom Shield Virtual Appliance is ready: shield_eval.ova"
  else
   echo "An error occured during the Virtual Appliance generation"
   exit 1
fi

# Need to define push strategy (ftp, GoogleDrive, repo)
#using gdrive for now (assuming it is installed:
#  gdrive installation from home directory (~)
#  
#  wget https://docs.google.com/uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE&export=download
#  ls
#  mv uc\?id\=0B3X9GlR6EmbnWksyTEtCM0VfaFE gdrive
#  chmod +x gdrive
#  sudo install gdrive /usr/local/bin/gdrive
#  gdrive list

gdrive update 0B_wcQRaAT_INcXhsc1E4bXlySWs shield_eval.ova

