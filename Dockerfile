FROM php:5.6-apache

# Maintainer
# ----------
MAINTAINER Mohamed Bouchenafa <mbouchenafa@smartwavesa.com>

RUN a2enmod rewrite expires

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mysqli opcache

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

#

ENV WORDPRESS_VERSION 4.5
ENV WORDPRESS_SHA1 439f09e7a948f02f00e952211a22b8bb0502e2e2

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
	&& rm wordpress.tar.gz \
	&& chown -R www-data:www-data /usr/src/wordpress


# Install GIT
# -------------------------------------------------------------
RUN 	apt-get update && \
		apt-get -y install git-core

# Install VI
# -------------------------------------------------------------
RUN 	apt-get -y install vim

# Cloning the WP-CONTENT from GIT
# -------------------------------------------------------------
ARG GIT_REPO 

RUN 	cd /var/www/html && \
		rm -rf * && \
		git clone $GIT_REPO /var/www/html


#Define the VOLUME /var/www/html
VOLUME /var/www/html

COPY docker-entrypoint.sh /entrypoint.sh
RUN		chmod 777 /entrypoint.sh
# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]