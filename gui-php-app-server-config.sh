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


echo "Enabling Apache modul: headers"
a2enmod headers

echo "Enabling Apache module: expires"
a2enmod expires  

echo "Enabling Apache module: deflate"
a2enmod deflate

echo "Writing configuration file for Apache module: deflate"
cat > /etc/apache2/mods-available/deflate.conf <<EOF
<IfModule mod_deflate.c>
  SetOutputFilter DEFLATE
  SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png)$ \
    no-gzip dont-vary
  SetEnvIfNoCase Request_URI \
    \.(?:exe|t?gz|zip|bz2|sit|rar)$ \
    no-gzip dont-vary
  SetEnvIfNoCase Request_URI \.pdf$ no-gzip dont-vary

  BrowserMatch ^Mozilla/4 gzip-only-text/html
  BrowserMatch ^Mozilla/4\.0[678] no-gzip
  BrowserMatch \bMSIE !no-gzip !gzip-only-text/html
</IfModule>
EOF


echo "Restarting Apache..."
/etc/init.d/apache2 restart
