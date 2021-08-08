FROM php:7.4-fpm
# Copy composer into the working directory
#COPY composer.lock composer.json /var/www/html/
ARG SSH_KEY
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

# Install Git and Configure SSH
RUN apt-get update && apt-get install -y git
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    echo "${SSH_KEY}" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa
RUN eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
#We gonna use this later# RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN mkdir /home/source && cd /home/source
# Clone Repo
RUN git clone git@github.com:mahmoudrashwan/laravel-app-1.git
RUN cp -r /var/www/html/laravel-app-1/. /var/www/html
RUN rm -rf laravel-app-1

# Copy env
COPY ./.env /var/www/html

#COPY Config files
COPY ./mysql /var/www/html
COPY ./nginx /var/www/html
COPY ./php /var/www/html

# Assign permissions of the working directory to the www-data user
RUN chown -R www-data:www-data /var/www/html/storage
RUN chown -R www-data:www-data /var/www/html/bootstrap/cache
RUN chmod -R 777 storage


# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]