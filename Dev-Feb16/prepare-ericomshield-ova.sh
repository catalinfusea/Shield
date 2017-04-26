#!/bin/bash
############################################
#####   Ericom Shield Virtual Appliance  ###
#######################################BH###

#Check if we are root
if (( $EUID != 0 )); then
#    sudo su
        echo " Please run it as Root"
        echo "sudo" $0 $1 $2
        exit 1
fi

LOGFILE="ericomshield-ova.log"
OVA_FILE="shield_eval.ova"

echo "Preparing Ericom Shield Virtual Appliance"
echo "Cleaning existing VM"
vagrant destroy -f
rm $OVA_FILE

ES_repo_Vagrant="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/Vagrantfile"
ES_repo_Vagrant_dev="https://raw.githubusercontent.com/ErezPasternak/Shield/master/Dev-Feb16/Vagrantfile_dev"


if [ "$1" == "-dev" ]; then
   echo "Using Dev Release"
   curl -s -S -o Vagrantfile $ES_repo_Vagrant_dev
   DEV="Dev"
   OVA_FILE="shield_eval_dev.ova"
  else
   echo "Using Production Release"
   curl -s -S -o Vagrantfile $ES_repo_Vagrant
fi

echo "***************     Vagrant Up"
time vagrant up
if [ $? == 0 ]; then
   echo "***************     Success!"
  else
   echo "An error occured during the Virtual Appliance $DEV generation"
   echo "$(date): An error occured during the Virtual Appliance $DEV generation" >> "$LOGFILE"
   exit 1
fi

time vagrant halt
echo "***************     Vagrant Export Ova"
time vboxmanage export shield-eval -o $OVA_FILE

if [ $? == 0 ]; then
   echo "***************     Success!"
   echo "Ericom Shield Virtual Appliance is ready: $OVA_FILE"
   echo "$(date): Ericom Shield Virtual Appliance is ready: $OVA_FILE" >> "$LOGFILE"
  else
   echo "An error occured during the Virtual Appliance $DEV generation"
   echo "$(date): An error occured during the Virtual Appliance $DEV generation" >> "$LOGFILE"
   exit 1
fi

chmod 277 $OVA_FILE

# Need to define push strategy (ftp, GoogleDrive, repo)
#  using gdrive for now (assuming it is installed:
#  gdrive installation from home directory (~)
#
#  wget https://docs.google.com/uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE&export=download
#  ls
#  mv uc\?id\=0B3X9GlR6EmbnWksyTEtCM0VfaFE gdrive
#  chmod +x gdrive
#  sudo install gdrive /usr/local/bin/gdrive
#  gdrive list

echo "***************     Uploading to GoogleDrive"

if [ "$1" == "-dev" ]; then
   time gdrive update 0B_wcQRaAT_INVkpVckU5eXh0cHM $OVA_FILE
  else
   time gdrive update 0B_wcQRaAT_INcXhsc1E4bXlySWs $OVA_FILE
fi

if [ $? == 0 ]; then
   echo "***************     Success!"
   echo "Ericom Shield Virtual Appliance Uploaded to Google Drive"
   echo "$(date): "Ericom Shield Virtual Appliance $DEV Uploaded to Google Drive" >> "$LOGFILE"
  else
   echo "An error occured during the Virtual Appliance upload"
   echo "$(date): An error occured during the Virtual Appliance $DEV upload" >> "$LOGFILE"
   exit 1
fi
