#!/bin/bash

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/7;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

ENVIRONMENT="prod"

while [[ $# > 1 ]]
do
    key="$1"
    case $key in
        -e|--e)
        ENVIRONMENT="$2"
        shift # past argument
        ;;
        *)
              # unknown option
        ;;
    esac
    shift # past argument or value
done

echo -e "Installing with \e[32m$ENVIRONMENT\e[39m environment ..."

choice=""
while [ "$choice" != "n" ] && [ "$choice" != "y" ]
do
    printf  "\e[46mDo you want to continue ?\e[49m (y/n) "
    read choice
    choice=$(echo ${choice} | tr '[:upper:]' '[:lower:]')
done
if [ "$choice" == "n" ]; then
    exit 0
fi

if [[ ${ENVIRONMENT} == "dev" ]]
then
    rm -Rf var/media/media/
    rm -Rf web/cache
    rm -Rf app/cache/dev

    php bin/console cache:clear --quiet --env=${ENVIRONMENT} || exit 1

    eval "$(parse_yaml ./app/config/parameters.yml "cfg_")"

    mysqladmin -u$cfg_parameters_database_user -p$cfg_parameters_database_password drop -f $cfg_parameters_database_name -b &>/dev/null || exit 1
    mysqladmin -u$cfg_parameters_database_user -p$cfg_parameters_database_password create $cfg_parameters_database_name -b &>/dev/null || exit 1

    php bin/console doctrine:migrations:migrate --no-interaction --quiet --env=${ENVIRONMENT} || exit 1

    php bin/console ekyna:install --no-interaction --env=${ENVIRONMENT} || exit 1
    php bin/console ekyna:admin:create-super-admin admin@example.org admin John Doe --env=${ENVIRONMENT} || exit 1

    choice=""
    while [ "$choice" != "n" ] && [ "$choice" != "y" ]
    do
        printf  "\e[46mDo you want to load fixtures data ?\e[49m (y/n) "
        read choice
        choice=$(echo ${choice} | tr '[:upper:]' '[:lower:]')
    done
    if [ "$choice" == "y" ]; then
        php bin/console d:f:l --append --fixtures=src/AppBundle --env=${ENVIRONMENT} || exit 1
    fi

else
    composer install

    php bin/console doctrine:database:create || exit 1
    php bin/console doctrine:migrations:migrate --no-interaction || exit 1

    rm -Rf app/cache/prod
    php bin/console cache:clear --env=prod || exit 1

    php bin/console ekyna:install --env=prod || exit 1
    php bin/console ekyna:requirejs:build --env=prod || exit 1
fi
