# ~/.bash_logout

# Get scripts to run at login
if [ -d ~/.bashrc.d.logout ]; then
    for rc in ~/.bashrc.d.logout/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc