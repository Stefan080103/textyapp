FROM php:8.2-fpm
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd
WORKDIR /var/www
COPY . .
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build
CMD php artisan serve --host=0.0.0.0 --port=8080