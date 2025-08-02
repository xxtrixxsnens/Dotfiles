# Dotfiles

This repository stores all my Dotfiles.

## Structure
Folders to specific programs are placed in the root of the repository.
There you can then write and save your Dotfiles for that program.

You can link the files easily with ``link.sh`` after adjusting the path for your needs. (To use $HOME just remove my custom value)

What to look for:
- To function, the ``link.sh`` file needs scripts in this bash configuration. => So do not remove it.
- Every subfolder needs to include a ``*.dotfiles.env`` file so that ``link.sh`` knows where to create the link.

    Examples:
    ~ /bash/bash.dotfiles.env
    ```
    CONFIG_PATH_LINUX="$HOME"
    CONFIG_PATH_MAC="$HOME"
    CONFIG_PATH_WINDOWS="/DEV"
    ```

    ~ /fish/dotfiles.env
    ```
    CONFIG_RECURSIVE="true"
    ```

Having no ``.env`` file will just skip that folder.

## Definiton of ``*.dotfiles.env``
CONFIG_RECURSIVE="true" => Searches subdirectories for ``*.dotfiles.env``.
CONFIG_PATH_* => The Path for linking the dotfiles.

## Customize the configuration with "HOME.USERNAME.env"
This file should be located in the $HOME directory.
Further modifications for custom scripts that will be triggered by ones here 
will be in ``HOME.USERNAME.config`` . An example is in ``bash/.basrc.d.login/sym_config.sh``

Example for ``HOME.USERNAME.env``
```
# Path to this File // For reinstallation purposes // Should always be set if it is a symlink.
setenv CONFIG_FILE_PATH "$HOME"

# Path to the User Home
setenv USER_HOME "$HOME"

# Path to the Config Home
setenv CONFIG_HOME "/home/config"
```

## A dev file to configure new user enviroments:
```bash
#!/bin/bash
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
# Determine the project root directory where 'link.sh' is located.
# This assumes 'link.sh' is directly in the root, and this script
# (link_dotfiles.sh) is within a subdirectory like 'scripts/link_dotfiles.sh'.
if [[ -f "$SCRIPT_DIR/link.sh" ]]; then
    ROOT_DIR_DOTFILES="$SCRIPT_DIR"
else
    # Navigate up until link.sh is found, or assume parent is root.
    current_dir="$SCRIPT_DIR"
    while [[ "$current_dir" != "/" && ! -f "$current_dir/link.sh" ]]; do
        current_dir="$(dirname "$current_dir")"
    done
    ROOT_DIR_DOTFILES="$current_dir"
fi

## Source the Config
source "$ROOT_DIR_DOTFILES"/bash/.bashrc.d/utilities.sh
source "$SCRIPT_DIR"/HOME.<USERNAME>.env

# Link this env file to the HOME dir
rm -f $USER_HOME/HOME.<USERNAME>.env
ln -s $SCRIPT_PATH/HOME.<USERNAME>.env $USER_HOME/HOME.<USERNAME>.env

# Create the links to this config
source "$ROOT_DIR_DOTFILES"/bash/.bashrc.d/link_dotfiles.sh
link_dotfiles --option '-d --force' -d

# Create the reinstall script
source "$ROOT_DIR_DOTFILES"/bash/.bashrc.d.login/create_reinstall_symlinks.sh

# Now can normally source
source "$HOME"/.bashrc

# Run the reinstall script
reinstall_symlinks
```
