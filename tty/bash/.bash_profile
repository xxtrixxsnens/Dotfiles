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
#
# # Get the profile
# # if [ -f ~/.profile ]; then
# #    . ~/.profile
# # fi

# In this file the user can write there own configs
user_config="$HOME/HOME.$username.config/login"
if [ -d $user_config ]; then
    for rc in $user_config/*; do
        if [ -f "$rc" ]; then
            source "$rc"
        fi
    done
fi
unset rc
