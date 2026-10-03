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

# while building wordpress image, download and install WP-CLI program
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

ENTRYPOINT ["/setup.sh"]