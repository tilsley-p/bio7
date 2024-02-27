"""
Created on Fri Mar 24 09:48:39 2023

@author: penny

-----------------------------------------------------------------------------------------
create_events_shell.py

script location: projects/bio7/analysis_code/preproc/functional/create_events_shell.py
-----------------------------------------------------------------------------------------
Goal of the script:
Create shell file to run R analysis and get events.tsvs for faces or faceloc 
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

if meso_home_dir.split("/")[-1] == "ptilsley":
    local_meso_path = "/Users/penny/disks"

## Organising task inputs
##-----------------------
data_output_dir = "{}/sourcedata/beh/{}".format(meso_proj_dir, task)
data_output_func_dir = os.path.join(data_output_dir, "func")
os.makedirs(data_output_func_dir, exist_ok = True)

## Defining R code path
#----------------------
if task == "faces":
    R_code_events = "{}/projects/{}/analysis_code/preproc/functional/create_events.R".format(meso_home_dir, projname)
else:
    pass


## Setting up R derivatives workingdir
#-------------------------------------
deriv_R_wdir = "{}/derivatives/R/beh/{}".format(meso_proj_dir, task)
os.makedirs(deriv_R_wdir, exist_ok = True)
deriv_R_fig = "{}/derivatives/R/beh/{}/figures".format(meso_proj_dir, task)
os.makedirs(deriv_R_fig, exist_ok = True)
deriv_R_tables = "{}/derivatives/R/beh/{}/tables".format(meso_proj_dir, task)
os.makedirs(deriv_R_tables, exist_ok = True)
deriv_R_events = "{}/derivatives/R/beh/{}/events".format(meso_proj_dir, task)
os.makedirs(deriv_R_events, exist_ok = True)
deriv_R_df = "{}/derivatives/R/beh/{}/dataframes".format(meso_proj_dir, task)
os.makedirs(deriv_R_df, exist_ok = True)
deriv_R_logs = "{}/derivatives/R/beh/{}/logs".format(meso_proj_dir, task)
os.makedirs(deriv_R_logs, exist_ok = True)

## Finding data and session
#--------------------------
rawsubdir = "{}/{}".format(data_output_dir, sub_label)

sessions = [s for s in os.listdir(rawsubdir) if "ses-" in s]

if len(sessions) == 1: session_number = sessions[0].split('-')[-1]

# Defining inputs 
subject_number = sub_number# subject_number = as.numeric(args[1])
session_number = session_number# session_number = as.numeric(args[2])
subject_type = input("patient or control? (P/C): ") # subject_type = as.character(args[3]) 
task_id = task# task_id = as.character(args[4])
wd = deriv_R_wdir# wd = as.character(args[5])
rawsubsessdir = os.path.join(rawsubdir,"ses-{}".format(session_number))  


logfile = "{}/sub-{}_ses-{}_events_{}.txt".format(deriv_R_logs,subject_number, session_number, task)
lf = open(logfile, 'w')
lf.close()

sh_file = "{}/sub-{}_ses-{}_task-{}_events.sh".format(deriv_R_logs,subject_number,session_number,task_id)
sh_file_loc = "{}/sub-{}_ses-{}_task-{}_events_localscript.sh".format(deriv_R_logs,subject_number,session_number,task_id)

R_command = "Rscript --verbose {R_code_events} {subject_number} {session_number} {subject_type} {task_id} {wd} {rawsubsessdir} >& {logfile}".format(R_code_events=R_code_events, subject_number=subject_number, session_number=session_number, subject_type=subject_type, task_id=task_id, wd=wd, rawsubsessdir=rawsubsessdir, logfile=logfile)

R_command_local = R_command.replace(meso_proj_dir, "{}/meso_shared/{}".format(local_meso_path,projname))
R_command_local = R_command_local.replace(meso_home_dir, "{}/meso_H".format(local_meso_path))

print(R_command)

of = open(sh_file, 'w')
of.write("#!/bin/bash\n\n")
of.write("module load userspace/all\n")
of.write("module load R/4.0.2\n")
of.write(R_command)
of.close()

print(R_command_local)

of = open(sh_file_loc, 'w')
of.write("#!/bin/bash\n\n")
of.write(R_command_local)
of.close()
    