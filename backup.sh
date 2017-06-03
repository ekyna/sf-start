#!/bin/bash

if [[ ! -d var/backup ]]
then
    printf "\e[31mBackup directory does not exist.\e[0m\n"
    exit 1
fi

# Data directory
if [[ -d var/data ]]
then
    tar -cf ./var-data.tar -C var/data . && mv ./var-data.tar var/backup
fi

# Test data directory
if [[ -d var/test/data ]]
then
    tar -cf ./var-test-data.tar -C var/test/data . && mv ./var-test-data.tar var/backup
fi

# Images cache directory
if [[ -d web/cache ]]
then
    tar -cf ./web-cache.tar -C web/cache . && mv ./web-cache.tar var/backup
fi

# Tinymce images directory
if [[ -d web/tinymce ]]
then
    tar -cf ./web-tinymce.tar -C web/tinymce . && mv ./web-tinymce.tar var/backup
fi

exit 0
