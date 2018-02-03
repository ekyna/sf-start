#!/bin/bash

# Required vars
if [ -z ${ROOT_DIR+x} ]; then printf "\e[31mThe 'ROOT_DIR' variable is not defined.\e[0m\n"; exit 1; fi
if [ -z ${DOCKER_DIR+x} ]; then printf "\e[31mThe 'DOCKER_DIR' variable is not defined.\e[0m\n"; exit 1; fi
if [ -z ${COMPOSE_PROJECT_NAME+x} ]; then printf "\e[31mThe 'COMPOSE_PROJECT_NAME' variable is not defined.\e[0m\n"; exit 1; fi
if [ -z ${REGISTRY+x} ]; then printf "\e[31mThe 'REGISTRY' variable is not defined.\e[0m\n"; exit 1; fi
if [ -z ${IMAGE_PREFIX+x} ]; then printf "\e[31mThe 'IMAGE_PREFIX' variable is not defined.\e[0m\n"; exit 1; fi
if [ -z ${LOG_PATH+x} ]; then printf "\e[31mThe 'LOG_PATH' variable is not defined.\e[0m\n"; exit 1; fi

# Vars defaults
DOCKER_ENV_REGEX="${DOCKER_ENV_REGEX:-^dev|prod$}"
SYMFONY_ENV_REGEX="${SYMFONY_ENV_REGEX:-^dev|prod|test$}"
SERVICE_REGEX="${SERVICE_REGEX:-^nginx|php|mysql|mysql_test|elasticsearch$}"
IMAGE_REGEX="${IMAGE_REGEX:-^nginx|php$}"
COMMAND_REGEX="${COMMAND_REGEX:-^[a-z0-9_]+(:[a-z0-9_]+)*(\s-((a-z)|(-[a-z-]+(=[a-zA-Z0-9/]+))))*$}"
BACKUP_REGEX="^[0-9]{12}$"


# ----------------------------- HEADER -----------------------------

Title() {
    printf "\n\e[1;46m --------- $1 --------- \e[0m\n\n"
}

Warning() {
    printf "\e[31;43m$1\e[0m\n"
}

Help() {
    printf "\e[2m$1\e[0m\n";
}

Confirm () {
    printf "\n"
    choice=""
    while [ "$choice" != "n" ] && [ "$choice" != "y" ]
    do
        printf "Do you want to continue ? (N/Y)"
        read choice
        choice=$(echo ${choice} | tr '[:upper:]' '[:lower:]')
    done
    if [ "$choice" = "n" ]; then
        printf "\nAbort by user.\n"
        exit 0
    fi
    printf "\n"
}

ClearLogs() {
    echo "" > ${LOG_PATH}
}

# ---------------------- PARAMETERS VALIDATION ----------------------

# ValidateDockerEnvName date
ValidateBackupDate() {
    if [[ ! $1 =~ $BACKUP_REGEX ]]
    then
        printf "\e[31mInvalid backup date '$1'\e[0m\n"
        exit 1
    fi
}

# ValidateDockerEnvName [env]
ValidateDockerEnvName() {
    if [[ ! $1 =~ $DOCKER_ENV_REGEX ]]
    then
        printf "\e[31mInvalid docker environment '$1'\e[0m\n"
        exit 1
    fi
}

# ValidateServiceName [service]
ValidateServiceName() {
    if [[ ! $1 =~ $SERVICE_REGEX ]]
    then
        printf "\e[31mInvalid service name\e[0m\n"
        exit 1
    fi
}

# ValidateImageName [service]
ValidateImageName() {
    if [[ ! $1 =~ $IMAGE_REGEXP ]]
    then
        printf "\e[31mInvalid image name\e[0m\n"
        exit 1
    fi
}

## ValidateSymfonyEnvName [env]
ValidateSymfonyEnvName() {
    if [[ ! $1 =~ $SYMFONY_ENV_REGEX ]]
    then
        printf "\e[31mInvalid symfony environment '$1'\e[0m\n"
        exit 1
    fi
}

# ----------------------------- IMAGE -----------------------------

ImageBuild() {
    ValidateImageName $1

    if [ ! -f ${ROOT_DIR}/build/.env ]
    then
        printf "\e[31mFile build/.env is missing.\e[0m\n" && exit 1
    fi

    printf "Building image \e[1;33m${REGISTRY}${IMAGE_PREFIX}$1\e[0m ... "

    docker build \
        --build-arg user=${B_USER} \
        --build-arg uid=${B_UID} \
        --build-arg group=${B_GROUP} \
        --build-arg gid=${B_GID} \
        -f ${ROOT_DIR}/build/$1 \
        -t ${REGISTRY}${IMAGE_PREFIX}$1:latest .
}

ImagePush() {
    ValidateImageName $1

    if [ ! -f ${ROOT_DIR}/build/.env ]
    then
        printf "\e[31mFile build/.env is missing.\e[0m\n" && exit 1
    fi

    printf "Pushing image \e[1;33m${REGISTRY}${IMAGE_PREFIX}$1\e[0m ... "

    docker push ${REGISTRY}${IMAGE_PREFIX}$1:latest
}

# ----------------------------- NETWORK -----------------------------

NetworkCreate() {
    printf "Creating network \e[1;33m$1\e[0m ... "
    if [ "$(docker network ls | grep $1)" ]
    then
        printf "\e[36mexists\e[0m\n"
    else
        docker network create $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mcreated\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
    fi
}

