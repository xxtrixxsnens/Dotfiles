# Dotfiles

This repository stores all my Dotfiles.

## Structure
Folders to specific programs are placed in the root of the repository.
There you can then write and save your Dotfiles for that program.

You can link the files easily with ``link.sh`` after adjusting the path for your needs. (To use $HOME just remove my custom value)

What to look for:
- To function, the ``link.sh`` file needs scripts in this bash configuration. => So do not remove it.
- Every subfolder needs to include a ``.env`` file so that ``link.sh`` knows where to create the link.

    Examples:
    ~ /bash/bash.env
    ```
    CONFIG_PATH="$HOME"
    ```

    ~ /fish/fish.env
    ```
    CONFIG_PATH="$HOME/.config"
    ```

Having no ``.env`` file will just skip that folder.
