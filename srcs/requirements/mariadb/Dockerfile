
# base os
FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/mysql/*
    # creates database directory & mysql.sock (unix socket file)

    # mariaDB is not supposed to run as root (otherwise might start but fail to write)
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# starting database server

COPY tools/setup.sh /setup.sh
# give exec permission
RUN chmod +x /setup.sh
# run setup.sh when container starts
ENTRYPOINT ["/setup.sh"]
