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

### CLIPBOARD
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
    "$@" >>/tmp/see
    nvim /tmp/see
}

hilf() {
    "$@" --help >>/tmp/hilf
    $EDITOR /tmp/hilf
}

hman() {
    man "$1" >>/tmp/hman
    $EDITOR /tmp/hman
}
