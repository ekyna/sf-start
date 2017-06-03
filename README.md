Ekyna Symfony Start
===================

Starting a symfony project with ekyna's bundles.

## Installation

Configure the project (replace "__start__" occurrences with your project name):

- etc/docker/config/dev/xdebug.ini
- etc/docker/config/elasticsearch.yml
- etc/docker/config/mysql.env
- etc/docker/config/mysql.test.env

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
