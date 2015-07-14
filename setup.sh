#!/bin/bash

#########################################
# BigBlueButton LDAP authentication app #
# 2015 (c) Spawnidze                    #
#########################################

# If you Tomcat webapps directory not "/var/lib/tomcat7/webapps"
# you need to modify this script

# Copying our app in webapp directory
sudo cp auth.war /var/lib/tomcat7/webapps

# Creating config file
sudo cp /var/lib/tomcat7/webapps/auth/WEB-INF/classes/blank-config.xml /var/lib/tomcat7/webapps/auth/WEB-INF/classes/config.xml

# Copying BBB API
cp /var/lib/tomcat7/webapps/demo/bbb_api_conf.jsp /var/lib/tomcat7/webapps/auth

# Copying nginx rule for our app
sudo cp auth.nginx /etc/bigbluebutton/nginx

# Modifying permissions
chown tomcat7:tomcat7 /var/lib/tomcat7/webapps/auth.war
chmod -x /var/lib/tomcat7/webapps/auth.war
chown -R tomcat7:tomcat7 /var/lib/tomcat7/webapps/auth

# Restarting Tomcat and Nginx
sudo service tomcat7 restart
sudo service nginx restart
