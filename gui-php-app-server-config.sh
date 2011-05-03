#!/bin/bash
#############################################################################
# GUI: Enable Required Packages
#
# Description: Install required modules for PHP app server.
# Author: Ticean Bennett 
# Copyright (c) 2010 Guidance Solutions, Inc., All Rights Reserved
#
##############################################################################

echo "Installing Subversion..."
apt-get install subversion -y


echo "Installing MySQL Client..."
apt-get install mysql-client-5.1 -y


echo "Installing PHP & MySql support..."
apt-get install php5-mysql -y

echo "Installing PHP-CURL..."
apt-get install curl libcurl3 libcurl3-dev php5-curl php5-mcrypt -y

echo "Installing PHP GD"
apt-get install php5-gd -y

echo "Enabling mod_rewrite..."
test -f "/etc/apache2/mods-available/rewrite.load" && ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

echo "Restarting Apache..."
/etc/init.d/apache2 restart
