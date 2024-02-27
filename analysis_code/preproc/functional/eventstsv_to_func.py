"""
Created on Fri Mar 24 09:48:39 2023

@author: penny

-----------------------------------------------------------------------------------------
eventstsv_to_func.py

script location: projects/bio7/analysis_code/preproc/functional/eventstsv_to_func.py
-----------------------------------------------------------------------------------------
Goal of the script:
After running R locally, copy events.tsvs to correct folders with correct naming  
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project data directory (e.g. /scratch/jstellmann/data/bio7)
sys.argv[2]: subject number (e.g., sub-8761 or 8761)
sys.argv[3]: task (resting, faces, faceloc)
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/bio7/analysis_code/preproc/functional
>> python create_events_shell.py [meso_proj_dir] [subject_number] [task]
-----------------------------------------------------------------------------------------
"""

import os
import sys
import subprocess

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Organise behavioural data with correct subject label',
    epilog = '')
parser.add_argument('[meso_proj_dir]', help='path to project data directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.add_argument('[subject_number]', help='desired subject number for dataset: 8762, sub-8762')
parser.add_argument('[task]', help='transfer data from which task: faces, faceloc, resting')
parser.parse_args()


# inputs
meso_proj_dir = sys.argv[1]
subject_level = sys.argv[2]
task = sys.argv[3]

# Check inputs
# ------------
if os.path.isdir(meso_proj_dir): print("meso sourcedata input OK")
else: print("meso sourcedata input doesnt exist"); exit()

if meso_proj_dir.endswith("/"): meso_proj_dir=meso_proj_dir[:-1]
else: pass

#Define subject
#--------------
if subject_level.split("-")[0] == "sub": sub_label = subject_level
else: sub_label = "sub-{}".format(subject_level)
sub_number = sub_label[4:]  
    
# Define home + project
#-----------------------
meso_home_dir = os.path.expanduser('~')
projname = meso_proj_dir.split('/')[-1]

## Organising  inputs
##-------------------
deriv_R_events = "{}/derivatives/R/beh/{}/events".format(meso_proj_dir, task)
deriv_R_logs = "{}/derivatives/R/beh/{}/logs".format(meso_proj_dir, task)



## Finding data and session
#--------------------------
sub_dir = "{}/{}".format(meso_proj_dir, sub_label)

event_files = [s for s in os.listdir(deriv_R_events) if sub_label in s]
session_label = event_files[0].split('_')[1]

sub_sess_func_dir = "{}/{}/func".format(sub_dir, session_label)

empty_event_files = [e for e in os.listdir(sub_sess_func_dir) if e.endswith("events.tsv") and task in e]

empty_event_files.sort()
event_files.sort()

for r in empty_event_files:
    
    empty_split_run = r.split('_')[-2]
    #run-01 
    corr_eventstsv = [run for run in event_files if empty_split_run in run]
    
    if len(corr_eventstsv)==1:
        copy_from = os.path.join(deriv_R_events, corr_eventstsv[0])
        copy_to = os.path.join(sub_sess_func_dir, r)

        rm_cmnd = "rm {}".format(copy_to)
        print(rm_cmnd)
        copy_cmnd = "cp {} {}".format(copy_from, copy_to)
        print(copy_cmnd)
        os.system(rm_cmnd)
        os.system(copy_cmnd)
        
    else:
        corr_eventstsv