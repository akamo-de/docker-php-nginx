# Lightweight container for php and nginx

## Introduction
Small and secure version of the LE*P stack as container (so basically LEMP without mysql/mariadb).

## Software

 * [nginx](https://nginx.org/): Fast HTTP server
 * [PHP](https://www.php.net/): PHP is a popular general-purpose scripting language that is especially suited to web development. PHP is configured as FPM Service.

## Setup

### Docker-Compose:

> Create a docker-compose.yml file. The following template may be changed it as you require:

~~~
version: '2'
services:
  webserver-container:
    image: akamo/php-webapplication:latest
    restart: always
    environment:
      USERID: 10000
      GROUPID: 10000
      PHP_MAX_POST_SIZE: 64M
      PHP_MEMORY_LIMIT: 96M
    ports:
      - "127.0.0.1:8080:8080"
    volumes:
      - /path/to/local/www:/var/www/html
~~~

Changing the environment may affect the following behaviour:

**USERID**: The nummeric user ID of the user `web`, that is running PHP and nginx processes.

**GROUPID**: The nummeric group ID of the group `web`, that is running PHP and nginx processes. This group is the primary group for the user `web`,

**PHP_MAX_POST_SIZE**: The maximum size for POST and uploads configured within PHP.

**PHP_MEMORY_LIMIT**: The maximum memory limit configured within PHP.


The container path `/var/www/html` is the directory of the web-root. It is possible to map `/var/www/` instead if PHP code should be outside the of the document root of the nginx webserver.

The webserver is listening on port `8080`, because the nginx service is running as non-priviliged user within the container.


If you need support - please ask [us](https://akamo.de).
