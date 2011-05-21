#!/bin/bash
#############################################################################
# GUI: DEPLOY: Simple SVN: Wordpress
#
# Description: Performs a simple SVN Checkout.
#              Can be useful to avoid the shared directory.
#              Includes specific actions for WP.
# 
# Author: Ticean Bennett 
# Copyright (c) 2010 Guidance Solutions, Inc., All Rights Reserved
#
# TODO: Write the SVN revision, so we can output to REVISION file.
#
# Parameters:
# ------------
#
# $APPLICATION  -- The name of the application.
# $DEPLOY_PATH  -- The deploy path, as in capistrano. Not currently used. 
#                  Assumes /var/www/APPLICATION.
# $SVN_PATH     -- The local path to the subversion binary.
# $SVN_REPO_URL -- The url of the SVN repository.
# $SVN_REVISION -- The SVN revision to deploy.
# $SVN_USERNAME -- The SVN username.
# $SVN_PASSWORD -- The SVN password.
#
#############################################################################
set -e

APPLICATION="%application%"
DEPLOY_PATH="/var/www/%application%"
SVN_PATH="/usr/bin/svn"
SVN_REPO_URL="%svn_repo_url%"
SVN_REVISION="%svn_revision%"
SVN_USERNAME="%svn_username%"
SVN_PASSWORD="%svn_password%"


if [ -z "$SVN_PATH" ]; then
      SVN_PATH="/usr/bin/svn"
fi

echo "Checking if SVN repository exists..."
if [ -z "$SVN_REPO_URL" ]; then 
    echo "SVN respository URL is undefined..."
    echo "Skipping the application deployment."
    exit -1
fi

echo "Checking if SVN revision exists..."
if [ -z "$SVN_REVISION" ]; then 
    echo "SVN revision is not defined..."
    echo "Skipping the application deployment."
    exit -1
fi


## General Preparation
echo "Preparing to deploy..."
echo "Creating directory: $DEPLOY_PATH "
mkdir -p "$DEPLOY_PATH"

## TODO: Get the SVN revision, so we can output to REVISION file.

## If the deploy directory doesn't exist checkout, otherwise update.
if [ ! -e "$DEPLOY_PATH" ] then
    echo "executing svn checkout -q --username $SVN_USERNAME --password XXXXXXXX --no-auth-cache  -r$SVN_REVISION $SVN_REPO_URL $DEPLOY_PATH"
    $SVN_PATH checkout -q --username $SVN_USERNAME --password $SVN_PASSWORD --no-auth-cache  -r$SVN_REVISION $SVN_REPO_URL $DEPLOY_PATH
elif
    echo "executing svn update -q --username $SVN_USERNAME --password XXXXXXXX --no-auth-cache  -r$SVN_REVISION"
    $SVN_PATH update -q --username $SVN_USERNAME --password $SVN_PASSWORD --no-auth-cache  -r$SVN_REVISION
fi

# Check if anything was downloaded - the directory is not empty.
#[ "$(du -s $DEPLOY_PATH| cut -f1)" -gt "8" ] || exit -1


## TODO: Probably don't need to do this. Can at least be more restrictive.
## Release/Deploy date of the application
## echo "Changing ownership 775 on $DEPLOY_PATH..."
## chmod -R 775 "$DEPLOY_PATH"


## -----------------------------------------------------------------------------

## WORDPRESS SPECIFICS
mkdir -p $DEPLOY_PATH/wp-content/uploads
chown -R www-data:www-data $DEPLOY_PATH/wp-content/uploads
chmod -R 775 $DEPLOY_PATH/wp-content/uploads

mkdir -p $DEPLOY_PATH/wp-content/cache
chown root:www-data $DEPLOY_PATH/wp-content/cache
chmod -R 775 $DEPLOY_PATH/wp-content/cache

mkdir -p $DEPLOY_PATH/wp-content/gallery
chown www-data:www-data $DEPLOY_PATH/wp-content/gallery
chmod -R 775 $DEPLOY_PATH/wp-content/gallery

## Assumes configuration files exist in SVN.
## We'll allow it to fail so the site doesn't break.
cp $DEPLOY_PATH/db-settings.production.php $DEPLOY_PATH/db-settings.php
cp $DEPLOY_PATH/wp-config.production.php $DEPLOY_PATH/wp-config.php


## -----------------------------------------------------------------------------

## Link the Apache document root to the current app dir
echo "Linking the Apache document root to the current working application directory..."
[ -h "$current_dir" ] && unlink "$current_dir"
ln -nfs "$apache_doc_pointer" "$current_dir"
