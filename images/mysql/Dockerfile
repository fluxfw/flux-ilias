ARG MYSQL_VERSION
FROM mysql:$MYSQL_VERSION

LABEL org.opencontainers.image.source="https://github.com/fluxapps/FluxIlias"
LABEL maintainer="fluxlabs <support@fluxlabs.ch> (https://fluxlabs.ch)"

COPY . /FluxIliasMysql

ENTRYPOINT ["/FluxIliasMysql/bin/entrypoint.sh"]

ENV ILIAS_MYSQL_BIND_ADDRESS 0.0.0.0
ENV ILIAS_MYSQL_PORT 3306
ENV ILIAS_MYSQL_CHARACTER_SET_SERVER utf8
ENV ILIAS_MYSQL_COLLATION_SERVER utf8_general_ci
ENV ILIAS_MYSQL_MAX_ALLOWED_PACKET 67108864
ENV ILIAS_MYSQL_DEFAULT_AUTHENTICATION_PLUGIN mysql_native_password
ENV MYSQL_DATABASE ilias
ENV MYSQL_USER ilias

EXPOSE $ILIAS_MYSQL_PORT
