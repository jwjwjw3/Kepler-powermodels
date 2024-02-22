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
sed -i 's@image: quay.io/sustainable_computing_io/kepler:latest@image: jvpoidaq/kepler-v0.7.2:latest@g' $KEPLER_POWERMODELS_PDIR/libs/kepler-model-server/model_training/deployment/kepler.yaml
# cd $KEPLER_POWERMODELS_PDIR/src

if [ -x "$(command -v docker)" ]; then
    echo "docker installation found."
else
    echo "docker not found or not properly configured. Trying to install docker..."
    # check if docker is installed
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg -y; done
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg -y
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo docker run hello-world
fi

# start kind cluster using script.sh in kepler-model-server
cd $KEPLER_POWERMODELS_PDIR/libs/kepler-model-server/model_training
sudo ./script.sh prepare_cluster
# cd $KEPLER_POWERMODELS_PDIR/src

# correct permission of config files
sudo chown -R $(id -u):$(id -g) $HOME/.kube/

# patch prometheus to enable database exporting
KUBE_CONFIG_PATH="$KEPLER_POWERMODELS_PDIR/libs/kepler-model-server/model_training/custom-cluster/kind/.kubeconfig"
echo "waiting for prometheus to start..."
kubectl wait pod \
    --all \
    --for=condition=Ready \
    --namespace=monitoring
# enable memory snapshot, recommended for taking prometheus TSDB snapshots later.
kubectl --kubeconfig $KUBE_CONFIG_PATH -n monitoring patch prometheus k8s --type merge --patch '{"spec":{"enableFeatures":["memory-snapshot-on-shutdown"]}}'
# enable admin api for taking snapshots later
kubectl --kubeconfig $KUBE_CONFIG_PATH -n monitoring patch prometheus k8s --type merge --patch '{"spec":{"enableAdminAPI":true}}'
# kubectl --kubeconfig $KUBE_CONFIG_PATH -n monitoring port-forward svc/prometheus-k8s 9090

# create new screen sessions for looping-forever kubectl prometheus port forwarding
# Note: a screen can be killed by command: screen -XS screen_id quit
sudo apt install screen
if ! screen -list | grep -q pmt_port_forward; then
    echo "starting prometheus port forwarding screen..."
	# screen -S pmt_port_forward -d -m ./runtime_scripts/prometheus_port_forward.sh
	screen -S pmt_port_forward -d -m bash -c "while true; do kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090; done;"
else 
    echo "prometheus port forwarding screen detected, assuming it is working normally..."
fi
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