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
        echo "function $function_name() {"
        echo "  echo '⚠️ WARNING: This will delete all top-level symlinks in your \$HOME directory.'"
        echo "  read -rp 'Are you sure you want to continue? (yes/no): ' confirm"
        echo "  if [[ \"\$confirm\" != \"yes\" && \"\$confirm\" != \"y\" ]]; then"
        echo "    echo '❌ Operation cancelled.'"
        echo "    return 1"
        echo "  fi"
        echo ""
        echo "  echo '🔁 Deleting top-level symlinks in \$HOME...'"
        echo '  find "$HOME" -maxdepth 1 -type l -exec rm -v {} \;'
        echo ""
        # Indent the original script and replace `-d` with `--force`, skip shebang
        sed 's/ -d/ --force/g' "$original_script" | grep -v '^#!' | sed 's/^/  /'
        echo "}"
    } >"$output_file"

    chmod +x "$output_file"
}

create_reinstall_symlinks
