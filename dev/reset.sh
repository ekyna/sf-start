#!/bin/sh

echo -e "Resetting dev environment ..."

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

rm -Rf var/cache/dev
rm -Rf var/data/dev
rm -Rf web/cache

php bin/console cache:clear || exit 1

php bin/console doctrine:schema:drop --force || exit 1
php bin/console doctrine:schema:create || exit 1

php bin/console ekyna:install --no-interaction || exit 1
php bin/console ekyna:admin:create-super-admin admin@example.org admin || exit 1

php bin/console doctrine:fixtures:load --append \
    --fixtures=src/Ekyna/Bundle/MediaBundle \
    --fixtures=src/AppBundle || exit 1

php bin/console fos:elastica:populate || exit 1

#php bin/console doctrine:fixtures:load --append --fixtures=src/AppBundle --fixtures=src/Ekyna/Bundle/MediaBundle
