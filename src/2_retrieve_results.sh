#!/usr/bin/bash 
# This script needs to be executed in root account or account with sudo privileges.
# All scripts in this folder needed to be executed in the same account.

source ./0_settings.sh

# Deploy a simple pod to download Kepler powermodel
kubectl apply -f result-collect/result-collect-pod.yaml

echo ""
echo "Waiting for result-collect-pod to start..."
sleep 75

# Use kubectl to copy Kepler powermodel folders to local data storage
# kubectl cp -n default result-collect-pod:/mnt/data/ $OUTPUT_POWERMODEL_RELATIVE_PATH/data/
# kubectl cp -n default result-collect-pod:/mnt/models/ $OUTPUT_POWERMODEL_RELATIVE_PATH/models/
kubectl cp -n default result-collect-pod:/mnt/models/XgboostFitTrainer_1.zip $OUTPUT_POWERMODEL_RELATIVE_PATH

# Remove the pod after finishing downloading Kepler powermodel
kubectl delete -f result-collect/result-collect-pod.yaml

# Done!