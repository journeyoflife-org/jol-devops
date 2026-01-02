FROM php:8.1-apache

# Install required PHP extensions for 1C-Bitrix
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd mysqli pdo_mysql opcache zip intl soap mbstring

# Bitrix-specific PHP configuration
RUN echo "short_open_tag = On" >> /usr/local/etc/php/conf.d/bitrix.ini \
    && echo "mbstring.func_overload = 0" >> /usr/local/etc/php/conf.d/bitrix.ini \
    && echo "max_input_vars = 10000" >> /usr/local/etc/php/conf.d/bitrix.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/bitrix.ini \
    && echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/bitrix.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/bitrix.ini

# Enable Apache modules
RUN a2enmod rewrite headers

WORKDIR /var/www/html

# Download Bitrix setup script
RUN curl -o bitrixsetup.php https://www.1c-bitrix.ru/download/scripts/bitrixsetup.php

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1
