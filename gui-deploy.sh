#!/bin/bash
#############################################################################
# GUI: SVN Deploy Export
#
# Description: Deploys in Capistrano style.
# Author: Ticean Bennett 
# Copyright (c) 2010 Guidance Solutions, Inc., All Rights Reserved
#
# TODO: Get the SVN revision, so we can output to REVISION file.
# TODO: Implement keep_releases functionality, to remove old revision directories.
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

echo "Checking if SVN revision is sets..."
if [ -z "$SVN_REVISION" ]; then 
    echo "SVN revision is not defined..."
    echo "Skipping the application deployment."
    exit -1
fi

## General Variables
deploy_date=$(date "+\%Y\%m\%d\%H\%M\%S")
content_dir="/var/www/$APPLICATION/releases"
current_dir="/var/www/$APPLICATION/current"
deploy_dir="$content_dir/$deploy_date"

## Apache document root (may not necessarily be the deploy_dir)
apache_doc_pointer="$deploy_dir"

## Working directory (may not necessarily be the deploy_dir)
working_dir_pointer="$deploy_dir"


## General Preparation
echo "Preparing to deploy..."
echo "Creating directory: $content_dir "
mkdir -p "$content_dir"
#rm -rf $deploy_dir

## TODO: Get the SVN revision, so we can output to REVISION file.

## Retrieve the code from SVN.
echo "executing svn export -q --username $SVN_USERNAME --password XXXXXXXX --no-auth-cache  -r$SVN_REVISION $SVN_REPO_URL $deploy_dir"
$SVN_PATH export -q --username $SVN_USERNAME --password $SVN_PASSWORD --no-auth-cache  -r$SVN_REVISION $SVN_REPO_URL $deploy_dir
# Check if anything was downloaded - the directory is not empty.
[ "$(du -s $deploy_dir| cut -f1)" -gt "8" ] || exit -1

## Release/Deploy date of the application
echo "Changing ownership 775 on $deploy_dir..."
chmod -R 775 "$deploy_dir"


## Link the Apache document root to the current app dir
echo "Linking the Apache document root to the current working application directory..."
[ -h "$current_dir" ] && unlink "$current_dir"
ln -nfs "$apache_doc_pointer" "$current_dir"
