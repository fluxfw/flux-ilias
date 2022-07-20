# flux-ilias

ILIAS base docker images

## Notes

- Even you use a proxy server you should use the ilias nginx image because it contains some dependencies which ILIAS needs (Like URL redirects or XAccel support)
- The install/update/migrate setup cli is auto be called on container (re)creation
  - The config json is automatic generated
  - Auto plugins setup are disabled because it's make problems with some plugins
- May additional manual config in ILIAS is automatic done
  - Set/override root user password
  - Create cron user / Override cron user password
  - Enable/disable ILIAS development mode
  - Enable/disable lucene search and lucene index cron job
  - Set smtp server
- The external `data` directory and `ilias.ini.php` are symlinks to the internal `data` directory to combine both in one

## database, ilias and nginx

Extends the ilias base image in a custom `Dockerfile` and download ILIAS core with the wished version

```dockerfile
FROM fluxfw/flux-ilias-ilias-base:php7.4 AS ilias

RUN /flux-ilias-ilias-base/bin/download-ilias-core.sh %version%
```

You may wish to download or copy other things like plugins or skins or apply some patches

```dockerfile
RUN (mkdir -p /var/www/html/Customizing/global/plugins/Services/X/Y/Z && cd /var/www/html/Customizing/global/plugins/Services/X/Y/Z && wget -O - https://github.com/x/y/archive/z.tar.gz | tar -xz --strip-components=1)
```

Extends the nginx base image too in the same `Dockerfile` and copy your ILIAS code base from your ilias image

```dockerfile
FROM fluxfw/flux-ilias-nginx-base:latest AS nginx
COPY --from=ilias /var/www/html /var/www/html
```

Currently, the follow versions are supported

- ILIAS 6 or newer
- PHP 7.4, 7.3 and 7.2 (8.0 is available only for development purposes)

You can build your custom images with

```shell
docker build . --pull --target ilias -t %image%/ilias:latest
docker build . --pull --target nginx -t %image%/nginx:latest
```

Create a `docker-compose.yaml` for run the containers

*You need to adjust placeholders and create secret files (Applies everywhere)*

```yaml
services:
    database:
        command: --character-set-server=utf8 --collation-server=utf8_general_ci
        environment:
            - MARIADB_DATABASE=ilias
            - MARIADB_PASSWORD_FILE=/run/secrets/database_ilias_password
            - MARIADB_ROOT_PASSWORD_FILE=/run/secrets/database_root_password
            - MARIADB_USER=ilias
        image: mariadb:latest
        secrets:
            - database_ilias_password
            - database_root_password
        volumes:
            - ./data/mysql:/var/lib/mysql
    ilias:
        depends_on:
            - database
        environment:
            - ILIAS_DATABASE_PASSWORD_FILE=/run/secrets/database_ilias_password
            - ILIAS_HTTP_PATH=http[s]://%host%
            - ILIAS_ROOT_USER_PASSWORD_FILE=/run/secrets/ilias_root_password
            - ILIAS_SYSTEMFOLDER_CONTACT_FIRSTNAME=...
            - ILIAS_SYSTEMFOLDER_CONTACT_LASTNAME=...
            - ILIAS_SYSTEMFOLDER_CONTACT_EMAIL=...
        image: %image%/ilias:latest
        secrets:
            - database_ilias_password
            - ilias_root_password
        volumes:
            - ./data/ilias:/var/iliasdata
            - ./data/log/ilias:/var/log/ilias
    nginx:
        depends_on:
            - ilias
        image: %image%/nginx:latest
        ports:
            - [%host_ip%:]80:80
        volumes:
            - ./data/ilias/web:/var/iliasdata/web:ro
secrets:
    database_ilias_password:
        file: ./data/secrets/database_ilias_password
    database_root_password:
        file: ./data/secrets/database_root_password
    ilias_root_password:
        file: ./data/secrets/ilias_root_password
```

## cron

```dockerfile
FROM fluxfw/flux-ilias-cron-base:php7.4 AS cron
COPY --from=ilias /var/www/html /var/www/html
```

```shell
docker build . --pull --target cron -t %image%/cron:latest
```

```yaml
services:
    ilias:
        environment:
            - ILIAS_CRON_USER_PASSWORD_FILE=/run/secrets/ilias_cron_password
        secrets:
            - ilias_cron_password
    cron:
        depends_on:
            - ilias
        environment:
            - ILIAS_CRON_USER_PASSWORD_FILE=/run/secrets/ilias_cron_password
        image: %image%/cron:latest
        secrets:
            - ilias_cron_password
        volumes:
            - ./data/ilias:/var/iliasdata
            - ./data/log/ilias:/var/log/ilias
secrets:
    ilias_cron_password:
        file: ./data/secrets/ilias_cron_password
```

## ilserver (Lucene search)

```dockerfile
FROM fluxfw/flux-ilias-ilserver-base:java8 AS ilserver
COPY --from=ilias /var/www/html /var/www/html
```

```shell
docker build . --pull --target ilserver -t %image%/ilserver:latest
```

```yaml
services:
    ilias:
        environment:
            - ILIAS_LUCENE_SEARCH=true
    ilserver:
        depends_on:
            - ilias
        image: %image%/ilserver:latest
        volumes:
            - ./data/ilserver:/var/ilserverdata
            - ./data/ilias:/var/iliasdata:ro
```

