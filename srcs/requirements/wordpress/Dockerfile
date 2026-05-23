FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    php8.2-redis \
    curl \
    default-mysql-client \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html
RUN mkdir -p /run/php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_setup.sh"]
