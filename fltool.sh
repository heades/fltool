 #!/bin/bash
#
# Author: Harley Eades 
#
# This script provides functions for helping to create a large number of Fossil repos for
# a course. 

# Flags
HELP=-h         # The help message.
INIT=-t         # Initialize.
IMPORT=-i       # Import.
EXPORT=-e       # Export.
IE=-ie          # Export then Import in one shot.
USER_FLAG=-u    # Set a group of users.
SETTING_FLAG=-s # Set some nice settings.

# Inits a set of dirs as Fossil repos.
function fl_init {
  REPOS_PATH=$1;     # Get the path to the fossil repos.
  REPO_PAT=$2;       # The repo name.
  OUTPUT=$3;         # The place the user wants to store the output. 
                     # OUTPUT must be absolute.

  for i in $(ls $REPOS_PATH) 
  do
      R_PATH=$REPOS_PATH/$i/$REPO_PAT
      echo "Repo: $R_PATH" >> $OUTPUT
      fossil init "$R_PATH" >> $OUTPUT
      echo >> $OUTPUT
      echo >> $OUTPUT
  done
}

# Exports a configuration triggered by the $EXPORT flag.
function fl_export {
    REPO_PATH=$1;      # Get the path to the fossil repo.
    CONFIG_PATH=$2;    # Get the path to the config.

    echo "Exporting the configuration of $REPO_PATH to $CONFIG_PATH"
    fossil configuration export all $CONFIG_PATH -R $REPO_PATH
    echo "done"
}

# Imports a configuration triggered by the $IMPORT flag.
function fl_import {    
    REPOS_PATH=$1;     # Get the path to the fossil repos.
    REPO_PAT=$2;       # The repo name.
    CONFIG_PATH=$3;    # Get the path to the config.

    for i in $(ls $REPOS_PATH) 
    do
        echo "Importing the given configuration into the repo: $i";
        fossil configuration merge $CONFIG_PATH -R "$REPOS_PATH/$i/$REPO_PAT"
        echo "done"
    done
}

# Adds all users in a USER config file.  
# This function is triggered by $USER
function fl_add_users {
    USER_CFG=$1
    for l in $(cat $USER_CFG)
    do
        # 0 - Repo Path
        # 1 - Username
        # 2 - Email
        # 3 - Password
        # 4 - Permissions
        a=($(echo $l | sed -e 's/:/ /g'));

        # Create the user.
        fossil user new ${a[1]} ${a[2]} ${a[3]} -R ${a[0]} > /dev/null
        # Set their permissions.
        fossil user capabilities ${a[1]} ${a[4]} -R ${a[0]} > /dev/null
    done
}

# Exports a Fossil repo config and then imports it into a dir of Fossil repos.
function fl_ie {
    REPO_PATH=$1
    CONFIG_PATH=$2
    REPOS_PATH=$3
    REPO_PAT=$4

    fl_export $REPO_PATH $CONFIG_PATH
    fl_import $REPOS_PATH $REPO_PAT $CONFIG_PATH
}

function fl_settings {
    REPOS_PATH=$1
    REPO_PAT=$2
    HEAD="fossil settings"

    for i in $(ls $REPOS_PATH) 
    do
        TAIL="-R $REPOS_PATH/$i/$REPO_PAT"

        # Set local auth.
        $HEAD localauth 1 $TAIL
        # Enable captcha.
        $HEAD auto-captcha 1 $TAIL        
    done
}

function help_msg {
    echo "The Fossil Tool for Courses.";
    echo;
    echo "Possible operations: ";
    echo "$INIT repos_path repo_pat output_path              Initialize all the dirs in repos_path as a Fossil repo named repo_pat
                                                and dump all the output into output_path. The output_path must be *absolute*.";
    echo;
    echo "$IMPORT repos_path repo_pat config_path              Import the configuration specified by config_path into all the 
                                                Fossil repos under repos_path named repo_pat existing values in the destination repo are retained.";
    echo;
    echo "$EXPORT repo_path config_path                        Export the configuration of the Fossil repo repo_path and save it as config_path.";
    echo;
    echo "$IE repo_path config_path repos_path repo_pat   Exports the configuration of repo_path, saves it as config_path, and imports the 
                                                configuration into all the Fossil repos under repos_path named repo_pat."
    echo;
    echo "$USER_FLAG user_cfg_path                                Creates all the users specified in the user config user_cfg.";
    echo;
    echo "$SETTING_FLAG repos_path repo_pat                          Enables local auth. and captcha for all repos under repos_path named repo_pat.";
    exit 0;    
}

# The start begins here >:-} .
if [ $HELP = $1 ] 
then
    help_msg
elif [ $IMPORT = $1 ] 
then
    fl_import $2 $3 $4
elif [ $EXPORT = $1 ] 
then
    fl_export $2 $3
elif [ $INIT = $1 ] 
then
    fl_init $2 $3 $4
elif [ $USER_FLAG = $1 ] 
then
    fl_add_users $2
elif [ $IE = $1 ]
then
    fl_ie $2 $3 $4 $5
elif [ $SETTING_FLAG = $1 ] 
then
    fl_settings $2 $3
else
    help_msg
fi
