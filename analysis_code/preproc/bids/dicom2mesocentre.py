#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Created on Mon Jan  9 14:03:15 2023

@author: Tilsley

-----------------------------------------------------------------------------------------
dicom2mesocentre.py

script location: projects/bio7/analysis_code/preproc/bids/dicom2mesocentre.py
-----------------------------------------------------------------------------------------
Goal of the script:
Transfer dicom files from DATA_CEMEREM server to mesocentre (archive, verbose, compression)
NB: If 1st transfer for a project, mkdir sourcedata/dicoms in project folder before running 
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project directory (e.g. /scratch/ptilsley/data/bio7)
sys.argv[2]: server raw dicom directory (e.g. /DATA_CEMEREM/data/protocols/terra/brain/bio7)
sys.argv[3]: subject number/label any following format (e.g. 8762, sub-8762, 876-1)
sys.argv[4]: mesocentre username (e.g. ptilsley)
-----------------------------------------------------------------------------------------
To run:
On laminar-mac 
(or other computer with mesocentre rsa key setup)

>> cd ~/projects/bio7/analysis_code/preproc/bids
>> python3 dicom2mesocentre.py [meso_proj_dir] [server_dcm_dir] [subject_number] [mesocentre_ID]
-----------------------------------------------------------------------------------------

"""

# General imports
# ---------------
import os
import sys
import subprocess

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Transfer dicoms to mesocentre. Outputs to sourcedata/dicoms. NB: If 1st transfer for a project, mkdir sourcedata/dicoms in project folder on mesocentre before running',
    epilog = ' ')
parser.add_argument('[meso_proj_dir]', help='path to data project directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.add_argument('[server_dcm_dir]', help='path to raw dicom data on cemerem server. e.g., /DATA_CEMEREM/data/protocols/terra/brain/bio7')
parser.add_argument('[subject_number]', help='subject to analyse. OPTIONS: all (treating any untreated subjects), OR, treating specific subjects, accepted formats: 8762, sub-8762, 876-2')
parser.add_argument('[meso_user]', help='your mesocentre username. e.g., ptilsley')
parser.parse_args()

# Get inputs
# ----------
meso_proj_dir = sys.argv[1]
server_dcm_dir = sys.argv[2]
subject_level = sys.argv[3]
meso_user = sys.argv[4]

# Check inputs
# ------------
if os.path.isdir(server_dcm_dir):
    print("server input OK")
else:
    print("server input doesnt exist")
    exit()
    
# Define sourcedirectory meso
#----------------------------
meso_src_dir = os.path.join(meso_proj_dir,"sourcedata")

# Define dicom dir meso
# ---------------------
meso_dir_dicoms = os.path.join(meso_src_dir,"dicoms")

#Define subject
#--------------
subj = subject_level.split("-")[-1]

if len(subj)<4:
    #print("error: please input subject number without dashes")
    subj_dcmid = subject_level
else:
    subj_dcmid = subj[0:3] + '-' + subj[3:]

# Echo subjects
#--------------
serv_subs = os.listdir(server_dcm_dir)
print("Server has subject(s): " + str(serv_subs) + ". Input to transfer subject: " +str(subj_dcmid))

serv_subj_input = os.path.join(server_dcm_dir,subj_dcmid)

# ssh to mkdir 
#- doesnt work for login ptilsley and scratch/jstellmann
#- works for login ptilsley and scratch/ptilsley..
# -------------------------------------------------

#meso_proj_dir_ = meso_proj_dir + "/"

#meso_ssh_mkdr = meso_user + "@login.mesocentre.univ-amu.fr:" + meso_proj_dir_

#subprocess.call(["ssh", meso_ssh_mkdr, "mkdir", "-p", meso_src_dir])
#subprocess.call(["ssh", meso_ssh_mkdr, "mkdir", "-p", meso_dir_dicoms])

# Create meso ssh command
# -----------------------
meso_ssh = meso_user + "@login.mesocentre.univ-amu.fr:" + meso_dir_dicoms

subprocess.call(["rsync", "-P", "-av",serv_subj_input, meso_ssh])

print("Finished syncing dicoms to mesocentre scratch")
