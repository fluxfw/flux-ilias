#!/usr/bin/env sh

set -e

echo "Generate mysql config"
echo "[mysqld]
bind-address=$ILIAS_MYSQL_BIND_ADDRESS
port=$ILIAS_MYSQL_PORT
character-set-server=$ILIAS_MYSQL_CHARACTER_SET_SERVER
collation-server=$ILIAS_MYSQL_COLLATION_SERVER
max-allowed-packet=$ILIAS_MYSQL_MAX_ALLOWED_PACKET
default_authentication_plugin=$ILIAS_MYSQL_DEFAULT_AUTHENTICATION_PLUGIN" > /etc/mysql/conf.d/zz_ilias.cnf

echo "Start mysql"
exec /entrypoint.sh mysqld
