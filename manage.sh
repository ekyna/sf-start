#!/bin/bash

source ./dev/docker/.env

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_DIR="$ROOT_DIR/dev/docker"
#REGISTRY="debian.dev:5000/"
REGISTRY=""
LOG_PATH="$ROOT_DIR/docker_logs.txt"

DOCKER_ENV_REGEX="^dev|prod$"
SYMFONY_ENV_REGEX="^dev|prod|test$"
SERVICE_REGEX="^nginx|php|mysql|mysql_test|elasticsearch|redis|varnish|se_hub|se_chrome$"
IMAGE_REGEX="^nginx|php$"
COMMAND_REGEX="^[a-z0-9_]+(:[a-z0-9_]+)*(\s-((a-z)|(-[a-z-]+(=[a-zA-Z0-9/]+))))*$"
BACKUP_REGEX="^[0-9]{12}$"

source ./dev/utils.sh

# Clear logs
ClearLogs

# ----------------------------- ACTIONS -----------------------------

CreateNetworkAndVolumes() {
    NetworkCreate "${PROJECT_NAME}-network"
    VolumeCreate "${PROJECT_NAME}-database"
    VolumeCreate "${PROJECT_NAME}-elasticsearch"
    VolumeCreate "${PROJECT_NAME}-test-database"
}

RemoveNetworkAndVolumes() {
    NetworkRemove "${PROJECT_NAME}-network"
    VolumeRemove "${PROJECT_NAME}-database"
    VolumeRemove "${PROJECT_NAME}-elasticsearch"
    VolumeRemove "${PROJECT_NAME}-test-database"
}

InitializeProject() {
    [[ $1 != "" ]] && SF_ENV=$1 || SF_ENV=dev
    ValidateSymfonyEnvName ${SF_ENV}

    SfCommand "cache:clear -e ${SF_ENV}"
    SfCommand "assets:install --relative -e ${SF_ENV}"

    if [[ -d 'app/DoctrineMigrations' ]]
    then
        SfCommand "doctrine:migration:migrate --no-interaction --allow-no-migration -e ${SF_ENV}"
    else
        SfCommand "doctrine:schema:update --force -e ${SF_ENV}"
    fi

    SfCommand "ekyna:install --no-interaction -e ${SF_ENV}"
    SfCommand "ekyna:admin:create-super-admin admin@example.org admin -e ${SF_ENV}"

    SfCommand "fos:elastica:populate -e ${SF_ENV}"
}

LoadFixtures() {
    [[ $2 != "" ]] && SF_ENV=$2 || SF_ENV=dev
    ValidateSymfonyEnvName ${SF_ENV}

    SfCommand "doctrine:fixtures:load --append --fixtures=src/Ekyna/Bundle/MediaBundle --fixtures=src/AppBundle -e ${SF_ENV}"

    SfCommand "fos:elastica:populate -e ${SF_ENV}"
}

Purge() {
    [[ $1 != "" ]] && SF_ENV=$1 || SF_ENV=dev
    ValidateSymfonyEnvName ${SF_ENV}

    # TODO Execute varnish "curl -X PURGE localhost"
    Execute redis "redis-cli flushall"

    SfCommand "doctrine:cache:clear-metadata -e ${SF_ENV}"
    SfCommand "doctrine:cache:clear-query -e ${SF_ENV}"
    SfCommand "doctrine:cache:clear-result -e ${SF_ENV}"
    SfCommand "cache:clear -e ${SF_ENV}"
}

Reset() {
    ValidateDockerEnvName $1

    ComposeDown $1
    RemoveNetworkAndVolumes

    sleep 2

    cd $ROOT_DIR

    rm -Rf var/data
    mkdir var/data
    touch var/data/.gitkeep

    rm -Rf var/cache
    mkdir var/cache
    touch var/cache/.gitkeep

    CreateNetworkAndVolumes
    sleep 2
    ComposeUp $1

    #sleep 7
    #InitializeProject $2
}