## chatroom

```dockerfile
FROM fluxfw/flux-ilias-chatroom-base:nodejs10 AS chatroom
COPY --from=ilias /var/www/html /var/www/html
```

```shell
docker build . --pull --target chatroom -t %image%/chatroom:latest
```

```yaml
services:
    chatroom:
        depends_on:
            - ilias
        image: %image%/chatroom:latest
        ports:
            - [%host_ip%:]8080:8080
        volumes:
            - ./data/ilias:/var/iliasdata:ro
```

## Autostart

*Note some containers needs that `ilias` is already init before start it (If it isn't the case, you may end in endless restarts of the containers)*

```yaml
services:
    database:
        restart: always
    ilias:
        restart: always
    nginx:
        restart: always
    [cron:
        restart: always]
    [ilserver:
        restart: always]
    [chatroom:
        restart: always]
```

## HTTPS

If you don't use a proxy server, you can directly enable HTTPS on the containers with the follow config like

```yaml
services:
    nginx:
        environment:
            - ILIAS_NGINX_HTTPS_CERT=/run/secrets/https_cert
            - ILIAS_NGINX_HTTPS_KEY=/run/secrets/https_key
            [- ILIAS_NGINX_HTTPS_DHPARAM=/run/secrets/https_pem]
        ports:
            - [%host_ip%:]443:443
        secrets:
            - https_cert
            - https_key
            [- https_pem]
secrets:
    https_cert:
        file: ./data/certs/ilias.crt
    https_key:
        file: ./data/certs/ilias.key
    [https_pem:
        file: ./data/certs/ilias.pem]
```

*Redirect HTTP to HTTPS is supported*

### chatroom

```yaml
services:
    ilias:
        environment:
            - ILIAS_CHATROOM_HTTPS_CERT=/run/secrets/https_cert
            - ILIAS_CHATROOM_HTTPS_KEY=/run/secrets/https_key
            - ILIAS_CHATROOM_HTTPS_DHPARAM=/run/secrets/https_pem
    chatroom:
        secrets:
            - https_cert
            - https_key
            - https_pem
```

## SMTP

Currently, for send emails only an external smtp server is supported

```yaml
services:
    ilias:
        environment:
            - ILIAS_SMTP_HOST=...
            - ILIAS_SMTP_PORT=465
            - ILIAS_SMTP_ENCRYPTION=tls
            - ILIAS_SMPT_USER_FILE=/run/secrets/ilias_smtp_user
            - ILIAS_SMTP_PASSWORD_FILE=/run/secrets/ilias_smtp_password
        secret:
            - ilias_smtp_user
            - ilias_smtp_password
secrets:
    ilias_smtp_user:
        file: ./data/secrets/ilias_smtp_user
    ilias_smtp_password:
        file: ./data/secrets/ilias_smtp_password
```

## Development

### ILIAS development mode

```yaml
services:
    ilias:
        environment:
            - ILIAS_DEVMODE=true
```

### PHP error reporting

```yaml
services:
    ilias:
        environment:
            - ILIAS_PHP_DISPLAY_ERRORS=On
```

### Source code

If you wish to live apply code changes, you can mount the source code as a volume in the containers

```yaml
services:
    ilias:
        volumes:
            - ./ilias:/var/www/html
    nginx:
        volumes:
            - ./ilias:/var/www/html:ro
    [cron:
        volumes:
            - ./ilias:/var/www/html:ro]
    [ilserver:
        volumes:
            - ./ilias:/var/www/html:ro]
    [chatroom:
        volumes:
            - ./ilias:/var/www/html:ro]
```

As base, you can copy the source code from your `ilias` image to your host

```shell
docker run --rm -it -u `id -u`:`id -g` -v "$PWD":/tmp/host_data --entrypoint cp %image%/ilias:latest -r /var/www/html /tmp/host_data/ilias
```

May you need to update the ILIAS core composer dependencies, but if you don't wish to use composer on your host, you can use the follow config to automatic to this on the container (re)creation

```yaml
services:
    ilias:
        environment:
            - ILIAS_WEB_DIR_COMPOSER_AUTO_INSTALL=true
```

### SMTP

You can use a development SMTP server with the follow config

```yaml
services:
    ilias:
        depends_on:
            - smtp
        environment:
            - ILIAS_SMTP_HOST=smtp
            - ILIAS_SMTP_PORT=1025
    smtp:
        image: mailhog/mailhog:latest
        ports:
            - [%host_ip%:]8025:8025
```

### Xdebug

Not supported

## More

You can find more information per image in

- [flux-ilias-ilias-base](https://github.com/fluxfw/flux-ilias-ilias-base)
- [flux-ilias-nginx-base](https://github.com/fluxfw/flux-ilias-nginx-base)
- [flux-ilias-cron-base](https://github.com/fluxfw/flux-ilias-cron-base)
- [flux-ilias-ilserver-base](https://github.com/fluxfw/flux-ilias-ilserver-base)
- [flux-ilias-chatroom-base](https://github.com/fluxfw/flux-ilias-chatroom-base)
