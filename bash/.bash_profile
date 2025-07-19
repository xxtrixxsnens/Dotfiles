# .bash_profile
# LANGUAGE
export LANG=en_AU.UTF-8

# Get scripts to run at login
if [ -d ~/.bashrc.d.login ]; then
    for rc in ~/.bashrc.d.login/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
# Enable keychain
# eval $(keychain --eval --quiet trison)
. "$HOME/.cargo/env"
