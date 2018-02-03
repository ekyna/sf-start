#!/bin/bash

if [ ! -f ./dev/docker/.env ]
then
    printf "\e[31mPlease create dev/docker/.env file.\e[0m\n"
    exit 1
fi

source ./dev/docker/.env

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_DIR="$ROOT_DIR/dev/docker"
LOG_PATH="$ROOT_DIR/docker_logs.txt"

DOCKER_ENV_REGEX="^dev|prod$"
SYMFONY_ENV_REGEX="^dev|prod|test$"
SERVICE_REGEX="^nginx|php|mysql|mysql_test|elasticsearch|redis|varnish$"
IMAGE_REGEX="^nginx|php$"
COMMAND_REGEX="^[a-z0-9_]+(:[a-z0-9_]+)*(\s-((a-z)|(-[a-z-]+(=[a-zA-Z0-9/]+))))*$"


source ./dev/utils.sh

# Clear logs
echo "" > ${LOG_PATH}

# ----------------------------- ACTIONS -----------------------------

CreateNetworkAndVolumes() {
    NetworkCreate "${COMPOSE_PROJECT_NAME}-network"
    VolumeCreate "${COMPOSE_PROJECT_NAME}-vendor"
    VolumeCreate "${COMPOSE_PROJECT_NAME}-database"
    VolumeCreate "${COMPOSE_PROJECT_NAME}-elasticsearch"
    #VolumeCreate "${COMPOSE_PROJECT_NAME}-database-migration"
    VolumeCreate "${COMPOSE_PROJECT_NAME}-database-test"
}

RemoveNetworkAndVolumes() {
    #NetworkRemove "${COMPOSE_PROJECT_NAME}-network"
    #VolumeRemove "${COMPOSE_PROJECT_NAME}-vendor"
    VolumeRemove "${COMPOSE_PROJECT_NAME}-database"
    VolumeRemove "${COMPOSE_PROJECT_NAME}-elasticsearch"
    #VolumeRemove "${COMPOSE_PROJECT_NAME}-database-migration"
    VolumeRemove "${COMPOSE_PROJECT_NAME}-database-test"
}

InitializeProject() {
    [[ $1 != "" ]] && SF_ENV=$1 || SF_ENV=dev
    ValidateSymfonyEnvName ${SF_ENV}

    Composer "install"
    #SfCommand "cache:clear -e ${SF_ENV}"
    #SfCommand "assets:install --relative -e ${SF_ENV}"

    #SfCommand "doctrine:schema:update --force -e ${SF_ENV}"
    SfCommand "doctrine:migration:migrate --no-interaction --allow-no-migration -e ${SF_ENV}"

    SfCommand "ekyna:install --no-interaction -e ${SF_ENV}"
    SfCommand "ekyna:admin:create-super-admin admin@example.org admin -e ${SF_ENV}"

    SfCommand "fos:elastica:populate -e ${SF_ENV}"
}

LoadFixtures() {
    [[ $2 != "" ]] && SF_ENV=$2 || SF_ENV=dev
    ValidateSymfonyEnvName ${SF_ENV}

    SfCommand "doctrine:fixtures:load --append --fixtures=src/AppBundle -e ${SF_ENV}"

    SfCommand "fos:elastica:populate -e ${SF_ENV}"
}

Purge() {
    [[ $1 != "" ]] && SF_ENV=$1 || SF_ENV=dev
    ValidateSymfonyEnvName ${SF_ENV}

    docker exec ${COMPOSE_PROJECT_NAME}_redis redis-cli flushall

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

    rm -Rf "$ROOT_DIR/var/data"
    mkdir "$ROOT_DIR/var/data"
    touch "$ROOT_DIR/var/data/.gitkeep"

    rm -Rf "$ROOT_DIR/var/cache"
    mkdir "$ROOT_DIR/var/cache"
    touch "$ROOT_DIR/var/cache/.gitkeep"

    rm -Rf "$ROOT_DIR/web/cache"
    mkdir "$ROOT_DIR/web/cache"

    rm -Rf "$ROOT_DIR/web/tinymce"
    mkdir "$ROOT_DIR/web/tinymce"

    SfCheckParameters
    CreateNetworkAndVolumes
    sleep 2
    ComposeUp $1

    sleep 7
    InitializeProject $2
}

