FROM php:8.2-apache

USER root

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

RUN echo "Listen 9000" >> /etc/apache2/ports.conf

# Set working directory
WORKDIR /var/www/html

COPY composer.json composer.lock ./

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    zip \
    unzip \
    libzip-dev \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy application files
COPY .env .

COPY . .

RUN composer install --no-dev --optimize-autoloader

# Correct permissions
RUN chown -R www-data:www-data /var/www/html \
    && composer dump-autoload --optimize \
    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["apache2-foreground"]
