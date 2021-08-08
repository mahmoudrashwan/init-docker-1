FROM php:fpm-alpine
# Copy composer into the working directory
COPY composer.lock composer.json /var/www/html/

# Set working directory
WORKDIR /var/www/html/

# Install dependencies for the operating system software
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    libzip-dev \
    unzip \
    git \
    libonig-dev \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions for php
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Install composer (php package manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Git and Clone the Repo 
RUN apt-get update \        
     apt-get install -y git
RUN mkdir /root/.ssh/
ADD id_rsa /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
#We gonna use this later# RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN mkdir /home/source \      
           cd /home/source \        
           git clone git@github.com:mahmoudrashwan/laravel-app-1.git
RUN cp -r /home/source/ /var/www/html/

# Assign permissions of the working directory to the www-data user
RUN chown -R www-data:www-data \
        /var/www/html/storage \
        /var/www/html/bootstrap/cache
RUN chmod -R 777 storage

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]