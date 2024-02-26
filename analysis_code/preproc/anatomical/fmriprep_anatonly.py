"""
-----------------------------------------------------------------------------------------
fmriprep_sbatch.py
-----------------------------------------------------------------------------------------
Goal of the script:
Run fMRIprep on mesocentre using job mode
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: main project directory
sys.argv[2]: subject (e.g. sub-001)
sys.argv[3]: save cifti hcp format data with 170k vertices 
sys.argv[4]: skip BIDS validation (1) or not (0)
sys.argv[5]: email account
-----------------------------------------------------------------------------------------
Output(s):

preprocessed files
-----------------------------------------------------------------------------------------
To run:
1. cd to function
>> cd ~/projects/bio7/analysis_code/preproc/functional
2. run python command
python fmriprep_sbatch.py [main directory] [subject num]
                          [skip bids validation] [cifti] [email account]
-----------------------------------------------------------------------------------------
Exemple:
python fmriprep_sbatch.py /scratch/jstellmann/data/bio7 sub-8761 1 1 martin.szinte
-----------------------------------------------------------------------------------------
Written by Martin Szinte (martin.szinte@gmail.com),  Penelope Tilsley
-----------------------------------------------------------------------------------------
"""

# imports modules
import sys
import os
import time
import json

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Run fmriprep anat-only to do freesurfer segmentation',
    epilog = 'Needs: singularity')
parser.add_argument('[meso_proj_dir]', help='path to project data directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.add_argument('[subject_level]', help='subject to analyse. OPTIONS: treating specific subjects, accepted formats: 8762, sub-8762, 876-2')
parser.add_argument('[hcp_cifti]', help='save cifti hcp format data with 170k vertices 0 = no, 1 = yes')
parser.add_argument('[skip_bids_val]', help='skip bids validation 0 = no, 1 = yes')
parser.add_argument('[email_account]', help='email username ID before @univ-amu.fr')
parser.parse_args()

# inputs
meso_proj_dir = sys.argv[1]
subject_level = sys.argv[2]
hcp_cifti_val = int(sys.argv[3])
skip_bids_val = int(sys.argv[4])
email_account = sys.argv[5]

# Check inputs
# ------------
if os.path.isdir(meso_proj_dir): print("meso sourcedata input OK")
else: print("meso sourcedata input doesnt exist"); exit()

if meso_proj_dir.endswith("/"): meso_proj_dir=meso_proj_dir[:-1]
else: pass

projname = meso_proj_dir.split('/')[-1]
s_bind = "/".join(meso_proj_dir.split("/")[:-1])
s_bind = ","+s_bind

#Define subject
#--------------
if subject_level.split("-")[0] == "sub": sub_label = subject_level
else: sub_label = "sub-{}".format(subject_level)
sub_number = sub_label[4:]  

# Define cluster/server specific parameters
singularity_dir = '{}/code/singularity/fmriprep-20.2.3.simg'.format(meso_proj_dir)

log_dir = os.path.join(meso_proj_dir,'derivatives','fmriprep','log_outputs')
tmp_workdir = "/tmp/fmriprep_wd"
os.makedirs(tmp_workdir,exist_ok=True)   



# special input
use_skip_bids_val, hcp_cifti, output_spaces, tf_export, tf_bind = '','','','',''

if skip_bids_val == 1:
    use_skip_bids_val = '--skip_bids_validation'
else: pass

if hcp_cifti_val == 1:
    tf_export = 'export SINGULARITYENV_TEMPLATEFLOW_HOME=/opt/templateflow'
    tf_bind = ',{}/code/singularity/fmriprep_tf/:/opt/templateflow'.format(meso_proj_dir)
    hcp_cifti = '--cifti-output 170k'

output_spaces = 'MNI152NLin6Asym MNI152NLin2009cAsym'

#define SLURM values
hour_proc = 34    
nb_procs = 8
memory_val = 100

# define SLURM cmd
slurm_cmd = """\
#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH -p skylake
#SBATCH --mail-user={email_account}@univ-amu.fr
#SBATCH -A a306
#SBATCH --nodes=1
#SBATCH --mem={memory_val}gb
#SBATCH --cpus-per-task={nb_procs}
#SBATCH --time={hour_proc}:00:00
#SBATCH -e {log_dir}/{sub_label}_fmriprep_anatonly_%N_%j_%a.err
#SBATCH -o {log_dir}/{sub_label}_fmriprep_anatonly_%N_%j_%a.out
#SBATCH -J {sub_label}_fmriprep_anatonly
#SBATCH --mail-type=BEGIN,END\n\n{tf_export}\n
""".format(nb_procs=nb_procs, hour_proc=hour_proc, sub_label=sub_label, 
           memory_val=memory_val, log_dir=log_dir, email_account=email_account, tf_export=tf_export)

# define singularity cmd
singularity_cmd = "singularity run --cleanenv -B {meso_proj_dir}:/work_dir{tf_bind}{s_bind} {simg} --fs-license-file /work_dir/code/freesurfer/license.txt /work_dir/ /work_dir/derivatives/fmriprep/ participant --participant-label {sub_num} -w {tmp_workdir} --ignore sbref --output-spaces T1w {output_spaces} {hcp_cifti} --low-mem --mem-mb {memory_val}000 --nthreads {nb_procs:.0f} {use_skip_bids_val} --skull-strip-t1w skip --anat-only --bids-filter-file /work_dir/code/config.json".format(tf_bind=tf_bind, tmp_workdir=tmp_workdir, s_bind=s_bind, meso_proj_dir=meso_proj_dir,
simg=singularity_dir, sub_num=sub_number, nb_procs=nb_procs, use_skip_bids_val=use_skip_bids_val, hcp_cifti=hcp_cifti, output_spaces=output_spaces, memory_val=memory_val)
# create sh folder and file
sh_dir = "{meso_proj_dir}/derivatives/fmriprep/jobs/sub-{sub_num}_fmriprep_anatonly.sh".format(meso_proj_dir=meso_proj_dir, sub_num=sub_number)

try:
    os.makedirs(os.path.join(meso_proj_dir,'derivatives','fmriprep','jobs'))
    os.makedirs(os.path.join(meso_proj_dir,'derivatives','fmriprep','log_outputs'))
except:
    pass

of = open(sh_dir, 'w')
of.write("{slurm_cmd}{singularity_cmd}".format(slurm_cmd=slurm_cmd, singularity_cmd=singularity_cmd))
of.close()

print("Created " + sh_dir + " with following commands: ")

shpr = open(sh_dir, 'r').read()
print(shpr)


# Submit jobs
print("Submitting {sh_dir} to queue".format(sh_dir=sh_dir))
os.chdir(log_dir)
os.system("sbatch {sh_dir}".format(sh_dir=sh_dir))