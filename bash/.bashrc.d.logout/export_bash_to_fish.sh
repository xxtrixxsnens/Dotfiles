#!/bin/bash

# GET THE FUNCTION
source "$HOME"/.bashrc

# Wrap the bashrc functions
generate_fish_wrappers -i $HOME/.bashrc.d -o $HOME/.config/fish/bash/bash_wrappers.fish -d

# Export scripts executed during login
generate_fish_wrappers -i $HOME/.bashrc.d.login -c -o $HOME/.config/fish/bash/bash_wrappers_login.fish -d
# Export scripts executed during logout
generate_fish_wrappers -i $HOME/.bashrc.d.logout -c -o $HOME/.config/fish/bash/bash_wrappers_logout.fish -d
