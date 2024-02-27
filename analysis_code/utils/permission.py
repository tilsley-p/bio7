"""
Created on Tue Jan 17 11:17:07 2023

@author: Tilsley, Martin Szinte
-----------------------------------------------------------------------------------------
permission.py
script location: projects/bio7/analysis_code/preproc/bids/change_folder_access.py
-----------------------------------------------------------------------------------------
Goal of the script:
Set of function to modify file permissions
-----------------------------------------------------------------------------------------
To run:
In other codes:
sys.path.append("{}/../../utils".format(os.getcwd()))
from permission import change_file_mod, change_file_group
change_file_mod('your/root/directory/')
change_file_group('your/root/directory/')
-----------------------------------------------------------------------------------------
"""

# General imports
import os
import sys

def change_file_mod(input_dir):
    # take out the w (write files) and r (read files) for all users, -R does for all folders below
    print('Changing file mod from: {}'.format(input_dir))
    os.system("chmod -Rf a+wrx {}".format(input_dir))

    # allow x (view files) for all users, -R does for all folders below
    os.system("chmod -Rf o-rw {}".format(input_dir))

def change_file_group(input_dir):
    print('Changing file group from: {}'.format(input_dir))
    # change group identifiant to bio7 number, -R does for all folders below
    os.system("chgrp -Rf 306 {}".format(input_dir))
