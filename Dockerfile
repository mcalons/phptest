FROM php:8.1-apache

# Instalación de extensiones necesarias
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install zip pdo pdo_mysql

# Install MongoDB extension (Corrected and robust)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb

# Instalación de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instalación del instalador de Laravel
RUN composer global require laravel/installer

RUN echo "export PATH=$PATH:/home/gitpod/.config/composer/vendor/bin" >> ~/.bashrc
RUN source ~/.bashrc
#ENV PATH="$PATH:/home/gitpod/.config/composer/vendor/bin"
#RUN source /home/gitpod/.bashrc


# Directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos de la aplicación
COPY . /var/www/html

# Instalación de dependencias de Laravel
RUN composer install --no-interaction --no-dev

# Generar la key de la aplicación
RUN php artisan key:generate

# Permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Exponer el puerto 80
EXPOSE 80