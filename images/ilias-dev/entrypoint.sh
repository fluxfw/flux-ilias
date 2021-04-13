#!/bin/sh
set -e

echo "Generate xdebug config"
echo "xdebug.client_port = $ILIAS_PHP_XDEBUG_CLIENT_PORT
xdebug.discover_client_host = $ILIAS_PHP_XDEBUG_DISCOVER_CLIENT_HOST
xdebug.log = $ILIAS_PHP_XDEBUG_LOG_FILE
xdebug.log_level = $ILIAS_PHP_XDEBUG_LOG_LEVEL
xdebug.mode = $ILIAS_PHP_XDEBUG_MODE
xdebug.output_dir = $ILIAS_PHP_XDEBUG_OUTPUT_DIR
xdebug.start_with_request = $ILIAS_PHP_XDEBUG_START_WITH_REQUEST" > "$PHP_INI_DIR/conf.d/xdebug.ini"

mkdir -p "$ILIAS_PHP_XDEBUG_LOG_DIR"
touch "$ILIAS_PHP_XDEBUG_LOG_FILE"
chown "$_ILIAS_WWW_DATA" -R "$ILIAS_PHP_XDEBUG_LOG_DIR"

/entrypoint.sh
