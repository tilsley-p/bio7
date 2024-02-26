"""

lesion_edits.py
-----------------------------------------------------------------------------------------
Goal of the script:
Transfer fsl_itksnap lesion folder to user home, do manual lesion mapping and transfer 
back to mesocentre
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project directory (e.g. /scratch/jstellmann/data/bio7)
sys.argv[3]: subject number/label any following format (e.g. 8762, sub-8762, 876-1)
sys.argv[4]: mesocentre username (e.g. ptilsley)
-----------------------------------------------------------------------------------------
Output(s):
Creates lesionmask using ITKsnap (T1w, FLAWs)
-----------------------------------------------------------------------------------------
To run:
On laminar-mac 
(or other computer with mesocentre rsa key setup + ITKSnap installed)

cd ~/disks/meso_H/projects/bio7/analysis_code/preproc/
python lesion_edits.py [meso_proj_dir] [subject number] [mesocentre_ID]
-----------------------------------------------------------------------------------------
Exemple:
python lesion_edits.py /scratch/jstellmann/data/bio7 8762 ptilsley
-----------------------------------------------------------------------------------------
Written by Penelope Tilsley, Martin Szinte
-----------------------------------------------------------------------------------------

"""
# General imports
# ---------------
import os
import sys
import subprocess

# Get inputs
# ----------
meso_proj_dir = sys.argv[1]
subject_level = sys.argv[2]
meso_user = sys.argv[3]

# Check inputs
# ------------

if meso_proj_dir.endswith("/"):
    #True
    meso_proj_dir = meso_proj_dir[:-1]
else:
    #True
    pass            

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
user_home_dir = os.path.expanduser('~')
projname = meso_proj_dir.split('/')[-1]

## Copying fsl_itksnap to user home
#----------------------------------
fsl_itksnap_dir = "{meso_proj_dir}/derivatives/fsl_itksnap/{subject}".format(meso_proj_dir=meso_proj_dir, subject=subject)

print("Copying lesion filling derivatives folder to {home}/temp_data/".format(home=user_home_dir))
subprocess.call[("rsync", "-azuv", "--progress", "{}@login.mesocentre.univ-amu.fr:{}".format(meso_user,fsl_itksnap_dir),\
                 "~/temp_data/fsl_itksnap/")]

## Finding T1, FLAWS
#-------------------   

tmp_dir = "{}/temp_data".format(user_home_dir)
tmp_dir_sub = "{}/temp_data/{}".format(user_home_dir, subject)
sess = [s for s in os.listdir(tmp_dir_sub) if s.startswith("ses")]
tmp_dir_ses = [os.path.join(tmp_dir_sub, o) for o in os.listdir(tmp_dir_sub) if os.path.isdir(os.path.join(tmp_dir_sub,o))]

if len(tmp_dir_ses) == 1:
    sess = sess[0]
    tmp_dir_anat = os.path.join(tmp_dir_ses[0], "anat")
else:
    print("more than one session in subject dir? Pls check")
    exit()
    
# T1 image
T1w_image = [f for f in os.listdir(tmp_dir_anat) if "rec-BcSs_" in f and f.endswith('_T1w.nii.gz')]

if len(T1w_image) == 1:
    T1w_image_path = os.path.join(tmp_dir_anat, T1w_image[0])
    lesion_labels = T1w_image[0].replace("_rec-BcSs_","_")
    lesionmask_name = lesion_labels.replace("T1w.nii.gz", "lesionmask.nii.gz")
else:
    print("more than one session in subject dir? Pls check")
    exit()

# FLAWS images    
FLAWS_images = [tmp_dir_anat + fl for fl in os.listdir(tmp_dir_anat) if fl.endswith('_FLAWS.nii.gz')]

## Creating shell file
#--------------------- 
sh_file = os.path.join(tmp_dir,"sub-{}_lesionmasking.sh".format(subject))