Backup() {
    ValidateDockerEnvName $1

    IsUpAndRunning ${PROJECT_NAME}_php
    if [[ $? -eq 0 ]]
    then
        printf "\e[31m$1 environment is not up and running.\e[0m\n"
        exit 1
    fi

    DATE=`date +%Y%m%d%H%M`
    if [[ -d "var/backup/$DATE" ]]
    then
        printf "\e[31mBackup $DATE has already been made.\e[0m\n"
        exit 1
    fi

    # Create the backup dir
    mkdir -p "var/backup/$DATE"

    # Database backup
    printf "Backup \e[1;33mdatabase\e[0m ... "
    docker exec ${PROJECT_NAME}_mysql ./backup.sh >> ${LOG_PATH} 2>&1
    if [[ $? -eq 0 ]]
    then
        mv var/backup/dump.sql var/backup/${DATE}/database.sql
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
        exit 1
    fi

    # Test database backup
    IsUpAndRunning ${PROJECT_NAME}_mysql_test
    if [[ $? -eq 1 ]]
    then
        printf "Backup \e[1;33mtest database\e[0m ... "
        docker exec ${PROJECT_NAME}_mysql_test ./backup.sh >> ${LOG_PATH} 2>&1
        if [[ $? -eq 0 ]]
        then
            mv var/backup/dump.sql var/backup/${DATE}/test_database.sql
            printf "\e[32mdone\e[0m\n"
        else
            printf "\e[31merror\e[0m\n"
            exit 1
        fi
    fi

    # File systems (var/data, web/tinymce, web/cache) backup
    printf "Backup \e[1;33mfile systems\e[0m ... "
    docker exec ${PROJECT_NAME}_php ./backup.sh >> ${LOG_PATH} 2>&1
    if [[ $? -eq 0 ]]
    then
        mv var/backup/var-data.tar var/backup/${DATE}
        if [[ -f var/backup/web-cache.tar ]]
        then
            mv var/backup/web-cache.tar var/backup/${DATE}
        fi
        if [[ -f var/backup/web-tinymce.tar ]]
        then
            mv var/backup/web-tinymce.tar var/backup/${DATE}
        fi
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
        exit 1
    fi

    # TODO remove old backup directories
}

Restore() {
    ValidateDockerEnvName $1
    ValidateBackupDate $2

    DATE=$2
    if [[ ! -d "var/backup/$DATE" ]]
    then
        printf "\e[31mBackup $2 does not exists.\e[0m\n"
        exit 1
    fi

    IsUpAndRunning ${PROJECT_NAME}_php
    if [[ $? -eq 0 ]]
    then
        printf "\e[31m$1 environment is not up and running.\e[0m\n"
        exit 1
    fi

    Reset $1
    sleep 10

    cd "$ROOT_DIR"

    # Copy files into backup root dir
    cp -f var/backup/${DATE}/var-data.tar var/backup
    if [[ -f var/backup/${DATE}/web-cache.tar ]]
    then
        cp -f var/backup/${DATE}/web-cache.tar var/backup
    fi
    if [[ -f var/backup/${DATE}/web-tinymce.tar ]]
    then
        cp -f var/backup/${DATE}/web-tinymce.tar var/backup
    fi
    cp -f var/backup/${DATE}/database.sql var/backup
    if [[ -f var/backup/${DATE}/test_database.sql ]]
    then
        cp -f var/backup/${DATE}/test_database.sql var/backup
    fi

    # Run restore
    printf "Restoring \e[1;33m$1\e[0m environment ... "
    docker exec ${PROJECT_NAME}_php ./restore.sh >> ${LOG_PATH} 2>&1
    if [[ $? -eq 0 ]]
    then
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
    fi

    # Remove copied files
    rm -f var/backup/var-data.tar
    if [[ -f var/backup/web-cache.tar ]]
    then
        rm -f var/backup/web-cache.tar
    fi
    if [[ -f var/backup/web-tinymce.tar ]]
    then
        rm -f var/backup/web-tinymce.tar
    fi
    rm -f var/backup/database.sql
    if [[ -f var/backup/test_database.sql ]]
    then
        rm -f var/backup/test_database.sql
    fi
}

# ----------------------------- EXEC -----------------------------

