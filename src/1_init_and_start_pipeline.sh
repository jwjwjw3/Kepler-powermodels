#!/usr/bin/bash 
# This script needs to be executed in root account or account with sudo privileges.
# All scripts in this folder needed to be executed in the same account.

# update the basic settings and setup script dirs
sed -i '/KEPLER_POWERMODELS_PDIR/d' ./0_settings.sh
echo "KEPLER_POWERMODELS_PDIR=$(dirname "`pwd`")" >> 0_settings.sh
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
# cd $KEPLER_POWERMODELS_PDIR/src

# start kind cluster using script.sh in kepler-model-server
cd $KEPLER_POWERMODELS_PDIR/libs/kepler-model-server/model_training
sudo ./script.sh prepare_cluster
# cd $KEPLER_POWERMODELS_PDIR/src

# Now we should already have access to Prometheus at http://localhost:9090.

# Next let's run Tekton pipeline, documentations at: 
# https://github.com/sustainable-computing-io/kepler-model-server/blob/main/model_training/tekton/README.md
# 1. Prepare resource
kubectl apply --filename $KEPLER_POWERMODELS_PDIR/libs/tekton/tekton_release_2024-01-05.yaml
cd $KEPLER_POWERMODELS_PDIR/libs/kepler-model-server/model_training/tekton
kubectl apply -f pvc/hostpath.yaml
# 2. Deploy Tekton tasks and pipelines
kubectl apply -f tasks
kubectl apply -f tasks/s3-pusher
kubectl apply -f pipelines
# 3. Run Tekton pipeline
kubectl apply -f pipelineruns/kepler-default.yaml
cd $KEPLER_POWERMODELS_PDIR/src

# Wait until experiment finishes, it can take several hours.
# Done!