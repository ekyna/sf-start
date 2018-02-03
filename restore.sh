#!/bin/bash

LOG_PATH="var/logs/restore.log"

VAR_DATA_PATH="var/backup/var-data.tar"
WEB_CACHE_PATH="var/backup/web-cache.tar"
WEB_TINYMCE_PATH="var/backup/web-tinymce.tar"

if [[ ! -f ${VAR_DATA_PATH} ]]
then
    printf "\e[31mFilesystem backup file is missing.\e[0m\n"
    exit 1
fi

Run() {
    printf "$1 ... "
    php bin/console $2 --env=prod >> ${LOG_PATH} 2>&1
    if [[ $? -eq 0 ]]
    then
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
        exit 1
    fi
}

# Apply migrations
Run "Applying \e[1;33mmigrations\e[0m" "doctrine:migration:migrate --no-interaction --allow-no-migration"

# Clear caches
printf "Clearing \e[1;33mcache\e[0m ... "
php bin/console doctrine:cache:clear-metadata --env=prod >> ${LOG_PATH} 2>&1
php bin/console doctrine:cache:clear-query --env=prod >> ${LOG_PATH} 2>&1
php bin/console doctrine:cache:clear-result --env=prod >> ${LOG_PATH} 2>&1
php bin/console cache:clear --env=prod >> ${LOG_PATH} 2>&1
printf "\e[32mdone\e[0m\n"

# Restore filesystem
printf "Restoring \e[1;33mfilesystem\e[0m ... "
chown -Rf $(id -u -n):$(id -g -n) var/data >> ${LOG_PATH} 2>&1
chmod -Rf +rwx var/data >> ${LOG_PATH} 2>&1
rm -Rf var/data/commerce >> ${LOG_PATH} 2>&1
rm -Rf var/data/ftp >> ${LOG_PATH} 2>&1
rm -Rf var/data/media >> ${LOG_PATH} 2>&1
rm -Rf var/data/tmp >> ${LOG_PATH} 2>&1
rm -Rf var/data/upload >> ${LOG_PATH} 2>&1
tar -xf ${VAR_DATA_PATH} -C ./var/data >> ${LOG_PATH} 2>&1
if [[ $? -eq 0 ]]
then
    printf "\e[32mdone\e[0m\n"
else
    printf "\e[31merror\e[0m\n"
    exit 1
fi

# Restore web image cache
if [[ -f ${WEB_CACHE_PATH} ]]
then
    printf "Restoring \e[1;33mimages cache\e[0m ... "
    chown -Rf $(id -u -n):$(id -g -n) web/cache >> ${LOG_PATH} 2>&1
    chmod -Rf +rwx web/cache >> ${LOG_PATH} 2>&1
    rm -Rf web/cache >> ${LOG_PATH} 2>&1
    mkdir web/cache >> ${LOG_PATH} 2>&1
    tar -xf ${WEB_CACHE_PATH} -C ./web/cache >> ${LOG_PATH} 2>&1
    if [[ $? -eq 0 ]]
    then
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
        exit 1
    fi
fi

# Restore web tinymce images
if [[ -f ${WEB_TINYMCE_PATH} ]]
then
    printf "Restoring \e[1;33mtinymce images\e[0m ... "
    chown -Rf $(id -u -n):$(id -g -n) web/tinymce >> ${LOG_PATH} 2>&1
    chmod -Rf +rwx web/tinymce >> ${LOG_PATH} 2>&1
    rm -Rf web/tinymce >> ${LOG_PATH} 2>&1
    mkdir web/tinymce >> ${LOG_PATH} 2>&1
    tar -xf ${WEB_TINYMCE_PATH} -C ./web/tinymce >> ${LOG_PATH} 2>&1
    if [[ $? -eq 0 ]]
    then
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
        exit 1
    fi
fi

# Install assets
Run "Installing \e[1;33mbundle assets\e[0m" "assets:install"

# Restore search engine
Run "Restoring \e[1;33melasticsearch\e[0m" "fos:elastica:populate"

# Clear logs if no error
rm ${LOG_PATH}

exit 0
