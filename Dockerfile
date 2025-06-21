# Stage 1: Build assets
FROM node:18 as node
WORKDIR /app
COPY . .
RUN npm install && npm run build

# Stage 2: PHP + Composer
FROM php:8.2-fpm
WORKDIR /var/www
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev unzip nginx supervisor
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=node /app /var/www
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader

# Nginx config
COPY ./docker/nginx.conf /etc/nginx/nginx.conf

# Supervisor config to run both PHP-FPM and Nginx
COPY ./docker/supervisord.conf /etc/supervisord.conf

EXPOSE 8080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]