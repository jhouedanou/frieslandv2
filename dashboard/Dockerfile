FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    libicu-dev \
    zip \
    unzip \
    supervisor \
    nginx \
    nodejs \
    npm \
    && docker-php-ext-install pdo_pgsql pdo_mysql mbstring exif pcntl bcmath gd zip intl \
    && docker-php-ext-enable pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy composer files first for better layer caching
COPY composer.json composer.lock ./

# Install PHP dependencies (include dev for proper package discovery)
RUN composer install --no-scripts --no-autoloader --optimize-autoloader

# Copy package.json for Node dependencies (if exists)
COPY package*.json ./
RUN if [ -f package.json ]; then npm ci --production; fi

# Copy application files
COPY . .

# Create .env file for build process
RUN cp env.example .env

# Skip autoload generation during build - will be done at runtime
# This prevents artisan script execution issues during Docker build

# Create Laravel directories and set permissions
RUN mkdir -p /var/www/storage/logs \
    && mkdir -p /var/www/storage/framework/cache \
    && mkdir -p /var/www/storage/framework/sessions \
    && mkdir -p /var/www/storage/framework/views \
    && mkdir -p /var/www/bootstrap/cache \
    && chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/sites-available/default
RUN rm /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Copy supervisor configuration
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create entrypoint script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Create Laravel directories and set permissions at runtime\n\
mkdir -p /var/www/storage/logs\n\
mkdir -p /var/www/storage/framework/cache\n\
mkdir -p /var/www/storage/framework/sessions\n\
mkdir -p /var/www/storage/framework/views\n\
mkdir -p /var/www/bootstrap/cache\n\
chown -R www-data:www-data /var/www/storage\n\
chown -R www-data:www-data /var/www/bootstrap/cache\n\
chmod -R 775 /var/www/storage\n\
chmod -R 775 /var/www/bootstrap/cache\n\
\n\
# Generate optimized autoloader\n\
composer dump-autoload --optimize\n\
\n\
# Wait for database\n\
until php artisan tinker --execute="DB::connection()->getPdo();" > /dev/null 2>&1; do\n\
    echo "Waiting for database connection..."\n\
    sleep 2\n\
done\n\
\n\
# Generate application key if not set\n\
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:YOUR_APP_KEY_HERE" ]; then\n\
    php artisan key:generate --force\n\
fi\n\
\n\
# Run migrations and seeding\n\
php artisan config:cache\n\
php artisan route:cache\n\
php artisan view:cache\n\
php artisan migrate --force\n\
php artisan db:seed --force\n\
\n\
# Start supervisor\n\
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

# Expose port 80
EXPOSE 80

# Use entrypoint script
ENTRYPOINT ["/entrypoint.sh"] 