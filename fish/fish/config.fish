### Get Enviroment Variables
# Function to mimic bash's export for sourcing
function setenv
    set -gx $argv
end

# Get Enviroment configuration
if test -f ~/HOME.snens.env
    source ~/HOME.snens.env
end

# Get locale
source ~/.config/fish/env/locale.fish

# Get general
source ~/.config/fish/env/general.fish

# Get ssh agent
source ~/.config/fish/env/ssh-agent.fish

if status is-interactive
    # Get the key bindings
    source ~/.config/fish/bindings/modified_vi_bindings.fish

    # Get the bash configuration and functions
    source ~/.bash_aliases
    source ~/.config/fish/bash/bash_wrappers.fish
    source ~/.config/fish/bash/bash_wrappers_login.fish
    source ~/.config/fish/bash/bash_wrappers_logout.fish
    # Commands to run in interactive sessions can go here
end