## Setting up shell commands
#---------------------------  
#open itksnap command - depending on available images
if len(FLAWS_images) == 0:
    open_itk_cmd = "itksnap -g {T1}\n\n".format(T1=T1w_image_path)
else:
    FLAWS_images_path = [os.path.join(tmp_dir_anat,fl) for fl in os.listdir(tmp_dir_anat) if fl.endswith('_FLAWS.nii.gz')]
    FLAWS_images_str = ' '.join(FLAWS_images_path)  
    open_itk_cmd = "itksnap -g {T1} -o {FLAWS}\n\n".format(T1=T1w_image_path, FLAWS = FLAWS_images_str)

#instructions command 
instructions_cmd = """
#!/bin/bash
echo 'Follow lesion mask instructions on https://invibe.nohost.me/bookstack/books/preprocessing/manual-lesion-filling-ITKsnap'
echo 'When you are done, save the lesionmask as {} and quit ITKsnap\n\n'
""".format(lesionmask_name)

#transfer back to meso command
transfer_cmd = """
while true; do
    read -p "Do you wish to transfer the edited lesionmask to the mesocentre? (y/n) " yn
    case $yn in
        [Yy]* ) echo "\n>> Uploading {lesionmask_name} to mesocentre";\
                rsync -avuz {tmp_dir_anat}/{lesionmask_name} {meso_user}@login.mesocentre.univ-amu.fr:{fsl_itksnap_dir}/{sess}/anat/
                rsync -avuz {sh_file} {meso_user}@login.mesocentre.univ-amu.fr:{meso_proj_dir}/code/shell_jobs/
        break;;
        [Nn]* ) echo "\n>> Not uploading lesionmask to mesocentre";\
                exit;;
        * ) echo "Please answer yes or no.";;
    esac
done""".format(tmp_dir_anat=tmp_dir_anat,lesionmask_name=lesionmask_name,meso_user=meso_user,fsl_itksnap_dir=fsl_itksnap_dir,sess=sess,sh_file=sh_file,meso_proj_dir=meso_proj_dir)

## Writing shell file
#--------------------- 

with open (sh_file, 'w') as shell:
    shell.write(instructions_cmd)
    shell.write(open_itk_cmd)
    shell.write(transfer_cmd)
shell.close()
    
   
print("Created " + sh_file + " with following commands: ")

shpr = open(sh_file, 'r').read()
print(shpr)
    
## Run shell job
#----------------
os.system("sh {}".format(sh_file))


# ITK-SnAP Command Line Usage:
#    /Applications/ITK-SNAP.app/Contents/MacOS/ITK-SNAP [options] [main_image]
# Image Options:
#    -g FILE              : Load the main image from FILE
#    -s FILE              : Load the segmentation image from FILE
#    -l FILE              : Load label descriptions from FILE
#    -o FILE [FILE+]      : Load additional images from FILE
#                         :   (multiple files may be provided)
#    -w FILE              : Load workspace from FILE
#                         :   (-w cannot be mixed with -g,-s,-l,-o options)
# Additional Options:
#    -z FACTOR            : Specify initial zoom in screen pixels/mm
#    --cwd PATH           : Start with PATH as the initial directory
#    --threads N          : Limit maximum number of CPU cores used to N.
#    --scale N            : Scale all GUI elements by factor of N (e.g., 2).
#    --geometry WxH+X+Y   : Initial geometry of the main window.
# Debugging/Testing Options:
#    --debug-events       : Dump information regarding UI events
#    --test list          : List available tests.
#    --test TESTID        : Execute a test.
#    --testdir DIR        : Set the root directory for tests.
#    --testacc factor     : Adjust the interval between test commands by factor (e.g., 0.5).
#    --css file           : Read stylesheet from file.
#    --opengl MAJOR MINOR : Set the OpenGL major and minor version. Experimental.
#    --testgl             : Diagnose OpenGL/VTK issues.