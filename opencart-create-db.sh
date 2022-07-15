#! /bin/bash

username='opencart'
password='gthtvjuf'
dbname='opencartdb'

# mysql -u ${user} -p 

cat <<SQL_CODE

CREATE DATABASE ${dbname}

CREATE USER '${username}'@'localhost' IDENTIFIED BY '${password}';
GRANT ALL PRIVILEGES ON ${dbname} . * TO '${username}'@'localhost';

SQL_CODE

echo '-------------------'
echo "database: ${dbname}"
echo "username: ${username}"
echo "password: ${password}"
