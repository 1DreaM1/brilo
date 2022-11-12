FROM php:7.2-apache

COPY .docker/php-apache/php.ini /usr/local/etc/php/

RUN apt-get update -y && apt-get install -y -qq git \
	apt-transport-https \
	zip unzip \
	wget \
	msmtp \
    zlib1g-dev \
    libicu-dev g++ \
	vim

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
