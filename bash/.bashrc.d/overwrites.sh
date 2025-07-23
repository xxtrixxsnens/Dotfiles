if ! command -v gvim &>/dev/null; then
    # Define the fallback function
    gvim() {
        # VIM should be installed!
        vim "$@"
    }
fi
