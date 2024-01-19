#!/usr/bin/bash 
# This script needs to be executed in root account or account with sudo privileges.
# All scripts in this folder needed to be executed in the same account.

source ./0_settings.sh

kubectl apply -f result-collect/result-collect-pod.yaml

echo ""
echo "Waiting for result-collect-pod to start..."
sleep 10

#TODO


# Done!