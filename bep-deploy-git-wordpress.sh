#!/bin/bash
#############################################################################
#
# Description: Performs a Git clone or pull.
#              Includes specific actions for WP.
# 
# Author: Ticean Bennett 
# Thanks to Wayne E. Seguin, and the BDSM teleportation from the future.
# @see https://github.com/wayneeseguin/bdsm-extensions/blob/master/deploy/modules/bash/dsl
#
# Assumptions:
#   - Git is installed.
#   - If required, appropriate keys exist for git user.
#
# Parameters:
# ------------
# $STAGE           -- Active stage. Used to copy configurations.
# $DEPLOY_TO       -- The web root, or folder to which to clone.
# $GIT_REPOSITORY  -- The git repository to clone/pull.
# $GIT_BRANCH      -- The branch to clone/pull.
#############################################################################

STAGE="%stage%"
DEPLOY_TO="%deploy_to%"
GIT_REPOSITORY="%repository%"
GIT_BRANCH="%branch%"
GIT_REMOTE="origin"
REVISION="%revision%"
#GIT_PATH="/usr/bin/git"


## Make sure deploy directory exists:
mkdir -p "$DEPLOY_TO"
cd "$DEPLOY_TO"



## Git Clone -------------------------------------------------------------------

## If .git directory doesn't exist, clone.
if [ ! -d "$DEPLOY_TO"/.git ]; then
    echo "No git repository detected at '$DEPLOY_TO/.git'"
    if [ $(ls -1A | wc -l) -eq 0 ]; then
        echo "Cloning Git repository."
        echo "git clone -q \"$GIT_REPOSITORY\" \"$DEPLOY_TO\""
        git clone -q "$GIT_REPOSITORY" "$DEPLOY_TO"
    else
        echo "Target clone directory is not empty. Cannot clone. '$DEPLOY_TO'" 1>&2
        exit 1
    fi
fi


## Git Checkout ----------------------------------------------------------------
#echo "Do checkout of master."
#git checkout master -f -q

# There should be *no* changes to the pristine repo.
echo "Ensure pristine copy. Executing 'git reset --hard'."
git reset --hard HEAD 2>/dev/null

echo "Pulling updates from $GIT_REMOTE"
git fetch $GIT_REMOTE

current_branch=$(git branch | awk '/\* /{print $2}')
#current_branch=$(git symbolic-ref -q HEAD 2>/dev/null)
if [[ "$current_branch" = "$GIT_BRANCH" ]]
then
    echo "Already on branch '$GIT_BRANCH'."
elif ! git branch | awk "/$GIT_BRANCH$/" >/dev/null 2>&1
then
    echo "Checkout of branch '$GIT_BRANCH'"
    git checkout -b $GIT_BRANCH --track $GIT_REMOTE/$GIT_BRANCH 2>/dev/null

elif ! git checkout $GIT_BRANCH 2>/dev/null
then
    echo "Branch '$GIT_REMOTE/$GIT_BRANCH' not found. Skipping remainder of update." 1>&2
    exit 1
fi

git pull

## Get submodules, if exist.
if [ -e ".gitmodules" ]
then
    echo "Updating submodules."
    git submodule init 2>/dev/null
    git submodule update
fi


# Get specific revision if provided.
if [[ -n "$REVISION" ]]
then
    echo "Checking out revision '$REVISION'."
    git checkout $REVISION >/dev/null 2>&1
fi




## -----------------------------------------------------------------------------
## WORDPRESS SPECIFICS

DEPLOY_PATH="$DEPLOY_TO"

echo "Changing ownership 775 on $DEPLOY_PATH..."
chmod -R 775 "$DEPLOY_PATH"

mkdir -p $DEPLOY_PATH/wp-content/uploads
chown -R :www-data $DEPLOY_PATH/wp-content/uploads
chmod -R 775 $DEPLOY_PATH/wp-content/uploads

mkdir -p $DEPLOY_PATH/wp-content/cache
chown :www-data $DEPLOY_PATH/wp-content/cache
chmod -R 775 $DEPLOY_PATH/wp-content/cache

mkdir -p $DEPLOY_PATH/wp-content/gallery
chown :www-data $DEPLOY_PATH/wp-content/gallery
chmod -R 775 $DEPLOY_PATH/wp-content/gallery


## Copy configuration files.

if [ -e "$DEPLOY_PATH/wp-config.$STAGE.php" ]; then
    cp "$DEPLOY_PATH/wp-config.$STAGE.php" "$DEPLOY_PATH/wp-config.php"
else
    echo "Wordpress wp-config file doesn't exist for stage. Expected: $DEPLOY_PATH/wp-config.$STAGE.php" 1>&2
fi

# Copy db-settings.
if [ -e "$DEPLOY_PATH/db-settings.$STAGE.php" ]; then
    cp "$DEPLOY_PATH/db-settings.$STAGE.php" "$DEPLOY_PATH/db-settings.php"
else 
    echo "Wordpress db-settings file doesn't exist for stage. Expected: '$DEPLOY_PATH/db-settings.$STAGE.php'" 1>&2
fi





