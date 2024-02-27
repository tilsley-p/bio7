"""
-----------------------------------------------------------------------------------------
freesurfer_pial.py
-----------------------------------------------------------------------------------------
Goal of the script:
Run freesurfer with new brainmask manually edited
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: main project directory
sys.argv[2]: project name (correspond to directory)
sys.argv[3]: subject (e.g. sub-01)
-----------------------------------------------------------------------------------------
Output(s):
new freesurfer segmentation files
-----------------------------------------------------------------------------------------
To run:
1. cd to function
>> ~/projects/bio7/analysis_code/preproc/anatomical/
2. run python command
python freesurfer_pial.py [main directory] [subject] [freesurfer_version]
-----------------------------------------------------------------------------------------
Exemple:
python freesurfer_pial.py /scratch/jstellmann/data/bio7 sub-8762 7
-----------------------------------------------------------------------------------------
Written by Martin Szinte (mail@martinszinte.net)
-----------------------------------------------------------------------------------------
"""

# imports modules
import os
import sys
import json

# inputs
main_dir = sys.argv[1]
subject = sys.argv[2]
fs_version = int(sys.argv[3])

# Define cluster/server specific parameters
cluster_name = 'skylake'
hour_proc = 20
nb_procs = 8
memory_val = 48

proj = main_dir.split('/')[-1]

if proj == "bio7": 
    proj_name = 'b306'
    group = 306
else: pass


# define directory and freesurfer licence
log_dir = "{}/derivatives/freesurfer_pial/log_outputs".format(main_dir)
job_dir = "{}/derivatives/freesurfer_pial/jobs".format(main_dir)

if fs_version == 7:
    fs_dir = "{}/derivatives/fmriprep/freesurfer/".format(main_dir)
    fs_licence = '{}/code/freesurfer7/license.txt'.format(main_dir)
    fs_home = '{}/code/freesurfer7'.format(main_dir)
    
elif fs_version == 6:
    fs_dir = "{}/derivatives/fmriprep/freesurfer/".format(main_dir)
    fs_licence = '{}/code/freesurfer/license.txt'.format(main_dir)
    fs_home = '{}/code/freesurfer'.format(main_dir)
    
else:
    print('freesurfer version invalid, 6 or 7')
    exit()


os.makedirs(log_dir, exist_ok=True)
os.makedirs(job_dir, exist_ok=True)

# define SLURM cmd
slurm_cmd = """\
#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH -p skylake
#SBATCH -A {proj_name}
#SBATCH --nodes=1
#SBATCH --mem={memory_val}gb
#SBATCH --cpus-per-task={nb_procs}
#SBATCH --time={hour_proc}:00:00
#SBATCH -e {log_dir}/{subject}_freesurfer-pial_%N_%j_%a.err
#SBATCH -o {log_dir}/{subject}_freesurfer-pial_%N_%j_%a.out
#SBATCH -J {subject}_freesurfer-pial\n\n""".format( nb_procs=nb_procs, subject=subject, memory_val = memory_val, 
                                                    hour_proc=hour_proc, log_dir=log_dir, proj_name=proj_name)

# define permission cmd
chmod_cmd = "chmod -Rf 771 {main_dir}\n".format(main_dir=main_dir)
chgrp_cmd = "chgrp -Rf {group} {main_dir}\n".format(main_dir=main_dir, group=group)


# define freesurfer command
freesurfer_cmd = """\
export FREESURFER_HOME={}\n\
export SUBJECTS_DIR={}\n\
export FS_LICENSE={}\n\
source $FREESURFER_HOME/SetUpFreeSurfer.sh
recon-all -autorecon-pial -subjid {} -no-isrunning""".format(fs_home, fs_dir, fs_licence, subject)

# create sh folder and file
sh_dir = "{}/{}_freesurfer-pial.sh".format(job_dir, subject)

of = open(sh_dir, 'w')
of.write("{}{}{}{}".format(slurm_cmd, chmod_cmd, chgrp_cmd, freesurfer_cmd, chmod_cmd, chgrp_cmd))
of.close()

# submit jobs
print("Submitting {} to queue".format(sh_dir))
os.chdir(log_dir)
os.system("sbatch {}".format(sh_dir))