# -*- coding: utf-8 -*-
"""
Created on Wed Jan 25 20:09:18 2023

@author: Tilsley
-----------------------------------------------------------------------------------------
bids_validation.py

script location: projects/bio7/analysis_code/preproc/bids/bids_validation.py
-----------------------------------------------------------------------------------------
Goal of the script:
Check if project directory is bids compatible
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project directory (e.g. /scratch/jstellmann/data/bio7)
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/bio7/analysis_code/preproc/bids
>> python bids_validation.py [meso_proj_dir]
-----------------------------------------------------------------------------------------
"""

# General imports
# ---------------
import os
import sys
import subprocess
from datetime import date

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Check project directory is bids validated. Outputs to sourcedata/logs/bids_validation*.log',
    epilog = ' ')
parser.add_argument('[meso_proj_dir]', help='path to data project directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.parse_args()

# Get inputs
# ----------
meso_proj_dir = sys.argv[1]
#meso_home_dir = sys.argv[2]
meso_home_dir = os.path.expanduser('~')

# Define source directories
#--------------------------
meso_src_dir = os.path.join(meso_proj_dir,"sourcedata")
meso_logs_dir = os.path.join(meso_src_dir,"logs")

# Define code directories
#-------------------------
meso_code_dir = os.path.join(meso_proj_dir,"code")
meso_singularity_dir = os.path.join(meso_code_dir,"singularity")

# Finding tar2bids sif
#----------------------
tar2bids_file = [sif for sif in os.listdir(meso_singularity_dir) if "tar2bids" in sif and sif.endswith(".simg")]
tar2bids_path = os.path.join(meso_singularity_dir, tar2bids_file[0])

# Finding subjects 
#-----------------
subjs = [s for s in os.listdir(meso_singularity_dir) if s.startswith("sub-")]

# Defining log output 
#--------------------
today = date.today()
d1 = str(today.strftime("%d-%m-%Y"))
logfile = os.path.join(meso_logs_dir, "bids_valitation_" + d1 + ".log") 

# Singularity -B bind
#---------------------
bindpath = meso_proj_dir + ',' + meso_home_dir

f = open(logfile, "w")
subprocess.call(["singularity", "exec", "-B", bindpath, tar2bids_path, "bids-validator", \
                 meso_proj_dir], stdout=f)