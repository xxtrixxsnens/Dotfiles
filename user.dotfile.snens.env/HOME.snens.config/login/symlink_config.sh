# YOU SCRIPT WILL BE EXECUTED BY ANOTHER SCRIPT ~/.bashrc.d.login/.symlink_config.sh
# It will be used to configure specific Configuration only for that user.

# CONFIG FILE FOR MY SYMLINKS
# LINKING FOLDERS
manage_symlinks --source $FOLDER_HOME --action create --link $USER_HOME -d

# LINKING SECRETS TO CONFIGURATIONS
#
# SSH
manage_symlinks --source $SECRETS_HOME/.ssh --action create --link $CONFIG_HOME/.ssh -d
