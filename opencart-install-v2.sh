#! /bin/bash

# Author: Ihor Sokorchuk, ihor.sokorchuk@nure.ua

trap 'echo "$BASH_COMMAND";echo -n "# ";read' DEBUG


apt update && apt upgrade

apt install -y lsb-release ca-certificates apt-transport-https \
               software-properties-common gnupg2 zlib unzip curl wget

mkdir -p ~/opencart_install
pushd ~/opencart_install


# Add the MySQL Repository
#
# https://dev.mysql.com/downloads/repo/apt/
#
wget -c https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb
#
dpkg -i mysql-apt-config_0.8.22-1_all.deb
#
apt update


# Install the MySQL Server
apt install mysql-server
#
systemctl enable mysql.service
#
systemctl restart mysql.service
#
systemctl status mysql.service
#
echo 'user:root  password: Lv-2022DevOps'
mysql_secure_installation
#
echo 'user: Lv-2022DevOps  password: Lv-2022DevOps'
#
mysql -u root --password='Lv-2022DevOps' <<'SQL_CODE'

CREATE USER 'Lv-2022DevOps'@'localhost' IDENTIFIED BY 'Lv-2022DevOps';
GRANT ALL PRIVILEGES ON *.* TO 'Lv-2022DevOps'@'localhost';

CREATE USER 'Lv-2022DevOps'@'%' IDENTIFIED BY 'Lv-2022DevOps';
GRANT ALL PRIVILEGES ON *.* TO 'Lv-2022DevOps'@'%';

CREATE DATABASE opencart CHARACTER SET utf8 COLLATE utf8_bin;

SHOW DATABASES;

SQL_CODE


# Install the Apache2
#
apt-get install apache2 apache2-utils
systemctl enable apache2
#
date_label="$(date +%y%m%d%H%M)"
#
pushd /etc/apache2/conf/
#
cp httpd.conf httpd.conf-${date_label}
#
# /etc/httpd/conf/httpd.conf 'AllowOverride None' -> '.. All'
cat httpd.conf-${date_label} \
| sed 's/AllowOwerride None/AllowOwerride All/g' \
>httpd.conf
#
popd
#
systemctl restart apache2
systemctl status apache2


# Install PHP 8.2 & Extensions for OpenCart 4.0
#
# Add the PHP packages APT repository to your Debian server.
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" \
> /etc/apt/sources.list.d/sury-php.list
#
# Import repository key:
wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -
#
# Perform package index update to confirm the repository has been added:
apt update && apt upgrade

# Install PHP 8.2 on Debian 10
apt install php8.2 php8.2-common php8.2-cli
#
for module in fpm opcache agd mysql curl intl xsl \
              mbstring zip bcmath soap \
              ldap odbc pear xml xmlrpc snmp mcrypt; do
    apt install php8.2-${module}
done
#
apt install libapache2-mod-php8.2*
#
a2enmod proxy_fcgi setenvif
a2enconf php8.2-fpm
#
systemctl restart apache2


# Step 4. Install the OpenCart 4.0
#
wget -c https://github.com/opencart/opencart/releases/download/4.0.0.0/opencart-4.0.0.0.zip
#
unzip opencart-4.0.0.0.zip
mv upload /var/www/html/opencart
#
cd /var/www/html/opencart/
cp config-dist.php config.php
cp admin/config-dist.php admin/config.php
#
chown -R www-data:www-data /var/www/html/opencart
chmod -R 755 /var/www/html/opencart


apt autoremove

echo 'Open:
http://OpencartServerIP/opencart/install/index.php

Remove the directory:
rm -rf /var/www/html/opencart/install'

 popd