Backup() {
    IsUpAndRunning ${COMPOSE_PROJECT_NAME}_php
    if [[ $? -eq 0 ]]
    then
        printf "\e[31mEnvironment is not up and running.\e[0m\n"
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
    docker exec ${COMPOSE_PROJECT_NAME}_mysql ./backup.sh >> ${LOG_PATH} 2>&1
    if [[ $? -eq 0 ]]
    then
        mv var/backup/db.sql var/backup/${DATE}/db.sql
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
        exit 1
    fi

    # Test database backup
    IsUpAndRunning ${COMPOSE_PROJECT_NAME}_mysql_test
    if [[ $? -eq 1 ]]
    then
        printf "Backup \e[1;33mtest database\e[0m ... "
        docker exec ${COMPOSE_PROJECT_NAME}_mysql_test ./backup.sh >> ${LOG_PATH} 2>&1
        if [[ $? -eq 0 ]]
        then
            mv var/backup/db.sql var/backup/${DATE}/db_test.sql
            printf "\e[32mdone\e[0m\n"
        else
            printf "\e[31merror\e[0m\n"
            exit 1
        fi
    fi

    # File systems (var/data, web/tinymce, web/cache) backup
    printf "Backup \e[1;33mfile systems\e[0m ... "
    docker exec ${COMPOSE_PROJECT_NAME}_php ./backup.sh >> ${LOG_PATH} 2>&1
    if [[ $? -eq 0 ]]
    then
        mv var/backup/var-data.tar var/backup/${DATE}
        if [[ -f var/backup/var-test-data.tar ]]; then mv var/backup/var-test-data.tar var/backup/${DATE}; fi
        if [[ -f var/backup/web-cache.tar ]]; then mv var/backup/web-cache.tar var/backup/${DATE}; fi
        if [[ -f var/backup/web-tinymce.tar ]]; then mv var/backup/web-tinymce.tar var/backup/${DATE}; fi
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
        exit 1
    fi
}

Restore() {
    IsUpAndRunning ${COMPOSE_PROJECT_NAME}_php
    if [[ $? -eq 0 ]]
    then
        printf "\e[31mEnvironment is not up and running.\e[0m\n"
        exit 1
    fi

    ValidateBackupDate $1

    DATE=$1
    if [[ ! -d "var/backup/$DATE" ]]
    then
        printf "\e[31mBackup $1 does not exists.\e[0m\n"
        exit 1
    fi

    cd "$ROOT_DIR"

    LOG_PATH="var/logs/restore.log"
    DB_ONLY=0
    if [ "$2" == "--db" ]; then DB_ONLY=1; fi

    # Copy files into backup root dir
    printf "Copying backup files ... "
    if [ ${DB_ONLY} -eq 0 ]
    then
        cp -f var/backup/${DATE}/var-data.tar var/backup
        if [[ -f var/backup/${DATE}/web-cache.tar ]]; then cp -f var/backup/${DATE}/web-cache.tar var/backup; fi
        if [[ -f var/backup/${DATE}/web-tinymce.tar ]]; then cp -f var/backup/${DATE}/web-tinymce.tar var/backup; fi
    fi
    cp -f var/backup/${DATE}/db.sql var/backup
    if [[ -f var/backup/${DATE}/db_test.sql ]]; then cp -f var/backup/${DATE}/db_test.sql var/backup; fi
    printf "\e[32mdone\e[0m\n"


    # Restore database
    printf "Restoring \e[1;33mdatabase\e[0m ... "
    docker exec ${COMPOSE_PROJECT_NAME}_mysql ./restore.sh >> ${LOG_PATH} 2>&1
    if [ $? -eq 0 ]
    then
        printf "\e[32mdone\e[0m\n"

        if [ ${DB_ONLY} -eq 0 ]
        then
            # Restore filesystems
            docker exec ${COMPOSE_PROJECT_NAME}_php ./restore.sh
            if [[ $? -ne 0 ]]
            then
                printf "\e[31mError: check restore log file.\e[0m\n"
            fi
        fi
    else
        printf "\e[31merror\e[0m\n"
    fi

    # Clear copied files
    printf "Clearing backup files ... "
    if [ ${DB_ONLY} -eq 0 ]
    then
        rm -f var/backup/var-data.tar
        if [[ -f var/backup/web-cache.tar ]]; then rm -f var/backup/web-cache.tar; fi
        if [[ -f var/backup/web-tinymce.tar ]]; then rm -f var/backup/web-tinymce.tar; fi
    fi
    rm -f var/backup/db.sql
    if [[ -f var/backup/db_test.sql ]]; then rm -f var/backup/db_test.sql; fi
    printf "\e[32mdone\e[0m\n"
}

