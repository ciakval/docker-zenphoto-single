#!/bin/bash

BASEDIR=/var/www/html
# extract and initialize zenphoto if not present
if [ ! -d $BASEDIR/zp-core ]
then
	rm -f $BASEDIR/index.html
	# extract zenphoto files
	tar xfz /zenphoto.tar.gz -C $BASEDIR --strip-components=1
	# create config
	cp $BASEDIR/zp-core/file-templates/zenphoto_cfg.txt $BASEDIR/zp-data/zenphoto.cfg.php
	sed -i "/mysql_user/c\$conf['mysql_user'] = 'root';" $BASEDIR/zp-data/zenphoto.cfg.php
	sed -i "/mysql_database/c\$conf['mysql_database'] = 'zenphoto';" $BASEDIR/zp-data/zenphoto.cfg.php
	sed -i "/mysql_pass/c\$conf['mysql_pass'] = 'zenphoto-pw';" $BASEDIR/zp-data/zenphoto.cfg.php
	# copy .htaccess file
	cp $BASEDIR/zp-core/file-templates/htaccess $BASEDIR/.htaccess
	# Set permissions for files in zp-data
	touch $BASEDIR/zp-data/debug.log
	touch $BASEDIR/zp-data/setup.log
	touch $BASEDIR/zp-data/charset_tést	# sic! (this name is required for charset testing)
	chmod 0600 $BASEDIR/zp-data/*
 
	chown -R www-data $BASEDIR
	chmod -R go-rwx $BASEDIR
fi

# initialize mysql files 
if [ ! -d /var/lib/mysql/mysql ]
then
	mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
	
	service mariadb start

	# Wait for DB to start
	while ! mariadb -e "USE mysql"; do
		sleep 2
	done

	mariadb -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('zenphoto-pw');"
	mariadb -e "FLUSH PRIVILEGES;"
fi

# run mysql daemon
service mariadb start

# create db
mysql -uroot -e "CREATE DATABASE zenphoto;"

# run CMD
exec "$@"

