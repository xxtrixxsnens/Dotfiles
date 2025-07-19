#!/bin/bash

### GET THE FUNCTIONS
source "$HOME".bashrc >/dev/null 2>&1 # Can throw unneccesary errors when reinstalling

if ! configuration_enviroment; then
    exit 0 # Exit with 0, otherwise it can crash the Desktop Enviroment
fi

# LINKING CONFIGURATIONS - managed in the other file
# Link the Dotfiles to CONFIG_HOME
link_dotfiles $CONFIG_HOME -d --option "-d"

# Link the Configuration to USER_HOME
manage_symlinks --source $CONFIG_HOME --action create --link $USER_HOME --ignore ".git,.gitignore" -d

# In this file the user can write there own configs
username=$(whoami)
user_config="$HOME/HOME.$username.config/login/symlink_config.sh"
if [[ -f "$user_config" ]]; then
    source $user_config
fi
