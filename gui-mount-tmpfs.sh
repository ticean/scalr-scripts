#!/bin/bash
#############################################################################
#
# Description: Creates a TMPFS mount. 
#              Deletes any existing content in mount location.
# 
# Author: Ticean Bennett 
# Copyright (c) 2010 Guidance Solutions, Inc., All Rights Reserved
#
# Parameters:
# ------------
# $MOUNT_PATH   -- The path at which the mount is created.
# $VOL_SIZE     -- The size of the memory volume. (ex: 500M)
# $MODE         -- The ownership mode of the volume (ex: 0755)
#
#############################################################################
set -e

MOUNT_PATH="%mount_path%"
SIZE="%size%"
MODE="%mode%"

# Detect existing mount.
if [ ! $(mount | grep -c "$MOUNT_PATH ") -eq 0 ]; then
    echo "A mount already exists at $MOUNT_PATH"
else
    echo "Creating the mount path: $MOUNT_PATH"
    mkdir -p "$MOUNT_PATH"

    #echo "Making sure mount path is empty: rm -Rf $MOUNT_PATH"
    #rm -Rf "$MOUNT_PATH/*"

    echo "Mounting TMPFS"
    mount -t tmpfs -o size=$SIZE,mode=$MODE tmpfs "$MOUNT_PATH"
fi
