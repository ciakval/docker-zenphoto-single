FROM debian:bookworm
LABEL original_maintainer="Enric Mieza <enric@enricmieza.com>" \
      maintainer="Jan Remes <jan@remes.cz>" \
      version="2.0.0"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
apt-get install -y curl \
	apache2 \
	libapache2-mod-php \
	locales \
	mariadb-server \
	php-bz2 \
	php-curl \
	php-mysql \
	php-gd \
	php-imagick \
	php-intl \
	php-mbstring \
	php-tidy \
	php-xml \
	php-zip \
	&& \
apt-get clean && apt-get autoclean && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/www/html/*

ARG ZENPHOTO_VERSION=1.6.5
ARG PHP_VERSION=8.2

RUN curl \
	-L \
	-o /zenphoto.tar.gz \
	https://github.com/zenphoto/zenphoto/archive/v${ZENPHOTO_VERSION}.tar.gz && \
sed -i "/upload_max_filesize/c\upload_max_filesize = 20M" /etc/php/${PHP_VERSION}/apache2/php.ini && \
echo "<Directory /var/www>" >> /etc/apache2/sites-available/000-default.conf && \
echo "	AllowOverride All" >> /etc/apache2/sites-available/000-default.conf && \
echo "	Options -Indexes +FollowSymLinks" >> /etc/apache2/sites-available/000-default.conf && \
echo "</Directory>" >> /etc/apache2/sites-available/000-default.conf && \
sed -i "/<\/VirtualHost>/d" /etc/apache2/sites-available/000-default.conf && \
echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf

EXPOSE 80

VOLUME ["/var/lib/mysql"]
VOLUME ["/var/www/html"]

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && dpkg-reconfigure locales

COPY run.sh /run.sh
RUN chmod 755 /run.sh
ENTRYPOINT ["/run.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
