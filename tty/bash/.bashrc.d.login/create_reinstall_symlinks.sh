#!/bin/bash

create_reinstall_symlinks() {
    local original_script="/home/snens_data/config_all/.bashrc.d.login/symlink_config.sh"
    local output_dir="$HOME/.bashrc.d"
    local output_file="$output_dir/reinstall_symlinks.sh"
    local function_name="reinstall_symlinks"

    if [[ -z "$original_script" || ! -f "$original_script" ]]; then
        echo "❌ Error: Please provide a valid script file to copy and modify."
        return 1
    fi

    mkdir -p "$output_dir"

    {
        echo "#!/bin/bash"
        echo ""
        echo "# This script defines a function to delete symlinks and re-create them using --force."
        echo "$function_name() {"
        echo "    # Check if CONFIG_FILE_PATH is set"
        echo "    if [[ -z \"\$CONFIG_FILE_PATH\" ]]; then"
        echo "        echo '❌ CONFIG_FILE_PATH is not set. Aborting.'"
        echo "        return 1"
        echo "    fi"
        echo ""
        echo "    local ROOT_DIR_DOTFILES"
        echo "    if [[ -f \"\$SCRIPT_DIR/link.sh\" ]]; then"
        echo "        ROOT_DIR_DOTFILES=\"\$SCRIPT_DIR\""
        echo "    else"
        echo "        local current_dir=\"\$SCRIPT_DIR\""
        echo "        while [[ \"\$current_dir\" != \"/\" && ! -f \"\$current_dir/link.sh\" ]]; do"
        echo "            current_dir=\"\$(dirname \"\$current_dir\")\""
        echo "        done"
        echo "        ROOT_DIR_DOTFILES=\"\$current_dir\""
        echo "    fi"
        echo ""
        echo "    source \"\$ROOT_DIR_DOTFILES/bash/.bashrc.d/manage_symlinks.sh\""
        echo "    source \"\$ROOT_DIR_DOTFILES/bash/.bashrc.d/link_dotfiles.sh\""
        echo ""
        echo "    # Confirm the functions were actually sourced"
        echo "    if ! declare -f manage_symlinks >/dev/null; then"
        echo "        echo '❌ Function manage_symlinks not found after sourcing. Aborting.'"
        echo "        return 1"
        echo "    else"
        echo "        echo '✅ Function manage_symlinks loaded.'"
        echo "    fi"
        echo ""
        echo "    if ! declare -f link_dotfiles >/dev/null; then"
        echo "        echo '❌ Function link_dotfiles not found after sourcing. Aborting.'"
        echo "        return 1"
        echo "    else"
        echo "        echo '✅ Function link_dotfiles loaded.'"
        echo "    fi"
        echo ""
        echo "    echo '⚠️ WARNING: This will delete all top-level symlinks in your \$HOME directory.'"
        echo "    read -rp 'Are you sure you want to continue? (yes/no): ' confirm"
        echo "    if [[ \"\$confirm\" != \"yes\" && \"\$confirm\" != \"y\" ]]; then"
        echo "        echo '❌ Operation cancelled.'"
        echo "        return 1"
        echo "    fi"
        echo ""
        echo "    echo '🔁 Deleting top-level symlinks in \$HOME...'"
        echo "    find \"\$HOME\" -maxdepth 1 -type l -exec rm -v {} \;"
        echo ""
        echo "    BASENAME=\$(basename \"\$CONFIG_FILE_PATH\")"
        echo "    ln -s \"\$CONFIG_FILE_PATH\" \"\$HOME/\$BASENAME\""
        echo "    source \"\$CONFIG_FILE_PATH\""
        echo "    link_dotfiles -p $HOME -d --option '-d --force'"
        echo ""

        sed '/^[[:space:]]*manage_symlinks/ s/^\([[:space:]]*manage_symlinks\>\)/\1 --force/' "$original_script" | grep -v '^#!' | sed 's/^/    /'
        echo "    echo 'Completed reinstallation of the symlinks'"
        echo "}"

    } >"$output_file"

    chmod +x "$output_file"
}

create_reinstall_symlinks
