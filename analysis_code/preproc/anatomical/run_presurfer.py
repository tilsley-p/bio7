#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 27 11:48:39 2023

@author: penny

-----------------------------------------------------------------------------------------
run_presurfer.py

script location: projects/bio7/analysis_code/preproc/bids/run_presurfer.py
-----------------------------------------------------------------------------------------
Goal of the script:
Create bids directory from tarfiles on mesocentre
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project data directory (e.g. /scratch/jstellmann/data/bio7)
sys.argv[2]: individual subject level or automatic all remaining (e.g., sub-8761 or 8761, all)
sys.argv[3]: run with slurm server (0 = no, 1 = yes)
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/bio7/analysis_code/preproc/bids
>> python run_presurfer.py [meso_proj_dir] [subject_number] [slurm] [dry_run]
-----------------------------------------------------------------------------------------
"""

import os
import sys
import subprocess

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Create brainmask, stripmask, wmmask and T1w from MP2RAGE UNI and INV2',
    epilog = 'Needs: snakemake, snakebids installed (pip install snakemake, pip install snakebids)')
parser.add_argument('[meso_proj_dir]', help='path to project data directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.add_argument('[subject_number]', help='subject to analyse. OPTIONS: treating specific subjects, accepted formats: 8762, sub-8762, 876-2')
parser.add_argument('[slurm]', help='user slurm server 0 = no, 1 = yes')
parser.add_argument('[dry_run]', help='run in test mode to see script 0 = no, 1 = yes')
parser.parse_args()


# Check installs
#---------------
rc = subprocess.call(['which', 'snakemake'])
if rc == 0:
    print('snakemake installed!')
else:
    try: 
        print('Trying pip install snakemake')
        subprocess.call(['pip', 'install', 'snakemake'])
    except:
        print('Didnt manage to install?')
    else:
        print('Snakemake installed') 
    
rc = subprocess.call(['which', 'snakebids'])
if rc == 0:
    print('snakebids installed!')
else:
    try: 
        print('Trying pip install snakebids')
        subprocess.call(['pip', 'install', 'snakebids'])
    except:
        print('Didnt manage to install?')
    else:
        print('Snakebids installed') 
    

# inputs
meso_proj_dir = sys.argv[1]
subject_level = sys.argv[2]
server_in = int(sys.argv[3])
test_mode = int(sys.argv[4])

# Check inputs
# ------------
if os.path.isdir(meso_proj_dir):
    print("meso project input OK")
    if meso_proj_dir.endswith("/"):
        #True
        meso_proj_dir = meso_proj_dir[:-1]
    else:
        #True
        pass            
else:
    print("meso project input doesnt exist")
    exit()
    

# Getting subject number
#----------------------- 
subj = subject_level.split("-")[-1]

if len(subj)<4:
    #Account for input subject number without dashes
    subj_dcmid = subject_level
    subject = subject_level.replace("-","")
else:
    #Account for input subject number as label or full number
    subj_dcmid = subj[0:3] + '-' + subj[3:] 
    subject = subj    
    
# Define home + project
#-----------------------
meso_home_dir = os.path.expanduser('~')
projname = meso_proj_dir.split('/')[-1]  

# Define log directory
#---------------------
meso_log_dir = "{}/sourcedata/logs/anat".format(meso_proj_dir)  
os.makedirs(meso_log_dir,exist_ok=True)

# Define output directory
#------------------------
tmp_output_dir = os.path.join(meso_proj_dir, "derivatives/presurfer_tmp")

## Arrange outputs
#-----------------    
if test_mode == 0:
    
    ## Copying files from tmp/presurfer
    ##----------------------------------
    presurfer_outputs = "/tmp/presurfer/sub-{}".format(subject)
    output_dir = os.path.join(meso_proj_dir, "derivatives/presurfer")
    os.makedirs(output_dir,exist_ok=True)
   
    cp_cmd = "cp -R {} {}\n".format(presurfer_outputs, output_dir)
    rm_tmp_cmd = "rm -R {}\n".format(tmp_output_dir)
    
    org_script = "{}/projects/{}/analysis_code/preproc/anatomical/org_presurfer.py".format(meso_home_dir, projname)
    org_cmd = "python {} {} {}".format(org_script, meso_proj_dir, subj)
    
else:
    echo_cmd = "echo run as dry-run, rerun as actual run with 0 if all ok"


## Defining SLURM
#----------------
hour_proc = 1
nb_procs = 8

# define SLURM cmd
slurm_cmd = """\
#!/bin/bash
#SBATCH -p skylake
#SBATCH -A a306
#SBATCH --nodes=1
#SBATCH --cpus-per-task={nb_procs}
#SBATCH --time={hour_proc}:00:00
#SBATCH -e {meso_log_dir}/sub-{subject}_presurfer_%N_%j_%a.err
#SBATCH -o {meso_log_dir}/sub-{subject}_presurfer_%N_%j_%a.out
#SBATCH -J sub-{subject}_presurf\n\n""".format(nb_procs=nb_procs, hour_proc=hour_proc, subject=subject, meso_log_dir=meso_log_dir)

# sh folder & file
sh_folder = "{}/code/shell_jobs".format(meso_proj_dir)
try: os.makedirs(sh_folder)
except: pass
sh_file = "{}/sub-{}_presurf.sh".format(sh_folder,subject)

of = open(sh_file, 'w')
if server_in: of.write(slurm_cmd)
of.write("module load userspace/all\n")
of.write("module load singularity/3.5.1\n")
if test_mode == 0: 
    pres_cmd = "python {mp}/code/presurfer-smk-master/presurfer/run.py {mp} {od} participant --participant_label {s} --cores 1 --use-singularity\n".format(mp=meso_proj_dir, od=tmp_output_dir, s=subject)
    of.write(pres_cmd)
    of.write(cp_cmd)
    of.write(rm_tmp_cmd)
    of.write(org_cmd)
elif test_mode == 1:
    pres_cmd = "python {mp}/code/presurfer-smk-master/presurfer/run.py {mp} {od} participant --participant_label {s} --cores 1 --use-singularity -np\n".format(mp=meso_proj_dir, od=tmp_output_dir, s=subject)
    of.write(pres_cmd)
    of.write(echo_cmd)
of.close()

print("Created " + sh_file + " with following commands: ")

shpr = open(sh_file, 'r').read()
print(shpr)
    
## Run or submit jobs
#--------------------

if server_in:
    os.chdir(meso_log_dir)
    print("Submitting {} to queue".format(sh_file))
    os.system("sbatch {}".format(sh_file))
else:
    os.system("sh {}".format(sh_file))