case $1 in
    # -------------- UP --------------
    up)
        CreateNetworkAndVolumes

        ComposeUp $2
    ;;
    # ------------- DOWN -------------
    down)
        ComposeDown $2
    ;;
    # ------------- BUILD -------------
    build)
        if [[ "" != "$3" ]]
        then
            ServiceBuild $2 $3
        else
            ComposeBuild $2
        fi
    ;;
    # ------------- RESTART -------------
    restart)
        if [[ "" != "$3" ]]
        then
            ServiceRestart $2 $3
        else
            ComposeRestart $2
        fi
    ;;
    # ------------- RUN -------------
    run)
        ValidateDockerEnvName $2
        ValidateServiceName $3

        Run $2 $3 "${*:4}"
    ;;
    # ------------- EXEC -------------
    exec)
        ValidateServiceName $2

        Execute $2 "${*:3}"
    ;;
    # ------------- COMPOSER -------------
    composer)
        Run prod php "composer ${*:2}"
    ;;
    # ------------- SYMFONY -------------
    sf)
        SfCommand "${*:2}"
    ;;
    # ------------- PURGE -------------
    purge)
        Purge $2
    ;;
    # ------------- RequireJs -------------
    rjs)
        SfCommand "a:i -e prod"
        SfCommand "e:r:b -e prod"
        r.js -o web/build.js
        SfCommand "a:i --relative"

        rm -f web/build.js
        rm -f web/js/require-config.js
    ;;
    # ------------- RESET ------------
    reset)
        ValidateDockerEnvName $2

        Title "Resetting [$2] stack"
        Warning "All data will be lost !"
        Confirm

        Reset $2
    ;;
    # ------------- INIT ------------
    init)
        ValidateSymfonyEnvName $2

        Title "Initializing php [$2]"
        Confirm

        InitializeProject $2
    ;;
    # ------------- FIXTURES ------------
    fixtures)
        ValidateDockerEnvName $2

        Title "Loading fixtures into [$2] stack"
        Confirm

        LoadFixtures
    ;;
    # ------------- BACKUP ------------
    backup)
        ValidateDockerEnvName $2

        Title "Backup"
        Confirm

        Backup $2
    ;;
    # ------------- RESTORE ------------
    restore)
        ValidateDockerEnvName $2
        ValidateBackupDate $3

        Title "Restore"
        Confirm

        Restore $2 $3
    ;;
    # --------- PREPARE (tests) ---------
    prepare)
        Title "Prepare tests"
        Warning "Stack must be reset first."
        Confirm

        Execute php "rm -rf var/test/data && rm -rf var/cache/test"
        InitializeProject test
        Backup dev

        cp var/backup/data_test.tar tests/data.tar
        cp var/backup/sf_dev_test_dump.sql tests/db.sql
    ;;
    # ------------- IMAGE BUILD -------------
    image-build)
        ValidateImageName $2

        Title "Build ${REGISTRY}${PROJECT_NAME}/$2"
        Confirm

        ImageBuild $2
    ;;
    # ------------- IMAGE BUILD -------------
    image-push)
        ValidateImageName $2

        Title "Build ${REGISTRY}${PROJECT_NAME}/$2"
        Confirm

        ImagePush $2
    ;;
    # ------------- HELP -------------
    *)
        Help "Usage:  ./manage.sh [action] [options]

\t\e[0mup\e[2m env\t\t\t Create and start containers for the [env] environment.
\t\e[0mdown\e[2m env\t\t Stop and remove containers for the [env] environment.
\t\e[0mbuild\e[2m env [service]\t Build the services images for the [env] environment.
\t\e[0mrestart\e[2m env [service]\t Restart the services for the [env] environment.
\t\e[0mrun\e[2m env service cmd\t Run the [command] in the [service] container of [env] environment.
\t\e[0mexec\e[2m service cmd\t Run the [command] in the [service] container.
\t\e[0mpurge\e[2m [env]\t\t Purges the cache.
\t\e[0mrjs\e[2m\t\t\t Require JS Build.

\t\e[0msf\e[2m env command\t\t Run the symfony [command] in the [env] environment's php container.
\t\e[0mcomposer\e[2m command\t Run a composer [command] in the prod environment's php container.
\t\e[0mreset\e[2m env\t\t Reset the [env] environment.
\t\e[0minit\e[2m env\t\t Initialize the php container for the [env] environment.
\t\e[0mfixtures\e[2m env\t\t Reset the [env] environment.
\t\e[0mbackup\e[2m env\t\t Backup the [env] environment.
\t\e[0mrestore\e[2m env date\t Restore the [date] backup for the [env] environment.
\t\e[0mprepare\e[2m\t\t\t Prepare the tests.

\t\e[0mimage-build\e[2m name\t Build the image for the [name] service.
\t\e[0mimage-push\e[2m name\t\t Push the image for the [name] service."
    ;;
esac

printf "\n"
