#!/usr/bin/bash 
# This script needs to be written before each run, does not need to be executed.

KEPLER_POWERMODELS_PDIR=/root/Documents/Kepler-powermodels
OUTPUT_POWERMODEL_RELATIVE_PATH="/CloudLab/XgboostFitTrainer_1_m510.zip"

# Add kubectl binary executable to path, can run "source 0_settings.sh" to 
# run kubectl commands.
export PATH=$HOME/bin:$PATH