#!/bin/bash

# Determine the absolute path of the directory containing this script.
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
# Source function to manage the symlinks
source "$SCRIPT_DIR/manage_symlinks.sh"

# Wrap the manage_symlink function to get the configuration in the .env file
#
# A .env file needs to have CONFIG_PATH set.
# bash for example has ```CONFIG_PATH="$HOME"```
# because its config needs to be stored at the $HOME directory.
#
# link_dotfiles [option] [path]
# path: Where your config files should reside ($HOME, but maybe you have them somewhere else and do from that place a symlink)
# Creates a symlink to that path.
link_dotfiles() {
    # Determine the project root directory where 'link.sh' is located.
    # This assumes 'link.sh' is directly in the root, and this script
    # (link_dotfiles.sh) is within a subdirectory like 'scripts/link_dotfiles.sh'.
    local ROOT_DIR_DOTFILES
    if [[ -f "$SCRIPT_DIR/link.sh" ]]; then
        ROOT_DIR_DOTFILES="$SCRIPT_DIR"
    else
        # Navigate up until link.sh is found, or assume parent is root.
        local current_dir="$SCRIPT_DIR"
        while [[ "$current_dir" != "/" && ! -f "$current_dir/link.sh" ]]; do
            current_dir="$(dirname "$current_dir")"
        done
        ROOT_DIR_DOTFILES="$current_dir"
    fi

    local USER_HOME="$HOME"
    local CONFIG_HOME="$HOME"
    local LINK_OPTIONS_STRING=""
    local SILENT_MODE="false"

    # Parse arguments using a while loop and shift
    while [[ "$#" -gt 0 ]]; do # Loop while there are arguments left
        case "$1" in
        -h | --help)
            echo "Usage: link_dotfiles [option] [path]"
            echo "  [option]:"
            echo "    -d               Suppress all script output."
            echo "    --option \"<args>\" Pass a string of arguments directly to manage_symlinks (e.g., '--option \"-d --verbose\"')."
            echo "  [path]:"
            echo "    The path to store the config via symlinks. Defaults to \$HOME if not provided."
            exit 0
            ;;
        -d)
            SILENT_MODE="true"
            shift # Consume the argument
            ;;
        --force)
            LINK_OPTIONS_STRING="$LINK_OPTIONS_STRING --force"
            shift
            ;;
        --option)
            shift                  # Consume '--option' itself
            if [[ -z "$1" ]]; then # Check if the value for --option is provided
                if [[ "$SILENT_MODE" == "false" ]]; then
                    echo "Error: --option requires an argument (e.g., --option \"-d --verbose\")." >&2
                fi
                exit 1
            fi
            LINK_OPTIONS_STRING="$1" # Store the next argument as the options string
            shift                    # Consume the value of --option
            ;;
        *)
            # If it's not a known option, treat it as the CONFIG_HOME path
            # This assumes the path doesn't start with '-'
            if [[ ! "$1" =~ ^- ]]; then
                CONFIG_HOME="$1"
            else
                if [[ "$SILENT_MODE" == "false" ]]; then
                    echo "Error: Unknown argument '$1'" >&2 # Output error to stderr
                fi
                exit 1
            fi
            shift # Consume the argument
            ;;
        esac
    done

    # Function to conditionally echo
    local_echo() {
        if [[ "$SILENT_MODE" == "false" ]]; then
            echo "$@"
        fi
    }

    HOME="$CONFIG_HOME"

    # Loop through each first-level subdirectory (full path) within the root dotfiles directory
    for dir in "$ROOT_DIR_DOTFILES"/*/; do
        # dir is the full path of the folder (with trailing slash)
        folder_path="${dir%/}" # Remove trailing slash

        # Search for *.env file in this folder
        env_file=$(find "$folder_path" -maxdepth 1 -type f -name "*.env" ! -name 'HOME*' | head -n 1)

        if [[ -n "$env_file" ]]; then
            local_echo "Folder: $folder_path"
            local_echo "  Env file: $env_file"

            HOME="$CONFIG_HOME"
            source "$env_file" # Gets the CONFIG_PATH

            local_echo " CONFIG_PATH: $CONFIG_PATH"
            # Pass the selected option to manage_symlinks
            # Ensure manage_symlinks also respects silent mode if implemented within it.
            manage_symlinks --source "$folder_path" --action create --link "$CONFIG_PATH" --ignore "*.env,dev" $LINK_OPTIONS_STRING

        else
            local_echo "Folder: $folder_path"
            local_echo "  No .env file found"
        fi

        local_echo ""
    done

    # Reset $HOME to its original value after the script finishes
    HOME="$USER_HOME"
}
