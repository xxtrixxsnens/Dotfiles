#!/bin/bash

# This script defines a function to delete symlinks and re-create them using --force.
reinstall_symlinks() {
    # Check if CONFIG_FILE_PATH is set
    if [[ -z "$CONFIG_FILE_PATH" ]]; then
        echo '❌ CONFIG_FILE_PATH is not set. Aborting.'
        return 1
    fi

    local ROOT_DIR_DOTFILES
    if [[ -f "$SCRIPT_DIR/link.sh" ]]; then
        ROOT_DIR_DOTFILES="$SCRIPT_DIR"
    else
        local current_dir="$SCRIPT_DIR"
        while [[ "$current_dir" != "/" && ! -f "$current_dir/link.sh" ]]; do
            current_dir="$(dirname "$current_dir")"
        done
        ROOT_DIR_DOTFILES="$current_dir"
    fi

    source "$ROOT_DIR_DOTFILES/bash/.bashrc.d/manage_symlinks.sh"
    source "$ROOT_DIR_DOTFILES/bash/.bashrc.d/link_dotfiles.sh"

    # Confirm the functions were actually sourced
    if ! declare -f manage_symlinks >/dev/null; then
        echo '❌ Function manage_symlinks not found after sourcing. Aborting.'
        return 1
    else
        echo '✅ Function manage_symlinks loaded.'
    fi

    if ! declare -f link_dotfiles >/dev/null; then
        echo '❌ Function link_dotfiles not found after sourcing. Aborting.'
        return 1
    else
        echo '✅ Function link_dotfiles loaded.'
    fi

    echo '⚠️ WARNING: This will delete all top-level symlinks in your $HOME directory.'
    read -rp 'Are you sure you want to continue? (yes/no): ' confirm
    if [[ "$confirm" != "yes" && "$confirm" != "y" ]]; then
        echo '❌ Operation cancelled.'
        return 1
    fi

    echo '🔁 Deleting top-level symlinks in $HOME...'
    find "$HOME" -maxdepth 1 -type l -exec rm -v {} \;

    BASENAME=$(basename "$CONFIG_FILE_PATH")
    ln -s "$CONFIG_FILE_PATH" "$HOME/$BASENAME"
    source "$CONFIG_FILE_PATH"
    link_dotfiles -p /home/snens_arch -d --option '-d --force'

    
    ### GET THE FUNCTIONS
    source "$HOME"/.bashrc #>/dev/null 2>&1 # Can throw unneccesary errors when reinstalling
    
    if ! configuration_enviroment >/dev/null 2>&1; then
        return 0 # Exit with 0, otherwise it can crash the Desktop Enviroment
    fi
    
    # LINKING CONFIGURATIONS - managed in the other file
    # Link the Dotfiles to CONFIG_HOME
    link_dotfiles -p $CONFIG_HOME -d
    
    # Link the Configuration to USER_HOME
    manage_symlinks --force --source $CONFIG_HOME --action create --link $USER_HOME --ignore ".git,.gitignore" -d
    
    # Share my Share file content
    export SHARE_HOME
    manage_symlinks --force --source "$SHARE_HOME" --action create --link "/usr/share/snens" -d
    
    # In this file the user can write there own configs
    username=$(whoami)
    user_config="$HOME/HOME.$username.config/login/symlink_config.sh"
    if [[ -f "$user_config" ]]; then
        source $user_config
    fi
    echo 'Completed reinstallation of the symlinks'
}
