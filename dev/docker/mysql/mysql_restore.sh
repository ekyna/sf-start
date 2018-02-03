#!/bin/bash

if [[ ! -f /backup/db.sql ]]
then
    printf "\e[31mDatabase backup file is missing.\e[0m\n"
    exit 1
fi

mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -s -e "DROP DATABASE ${MYSQL_DATABASE};"
mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -s -e "CREATE DATABASE ${MYSQL_DATABASE};"
mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -s  ${MYSQL_DATABASE} < /backup/db.sql

exit 0
