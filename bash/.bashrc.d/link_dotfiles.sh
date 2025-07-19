#!/bin/bash

# Source function to manage the symlinks
SCRIPT_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_PATH/manage_symlinks.sh

# Wrap the manage_symlink function to get the configuration in the .env file
#
# A .env file needs to have CONFIG_PATH set.
# bash for example has ```CONFIG_PATH="$HOME"```
# because its config needs to be stored at the $HOME directory.
#
# link_dotfiles [path]
# path: Where your config files should reside ($HOME, but maybe you have them somewhere else and do from that place a symlink)
# Creates a symlink to that path.
link_dotfiles() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: link [path]"
        echo "If [path], the path to store the config via symlinks is not provided, defaults to \$HOME."
        exit 0
    fi

    local USER_HOME="$HOME"
    local CONFIG_HOME="${1:-$HOME}"
    HOME="$CONFIG_HOME"

    # Loop through each first-level subdirectory (full path)
    for dir in "$PWD"/*/; do
        # dir is the full path of the folder (with trailing slash)
        folder_path="${dir%/}" # Remove trailing slash

        # Search for *.env file in this folder
        env_file=$(find "$folder_path" -maxdepth 1 -type f -name "*.env" | head -n 1)

        if [[ -n "$env_file" ]]; then
            echo "Folder: $folder_path"
            echo "  Env file: $env_file"
            HOME="$CONFIG_HOME"
            source "$env_file" # Gets the CONFIG_PATH

            echo " CONFIG_PATH: $CONFIG_PATH"
            manage_symlinks --source "$folder_path" --action create --link "$CONFIG_PATH" --ignore "*.env"
        else
            echo "Folder: $folder_path"
            echo "  No .env file found"
        fi

        echo ""
    done

    # Reset $HOME
    HOME="$USER_HOME"
}
