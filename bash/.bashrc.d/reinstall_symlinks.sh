#!/bin/bash

# This script defines a function to delete symlinks and re-create them using --force.
reinstall_symlinks() {
    echo '⚠️ WARNING: This will delete all top-level symlinks in your $HOME directory.'
    read -rp 'Are you sure you want to continue? (yes/no): ' confirm
    if [[ "$confirm" != "yes" && "$confirm" != "y" ]]; then
        echo '❌ Operation cancelled.'
        return 1
    fi

    echo '🔁 Deleting top-level symlinks in $HOME...'
    find "$HOME" -maxdepth 1 -type l -exec rm -v {} \;

    # GET THE FUNCTION
    source "$HOME"/.bashrc

    # CONFIG FILE FOR MY SYMLINKS
    # VARIABLES
    USER_HOME=$HOME

    # LINKING FOLDERS
    manage_symlinks --source /home/snens_data/folders --action create --link $USER_HOME --force

    # LINKING CONFIGURATIONS - managed in the other file
    manage_symlinks --source /home/snens_data/config_all --action create --link $USER_HOME --ignore ".git,.gitignore" --force

    # LINKING SECRETS TO CONFIGURATIONS
    #
    # SSH
    manage_symlinks --source /home/snens_data/secrets/.ssh --action create --link /home/snens_data/config_all/.ssh --force
}
