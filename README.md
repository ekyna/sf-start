Ekyna Symfony Start
===================

Starting a symfony project with ekyna's bundles.

## Installation

Create app/config/parameters.yml file.

Configure the project (replace "__start__" occurrences with your project name) in files:

- etc/docker/config/.env
- etc/docker/config/mysql.env
- etc/docker/config/elasticsearch.yml
- etc/docker/config/dev/xdebug.ini

Run commands:

```
# Docker compose up
./manager.sh up dev

# Composer install
./manage.sh composer install --prefer-dist

# Initialize the project
./manager.sh init dev
```

TODO admin default login

TODO npm / bower / grunt (how to)
 
TODO requirejs build

TODO manage script commands

TODO docker deploy guide
