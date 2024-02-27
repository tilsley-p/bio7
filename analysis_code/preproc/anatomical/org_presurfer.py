#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 27 11:48:39 2023

@author: penny

-----------------------------------------------------------------------------------------
org_presurfer.py

script location: projects/bio7/analysis_code/preproc/bids/org_presurfer.py
-----------------------------------------------------------------------------------------
Goal of the script:
Organise presurfer outputs and setup for fsl/itk lesion filling 
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project data directory (e.g. /scratch/jstellmann/data/bio7)
sys.argv[2]: individual subject level or automatic all remaining (e.g., sub-8761 or 8761, all)
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/bio7/analysis_code/preproc/bids
>> python org_presurfer.py [meso_proj_dir] [subject_number]
-----------------------------------------------------------------------------------------
"""

import os
import sys
import subprocess

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Organise presurfer outputs, setup for ITKsnap lesion filling and skullstrip T1',
    epilog = '')
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

## Organising anat outputs
##------------------------
presurfer_dir = "derivatives/presurfer/sub-{}".format(subject)
output_dir = os.path.join(meso_proj_dir, presurfer_dir)

sess = os.listdir(output_dir)
sess = sess[0]

presurfer_anat_dir = os.path.join(output_dir, "{}/anat/".format(sess))
os.makedirs(presurfer_anat_dir,exist_ok=True)

presurfer_output_lvl = "{}/{}/".format(output_dir, sess)
ps_dir = [ps for ps in os.listdir(presurfer_output_lvl) if ps.endswith('presurfer')]
ps_dir = ps_dir[0]

presurfer_UNI_dir = "{}/{}/{}/presurf_UNI/".format(output_dir, sess, ps_dir)
presurfer_INV_dir = "{}/{}/{}/presurf_INV2/".format(output_dir, sess, ps_dir)
presurfer_MPRAGE_dir = "{}/{}/{}/presurf_MPRAGEise/".format(output_dir, sess, ps_dir)


## Copying stripmask
##------------------
print("Copying relevant files to " + presurfer_anat_dir)

stripmask = [sm for sm in os.listdir(presurfer_INV_dir) if "mask" in sm]

for elemstrip in stripmask:

    spl = elemstrip.split('_')
    spl.remove('INV2')
    stripname = '_'.join(spl)

    stripmask_orig = os.path.join(presurfer_INV_dir,elemstrip)
    stripmask_new = os.path.join(presurfer_anat_dir,stripname)
    subprocess.call(['cp', stripmask_orig, stripmask_new])

## Copying brainmask and wmmask
##-----------------------------
brainmasks = [sm for sm in os.listdir(presurfer_UNI_dir) if "mask" in sm]

for elem in brainmasks:

    spl = elem.split('_')
    spl.remove('UNI')
    spl.remove('MPRAGEised')
    maskname = '_'.join(spl)

    brainmask_orig = os.path.join(presurfer_UNI_dir,elem)
    brainmask_new = os.path.join(presurfer_anat_dir,maskname)
    subprocess.call(['cp', brainmask_orig, brainmask_new])

## Copying T1w
##------------
T1w = [sm for sm in os.listdir(presurfer_MPRAGE_dir) if "MPRAGEised" in sm]

for elemt1 in T1w:

    spl = elemt1.split('_')
    spl[-1] = 'T1w.nii'
    spl.remove('UNI')
    spl[1] = '{}_rec-Bc'.format(spl[1])
    T1wname = '_'.join(spl)

    T1w_orig = os.path.join(presurfer_MPRAGE_dir,elemt1)
    T1w_new = os.path.join(presurfer_anat_dir,T1wname)
    subprocess.call(['cp', T1w_orig, T1w_new])

##Setting up for fsl itksnap
#---------------------------
fsl_itksnap_dir = os.path.join(meso_proj_dir, "derivatives/fsl_itksnap/sub-{}/{}/".format(subject, sess))
os.makedirs(fsl_itksnap_dir,exist_ok=True)

print("Setting up for fsl/itksnap...")
print("Copying relevant presurfer files to " + fsl_itksnap_dir)
subprocess.call(['cp', '-r', presurfer_anat_dir, fsl_itksnap_dir])

# Finding FLAWS images
sub_anat_dir = os.path.join(meso_proj_dir,"sub-{}/{}/anat/".format(subject, sess))
fsl_itksnap_anat_dir = os.path.join(fsl_itksnap_dir,"anat/")

flaws_image = [flws for flws in os.listdir(sub_anat_dir) if flws.endswith("FLAWS.nii.gz")]

if len(flaws_image) > 0:
    for im in flaws_image: 
        print("Copying FLAWS images to " + fsl_itksnap_dir)
        flaws_path = os.path.join(sub_anat_dir, im)
        subprocess.call(['cp', flaws_path, fsl_itksnap_anat_dir])
else: 
    print("No FLAWS found for subject " + subject)
    
## Performing skull-stripping with brainmask 
#-------------------------------------------

brainmask_new_spl = brainmask_new.split('_')
brainmask_new_spl[1] = '{}_rec-fillh'.format(brainmask_new_spl[1])
brainmask_new_spl[0] = brainmask_new_spl[0].replace("presurfer", "fsl_itksnap")
brainmask_new_filled = '_'.join(brainmask_new_spl)

T1_rec_name = T1w_new.split('_')
T1_rec_name[2] = T1_rec_name[2].replace("rec-Bc", "rec-BcSs")
T1_rec_name[0] = T1_rec_name[0].replace("presurfer", "fsl_itksnap")
T1_rec_name_skullstripped = '_'.join(T1_rec_name)

#Perform fslmaths nb. with orig presurfer output in derivatives/presurfer 

print("Running fslmaths skullstripping to create " + T1_rec_name_skullstripped)
subprocess.call(['fslmaths', brainmask_new, '-fillh', brainmask_new_filled])
subprocess.call(['fslmaths', T1w_new, '-mul', brainmask_new_filled, T1_rec_name_skullstripped])

sys.path.append("{}/projects/{}/analysis_code/utils".format(meso_home_dir, projname))
from permission import change_file_mod, change_file_group
change_file_mod(presurfer_dir)
change_file_group(presurfer_dir)
change_file_mod(fsl_itksnap_dir)
change_file_group(fsl_itksnap_dir)