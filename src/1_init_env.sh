#!/usr/bin/bash 
# This script needs to be executed in root account or account with sudo privileges.
# All scripts in this folder needed to be executed in the same account.

# update the basic settings and setup script dirs
sed -i '/KEPLER_POWERMODELS_PDIR/d' ./0_settings.sh
echo "KEPLER_POWERMODELS_PDIR=$(dirname $(dirname $(dirname "`pwd`")))" >> 0_settings.sh
source ./0_settings.sh

# check Kepler-model-server
# mkdir $KEPLER_POWERMODELS_PDIR/libs/
if [ -d $KEPLER_POWERMODELS_PDIR/libs/kepler-model-server ] 
then
    echo "kepler-mode-server directory found, assuming kepler-model-server Git Repo already exists."
else
    git clone https://github.com/sustainable-computing-io/kepler-model-server.git $KEPLER_POWERMODELS_PDIR/libs/kepler-model-server
fi 
cd $KEPLER_POWERMODELS_PDIR/libs/kepler-model-server
git checkout 005852032f2fd03c2e84818ea92abc0541464f95
cd $KEPLER_POWERMODELS_PDIR/src

# start kind cluster using script.sh in kepler-model-server
cd $KEPLER_POWERMODELS_PDIR/libs/kepler-model-server/model_training
sudo ./srcript.sh prepare_cluster

# Now we should already have access to Prometheus at http://localhost:9090.
# Done!