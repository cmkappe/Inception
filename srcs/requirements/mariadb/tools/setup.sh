#!/bin/bash

# "If anything fails, stop immediately."
set -e

echo "MariaDB setup script started"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# make mariaDB listen on the container network
exec mysqld --user=mysql --socket=/run/mysqld/mysqld.sock --bind-address=0.0.0.0 --console
