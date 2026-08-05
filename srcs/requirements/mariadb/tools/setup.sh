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

echo "MariaDB setup script started"

# mkdir -p /run/mysqld /var/lib/mysql
# CHange OWNer // chown owner:group file // -R recursive, so every (sub)folder/file gets checked
chown -R mysql:mysql /run/mysqld /var/lib/mysql



# -d checks if directory exists // /var/lib/mysql/ contains mariadb data // -z asks if directory is emtpy
if [ ! -d "/var/lib/mysql/mysql" ] || [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "----- First startup of MariaDB detected -----"

    # creates internal system tables
    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql

    # mysqld starts the server (deamon process)
        # 0.0.0.0  = ALL local IPv4 addresses
        # with '&' mysql never returns -> endless looop // '&' makes it start in the background so shell doesn't wait and immeaditely turn back to script
        # checks once every second if MariaDB is alive yet
    mysqld \
        --user=mysql \
        --socket=/run/mysqld/mysqld.sock \
        --bind-address=0.0.0.0 &

    until mysqladmin ping --silent; do
        sleep 1
    done

    # checks if database exists, and if not creates it
    # mysql starts the client
    echo "----- Creating database -----"
    mysql <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES
ON \`${MYSQL_DATABASE}\`.*
TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF
    echo "----- SQL finished -----"
    echo "----- Stopping temporary server -----"
mysqladmin shutdown

fi
echo "----- Starting final MariaDB -----"
# start final server & make mariaDB listen on the container network
exec mysqld \
    --user=mysql \
    --socket=/run/mysqld/mysqld.sock \
    --bind-address=0.0.0.0 \
    --console

    # exec mysqld ... twice (once temporarily, once permanently)
    # should be cleaned up later by storing the common options in a variable