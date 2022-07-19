#! /bin/bash

dbuser='root'
dbpass='Lv-2022DevOps'
dbname='opencart'

dumpfile="${dbname}-backup-$(date -u +%Y%m%d%H%M%S).sql"

mysqldump -u ${dbuser} -p${dbpass} ${dbname} | gzip >${dumpfile}.gz
