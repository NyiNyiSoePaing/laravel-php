FROM nnsp/alpine-php:81
LABEL maintainer="nyinyisoepaing1997@gmail.com"
ENV COMPOSER_ALLOW_SUPERUSER=1
# Setup document root
WORKDIR /var/www/html

# Install packages                                                                                                 14:22:38

# RUN apk add --no-cache \
#   php82-ctype \
#   php82-curl 

# Configure nginx
COPY docker-config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY docker-config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY docker-config/php.ini /etc/php81/conf.d/custom.ini

# Configure supervisord
COPY docker-config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add application
COPY laravel/ /var/www/html/

# Install composer packages 
RUN composer install
RUN chown -R www-data:www-data /var/www/html /run /var/lib/nginx /var/log/nginx

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8000/fpm-ping
