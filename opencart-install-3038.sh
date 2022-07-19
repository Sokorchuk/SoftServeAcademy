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
echo 'user:root  password: Lv-2022DevOps'
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
pushd /etc/apache2/
#
cp apache2.conf apache2.conf-${date_label}
#
# /etc/apache2/apache2.conf 'AllowOverride None' -> '.. All'
cat apache2.conf-${date_label} \
| sed 's/AllowOwerride None/AllowOwerride All/g' \
>apache2.conf
#
popd
#
systemctl restart apache2
systemctl status apache2


# Install PHP 7.3 on Debian 10
apt install php7.3 php7.3-common php7.3-cli
#
apt install \
    php7.3-fpm \
    php7.3-opcache \
    php7.3-gd \
    php7.3-mysql \
    php7.3-curl \
    php7.3-intl \
    php7.3-xsl \
    php7.3-mbstring \
    php7.3-zip \
    php7.3-bcmath \
    php7.3-soap \
    php7.3-ldap \
    php7.3-odbc \
    php7.3-xml \
    php7.3-xmlrpc \
    php7.3-snmp \
#
apt install libapache2-mod-php7.3*
#
a2enmod proxy_fcgi setenvif
a2enconf php7.3-fpm
#
systemctl restart apache2
systemctl status apache2


# Step 4. Install the OpenCart 3.0
#
wget -c 'https://github.com/opencart/opencart/releases/download/3.0.3.8/opencart-3.0.3.8.zip'
#
unzip opencart-3.0.3.8.zip
mv upload /var/www/html/opencart
#
cd /var/www/html/opencart/
cp config-dist.php config.php
cp ./admin/config-dist.php ./admin/config.php
#
chown -R www-data:www-data /var/www/html/opencart
chmod -R 755 /var/www/html/opencart


apt autoremove


ip address | grep 'inet '
echo '
--------------------------------------------------------
Open: http://OpencartServerIP/opencart/install/index.php

login: Lv-2022DevOps   password: Lv-2022DevOps
login: admin           password: Lv-2022DevOps
database: opencart
--------------------------------------------------------
'


opencart_inst_dir='/var/www/html/opencart/install'
echo 'Remove the directory:'
echo "${opencart_inst_dir}"
#
if [ "$(read -p 'Remove ${opencart_inst_dir} [yes/No]: ')" = 'yes' ]; then
    rm -rf ${opencart_inst_dir}
fi

popd
# EOF
