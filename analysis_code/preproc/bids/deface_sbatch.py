"""
-----------------------------------------------------------------------------------------
deface_sbatch.py
-----------------------------------------------------------------------------------------
Goal of the script:
Deface UNI and INV images
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project data directory (e.g. /scratch/jstellmann/data/bio7)
sys.argv[2]: subject (e.g., sub-8761 or 8761, all)
sys.argv[3]: run with slurm server (0 = no: use terminal, 1 = yes: use server)
-----------------------------------------------------------------------------------------
Output(s):
Defaced images
-----------------------------------------------------------------------------------------
To run:
Example BIO7:
python deface_sbatch.py /scratch/jstellmann/data/bio7 sub-8761 1

cd ~/projects/bio7/analysis_code/preproc/bids/
python deface_sbatch.py [meso_proj_dir] [subject_number] [slurm]
-----------------------------------------------------------------------------------------
Written by Martin Szinte (martin.szinte@gmail.com), Penelope Tilsley
-----------------------------------------------------------------------------------------
"""

# imports modules
import sys
import os
import subprocess
import shutil
import csv

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Deface MP2RAGE UNI and INV images using pydeface',
    epilog = '')
parser.add_argument('[meso_proj_dir]', help='path to project data directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.add_argument('[subject_number]', help='subject to analyse. OPTIONS: treating specific subjects, accepted formats: 8762, sub-8762, 876-2')
parser.add_argument('[slurm]', help='user slurm server 0 = no, 1 = yes')
parser.parse_args()

# Get inputs
# ----------
meso_proj_dir = sys.argv[1]
subject_level = sys.argv[2]
server_in = int(sys.argv[3])

# Check inputs
# ------------
if os.path.isdir(meso_proj_dir): print("meso project input OK")
    if meso_proj_dir.endswith("/"):
        meso_proj_dir = meso_proj_dir[:-1]
    else:
        pass            
else:
    print("meso project input doesnt exist")
    exit()

## Check_install
#---------------        
dependencies_pipinstall = ['pydeface', 'nibabel', 'nipype']

for soft in dependencies_pipinstall:

    if shutil.which(soft) is None:
        try: 
            print('Trying to install {}'.format(soft)) 
            subprocess.call(['pip', 'install', soft])
        except:
            print('Didnt manage to install {}?'.format(soft))
    else:
        print('{} already installed!'.format(soft))
        
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
meso_log_dir = "{}/sourcedata/logs/anat/".format(meso_proj_dir)  
os.makedirs(meso_log_dir,exist_ok=True)

## Defining SLURM
#----------------
hour_proc = 3
nb_procs = 8

# Write slurm command cond
slurmwrite = 1

# define SLURM cmd
slurm_cmd = """\
#!/bin/bash
#SBATCH -p skylake
#SBATCH -A a306
#SBATCH --nodes=1
#SBATCH --cpus-per-task={nb_procs}
#SBATCH --time={hour_proc}:00:00
#SBATCH -e {meso_log_dir}/sub-{subject}_deface_%N_%j_%a.err
#SBATCH -o {meso_log_dir}/sub-{subject}_deface_%N_%j_%a.out
#SBATCH -J sub-{subject}_deface\n\n""".format(nb_procs=nb_procs, hour_proc=hour_proc, subject=subject, meso_log_dir=meso_log_dir)




## Finding T1 images
#-------------------
subj_dir = "{}/sub-{}".format(meso_proj_dir,subject)
sessions = [ses for ses in os.listdir(subj_dir) if "ses" in ses]

for it in sessions:
    tmp_sess_dir = os.path.join(subj_dir, it)
    tmp_anat_dir = os.path.join(tmp_sess_dir, "anat")
    backupdir = "{}/sourcedata/pydeface/sub-{}/{}/anat/".format(meso_proj_dir, subject, it)

    
    if os.path.exists(tmp_anat_dir):
        anat_scans = [scn for scn in os.listdir(tmp_anat_dir) if scn.endswith("FLAWS.nii.gz") or scn.endswith("MP2RAGE.nii.gz")]
        uni_image = [uni for uni in os.listdir(tmp_anat_dir) if "UNI" in uni and uni.endswith("MP2RAGE.nii.gz")]
        apply_to_images = list(set(anat_scans) - set(uni_image))
    
    
        # Test for images
        #----------------
        if len(uni_image) == 0 and len(apply_to_images) == 0:
            print("no T1 images to deface in " + tmp_anat_dir) 
            deface = 'no'
            applyto = 'no'

        elif len(uni_image) == 1 and len(apply_to_images) == 0:
            print("only T1 UNI image to deface in " + tmp_anat_dir)

            deface = 'yes'
            uni_filepath = os.path.join(tmp_anat_dir, uni_image[0])
            uni_filepath_newname = uni_filepath.replace('.nii.gz', '_defaced.nii.gz')

            applyto = 'no'

            deface_cmd = "pydeface {uni} --cost normmi --force --verbose\n".format(uni = uni_filepath)
            mkdir_cmd = "mkdir -p {}\n".format(backupdir)
            cp_cmd = "cp {} {} {}\n".format(uni_filepath, uni_filepath_newname, backupdir)
            rn_cmd = "rename _defaced.nii.gz .nii.gz {}/*\n".format(tmp_anat_dir)
            

        elif len(uni_image) == 1 and len(apply_to_images) > 0:
            print("T1 UNI image to deface in " + tmp_anat_dir)
            print("and will apply deface to " + str(apply_to_images))

            deface = 'yes'
            uni_filepath = os.path.join(tmp_anat_dir, uni_image[0])
            uni_filepath_newname = uni_filepath.replace('.nii.gz', '_defaced.nii.gz')

            applyto = 'yes'
            applypath = [tmp_anat_dir + '/' + img for img in apply_to_images] 
            apply_filepath = ' '.join(applypath)
            applypath_newname = [s.replace('.nii.gz', '_defaced.nii.gz') for s in applypath]
            apply_filepath_newname = ' '.join(applypath_newname)
    

            deface_cmd = "pydeface {uni} --cost normmi --applyto {apply} --force --verbose\n".format(uni = uni_filepath, apply = apply_filepath)       
            mkdir_cmd = "mkdir -p {}\n".format(backupdir)
            cp_cmd = "cp {} {} {} {} {}\n".format(uni_filepath, uni_filepath_newname, apply_filepath, apply_filepath_newname, backupdir)
            rn_cmd = "rename _defaced.nii.gz .nii.gz {}/*\n".format(tmp_anat_dir)
            
        elif len(uni_image) == 0 and len(apply_to_images) > 0:
            print("please check sub-" + tmp_anat_dir + " no UNI but other anat images?: " + str(apply_to_images))
            deface = 'no'
            applyto = 'no'

        elif len(uni_image) > 0:
            print("please check sub-" + tmp_anat_dir + " more than one UNI image? :" + str(uni_image))
            deface = 'no'
            applyto = 'no'
        else: 
            deface = 'no'
            applyto = 'no'


        # Create shell if defacing needed
        #--------------------------------
        if deface == 'no':
            pass
        elif deface == 'yes':

            # sh folder & file
            sh_folder = "{}/code/shell_jobs".format(meso_proj_dir)
            os.makedirs(sh_folder,exist_ok=True)
            sh_file = "{}/sub-{}_deface.sh".format(sh_folder,subject)

            if server_in == 1 and slurmwrite == 1:
                of = open(sh_file, 'w')
                of.write(slurm_cmd)
                slurmwrite = 0
                of.close()
            
            of = open(sh_file, 'a')
            of.write(deface_cmd)  
            of.write(mkdir_cmd)
            of.write(cp_cmd)
            of.write(rn_cmd)
            of.close()

            print("Created " + sh_file + " with following commands: ")
            shpr = open(sh_file, 'r').read()
            print(shpr)

# Run or submit jobs
if server_in:
    os.chdir(meso_log_dir)
    print("Submitting {} to queue".format(sh_file))
    os.system("sbatch {}".format(sh_file))
else:
    os.system("sh {}".format(sh_file))
