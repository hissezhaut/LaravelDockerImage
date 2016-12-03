FROM php:latest
MAINTAINER hissezhaut - https://github.com/hissezhaut
RUN a2enmod rewrite
COPY 010-default.conf /etc/apache2/sites-available
WORKDIR /var/www
RUN apt-get update && apt-get install --no-install-recommends -y \
    libgmp10 \
    libgmp-dev \
    libldb-dev \
    libldap2-dev \
    mysql-client \
    zlib1g-dev \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && ln -s /usr/lib/x86_64-linux-gnu/libld* /usr/lib/ \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    gmp \
    ldap \
    mbstring \
    mysql \
    pdo \
    pdo_mysql \
    zip \
    && a2dissite 000-default \
    && a2ensite 010-default \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer create-project \
    --no-ansi \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    laravel/laravel /var/www/html ~5.* \
    && /var/www/html/app/Users.php \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN chown -R www-data:www-data /var/www/html

COPY config_database.php /var/www/html/config/database.php

ONBUILD RUN composer self-update \
        && cd /var/www/html \
        && composer update \
        --no-ansi \
        --no-dev \
        --no-interaction \
        --no-progress \
        --prefer-dist
WORKDIR /var/www/html
