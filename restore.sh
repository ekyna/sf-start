#!/bin/bash

if [[ $(cat /etc/passwd | grep 1001) ]]
then
    if [[ 1001 != $(id -u) ]]
    then
        printf "\e[31mInvalid user.\e[0m\n"
        exit 1
    fi
fi

LOG_PATH="var/logs/restore.log"

DB_PATH="var/backup/database.sql"
VAR_DATA_PATH="var/backup/var-data.tar"
WEB_CACHE_PATH="var/backup/web-cache.tar"
WEB_TINYMCE_PATH="var/backup/web-tinymce.tar"

if [[ ! -f ${DB_PATH} ]]
then
    printf "\e[31mDatabase backup file is missing.\e[0m\n"
    exit 1
fi

if [[ ! -f ${VAR_DATA_PATH} ]]
then
    printf "\e[31mFilesystem backup file is missing.\e[0m\n"
    exit 1
fi

# Database
printf "Restore \e[1;33mdatabase\e[0m ... "
php bin/console doctrine:database:import --connection=default --env=prod ${DB_PATH} >> ${LOG_PATH} 2>&1
if [[ $? -eq 0 ]]
then
    printf "\e[32mdone\e[0m\n"
else
    printf "\e[31merror\e[0m\n"
    exit 1
fi

# Elasticsearch
printf "Restore \e[1;33melasticsearch\e[0m ... "
php bin/console fos:elastica:populate --env=prod >> ${LOG_PATH} 2>&1
if [[ $? -eq 0 ]]
then
    printf "\e[32mdone\e[0m\n"
else
    printf "\e[31merror\e[0m\n"
    exit 1
fi

# Filesystem
printf "Restore \e[1;33mfilesystem\e[0m ... "
#chmod -Rf +rwx var/data
rm -Rf var/data
mkdir var/data
tar -xf ${VAR_DATA_PATH} -C ./var/data >> ${LOG_PATH} 2>&1
if [[ $? -eq 0 ]]
then
    printf "\e[32mdone\e[0m\n"
else
    printf "\e[31merror\e[0m\n"
    exit 1
fi

# Cache (images)
if [[ -f ${WEB_CACHE_PATH} ]]
then
    printf "Restore \e[1;33mimages cache\e[0m ... "
    #chmod -Rf +rwx web/cache
    rm -Rf web/cache
    mkdir web/cache
    tar -xf ${WEB_CACHE_PATH} -C ./web/cache >> ${LOG_PATH} 2>&1
    if [[ $? -eq 0 ]]
    then
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
        exit 1
    fi
fi

# Tinymce
if [[ -f ${WEB_TINYMCE_PATH} ]]
then
    printf "Restore \e[1;33mtinymce images\e[0m ... "
    #chmod -Rf +rwx web/tinymce
    rm -Rf web/tinymce
    mkdir web/tinymce
    tar -xf ${WEB_TINYMCE_PATH} -C ./web/tinymce >> ${LOG_PATH} 2>&1
    if [[ $? -eq 0 ]]
    then
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
        exit 1
    fi
fi

php bin/console assets:install --env=prod >> ${LOG_PATH} 2>&1

# Clear logs if no error
rm ${LOG_PATH}

exit 0
