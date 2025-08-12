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
    local DEBUG="false"
    local -a FILTER=()
    local -a INCLUDE=()
    local OS="LINUX" # LINUX || MAC || WINDOWS
    local DELETE="false"

    # Parse arguments using a while loop and shift
    while [[ "$#" -gt 0 ]]; do # Loop while there are arguments left
        case "$1" in
        -h | --help)
            echo "Usage: link_dotfiles [option] [path]"
            echo "  [option]:"
            echo "    -d               Suppress all script output."
            echo "    --delete         Deletes the symlinks."
            echo "    --debug          Verbose output."
            echo "    --ignore         <pattern1,pattern2> Comma-separated list of patterns to ignore (foldernames). Overwrites * (all)."
            echo "    --include        <pattern1,pattern2> Comma-separated list of patterns to include (foldernames). Overwrites patterns in ignore."
            echo "    --option         \"<args>\" Pass a string of arguments directly to manage_symlinks (e.g., '--option \"-d --verbose\"')."
            echo "    --root           Searches for config files from the given dir instead of the repositories root."
            echo "  [path]:"
            echo "    The path to store the config via symlinks. Defaults to \$HOME if not provided."
            exit 0
            ;;
        -d)
            SILENT_MODE="true"
            LINK_OPTIONS_STRING="$LINK_OPTIONS_STRING -d"
            shift
            ;;
        --delete)
            DELETE="true"
            shift
            ;;
        --debug)
            DEBUG="true"
            shift
            ;;
        --ignore)
            IFS=',' read -ra TEMP_PATTERNS <<<"$2"
            FILTER+=("${TEMP_PATTERNS[@]}")
            shift 2
            ;;
        --include)
            IFS=',' read -ra TEMP_PATTERNS <<<"$2"
            INCLUDE+=("${TEMP_PATTERNS[@]}")
            shift 2
            ;;
        --os)
            shift
            os_input="$(echo "$1" | tr '[:upper:]' '[:lower:]')" # Portable lowercase conversion
            case "$os_input" in
            linux | ubuntu | debian | arch | fedora)
                OS="LINUX"
                ;;
            mac | macos | darwin | osx)
                OS="MAC"
                ;;
            win | windows | win32 | win64)
                OS="WINDOWS"
                echo "ERROR: Currently no support for WINDOWS!"
                exit 1
                ;;
            *)
                echo "Warning: Unknown OS '$1'"
                OS="LINUX"
                exit 1
                ;;
            esac
            shift
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
        -p | --path)
            # If it's not a known option, treat it as the CONFIG_HOME path
            CONFIG_HOME="$2"
            shift 2
            ;;
        --root)
            ROOT_DIR_DOTFILES="$(readlink -f "$2")"
            shift 2
            ;;
        *)
            if [[ "$SILENT_MODE" == "false" ]]; then
                echo "Error: Unknown argument: $1."
            fi
            exit 1
            ;;
        esac
    done

    ### Functions
    # Function to conditionally echo
    local_echo() {
        if [[ "$SILENT_MODE" == "false" ]]; then
            echo "$@"
        fi
    }

    local_debug() {
        if [[ "$DEBUG" == "true" ]]; then
            echo "$@"
        fi
    }

    loop_folder() {
        local folder_path="$1"

        # Loop through each first-level subdirectory (full path)
        for dir in "$folder_path"/*/; do
            # dir is the full path of the folder (with trailing slash)
            folder_path="${dir%/}"
            create_config_path_from_env $folder_path
        done
    }

    create_config_path_from_env() {
        local folder_path="$1"
        local basename=$(basename "$folder_path")

        # Functions
        reset() {
            unset CONFIG_PATH
            unset CONFIG_PATH_LINUX
            unset CONFIG_PATH_MAC
            unset CONFIG_PATH_WINDOWS
            CONFIG_RECURSIVE="false"
            unset folder_path
            include="false"
            ignore="false"
        }

        skip_if_ignored() {
            local basename="$1"
            local include="false"

            shopt -s dotglob
            shopt -s nullglob

            for PATTERN in "${INCLUDE[@]}"; do
                if [[ "*" == $PATTERN ]]; then
                    include="default" # Included by default - Can be excluded
                elif [[ "$basename" == $PATTERN ]]; then
                    local_debug "INCLUDE: $basename"
                    include="true" # Included in any case
                fi
            done

            # Skip ignored patterns
            for PATTERN in "${FILTER[@]}"; do
                if [[ ("$basename" == $PATTERN && "$include" != "true") ]]; then
                    local_debug "EXCLUDE: $basename because of $PATTERN"
                    include="false"
                fi
            done

            if [[ "$include" == "false" ]]; then
                local_echo "Ignoring following folder: $folder_path"
                reset
                return 1
            fi

            local_debug "INCLUDED by default: $basename"
        }

        # Search for *.dotfiles.env file in this folder
        env_file=$(find "$folder_path" -maxdepth 1 -type f -name "*.dotfiles.env" ! -name 'HOME*' | head -n 1)

        if [[ -n "$env_file" ]]; then

            if ! skip_if_ignored "$basename"; then
                return 0
            fi

            local_echo "Folder: $folder_path"
            local_echo "  Env file: $env_file"

            HOME="$CONFIG_HOME"
            source "$env_file" # Gets the CONFIG_PATH

            # See dotfiles.env definion in README.md
            # Go recursively through the folders
            if [[ "$CONFIG_RECURSIVE" == "true" ]]; then
                local_echo "Searching recursively..."
                reset
                loop_folder $folder_path
                return 0
            fi

            # Get Path depending on OS
            case $OS in
            LINUX)
                CONFIG_PATH=$CONFIG_PATH_LINUX
                ;;
            MAC)
                CONFIG_PATH=$CONFIG_PATH_MAC
                ;;
            WINDOWS)
                CONFIG_PATH=$CONFIG_PATH_WINDOWS
                ;;
            esac

            if [[ -z "$CONFIG_PATH" ]]; then
                local_echo "  Not a valid CONFIG_PATH."
                reset
                return 0
            fi

            local_echo "  CONFIG_PATH: $CONFIG_PATH"

            # Delete Link
            if [[ "$DELETE" == "true" ]]; then
                case $OS in
                LINUX | MAC)
                    manage_symlinks --source "$folder_path" --action delete --link "$CONFIG_PATH" --ignore "*.dotfiles.env,dev,.git" $LINK_OPTIONS_STRING
                    ;;
                WINDOWS)
                    # TODO!
                    echo "DELETING THE LINKED FILES IN WINDOWS NEEDS TO BE IMPLEMENTED"
                    exit 1
                    ;;
                esac
                return 0
            fi

            # Create the link
            case $OS in
            LINUX | MAC)
                manage_symlinks --source "$folder_path" --action create --link "$CONFIG_PATH" --ignore "*.dotfiles.env,dev,.git,*.md" $LINK_OPTIONS_STRING
                ;;
            WINDOWS)
                # TODO!
                echo "LINKING THE FILES IN WINDOWS NEEDS TO BE IMPLEMENTED"
                exit 1
                ;;
            esac
        else
            local_echo "Folder: $folder_path"
            local_echo "  No dotfiles.env file found"
        fi

        local_echo ""
        reset
        return 0
    }

    # DEBUG: PRINT provided input.
    local_debug "USER_HOME: $USER_HOME"
    local_debug "CONFIG_HOME: $CONFIG_HOME"
    local_debug "LINK_OPTIONS_STRING: $LINK_OPTIONS_STRING"
    local_debug "SILENT_MODE: $SILENT_MODE"
    local_debug "DEBUG: $DEBUG"
    local_debug "FILTER: $FILTER"
    local_debug "INCLUDE: $INCLUDE"
    local_debug "OS: $OS"
    local_debug "DELETE: $DELETE"
    local_debug "ROOT_DIR_DOTFILES: $ROOT_DIR_DOTFILES"

    # Set HOME to given Config HOME
    HOME="$CONFIG_HOME"

    # Start from root
    loop_folder "$ROOT_DIR_DOTFILES"

    # Reset $HOME to its original value after the script finishes
    HOME="$USER_HOME"
}
