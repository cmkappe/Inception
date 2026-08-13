#!/bin/bash

# Docker starts container
#        |
#        ▼
# setup.sh
#        |
#        ▼
# Is WordPress already installed?
#        |
#   ┌────┴────┐
#   no        yes
#   |         |
#   ▼         ▼
# Download    Skip installation
# WordPress
#   |
#   ▼
# Create wp-config.php
#   |
#   ▼
# Start php-fpm


# "If anything fails, stop immediately."
set -e

echo "WordPress setup started"


# PHP-FPM needs this directory for runtime files
# similar to MariaDB needing /run/mysqld for its socket
mkdir -p /run/php


# wp-config.php is the configuration file that connects
# WordPress to MariaDB.
#
# If it exists:
#     WordPress was already installed
#
# If it does not exist:
#     first startup -> download and configure WordPress
# 'if [ ! -f "/var/www/html/wp-config.php" ] || [ ! -f "/var/www/html/index.php" ]; then' -> checks for WordPress configs & if file exists 
if [ ! -f "/var/www/html/wp-config.php" ] || [ ! -f "/var/www/html/index.php" ]; then

    echo "Downloading WordPress..."


    # WordPress files will live here
    mkdir -p /var/www/html

    cd /var/www/html


    # Download the official WordPress archive
    curl -O https://wordpress.org/latest.tar.gz


    # Extracts:
    #
    # latest.tar.gz
    #       |
    #       ▼
    # wordpress/
    #       |
    #       ├── wp-admin
    #       ├── wp-content
    #       └── wp-includes
    tar -xzf latest.tar.gz


    # Move WordPress files from:
    #
    # /var/www/html/wordpress/
    #
    # to:
    #
    # /var/www/html/
    #
    # because nginx/php-fpm should serve directly from html
    mv wordpress/* .


    # Remove downloaded archive and empty folder
    rm -rf wordpress latest.tar.gz



    echo "Creating wp-config.php..."


    # WordPress provides a template:
    #
    # wp-config-sample.php
    #
    # We copy it and replace placeholders
    # with our Docker environment variables
    cp wp-config-sample.php wp-config.php


    # Replace database settings inside wp-config.php
    #
    # Example:
    #
    # database_name_here
    #          |
    #          ▼
    # wordpress
    #
    # The backticks are escaped because the variables
    # are inserted into SQL/PHP configuration text.
    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php

    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php

    sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php


    # IMPORTANT:
    #
    # localhost would mean:
    #
    # WordPress container
    #        |
    #        X
    #        |
    #        MariaDB
    #
    # Instead Docker DNS lets us use the service name:
    #
    # wordpress container
    #        |
    #        |
    #     mariadb container
    #
    sed -i "s/localhost/${MYSQL_HOST}/" wp-config.php

fi



echo "Starting PHP-FPM..."


# PHP-FPM normally runs as a background daemon.
#
# Docker containers should keep the main process
# in the foreground, otherwise Docker thinks the
# container has stopped.
#
# exec replaces this shell process:
#
# PID 1
#  |
#  └── bash
#       |
#       └── php-fpm
#
# becomes:
#
# PID 1
#  |
#  └── php-fpm
#
# -F = foreground mode
exec php-fpm7.4 -F
