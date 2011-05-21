#!/bin/bash
#########################################
# Write an application configuration.
#########################################


#Get vars from Scalr.
APPLICATION_CONFIG_INI="%application_config_ini%"
FACEBOOK_APP_ID="%facebook_app_id%"
DB_HOST="%db_host%"
DB_NAME="%db_name%"
DB_USERNAME="%db_username%"
DB_PASSWORD="%db_password%"

#Write configuration.
echo "Configuring custom application..."
echo "Writing configuration to $APPLICATION_CONFIG_INI"

(cat <<-ENDOFFILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; Application Configuration
;
; This file has been written by an automated process!
; Manual changes will be lost!
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[production]
phpSettings.display_startup_errors = 0
phpSettings.display_errors = 0
includePaths.library = APPLICATION_PATH "/../library"
bootstrap.path = APPLICATION_PATH "/Bootstrap.php"
bootstrap.class = "Bootstrap"
appnamespace = "Application"
configuration.cache = 0
configuration.theme = "honda"
configuration.base_path =  ""
configuration.facebook_app_id =  $FACEBOOK_APP_ID
configuration.pagination.grid.items_perpage = 6
configuration.pagination.list.items_perpage = 10
resources.modules[]=
resources.db.adapter = "PDO_MYSQL"
resources.db.params.host = "$DB_HOST"
resources.db.params.dbname = "$DB_NAME"
resources.db.params.username = "$DB_USERNAME"
resources.db.params.password = "$DB_PASSWORD"

[testing : production]

[development : production]

ENDOFFILE
) > "$APPLICATION_CONFIG_INI"


