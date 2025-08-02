#!/bin/bash

### GET THE FUNCTIONS
source "$HOME"/.bashrc #>/dev/null 2>&1 # Can throw unneccesary errors when reinstalling

if ! configuration_enviroment >/dev/null 2>&1; then
    return 0 # Exit with 0, otherwise it can crash the Desktop Enviroment
fi

# LINKING CONFIGURATIONS - managed in the other file
# Link the Dotfiles to CONFIG_HOME

if [ -n "$CONFIG_HOME" ]; then
    CONFIG_HOME="$HOME"
fi
link_dotfiles -p $CONFIG_HOME -d

# Link the Configuration to USER_HOME
if [ "$USER_HOME" != "$CONFIG_HOME" ]; then
    manage_symlinks --source $CONFIG_HOME --action create --link $USER_HOME --ignore ".git,.gitignore" -d
fi

# Share my Share file content
if [ -n "$SHARE_HOME" ]; then
    manage_symlinks --source "$SHARE_HOME" --action create --link "/usr/share/$USER_HOME" -d
fi
