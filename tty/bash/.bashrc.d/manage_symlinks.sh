#!/bin/bash

# Function to manage the symlinks
manage_symlinks() {
    # DEFAULT VALUES
    local FILTER=*
    local LINK="$HOME"
    local FORCE=0
    local IGNORE_PATTERNS=()
    local SILENT=1
    local ALLOWED_PATH="$HOME/"

    # FUNCTIONS
    # Simple usage info
    usage() {
        echo "Usage: $0 --source <source_folder> --action <create|delete> [options]"
        echo ""
        echo "Options:"
        echo "  --source <source_folder>     Source directory containing files to link"
        echo "  --link <link_folder>         Target directory for symlinks (default: \$HOME)"
        echo "  --filter <pattern>           Filter pattern for files (default: *)"
        echo "  --ignore <pattern1,pattern2> Comma-separated list of patterns to ignore"
        echo "  --action <create|delete>     Action to perform: create or delete"
        echo "  --allowed-path <path>        Restrict deletions to this path (default: \$HOME/)"
        echo "  --force                      Force overwrite existing files/symlinks"
        echo "  --silent, -d                 Disable prompts and extra output"
        echo "  --help                       Show this help message"
        exit 1
    }

    # Create the symlink
    create() {
        # Avoid self-referencing symlinks
        if [ "$(realpath "$ITEM" 2>/dev/null || echo "$ITEM")" == "$(realpath "$LINK_PATH" 2>/dev/null || echo "$LINK_PATH")" ]; then
            [[ $SILENT -eq 1 ]] && echo "Skipping self-referencing symlink: $LINK_PATH"
            return
        fi
        mkdir -p "$(dirname "$LINK_PATH")"
        ln -s "$ITEM" "$LINK_PATH"
        [[ $SILENT -eq 1 ]] && echo "Created symlink: $LINK_PATH -> $ITEM"
    }

    delete_force() {
        local resolved_link_path
        resolved_link_path="$(realpath "$LINK_PATH" 2>/dev/null || echo "$LINK_PATH")"
        local resolved_allowed_path
        resolved_allowed_path="$(realpath "$ALLOWED_PATH" 2>/dev/null || echo "$ALLOWED_PATH")"

        if [[ "$resolved_link_path" == "$resolved_allowed_path"* || true ]]; then
            rm -rf "$LINK_PATH"
            [[ $SILENT -eq 1 ]] && echo "Removed: $LINK_PATH"
            create
        else
            [[ $SILENT -eq 1 ]] && echo "Refusing to delete outside your allowed path ($ALLOWED_PATH): $LINK_PATH"
            return 1
        fi
    }

    # Parse CLI arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --source)
            SOURCE_DIR="$2"
            shift 2
            ;;
        --link)
            LINK="$2"
            shift 2
            ;;
        --filter)
            FILTER="$2"
            shift 2
            ;;
        --ignore)
            IFS=',' read -ra TEMP_PATTERNS <<<"$2"
            IGNORE_PATTERNS+=("${TEMP_PATTERNS[@]}")
            shift 2
            ;;
        --action)
            ACTION="$2"
            shift 2
            ;;
        --allowed-path)
            ALLOWED_PATH="$2"
            shift 2
            ;;
        --force)
            FORCE=1
            shift
            ;;
        --silent | -d)
            SILENT=0
            shift
            ;;
        *)
            [[ $SILENT -eq 1 ]] && echo "Unknown argument: $1"
            usage
            ;;
        esac
    done

    # Validate input
    if [ -z "$SOURCE_DIR" ] || [ -z "$ACTION" ]; then
        usage
    fi

    if [ ! -d "$SOURCE_DIR" ]; then
        [[ $SILENT -eq 1 ]] && echo "Error: Source directory '$SOURCE_DIR' does not exist."
        return 1
    fi

    if [[ "$ACTION" != "create" && "$ACTION" != "delete" ]]; then
        [[ $SILENT -eq 1 ]] && echo "Error: Action must be 'create' or 'delete'."
        return 1
    fi

    shopt -s dotglob
    shopt -s nullglob

    # Execute action
    for ITEM in "$SOURCE_DIR"/$FILTER; do
        BASENAME=$(basename "$ITEM")

        # Skip ignored patterns
        for PATTERN in "${IGNORE_PATTERNS[@]}"; do
            if [[ "$BASENAME" == $PATTERN ]]; then
                [[ $SILENT -eq 1 ]] && echo "Ignoring: $BASENAME"
                continue 2 # skip to next ITEM
            fi
        done

        LINK_PATH="$LINK/$BASENAME"

        # CREATE
        if [ "$ACTION" == "create" ]; then
            if [ -e "$LINK_PATH" ] || [ -L "$LINK_PATH" ]; then
                # PATH EXISTS
                if [ "$FORCE" -eq 1 ]; then
                    # ASK TO DELETE
                    if [ $SILENT -eq 1 ]; then
                        # ASK USER
                        echo "Conflict: $LINK_PATH already exists."
                        read -p "Do you want to remove it and replace with symlink? [y/N] " CONFIRM
                    else
                        # NO PROMPTING
                        CONFIRM=y
                    fi
                    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
                        delete_force
                        create
                    else
                        [[ $SILENT -eq 1 ]] && echo "Skipping: $LINK_PATH"
                        continue
                    fi
                else
                    # SKIPPING
                    [[ $SILENT -eq 1 ]] && echo "Skipping (Already exists): $LINK_PATH"
                fi
            else
                # CREATE
                create
            fi

        # DELETE
        elif [ "$ACTION" == "delete" ]; then
            if [ -L "$LINK_PATH" ]; then
                rm "$LINK_PATH"
                [[ $SILENT -eq 1 ]] && echo "Deleted symlink: $LINK_PATH"
            else
                [[ $SILENT -eq 1 ]] && echo "Skipping (not a symlink): $LINK_PATH"
            fi
        fi
    done

    [[ $SILENT -eq 1 ]] && echo "Done."
    return 0
}
