FROM nginx:mainline-alpine

LABEL org.opencontainers.image.source="https://github.com/fluxapps/FluxIlias"
LABEL maintainer="fluxlabs <support@fluxlabs.ch> (https://fluxlabs.ch)"

RUN unlink /etc/nginx/conf.d/default.conf

COPY . /FluxIliasNginx

ENTRYPOINT ["/FluxIliasNginx/bin/entrypoint.sh"]

ENV ILIAS_WEB_DIR /var/www/html

ENV ILIAS_NGINX_HTTP_PORT 80
ENV ILIAS_NGINX_HTTPS_PORT 443

ENV ILIAS_NGINX_LISTEN 0.0.0.0

ENV ILIAS_NGINX_PHP_HOST ilias
ENV ILIAS_NGINX_PHP_PORT 9000

ENV ILIAS_NGINX_SERVER_TOKENS off

ENV ILIAS_NGINX_CLIENT_MAX_BODY_SIZE 200M

ENV ILIAS_NGINX_PHP_READ_TIMEOUT 900

EXPOSE $ILIAS_NGINX_HTTP_PORT
EXPOSE $ILIAS_NGINX_HTTPS_PORT
