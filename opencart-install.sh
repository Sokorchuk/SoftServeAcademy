#! /bin/bash


trap 'echo "$BASH_COMMAND";echo -n "# ";read' DEBUG

apt update && apt upgrade


apt install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2

mkdir -p ~/opencart_installation
cd ~/opencart_installation

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
systemctl status mysql.service
#
mysql_secure_installation


# Install the Apache2
#
apt-get install apache2 apache2-utils
systemctl status apache2


# Install PHP 8.2 & Extensions for OpenCart
#
# Add the PHP packages APT repository to your Debian server.
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list
# Import repository key:
wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -
# Perform package index update to confirm the repository has been added:
apt update && apt upgrade

# Install PHP 8.2 on Debian 10
apt install php8.2 php8.2-common php8.2-cli 
apt install php8.2-fpm php8.2-opcache php8.2-gd php8.2-mysql php8.2-curl php8.2-intl php8.2-xsl php8.2-mbstring php8.2-zip php8.2-bcmath php8.2-soap
apt install unzip libapache2-mod-php8.2*

a2enmod proxy_fcgi setenvif
a2enconf php8.2-fpm

systemctl restart apache2


# Step 4. Install the OpenCart
#
wget -c https://github.com/opencart/opencart/releases/download/4.0.0.0/opencart-4.0.0.0.zip
unzip opencart-4.0.0.0.zip
mv upload /var/www/html/opencart

cd /var/www/html/opencart/
mv config-dist.php config.php
mv admin/config-dist.php admin/config.php

chown -R www-data:www-data /var/www/html/opencart
chmod -R 755 /var/www/html/opencart

apt autoremove

echo 'Open:
http://OpencartServerIP/opencart/install/index.php

Remove the directory:
rm -rf /var/www/html/opencart/install'
