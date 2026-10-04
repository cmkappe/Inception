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

# Docker mounts secrets as files under /run/secrets/
# Read the password values from those files into shell variables
# so the setup script can use them when installing WordPress
# and creating the second user.
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_SECOND_PASSWORD=$(cat /run/secrets/wp_second_password)

echo "WordPress setup started"

WORDPRESS_PATH="/var/www/html"

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
if [ ! -f "$WORDPRESS_PATH/wp-config.php" ] || [ ! -f "$WORDPRESS_PATH/index.php" ]; then

    echo "Downloading WordPress..."


    # WordPress files will live here
    mkdir -p "$WORDPRESS_PATH"

    cd "$WORDPRESS_PATH"


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
    # We copy it and replace placeholders with the database values provided by Docker (eg passwords live in secrets)
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
    # Replace the database placeholders with the values provided through the Docker environment
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

# runtime readiness check
# keep asking MariaDB "are you alive and accepting connections?" until it says yes
echo "Waiting for MariaDB..."

# --silent suppresses normal successful output ("mysqld is alive")
until mysqladmin ping \
    -h"$MYSQL_HOST" \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    --silent; do
    sleep 1
done

echo "MariaDB is ready."


# Check if wordpress is actually installed
# 
# wp-config.php existing only means that wordpress has been configured to connect to MariaDB
#
# It does NOT mean that wordpress has already created its
# database tables or completed the wordpress installation
#
# wp core is-installed checks whether the wordpress database
# tables and installation exist.
#
#     installed      -> false -> ! makes it true
#     not installed  -> true
#
# --allow-root allows WP-CLI to run as root inside the container.
cd "$WORDPRESS_PATH"
if ! wp --path="$WORDPRESS_PATH" core is-installed --allow-root; then

    echo "Installing WordPress..."

    wp --path="$WORDPRESS_PATH" core install \
        --url="${DOMAIN_NAME}" \
        --title="Inception WordPress" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root


    echo "Creating second WordPress user..."

    wp --path="$WORDPRESS_PATH" user create \
        "${WP_SECOND_USER}" \
        "${WP_SECOND_EMAIL}" \
        --user_pass="${WP_SECOND_PASSWORD}" \
        --role=subscriber \
        --allow-root

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
