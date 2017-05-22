#!/bin/bash
############################################
#####   Ericom Shield Installer        #####
#######################################BH###

#BRANCH="master"
BRANCH="BenyH-patch-1"

# Development Repository: (Latest)
ES_repo_setup="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/ericomshield-setup.sh"
ES_repo_run="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/run.sh"
ES_repo_update="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/autoupdate.sh"
ES_repo_version="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/showversion.sh"
ES_repo_stop="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/stop.sh"
ES_repo_status="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/status.sh"
ES_repo_service="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/ericomshield"
ES_repo_ip="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/show-my-ip.sh"
ES_repo_systemd_service="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/ericomshield.service"
ES_repo_systemd_updater_service="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/ericomshield-updater.service"
ES_repo_sysctl_shield_conf="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/sysctl_shield.conf"


# Production Version Repository: (Release)
ES_repo_ver="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/shield-version.txt"
# Development Version Repository: (Latest)
ES_repo_dev_ver="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/shield-version-dev.txt"

# Production Repository: (Release)
ES_repo_yml="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/docker-compose.yml"
# Swarm Repository: (Latest)
ES_swarm_repo_yml="https://raw.githubusercontent.com/ErezPasternak/Shield/$BRANCH/Dev-Feb16/docker-compose_swarm.yml"
