FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    mariadb-client \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*


# PHP-FPM normally listens on a Unix socket but
# nginx is running in a separate container, so like this it's 
# using TCP port 9000 for communication between the containers    
RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf


# while building wordpress image, download and install WP-CLI program
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

ENTRYPOINT ["/setup.sh"]