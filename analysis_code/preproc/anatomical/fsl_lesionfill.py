# -*- coding: utf-8 -*-
"""
Created on Sat Feb  4 21:15:12 2023

@author: Tilsley
-----------------------------------------------------------------------------------------
fsl_lesionfill.py

script location: projects/bio7/analysis_code/preproc/anat/fsl_lesionfill.py
-----------------------------------------------------------------------------------------
Goal of the script:
Fill lesions in T1 ready for fmriprep
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project directory (e.g. /scratch/jstellmann/data/bio7)
sys.argv[2]: individual subject level (e.g., 8762, sub-8761 or 8761)
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/bio7/analysis_code/preproc/anat
>> python fsl_lesionfill.py [meso_proj_dir] [subject_number]
-----------------------------------------------------------------------------------------
"""

import os
import sys
import subprocess
import shutil
import json

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Fill lesions in T1 using manual lesionmask before running fmriprep',
    epilog = 'Needs: fsl installed for lesion_filling and SimpleITK for creating T1w.json')
parser.add_argument('[meso_proj_dir]', help='path to project data directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.add_argument('[subject_number]', help='subject to analyse. OPTIONS: treating specific subjects, accepted formats: 8762, sub-8762, 876-2')
parser.parse_args()


# inputs
meso_proj_dir = sys.argv[1]
subject_level = sys.argv[2]

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
    
dependencies_pyinstall = ['fsl']

for inst in dependencies_pyinstall:
    if shutil.which(inst) is None:
        try:
            print('Trying to install {}, may take a while..'.format(inst))
            inst_folder = '{}/code/{}'.format(meso_proj_dir, inst)
            inst_script = [fl for fl in os.listdir(inst_folder) if inst in fl and fl.endswith('.py')]
            inst_path = os.path.join(inst_folder, inst_script)
            subprocess.call(['python', inst_path])
        except:
            print('Didnt manage to install {}?'.format(inst))
    else:
        print('{} already installed!'.format(inst))

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
#SBATCH -e {meso_log_dir}/sub-{subject}_lesionfilling_%N_%j_%a.err
#SBATCH -o {meso_log_dir}/sub-{subject}_lesionfilling_%N_%j_%a.out
#SBATCH -J sub-{subject}_presurf\n\n""".format(nb_procs=nb_procs, hour_proc=hour_proc, subject=subject, meso_log_dir=meso_log_dir)

# sh folder & file
sh_folder = "{}/code/shell_jobs".format(meso_proj_dir)
try: os.makedirs(sh_folder)
except: pass
sh_file = "{}/sub-{}_lesionfilling.sh".format(sh_folder,subject)

# Find fsl_itksnapdir
#--------------------
fsl_itksnap_sub_dir = os.path.join(meso_proj_dir, "derivatives/fsl_itksnap/sub-{}".format(subject))
fsl_itksnap_subsess = [ss for ss in os.listdir(fsl_itksnap_sub_dir) if "ses" in ss]
fsl_itksnap_anat_dir = os.path.join(fsl_itksnap_sub_dir, (fsl_itksnap_subsess[0] + "/anat"))

niftiis = [ni for ni in os.listdir(fsl_itksnap_anat_dir) if ni.endswith(".nii")]

#Gzip all files
for elem in niftiis:
    nii_file = os.path.join(fsl_itksnap_anat_dir, elem)
    subprocess.call(["gzip", nii_file])

T1w = [t1 for t1 in os.listdir(fsl_itksnap_anat_dir) if "rec-BcSs" in t1 and t1.endswith("T1w.nii.gz")]

if len(T1w) == 1:
    T1_skullstripped = T1w[0]
    T1_skullstripped_path = os.path.join(fsl_itksnap_anat_dir, T1_skullstripped)
    T1_lesionfilled_path = T1_skullstripped_path.replace("rec-BcSs", "rec-BcSsLf")
elif len(T1w) == 0:
    print("error: didnt find Rec-BcSs T1w?")
    exit()
else:
    print("error: multiple T1s selected? want rec-BcSs T1w - or already done lesion filling?")
    exit()
    
lesionmask = [lm for lm in os.listdir(fsl_itksnap_anat_dir) if lm.endswith("lesionmask.nii.gz")]

if len(lesionmask) == 1:
    lesion_mask = lesionmask[0]
    lesion_mask_path = os.path.join(fsl_itksnap_anat_dir, lesion_mask)
elif len(lesionmask) == 0:
    print("error: didnt find lesionmask.nii.gz?")
    exit()
else:
    print("error: multiple lesionmask.nii.gz present?")
    exit()

wmmask = [wm for wm in os.listdir(fsl_itksnap_anat_dir) if wm.endswith("WMmask.nii.gz")]

if len(wmmask) == 1:
    wm_mask = wmmask[0]
    wm_mask_path = os.path.join(fsl_itksnap_anat_dir, wm_mask)
elif len(wmmask) == 0:
    print("error: didnt find WMmask.nii.gz?")
    exit()
else:
    print("error: multiple WMmask.nii.gz present?")
    exit()

## Performing lesion filling fsl 
#-------------------------------

print("lesion filling with fsl lesion_filling")
subprocess.call(["lesion_filling","-i", T1_skullstripped_path,"-l", lesion_mask_path, "-w", wm_mask_path, "-o", T1_lesionfilled_path])

sess = fsl_itksnap_subsess[0]

sub_proj_dir = "{}/sub-{}/{}/anat".format(meso_proj_dir, subject, sess)
print("Copying T1s to " + sub_proj_dir)

T1s = [ls for ls in os.listdir(fsl_itksnap_anat_dir) if ls.endswith("T1w.nii.gz")]

print("found " + str(T1s))

for T1image in T1s:
    T1image_oldpath = os.path.join(fsl_itksnap_anat_dir, T1image)
    T1image_newpath = os.path.join(sub_proj_dir, T1image)
    
    subprocess.call(["cp", T1image_oldpath, T1image_newpath])
    
    T1image_jsonpath = T1image_newpath.replace(".nii.gz", ".json")
    T1image_jsonpath_spl = T1image_jsonpath.split('_')
    T1image_jsonpath_spl[2] = "acq-UNI"
    T1image_jsonpath_spl[-1] = T1image_jsonpath_spl[-1].replace("T1w", "MP2RAGE")
    UNIimage_jsonpath = "_".join(T1image_jsonpath_spl)
    
    subprocess.call(["cp", UNIimage_jsonpath, T1image_jsonpath])
  
    if "rec-BcSs" in T1image_jsonpath:
        ss_status = "true"
        print("adding SkullStripped: " + ss_status + " to " + T1image_jsonpath)
        
        with open(T1image_jsonpath) as json_file:
            json_data = json.load(json_file)
            json_data["SkullStripped"] = bool(ss_status)
            json_file.close
            
            with open(T1image_jsonpath, 'w') as json_file:
                json.dump(json_data, json_file, indent=4, sort_keys = True)
                json_file.close 

sys.path.append("{}/projects/{}/analysis_code/utils".format(meso_home_dir, projname))
from permission import change_file_mod, change_file_group
change_file_mod(fsl_itksnap_anat_dir)
change_file_group(fsl_itksnap_anat_dir)
change_file_mod(sub_proj_dir)
change_file_group(sub_proj_dir)