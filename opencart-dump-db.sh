#! /bin/bash
# Author: Ihor Sokorchuk, ihor.sokorchuk@nure.ua

dbuser='root'
dbpass='gthtvjuf'
dbname='opencartdb'

dumpfile="${dbname}-backup-$(date -u +%Y%m%d%H%M%S).sql"

mysqldump -u ${dbuser} -p${dbpass} ${dbname} | gzip >${dumpfile}.gz
