#!/usr/bin/bash 
# This script needs to be written before each run, does not need to be executed.

# The output powermodel relative path after path of this Git repo folder
OUTPUT_POWERMODEL_RELATIVE_PATH="/CloudLab/XgboostFitTrainer_1_m510.zip"

# Add kubectl binary executable to path, can run "source 0_settings.sh" to run kubectl commands.
export PATH=$HOME/bin:$PATH

# Parent directory of this Git repo folder
KEPLER_POWERMODELS_PDIR=/home/username/Documents/Kepler-powermodels
