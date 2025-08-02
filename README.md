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
