#!/bin/bash

#    Docker starts container
#            │
#            ▼
#    setup.sh
#            │
#            ▼
#    Has MariaDB been initialized?
#            │
#    ┌────┴────┐
#    │         │
#    no        yes
#    │         │
#    ▼         ▼
#    Initialize   Start MariaDB
#    │
#    ▼
#    Create database
#    Create user
#    Grant privileges
#    │
#    ▼
#    Start MariaDB


# "If anything fails, stop immediately."
set -e

# Docker mounts secrets as files under /run/secrets/
# Read the password values from those files into shell variables so the setup script can use them when creating the database/user
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)


# Make sure the password secrets are not empty.
# -z checks whether the string has a length of zero
if [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "ERROR: Mysql passwords must not be empty."
    exit 1
fi

echo "MariaDB setup script started"

# make sure MariaDB owns its data and runtime directories
# chown = change owner
# -R = recursive, so every subfolder/file gets checked
chown -R mysql:mysql /run/mysqld /var/lib/mysql


# -d checks if directory exists // /var/lib/mysql/ contains mariadb data // -z asks if directory is emtpy
# if the mysql system database does not exist OR the data directory is empty, this is the first startup of MariaDB
if [ ! -d "/var/lib/mysql/mysql" ] || [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "----- First startup of MariaDB detected -----"

    # creates internal system tables
    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql

    # Create an SQL file containing the commands that should run
    # when the temporary MariaDB server starts
    #
    # --init-file tells MariaDB to execute this file during startup.
    # Unlike --bootstrap, MariaDB starts normally here, so
    # CREATE USER, GRANT and ALTER USER can be executed.

    # SHUTDOWN tells the temporary MariaDB server to stop after all initialization commands have been executed.
    cat > /tmp/mariadb-init.sql <<EOF

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES
ON \`${MYSQL_DATABASE}\`.*
TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;

SHUTDOWN;

EOF

    echo "----- Starting temporary MariaDB for initialization -----"

    # Start MariaDB in the foreground.
    #
    # --init-file tells MariaDB to execute our SQL file at startup.
    # --bind-address=0.0.0.0 allows connections from all IPv4 addresses inside the Docker network.
    
    # There is deliberately NO '&' here.
    # MariaDB stays in the foreground until SHUTDOWN in the
    # init file tells it to exit.
    mysqld \
        --user=mysql \
        --socket=/run/mysqld/mysqld.sock \
        --bind-address=0.0.0.0 \
        --init-file=/tmp/mariadb-init.sql \
        --console

    # The temporary server has shut down after completing the initialization SQL.
    # Remove the temporary SQL file because it contained passwords.
    rm -f /tmp/mariadb-init.sql

    echo "----- MariaDB initialization finished -----"


fi
echo "----- Starting final MariaDB -----"
# Start MariaDB as the main process of the container.
# exec replaces the setup script with mysqld, making MariaDB PID 1 inside the container
exec mysqld \
    --user=mysql \
    --socket=/run/mysqld/mysqld.sock \
    --bind-address=0.0.0.0 \
    --console
