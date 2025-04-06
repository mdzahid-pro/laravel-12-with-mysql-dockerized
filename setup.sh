#!/bin/bash

# Create project structure
mkdir -p docker/{nginx,php,node,supervisor} src

# Copy Docker files
cat > docker/nginx/Dockerfile << 'EOF'
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/www/html
EOF

cat > docker/nginx/nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

cat > docker/php/Dockerfile << 'EOF'
ARG PHP_VERSION=8.4

FROM php:${PHP_VERSION}-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    supervisor

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www/html

# Change current user to www
USER www

EXPOSE 9000
CMD ["php-fpm"]
EOF

cat > docker/node/Dockerfile << 'EOF'
FROM node:latest

# Set working directory
WORKDIR /var/www/html

# Install dependencies (optional, mainly done in the volume)
RUN npm install -g npm@latest

EXPOSE 5173
EOF

cat > docker/supervisor/Dockerfile << 'EOF'
FROM php:8.4-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    supervisor

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Set up supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
EOF

cat > docker/supervisor/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
user=root
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid

[program:laravel-horizon]
process_name=%(program_name)s
command=php /var/www/html/artisan horizon
autostart=true
autorestart=true
user=root
redirect_stderr=true
stdout_logfile=/var/log/supervisor/horizon.log
stopwaitsecs=3600
EOF

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  nginx:
    build:
      context: ./docker/nginx
    ports:
      - "80:80"
    volumes:
      - ./src:/var/www/html
    depends_on:
      - php
    networks:
      - app-network

  php:
    build:
      context: ./docker/php
      args:
        PHP_VERSION: 8.4
    volumes:
      - ./src:/var/www/html
    depends_on:
      - mysql
    networks:
      - app-network

  node:
    build:
      context: ./docker/node
    volumes:
      - ./src:/var/www/html
    ports:
      - "5173:5173"
    networks:
      - app-network
    tty: true
    command: /bin/sh -c "cd /var/www/html && npm run dev"

  mysql:
    image: mysql:latest
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: laravel
      MYSQL_ROOT_PASSWORD: root
      MYSQL_USER: laravel
      MYSQL_PASSWORD: laravel
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - app-network

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    ports:
      - "8080:80"
    environment:
      PMA_HOST: mysql
      PMA_PORT: 3306
      MYSQL_ROOT_PASSWORD: root
    depends_on:
      - mysql
    networks:
      - app-network

  mailhog:
    image: mailhog/mailhog
    ports:
      - "1025:1025"
      - "8025:8025"
    networks:
      - app-network

  supervisor:
    build:
      context: ./docker/supervisor
    volumes:
      - ./src:/var/www/html
    depends_on:
      - php
      - mysql
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  mysql-data:
EOF

echo "Docker configuration completed. Installing Laravel..."

docker compose up -d php

# Install Laravel
docker compose exec php composer create-project laravel/laravel .
docker compose exec php composer require laravel/horizon

# Configure environment variables
docker compose exec php cp .env.example .env
docker compose exec php php artisan key:generate

# Update DB connection to use MySQL service
docker compose exec php sed -i 's/DB_HOST=127.0.0.1/DB_HOST=mysql/g' .env
docker compose exec php sed -i 's/DB_PASSWORD=/DB_PASSWORD=laravel/g' .env

# Install React and TypeScript
docker compose up -d node
docker compose exec node npm install react@latest react-dom@latest @types/react @types/react-dom typescript @vitejs/plugin-react

echo "Setup completed successfully!"