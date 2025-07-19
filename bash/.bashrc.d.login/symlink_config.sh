#!/bin/bash

# GET THE FUNCTION
source "$HOME"/.bashrc

# CONFIG FILE FOR MY SYMLINKS
# VARIABLES
USER_HOME=$HOME

# LINKING FOLDERS
manage_symlinks --source /home/snens_data/folders --action create --link $USER_HOME -d

# LINKING CONFIGURATIONS - managed in the other file
manage_symlinks --source /home/snens_data/config_all --action create --link $USER_HOME --ignore ".git,.gitignore" -d

# LINKING SECRETS TO CONFIGURATIONS
#
# SSH
manage_symlinks --source /home/snens_data/secrets/.ssh --action create --link /home/snens_data/config_all/.ssh -d
