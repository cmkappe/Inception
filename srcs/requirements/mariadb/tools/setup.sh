#!/bin/bash

# "If anything fails, stop immediately."
set -e

echo "MariaDB setup script started"

mkdir -p /run/mysqld
# CHange OWNer // chown owner:group file // -R recursive, so every (sub)folder/file gets checked
chown -R mysql:mysql /run/mysqld /var/lib/mysql

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

# -d checks if directory exists // /var/lib/mysql/ contains mariadb data
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "First startup of MariaDB detected."

    # creates internal system tables
    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql
    
    mysqld \
    # mysqld starts the server (deamon process)
        --user=mysql \
        --socket=/run/mysqld/mysqld.sock \
        # 0.0.0.0  = ALL local IPv4 addresses
        --bind-address=0.0.0.0 &
        # with '&' mysql never returns -> endless looop // '&' makes it start in the background so shell doesn't wait and immeaditely turn back to script
    until mysqladmin ping --silent; do
        # checks once every second if MariaDB is alive yet
        sleep 1
    done


# mysql starts the client 
mysql <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES
ON \`${MYSQL_DATABASE}\`.*
TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF
    mysqladmin shutdown

fi
# make mariaDB listen on the container network
exec mysqld \
    --user=mysql \
    --socket=/run/mysqld/mysqld.sock \
    --bind-address=0.0.0.0 \
    --console

    # exec mysqld ... twice (once temporarily, once permanently)
    # should be cleaned up later by storing the common options in a variable