# FluxIlias

This project contains docker images for ILIAS based on alpine linux (Expect database image)

ILIAS is based on php-fpm

For the web it uses nginx

For the database it uses mysql

Addition there are images for cron, ilserver and chatroom

There is also an image of php-fpm for development

It is assumed that docker and docker-compose is already installed on your server, and you have some basic knowledge of this

For start download a `docker-compose.yml` of the [examples folder](examples) to the directory in which you want to store ILIAS and adjust placeholders

Please also download the `.gitignore` for ensure not to push installation data like database, logs, ...

Builds of the docker images are available on the github docker registry, if you prefer to build self, look at the [gitlab ci file](.gitlab-ci.yml) how to do (You don't need gitlab) - The build process can take over 30 minutes (Depending on which images and versions you wish to build)

The design of the docker images is that the ILIAS source code and maybe plugins/skins are maintained separate from this

Either you can use additional [FluxReposFetcher](https://github.com/fluxapps/FluxReposFetcher) for maintain the used repos in a single `repos.yml` file (See more infos there)

Or manually clone ILIAS with the follow command (Adjust version number)

```shell
git clone -b release_%version% https://github.com/ILIAS-eLearning/ILIAS ilias
```

And if needed manually clone some plugins or skins to `ilias/Customizing/...`

These docker images are supporting minimal ILIAS 6, older versions will not work

You can start/update the containers with the follow command

```shell
docker-compose pull && docker-compose up -d
```

You don't need to install composer dependencies of ILIAS, because the ilias container will do automatic this

Also the install/update/migrate setup cli is auto be called in the ilias container

You can watch that process with

```shell
docker-compose logs -f
```

After some minutes (Depending on first run or state of database) you can access the installation according port forwarding configuration in `docker-compose.yml` on your web browser

If ILIAS is not init yet, the cron, ilserver and chatroom containers will exit, you need to restart it manually after that (May you should temporarily remove `restart:always` to avoid endless restart loop)

The example `docker-compose.yml` store the ilias data in a `data` folder on your working directory

Here a brief overview of the folder structure of the default configuration

- docker-compose.yml
- ilias > Mounted to `/var/www/html` inside most containers
    - data > Symlink to `/var/iliasdata/web` (Only works inside container)
    - ilias.ini.php > Symlink to `/var/iliasdata/ilias.ini.php` (Only works inside container)
    - index.php
    - ilias.php
    - Customizing
      - ...
    - ...
- data
    - mysql > Mounted to `/var/lib/mysql` inside mysql container
    - ilias > Mounted to `/var/iliasdata` inside most containers
      - config.json > (Re)generated config for ILIAS setup cli
      - ilias.ini.php
      - default
        - chatroom
          - server.cfg
          - client.cfg
          - ...
        - ...
      - web
        - default
            - client.ini.php
            - ...
      - ilserver.properties
      - ilserver
        - default_0
            - ...
      - ...
    - log
      - mysql > Mounted to `/var/log/mysql` inside mysql container
        - error.log
      - ilias > Mounted to `/var/log/ilias` inside ilias and cron containers
        - ilias.log
        - errors (prod only)
        - cron.log
      - nginx > Mounted to `/var/log/nginx` inside nginx container
        - access.log
        - error.log
      - ilserver > Mounted to `/var/log/ilserver` inside ilserver container
        - ilserver.log
      - chatroom > Mounted to `/var/log/chatroom` inside chatroom container
        - chatroom.log
        - error.log
      - xdebug > Mounted to `/var/log/xdebug` inside ilias and cron containers (dev only)
        - xdebug.log
        - output
    - certs > Mounted to `/certs` inside ilias and chatroom containers (prod only)
        - ilias.cert
        - ilias.key
        - ilias.pem

You can find more information (For example possible environment variables) in the corresponding readme in the [images folder](images)

To remove the containers, you can use the follow command

```shell
docker-compose down --remove-orphans
```

If you wish a fresh installation you can complete remove the data with the follow command

```shell
docker-compose down --remove-orphans && sudo rm -rf data && sudo unlink ilias/data && sudo unlink ilias/ilias.ini.php
```
