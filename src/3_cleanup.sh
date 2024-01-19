#!/usr/bin/bash 
# This script needs to be executed in root account or account with sudo privileges.
# All scripts in this folder needed to be executed in the same account.

source ./0_settings.sh

# destroy cluster using script.sh in kepler-model-server
cd $KEPLER_POWERMODELS_PDIR/libs/kepler-model-server/model_training
sudo ./script.sh cleanup
# Done!