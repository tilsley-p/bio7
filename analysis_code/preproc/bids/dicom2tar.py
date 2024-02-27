# -*- coding: utf-8 -*-
"""
Created on Mon Jan  9 10:57:22 2023

@author: Tilsley

-----------------------------------------------------------------------------------------
dicom2tar.py

script location: projects/bio7/analysis_code/preproc/bids/dicom2tar.py
-----------------------------------------------------------------------------------------
Goal of the script:
Create .tar file from dicoms on mesocentre
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project directory (e.g. /scratch/jstellmann/data/bio7)
sys.argv[2]: individual subject level or automatic all remaining (e.g., sub-8761 or 8761, all)
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/bio7/analysis_code/preproc/bids
>> python dicom2tar.py [meso_proj_dir] [subject_number]
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
    description = 'Convert dicoms to .tar files. Outputs to sourcedata/tarfiles/{subject}_{session}.tar',
    epilog = ' ')
parser.add_argument('[meso_proj_dir]', help='path to data project directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.add_argument('[subject_number]', help='subject to analyse. OPTIONS: all (treating any untreated subjects), OR, treating specific subjects, accepted formats: 8762, sub-8762, 876-2')
parser.parse_args()

# Get inputs
# ----------
meso_proj_dir = sys.argv[1]
subject_level = sys.argv[2]

# Check inputs
# ------------
if os.path.isdir(meso_proj_dir): print("meso sourcedata input OK")
else: print("meso sourcedata input doesnt exist"); exit()

if meso_proj_dir.endswith("/"): meso_proj_dir=meso_proj_dir[:-1]
else: pass
 
# Define homedir + sourcedirectory
#---------------------------------
meso_src_dir = os.path.join(meso_proj_dir,"sourcedata")
meso_home_dir = os.path.expanduser('~')

# Define code directories
#-------------------------
meso_code_dir = os.path.join(meso_proj_dir,"code")
meso_singularity_dir = os.path.join(meso_code_dir,"singularity")
    
# Finding dicom2tar sif
#----------------------
dicom2tar_file = [sif for sif in os.listdir(meso_singularity_dir) if "dicom2tar" in sif and sif.endswith(".sif")]
dicom2tar_path = os.path.join(meso_singularity_dir, dicom2tar_file[0])
                  
# Create tarfile dir meso
# -----------------------
meso_dir_dicoms = os.path.join(meso_src_dir,"dicoms")
meso_dir_tarfiles = os.path.join(meso_src_dir,"tarfiles")
meso_dir_logs = os.path.join(meso_src_dir,"logs")

os.makedirs(meso_dir_tarfiles,exist_ok=True)    
os.makedirs(meso_dir_logs,exist_ok=True)   

#Define subject
#--------------
subj = subject_level.split("-")[-1]

if subj == "all":

    print('search all')

    # Find subjects as dcm
    #---------------------
    meso_subs = os.listdir(meso_dir_dicoms)
    print("Mesocentre has subject(s): " + str(meso_subs) + " as dicoms")
    
    meso_subs_norm = []
    for dcms in meso_subs:
        meso_subs_norm.append(dcms.replace("-",""))
    
    # Find subjects with tar 
    #-----------------------    
    meso_subs_tar = os.listdir(meso_dir_tarfiles)
    print("Mesocentre has subject(s): " + str(meso_subs_tar) + " as tarfiles")
    
    meso_subs_tar_spl = []
    for trs in meso_subs_tar:
        meso_subs_tar_spl.append(trs.split("_")[0])
    
    meso_subs_tar_norm = list(set(meso_subs_tar_spl))
        
    # Missing subjects to convert
    #----------------------------
    subtotar = list(set(meso_subs_norm) - set(meso_subs_tar_norm))

    print("Converting subject(s) :" + str(subtotar) + " dicom to tar")

    # Loop over subjects
    #-------------------
    for s in subtotar:

        s_dcm_format = s[0:3] + "-" + s[3]
        s_dicompath = os.path.join(meso_dir_dicoms,s_dcm_format)
        s_dicompath_dirs = [dcm for dcm in os.listdir(s_dicompath)]
        
        for dicdir in s_dicompath_dirs:
            
            if len(dicdir) == 1:
                # Convert dicom to tar file
                #--------------------------
                dicfiles = os.path.join(s_dicompath, dicdir)
                subprocess.call(["singularity","run", "-e", "-B", meso_proj_dir + "," + meso_home_dir, dicom2tar_path, dicfiles, meso_dir_tarfiles])
                
                # Rename tar files sub_ses
                #-------------------------
                raw_tarfiles = [tr for tr in os.listdir(meso_dir_tarfiles) if not tr.startswith("876")]
    
                # Need to check what original tar output is named as and use for defining ses_ better, not sure iter will work
                for r in raw_tarfiles:
                    
                    #NEURO_3T-7T_20221013_876_1_1.A8354408.tar
                    ses_iter = "0" + r.split("_")[-1][0]
                    tar_rename = os.path.join(meso_dir_tarfiles, s + "_" + ses_iter + ".tar")
                    raw_name = os.path.join(meso_dir_tarfiles, r)
                    
                    print("Converting: ")
                    print(raw_name)
                    print("To: ")
                    print(tar_rename)      
                    os.rename(raw_name,tar_rename)
                    
                converted_tarfiles = [tl for tl in os.listdir(meso_dir_tarfiles) if tl.startswith(s)]
                
                with open(meso_dir_logs + '/sub-' + s + '_dicom2tar_log.csv', 'w') as fp:
                    fp.write("Original tars for subject " + s + ": \n")
                    fp.write('\t'.join(raw_tarfiles))
                    fp.write("\n Converted tars for subject " + s + ": \n")
                    fp.write('\t'.join(converted_tarfiles))
                fp.close()  
                    
                #Once sure the code works, uncomment for deleting the dicom files
                dicdir_content = dicfiles
                #subprocess.call(["rm", "-rf", dicdir_content])
                #subprocess.call(["mkdir", dicdir_content])
    
            else: 
                print("subject "+ str(s) +"more than one dicom series "+ str(s_dicompath_dirs) +", check and filter dicoms before continuing")
                
else:
    if len(subj)<4:
        #input subject number without dashes
        subj_dcmid = subject_level
        s = subject_level.replace("-","")
    else:
        #input subject number as label or full number
        subj_dcmid = subj[0:3] + '-' + subj[3:] 
        s = subj

    s_tarfiles = [trr for trr in os.listdir(meso_dir_tarfiles) if s in trr]
    
    # Checking tar files don't exist
    #-------------------------------
    for star in s_tarfiles:
        s_tarpath = os.path.join(meso_dir_tarfiles,star)
        
        if os.path.isfile((s_tarpath + ".tar")):
            print("subject " + s + " already has " + star + ".tar, pass to next")
            exit()
        else:
            print("no prexisting tar, converting subject " + s + "," + star + " dicom to tar")
        
    # Find dicoms
    #------------
    s_dicompath = os.path.join(meso_dir_dicoms,subj_dcmid)
    s_dicompath_dirs = [dcm for dcm in os.listdir(s_dicompath)]
    
    for dicdir in s_dicompath_dirs:
        
        if len(s_dicompath_dirs) == 1:
            # Convert dicom to tar file
            #--------------------------
            dicfiles = os.path.join(s_dicompath, dicdir)
            subprocess.call(["singularity","run", "-e", "-B", meso_proj_dir + "," + meso_home_dir, dicom2tar_path, dicfiles, meso_dir_tarfiles])
            
            # Rename tar files sub_ses
            #-------------------------
            raw_tarfiles = [tr for tr in os.listdir(meso_dir_tarfiles) if not tr.startswith("876")]
    
            # Need to check what original tar output is named as and use for defining ses_ better, not sure iter will work
            for r in raw_tarfiles:
                
                #NEURO_3T-7T_20221013_876_1_1.A8354408.tar
                ses_iter = "0" + r.split("_")[-1][0]
                tar_rename = os.path.join(meso_dir_tarfiles, s + "_" + ses_iter + ".tar")
                raw_name = os.path.join(meso_dir_tarfiles, r)
                
                print("Converting: ")
                print(raw_name)
                print("To: ")
                print(tar_rename)    
                os.rename(raw_name,tar_rename)
                
            converted_tarfiles = [tl for tl in os.listdir(meso_dir_tarfiles) if tl.startswith(s)]
            
            with open(meso_dir_logs + '/sub-' + s + '_dicom2tar_log.csv', 'w') as fp:
                fp.write("Original tars for subject " + s + ": \n")
                fp.write('\t'.join(raw_tarfiles))
                fp.write("\n Converted tars using " + dicom2tar_file[0] + " for subject " + s + ": \n")
                fp.write('\t'.join(converted_tarfiles))  
            fp.close()   
            
            #Once sure the code works, uncomment for deleting the dicom files
            dicdir_content = dicdir + "/*"
            #subprocess.call(["rm", "-rf", dicdir_content])
    
        else: 
            print("subject "+ str(s) +"more than one dicom series "+ str(s_dicompath_dirs) +", check and filter dicoms before continuing")
        
