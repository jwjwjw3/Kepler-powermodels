# User Guide

## Overview

This repo contains several bash scripts used to obtain Kepler powermodel from a BARE METAL machine (Not VM!). User needs to run bash scripts one-by-one in a specified order on the machine to collect its power model, manually check outputs of each bash script, and re-run if some script fails. 

## Requirements
- Root or sudo access on the target machine is required. (target machine should be running in a linux OS) 
- Internet access of the target machine is needed.

## K8s tools used under directory ```/libs```
- Kepler-model-server
    - Using git commit 005852032f2fd03c2e84818ea92abc0541464f95

- Tekton
    - Already downloaded from https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml at 2024-01-05.
    - Official guideline at https://tekton.dev/docs/installation/pipelines.


## Scripts behavior description

All scripts the user needs to run are in:
```
/src/
```
User needs to ```cd``` to this directory, and then run all the following scripts one-by-one, starting from ```./0_settings.sh```.
- 0_settings.sh: This script does not need to be executed, user need to write worker hostname filenames to it.
- 1_init_env.sh
    - update automated settings in 0_settings.sh
    - download Kepler-model-server and switch to corresponding commit
    - start a local kind cluster on the target machine 
- 2_start_pipeline.sh
    - start running the tekton pipeline for several hours and collect data for power model
- 3_retrieve_results.sh
    - deploy in a new pod and download results from kind cluster to the specified directory in ```0_settings.sh```
- 4_cleanup.sh
    - remove the kind clusters created in ```1_init_env.sh```.