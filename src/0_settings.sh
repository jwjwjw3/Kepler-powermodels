#!/usr/bin/bash 
# This script needs to be written before each run, does not need to be executed.

# the exported Prometheus DB folder path
pmt_export_directory="/root/PROM_DB/_run_2024-01-18-12-35/"

# The output powermodel relative path after path of this Git repo folder
# OUTPUT_POWERMODEL_RELATIVE_FOLDER=/collected_results/CloudLab/
OUTPUT_POWERMODEL_RELATIVE_PATH=/collected_results/CloudLab/m510/XgboostFitTrainer_1_m510.zip

# Add kubectl binary executable to path, can run "source 0_settings.sh" to run kubectl commands.
export PATH=$HOME/bin:$PATH

# Parent directory of this Git repo folder
KEPLER_POWERMODELS_PDIR=/root/Documents/Kepler-powermodels
