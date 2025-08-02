#!/bin/bash

# Source the necessary command
SCRIPT_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_PATH/tty/bash/.bashrc.d/link_dotfiles.sh

# Link the files / folders in the subfolders of the
# Dotfiles Folder to your $HOME or where you store all your Dotfiles

# A .env file needs to have CONFIG_PATH set.
# bash for example has ```CONFIG_PATH="$HOME"```
# because its config needs to be stored at the $HOME directory.
#
# link_dotfiles [path]
# path: Where your config files should reside ($HOME, but maybe you have them somewhere else and do from that place a symlink)
# Creates a symlink to that path.
link_dotfiles -p /home/snens_arch/ --ignore "/etc*,wlogout,swaylock,qt5ct,nvim,hyprpaper" --include "*" --force
