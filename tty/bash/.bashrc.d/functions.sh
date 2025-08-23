### CONFIGURATION MANAGEMENT
# Function to mimic fish's setenv for sourcing
function setenv() {
    export "$1=$2"
}

configuration_enviroment() {
    # Get my Configuration Enviroment Variables
    username=$(whoami)
    enviroment_path="$HOME/HOME.$username.env"
    logfile="$HOME/home_env_check.log"

    if [[ -f "$enviroment_path" ]]; then
        source $enviroment_path
    else
        {
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ Missing file: $enviroment_path"
            echo "Reason: Expected environment config for managing the Home partition and different User Configurations on different distros."
            echo
        } >>"$logfile"
        return 1
    fi
}

startvm_services() {
    /usr/bin/sudo /usr/bin/systemctl enable --now virtqemud.socket
    /usr/bin/sudo /usr/bin/systemctl enable --now virtlogd.socket
    /usr/bin/sudo /usr/bin/systemctl enable --now virtproxyd.socket
    /usr/bin/sudo /usr/bin/systemctl enable --now virtnetworkd.socket
    /usr/bin/sudo /usr/bin/systemctl enable --now virtstoraged.socket
    #/usr/bin/sudo /usr/bin/systemctl start libvirtd.service
    #/usr/bin/sudo /usr/bin/systemctl start virtqemud.service
    /usr/bin/sudo /usr/bin/virsh net-start default
}

stopvm_services() {
    /usr/bin/sudo /usr/bin/virsh net-destroy default
    /usr/bin/sudo /usr/bin/systemctl disable --now virtstoraged.socket
    /usr/bin/sudo /usr/bin/systemctl disable --now virtnetworkd.socket
    /usr/bin/sudo /usr/bin/systemctl disable --now virtproxyd.socket
    /usr/bin/sudo /usr/bin/systemctl disable --now virtlogd.socket
    /usr/bin/sudo /usr/bin/systemctl disable --now virtqemud.socket
    /usr/bin/sudo /usr/bin/systemctl stop libvirtd.service
    /usr/bin/sudo /usr/bin/systemctl stop virtqemud.service
}

### /usr/bin/sudoCLIPBOARD
# Get Output to the Clipboard
tee_clipboard() {
    local debug=0
    local clipboard_tool=""
    local output

    if [[ "$1" == "--debug" ]]; then
        debug=1
        shift
    fi

    # Read command output from stdin
    output=$(cat)

    # Check available clipboard tools
    if command -v xsel &>/dev/null; then
        clipboard_tool="xsel --clipboard --input"
    elif [[ -n "$KITTY_WINDOW_ID" ]] && kitty +kitten clipboard <<<"" &>/dev/null; then
        # We're in Kitty and kitten clipboard works
        clipboard_tool="kitty +kitten clipboard"
    elif command -v wl-copy &>/dev/null; then
        clipboard_tool="wl-copy"
    elif command -v xclip &>/dev/null; then
        clipboard_tool="xclip -selection clipboard"
    elif command -v pbcopy &>/dev/null; then
        clipboard_tool="pbcopy"
    fi

    # Output to terminal
    echo "$output"

    # Copy to clipboard if a tool is available
    if [[ -n "$clipboard_tool" ]]; then
        echo "$output" | eval "$clipboard_tool"
        if ((debug)); then
            echo "[DEBUG] Used clipboard tool: $clipboard_tool" >&2
        fi
    else
        echo "⚠️ No supported clipboard tool found." >&2
    fi
}

ctee() {
    "$@" | tee_clipboard
}

### DISPLAY PRINTED TERMINAL BETTER
### Better navigate help pages with hilf and hman!
see() {
    "$@" >/tmp/see
    $EDITOR /tmp/see
}

hilf() {
    "$@" --help >/tmp/hilf
    $EDITOR /tmp/hilf
}

hman() {
    man "$1" >/tmp/hman
    $EDITOR /tmp/hman
}

### Utilites
# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Write iso file to sd card
iso2sd() {
    if [ $# -ne 2 ]; then
        echo "Usage: iso2sd <input_file> <output_device>"
        echo "Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
        echo -e "\nAvailable SD cards:"
        lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
    else
        sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
        sudo eject $2
    fi
}

# Create a desktop launcher for a web app
web2app() {
    if [ "$#" -ne 3 ]; then
        echo "Usage: web2app <AppName> <AppURL> <IconURL> (IconURL must be in PNG -- use https://dashboardicons.com)"
        return 1
    fi

    local APP_NAME="$1"
    local APP_URL="$2"
    local ICON_URL="$3"
    local ICON_DIR="$HOME/.local/share/applications/icons"
    local DESKTOP_FILE="$HOME/.local/share/applications/${APP_NAME}.desktop"
    local ICON_PATH="${ICON_DIR}/${APP_NAME}.png"

    mkdir -p "$ICON_DIR"

    if ! curl -sL -o "$ICON_PATH" "$ICON_URL"; then
        echo "Error: Failed to download icon."
        return 1
    fi

    cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=chromium --new-window --ozone-platform=wayland --app="$APP_URL" --name="$APP_NAME" --class="$APP_NAME"
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
EOF

    chmod +x "$DESKTOP_FILE"
}

web2app_remove() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: web2app-remove <AppName>"
        return 1
    fi

    local APP_NAME="$1"
    local ICON_DIR="$HOME/.local/share/applications/icons"
    local DESKTOP_FILE="$HOME/.local/share/applications/${APP_NAME}.desktop"
    local ICON_PATH="${ICON_DIR}/${APP_NAME}.png"

    rm "$DESKTOP_FILE"
    rm "$ICON_PATH"
}

mount_sftp() {
    if [ "$#" -ne 3 ]; then
        echo "Usage: mount_sftp <MOUNT_PATH> <REMOTE_ADDRESS> <REMOTE_SSH_CONNECTION>"
        return 1
    fi

    local MOUNT_PATH="$1"
    local REMOTE_SSH_CONNECTION="$2"
    local REMOTE_ADDRESS="$3"

    local SLEEP_TIME=5
    # Wait for a Response by pinging host
    until ping -c1 $REMOTE_ADDRESS &>/dev/null; do
        sleep $SLEEP_TIME
        $SLEEP_TIME=$(($SLEEP_TIME * 2))
    done

    # Now mount
    sshfs $REMOTE_SSH_CONNECTION "$MOUNT_PATH" \
        -o reconnect \
        -o ServerAliveInterval=15 \
        -o ServerAliveCountMax=3 \
        -o idmap=user \
        -o StrictHostKeyChecking=no
}
