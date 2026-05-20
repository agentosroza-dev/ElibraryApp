#set -e
#
#chown -R www-data:www-data /var/www/html/storage
#chown -R www-data:www-data /var/www/html/storage/app
#chown -R www-data:www-data /var/www/html/storage/app/public
#chown -R www-data:www-data /var/www/html/storage/app/private
#chown -R www-data:www-data /var/www/html/bootstrap/cache
#chown -R www-data:www-data /var/www/html/public
#
## Install dependencies without production optimizations
#composer install &
#wait $!
#
## Generate key and run migrations first
#php artisan key:generate --force
#php artisan migrate --force
#wait $!
#
## Run specific migrations for cache and jobs tables
## php artisan migrate --path=database/migrations/0001_01_01_000001_create_cache_table.php --force
## php artisan migrate --path=database/migrations/0001_01_01_000002_create_jobs_table.php --force
#
#
## Restart Reverb to apply any changes
## php artisan reverb:restart
#
##clear and optimize caches
#php artisan optimize:clear
#
## Retry failed jobs
#php artisan queue:retry all
#
## Start services
#apache2-foreground &
## php artisan reverb:start &
#php artisan queue:work
#
##assing file permission
#chown www-data:www-data start.sh


#!/bin/bash
set -e

#set all child
chmod -R g+s /var/www/html/storage

chown -R www-data:www-data /var/www/html/bootstrap/cache
chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /var/www/html/storage/app
chown -R www-data:www-data /var/www/html/storage/app/public
chown -R www-data:www-data /var/www/html/storage/app/private

#sudo chmod -R 775 storage

composer install
wait $!

# Generate key and run migrations first
php artisan key:generate --force
php artisan migrate --force
wait $!

# Clear and optimize caches
php artisan optimize:clear

# Create storage link if needed
php artisan storage:link

# Retry failed jobs
php artisan queue:retry all

# Start services
apache2-foreground &
php artisan reverb:start &
# php artisan schedule:work &
php artisan queue:work