BackupTest() {
    IsUpAndRunning ${COMPOSE_PROJECT_NAME}_php
    if [[ $? -eq 0 ]]
    then
        printf "\e[31mEnvironment is not up and running.\e[0m\n"
        exit 1
    fi

    # Test database backup
    IsUpAndRunning ${COMPOSE_PROJECT_NAME}_mysql_test
    if [[ $? -eq 1 ]]
    then
        printf "Backup \e[1;33mtest database\e[0m ... "
        Execute mysql_test ./backup.sh
        if [[ $? -eq 0 ]]
        then
            mv var/backup/dump.sql var/backup/db_test.sql
            printf "\e[32mdone\e[0m\n"
        else
            printf "\e[31merror\e[0m\n"
            exit 1
        fi
    fi

    # File systems (var/data, web/tinymce, web/cache) backup
    printf "Backup \e[1;33mfile systems\e[0m ... "
    Execute php ./backup.sh
    if [[ $? -eq 0 ]]
    then
        printf "\e[32mdone\e[0m\n"
    else
        printf "\e[31merror\e[0m\n"
        exit 1
    fi

    # TODO remove old backup directories
}

Prepare() {
    ComposeDown dev
    VolumeRemove "${COMPOSE_PROJECT_NAME}-test-database"

    sleep 4

    cd "$ROOT_DIR"

    if [[ -d var/test/data ]]; then rm -Rf var/test/data; fi
    mkdir var/test/data

    if [[ -d var/test/data ]]; then rm -Rf var/cache/test; fi
    mkdir var/cache/test

    SfCheckParameters
    CreateNetworkAndVolumes
    sleep 2
    ComposeUp dev

    sleep 4

    InitializeProject test
    BackupTest

    sleep 6

    cd "$ROOT_DIR"

    if [[ -f tests/data.tar ]]; then rm -f tests/data.tar; fi
    cp var/backup/var-test-data.tar tests/data.tar

    if [[ -f tests/db.sql ]]; then rm -f tests/db.sql; fi
    cp var/backup/db_test.sql tests/db.sql
}

RJsBuild() {
    SfCommand "cache:clear -e prod"
    SfCommand "assets:install -e prod"
    SfCommand "ekyna:requirejs:build -e prod"
    r.js -o web/build.js
    SfCommand "assets:install --relative"

    rm -f web/build.js
    rm -f web/js/require-config.js
}

Deploy() {
    IsUpAndRunning ${COMPOSE_PROJECT_NAME}_php
    if [[ $? -eq 0 ]]
    then
        printf "\e[31mEnvironment is not up and running.\e[0m\n"
        exit 1
    fi

    RJsBuild

    # TODO user, group, uid, gid build ARGS (use <user> as filename when copying crontab in dockerfile-php)

    ImageBuild php
    ImageBuild nginx
    ImagePush php
    ImagePush nginx

    #ssh ${SSH_REMOTE} 'cd www && ./manage.sh update --yes'
}

# ----------------------------- EXEC -----------------------------

