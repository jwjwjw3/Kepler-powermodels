#!/usr/bin/bash 
# This script needs to be executed in root account or account with sudo privileges.
# All scripts in this folder needed to be executed in the same account.

source ./0_settings.sh

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

# Wait until experiment finishes, it can take several hours.
# Done!