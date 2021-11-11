ARG PHP_VERSION
FROM php:$PHP_VERSION-fpm-alpine

LABEL org.opencontainers.image.source="https://github.com/fluxapps/FluxIlias"
LABEL maintainer="fluxlabs <support@fluxlabs.ch> (https://fluxlabs.ch)"

RUN apk add --no-cache curl ffmpeg freetype-dev ghostscript imagemagick libjpeg-turbo-dev libpng-dev libxslt-dev libzip-dev mariadb-client openldap-dev patch su-exec unzip zlib-dev zip && \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS && \
    case $PHP_VERSION in 8.*|7.4*) docker-php-ext-configure gd --with-freetype --with-jpeg ;; *) docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ ;; esac && \
    docker-php-ext-install gd ldap mysqli pdo_mysql soap xsl zip && \
    case $PHP_VERSION in 8.*) pecl install "channel://pecl.php.net/xmlrpc-1.0.0RC2" && docker-php-ext-enable xmlrpc ;; *) docker-php-ext-install xmlrpc ;; esac && \
    docker-php-source delete && \
    apk del .build-deps

ENV ILIAS_PDFGENERATION_PATH_TO_PHANTOM_JS /usr/local/bin/phantomjs
RUN wget -O - https://github.com/dustinblackman/phantomized/releases/download/2.1.1a/dockerized-phantomjs.tar.gz | tar -xz -C / && \
    (mkdir -p /tmp/phantomjs && cd /tmp/phantomjs && wget -O - https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 | tar -xj --strip-components=1 && mv bin/phantomjs "$ILIAS_PDFGENERATION_PATH_TO_PHANTOM_JS" && rm -rf /tmp/phantomjs)

ENV ILIAS_STYLE_PATH_TO_LESSC /usr/share/lessphp/plessc
RUN (mkdir -p "$(dirname $ILIAS_STYLE_PATH_TO_LESSC)" && cd "$(dirname $ILIAS_STYLE_PATH_TO_LESSC)" && wget -O - https://github.com/leafo/lessphp/archive/refs/tags/v0.5.0.tar.gz | tar -xz --strip-components=1 && sed -i "s/{0}/[0]/" lessc.inc.php)

COPY --from=composer:1 /usr/bin/composer /usr/bin/composer1
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer2

COPY . /FluxIlias

ENTRYPOINT ["/FluxIlias/bin/entrypoint.sh"]

ENV _ILIAS_WWW_DATA www-data:www-data
ENV _ILIAS_EXEC_AS_WWW_DATA su-exec $_ILIAS_WWW_DATA

ENV ILIAS_FILESYSTEM_DATA_DIR /var/iliasdata
ENV ILIAS_FILESYSTEM_INI_PHP_FILE $ILIAS_FILESYSTEM_DATA_DIR/ilias.ini.php
ENV ILIAS_LOG_DIR /var/log/ilias
ENV ILIAS_WEB_DIR /var/www/html

ENV ILIAS_CONFIG_FILE $ILIAS_FILESYSTEM_DATA_DIR/config.json

ENV ILIAS_FILESYSTEM_WEB_DATA_DIR $ILIAS_FILESYSTEM_DATA_DIR/web

ENV ILIAS_PHP_DISPLAY_ERRORS Off
ENV ILIAS_PHP_ERROR_REPORTING E_ALL & ~E_NOTICE & ~E_WARNING & ~E_STRICT
ENV ILIAS_PHP_EXPOSE Off
ENV ILIAS_PHP_LISTEN 0.0.0.0
ENV ILIAS_PHP_LOG_ERRORS On
ENV ILIAS_PHP_MAX_EXECUTION_TIME 900
ENV ILIAS_PHP_MAX_INPUT_TIME 900
ENV ILIAS_PHP_MAX_INPUT_VARS 1000
ENV ILIAS_PHP_MEMORY_LIMIT 300M
ENV ILIAS_PHP_PORT 9000
ENV ILIAS_PHP_POST_MAX_SIZE 200M
ENV ILIAS_PHP_UPLOAD_MAX_SIZE 200M
RUN echo "memory_limit = $ILIAS_PHP_MEMORY_LIMIT" > "$PHP_INI_DIR/conf.d/ilias.ini"

ENV _ILIAS_WEB_DATA_DIR $ILIAS_WEB_DIR/data
ENV _ILIAS_WEB_PHP_FILE $ILIAS_WEB_DIR/ilias.ini.php
RUN ln -sfT "$ILIAS_FILESYSTEM_WEB_DATA_DIR" "$_ILIAS_WEB_DATA_DIR"
RUN ln -sfT "$ILIAS_FILESYSTEM_INI_PHP_FILE" "$_ILIAS_WEB_PHP_FILE"

ENV ILIAS_COMMON_CLIENT_ID default

ENV ILIAS_DATABASE_HOST mysql
ENV ILIAS_DATABASE_DATABASE ilias
ENV ILIAS_DATABASE_USER ilias

ENV ILIAS_LOGGING_ENABLE true
ENV ILIAS_LOGGING_PATH_TO_LOGFILE $ILIAS_LOG_DIR/ilias.log
ENV ILIAS_LOGGING_ERRORLOG_DIR $ILIAS_LOG_DIR/errors

ENV ILIAS_MEDIAOBJECT_PATH_TO_FFMPEG /usr/bin/ffmpeg

ENV ILIAS_PREVIEW_PATH_TO_GHOSTSCRIPT /usr/bin/gs

ENV ILIAS_UTILITIES_PATH_TO_CONVERT /usr/bin/convert
ENV ILIAS_UTILITIES_PATH_TO_ZIP /usr/bin/zip
ENV ILIAS_UTILITIES_PATH_TO_UNZIP /usr/bin/unzip

ENV ILIAS_WEBSERVICES_RPC_SERVER_HOST ilserver
ENV ILIAS_WEBSERVICES_RPC_SERVER_PORT 11111

ENV ILIAS_CHATROOM_ADDRESS 0.0.0.0
ENV ILIAS_CHATROOM_PORT 8080
ENV ILIAS_CHATROOM_LOG /dev/stdout
ENV ILIAS_CHATROOM_LOG_LEVEL info
ENV ILIAS_CHATROOM_ERROR_LOG /dev/stderr

ENV ILIAS_ROOT_USER_LOGIN root

ENV ILIAS_CRON_USER_LOGIN cron

VOLUME $ILIAS_FILESYSTEM_DATA_DIR
VOLUME $ILIAS_LOG_DIR

EXPOSE $ILIAS_PHP_PORT