case $1 in
    # -------------- UP --------------
    up)
        SfCheckParameters

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
    # ------------- CREATE -------------
    create)
        if [[ "" != "$3" ]]
        then
            ServiceCreate $2 $3
        else
            ComposeCreate $2
        fi
    ;;
    # ------------- START -------------
    start)
        if [[ "" != "$3" ]]
        then
            ServiceStart $2 $3
        else
            ComposeStart $2
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
        Composer "${*:2}"
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
        RJsBuild
    ;;
    # ------------- RESET ------------
    reset)
        ValidateDockerEnvName $2

        Title "Resetting stack"
        Warning "All data will be lost !"
        Confirm

        Reset $2 $2
    ;;
    # ------------- INIT ------------
    init)
        ValidateDockerEnvName $2

        Title "Initializing php [$2]"
        Confirm

        InitializeProject
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
        Title "Backup"
        Confirm

        Backup
    ;;
    # ------------- RESTORE ------------
    restore)
        if [[ "$2" == "" ]]
        then
            printf "\e[31mPlease provide a backup date to restore:\e[0m\n"
            cd var/backup && for i in $(ls -d */); do echo ${i%%/}; done
            exit 1
        fi

        ValidateBackupDate $2

        Title "Restore"
        Confirm

        Restore $2 $3
    ;;
    # --------- PREPARE (tests) ---------
    prepare)
        Title "Prepare tests"
        Confirm

        Prepare
    ;;
    # -------------- TOOLS --------------
    tools)
        if [[ ! $2 =~ ^up|down$ ]]
        then
            printf "\e[31mExpected 'up' or 'down'\e[0m\n"
            exit 1
        fi

        if [[ $2 == 'up' ]]
        then
            ToolsUp
        else
            ToolsDown
        fi
    ;;
    # ------------- IMAGE BUILD -------------
    image-build)
        ValidateImageName $2

        Title "Build ${REGISTRY}${IMAGE_PREFIX}$2"
        Confirm

        ImageBuild $2
    ;;
    # ------------- IMAGE BUILD -------------
    image-push)
        ValidateImageName $2

        Title "Push ${REGISTRY}${IMAGE_PREFIX}$2"
        Confirm

        ImagePush $2
    ;;
    # ------------- DEPLOY -------------
    deploy)
        Title "Deploying"
        Warning "                                     "
        Warning "   Did you generate migration(s) ?   "
        Warning "   Did you bump asset version ?      "
        Warning "                                     "
        Confirm

        Deploy
    ;;
    # ------------- HELP -------------
    *)
        Help "Usage:  ./manage.sh [action] [options]

 - \e[0mup\e[2m env\t\t Create and start containers for the [env] environment.
 - \e[0mdown\e[2m env\t\t Stop and remove containers for the [env] environment.
 - \e[0mbuild\e[2m env [service]\t Build the service(s) images for the [env] environment.
 - \e[0mcreate\e[2m env [service]\t Create the service(s) for the [env] environment.
 - \e[0mstart\e[2m env [service]\t Start the service(s) for the [env] environment.
 - \e[0mrestart\e[2m env [service] Restart the service(s) for the [env] environment.
 - \e[0mrun\e[2m env service cmd\t Run the [command] in the [service] container of [env] environment.
 - \e[0mexec\e[2m service cmd\t Run the [command] in the [service] container.
 - \e[0mpurge\e[2m [env]\t\t Purges the cache.
 - \e[0mrjs\e[2m\t\t\t Require JS Build.

 - \e[0msf\e[2m env command\t Run the symfony [command] in the [env] php container.
 - \e[0mcomposer\e[2m command\t Run a composer [command] in the prod php container.
 - \e[0mreset\e[2m env\t\t Reset the [env] environment.
 - \e[0minit\e[2m env\t\t Initialize the php container for the [env] environment.
 - \e[0mfixtures\e[2m env\t\t Reset the [env] environment.
 - \e[0mbackup\e[2m\t\t Backup the environment.
 - \e[0mrestore\e[2m date\t\t Restore the [date] backup.
 - \e[0mprepare\e[2m\t\t Prepare the tests.

 - \e[0mtools\e[2m up|down\t Start or stop tools containers.

 - \e[0mimage-build\e[2m name\t Build the image for the [name] service.
 - \e[0mimage-push\e[2m name\t Push the image for the [name] service.

 - \e[0mdeploy\e[2m\t\t Deploy on remote server."
    ;;
esac

printf "\n"
