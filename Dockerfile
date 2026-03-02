FROM php:8.2-fpm-alpine
# info: info@intiinside.com
# 1. Instalar dependencias (Agregamos libsodium-dev)
RUN apk add --no-cache \
    git \
    linux-headers \
    oniguruma-dev \
    libsodium-dev \
    icu-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    libxml2-dev \
    postgresql-dev \
    zlib-dev \
    shadow \
    ghostscript \
    dcron

# 2. Configurar GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# 3. Instalar extensiones (Agregamos SODIUM al final)
RUN docker-php-ext-install -j$(nproc) \
    intl soap zip pgsql pdo_pgsql exif opcache bcmath sockets mbstring sodium

# 4. Configuración PHP
RUN { \
    echo 'max_input_vars=5000'; \
    echo 'memory_limit=512M'; \
    echo 'upload_max_filesize=512M'; \
    echo 'post_max_size=512M'; \
    echo 'max_execution_time=600'; \
} > /usr/local/etc/php/conf.d/moodle.ini

RUN usermod -u 82 www-data && groupmod -g 82 www-data
WORKDIR /var/www/html