NetworkRemove() {
    printf "Removing network \e[1;33m$1\e[0m ... "
    if [ "$(docker network ls | grep $1)" ]
    then
        docker network rm $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mremoved\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
    else
        printf "\e[35munknown\e[0m\n"
    fi
}

# ----------------------------- VOLUME -----------------------------

VolumeCreate() {
    printf "Creating volume \e[1;33m$1\e[0m ... "
    if [ "$(docker volume ls | grep $1)" ]
    then
        printf "\e[36mexists\e[0m\n"
    else
        docker volume create --name $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mcreated\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
    fi
}

VolumeRemove() {
    printf "Removing volume \e[1;33m$1\e[0m ... "
    if [ "$(docker volume ls | grep $1)" ]
    then
        docker volume rm $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mremoved\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
    else
        printf "\e[35munknown\e[0m\n"
    fi
}

# ----------------------------- COMPOSE -----------------------------

IsUpAndRunning() {
    if [[ "$(docker ps -a | grep $1)" ]]
    then
        return 1
    fi
    return 0
}

# ComposeUp [env]
ComposeUp() {
    ValidateDockerEnvName $1

    IsUpAndRunning "${COMPOSE_PROJECT_NAME}_php"
    if [[ $? -eq 1 ]]
    then
        printf "\e[31mAlready up and running.\e[0m\n"
        exit 1
    fi

    printf "Composing up \e[1;33m$1\e[0m environment ... "
    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml up -d >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ComposeDown [env]
ComposeDown() {
    ValidateDockerEnvName $1

    printf "Composing down \e[1;33m$1\e[0m environment ... "
    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml down -v --remove-orphans >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ComposeBuild [env]
ComposeBuild() {
    ValidateDockerEnvName $1

    printf "Building \e[1;33m$1\e[0m environment ... "

    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml build >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ComposeStart [env]
ComposeStart() {
    ValidateDockerEnvName $1

    printf "Starting \e[1;33m$1\e[0m environment ... "

    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml start >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ComposeRestart [env]
ComposeRestart() {
    ValidateDockerEnvName $1

    printf "Restarting \e[1;33m$1\e[0m environment ... "

    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml restart >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ComposeCreate [env]
ComposeCreate() {
    ValidateDockerEnvName $1

    printf "Creating \e[1;33m$1\e[0m environment ... "

    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml create --force-recreate >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ----------------------------- SERVICE -----------------------------

# ServiceBuild [env] [service]
ServiceBuild() {
    ValidateDockerEnvName $1
    ValidateServiceName $2

    printf "Building service [$1] \e[1;33m$2\e[0m ... "

    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml build $2 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ServiceStart [env] [service]
ServiceStart() {
    ValidateDockerEnvName $1
    ValidateServiceName $2

    printf "Starting service [$1] \e[1;33m$2\e[0m ... "

    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml start $2 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ServiceStop [env] [service]
ServiceStop() {
    ValidateDockerEnvName $1
    ValidateServiceName $2

    printf "Stopping service [$1] \e[1;33m$2\e[0m ... "

    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml stop $2 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ServiceRestart [env] [service]
ServiceRestart() {
    ValidateDockerEnvName $1
    ValidateServiceName $2

    printf "Restarting service [$1] \e[1;33m$2\e[0m ... "

    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml restart $2 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ServiceCreate [env] [service]
ServiceCreate() {
    ValidateDockerEnvName $1
    ValidateServiceName $2

    printf "Creating service [$1] \e[1;33m$2\e[0m ... "

    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml create --force-recreate $2 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ----------------------------- SYMFONY -----------------------------

SfCheckParameters() {
    if [[ ! -f "$ROOT_DIR/app/config/parameters.yml" ]]
    then
        printf "\e[31mParameters file not found\e[0m\n"
        exit 1;
    fi
}

Execute() {
    ValidateServiceName $1

    printf "Executing $2\n"

    printf "\n"
    if [[ "$(uname -s)" = \MINGW* ]]
    then
        winpty docker exec -it ${COMPOSE_PROJECT_NAME}_$1 $2
    else
        docker exec -it ${COMPOSE_PROJECT_NAME}_$1 $2
    fi
    printf "\n"
}

Run() {
    ValidateDockerEnvName $1
    ValidateServiceName $2

    printf "\n"
    printf "Running \e[1;33m$3\e[0m on \e[1;33m$2\e[0m service for \e[1;33m$1\e[0m env:\n"

    cd ${DOCKER_DIR} && \
        docker-compose -f common.yml -f $1.yml \
        run --rm $2 $3
}

SfCommand() {
    Execute php "php bin/console $1"
}

Composer() {
    Execute php "composer $1"
}

# ----------------------------- TOOLS -----------------------------

# ToolsUp
ToolsUp() {
    IsUpAndRunning "${COMPOSE_PROJECT_NAME}_php"
    if [[ $? -eq 0 ]]
    then
        printf "\e[31mStack is not up.\e[0m\n"
        exit 1
    fi

    printf "Composing up \e[1;33mtools\e[0m ... "
    cd ${DOCKER_DIR} && \
        docker-compose -f tools.yml up -d >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ToolsDown
ToolsDown() {
    IsUpAndRunning "${COMPOSE_PROJECT_NAME}_sftp"
    if [[ $? -eq 0 ]]
    then
        printf "\e[31mTools are not up.\e[0m\n"
        exit 1
    fi

    printf "Composing down \e[1;33mtools\e[0m ... "
    cd ${DOCKER_DIR} && \
        docker-compose -f tools.yml down -v >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}
