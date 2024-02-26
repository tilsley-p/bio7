#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 23 15:27:54 2023

@author: Tilsley

-----------------------------------------------------------------------------------------
tsv_editor.py

script location: projects/bio7/analysis_code/preproc/bids/tsv_editor.py
-----------------------------------------------------------------------------------------
Goal of the script:
Update .tsvs with correct information
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project directory (e.g. /scratch/ptilsley/data/bio7)
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/bio7/analysis_code/preproc/bids
>> python tsv_editor.py [meso_proj_dir]
-----------------------------------------------------------------------------------------
"""

# General imports
# ---------------
import os
import sys
import csv

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Reformat participants.tsv',
    epilog = ' ')
parser.add_argument('[meso_proj_dir]', help='path to data project directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.parse_args()

# Get inputs
# ----------
meso_proj_dir = sys.argv[1]

# Check inputs
# ------------
if os.path.isdir(meso_proj_dir):
    print("meso project input OK")
else:
    print("meso project input doesnt exist")
    exit()

# Find number of bids subjects
#-----------------------------
bids_subjects = [sub for sub in os.listdir(meso_proj_dir) if sub.startswith("sub-")]

# Remove automatic participants.tsv
#----------------------------------
ptsv = os.path.join(meso_proj_dir, "participants.tsv")

if os.path.exists(ptsv):
    os.remove(ptsv)
else:
    pass

with open(ptsv, 'w') as file:
    tsv_file = csv.writer(file, delimiter="\t")
    tsv_file.writerow(["participant_id"])
    tsv_file.writerows([i.strip().split(',') for i in bids_subjects])
file.close()