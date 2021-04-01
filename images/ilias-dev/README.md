# ILIAS development php-fpm image

This image is based on [ILIAS php-fpm image](../ilias)

The follow PHP versions are available

- 7.2
- 7.3
- 7.4
- 8.0 (For development purposes only, ILIAS doesn't support yet)

The xdebug config is automatic generated based set the follow environment variables

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| ILIAS_PHP_XDEBUG_CLIENT_PORT | Client port | 9003 |
| ILIAS_PHP_XDEBUG_DISCOVER_CLIENT_HOST | Discover client host | true |
| ILIAS_PHP_XDEBUG_LOG_DIR | Path to log directory<br>This is a volume | /var/log/xdebug |
| ILIAS_PHP_XDEBUG_LOG_FILE | Path to log file | *%ILIAS_PHP_XDEBUG_LOG_DIR%*/xdebug.log |
| ILIAS_PHP_XDEBUG_MODE | Modes | develop,debug,profile |
| ILIAS_PHP_XDEBUG_OUTPUT_DIR | Output dir | *%ILIAS_PHP_XDEBUG_LOG_DIR%*/output |
| ILIAS_PHP_XDEBUG_START_WITH_REQUEST | Start with request | trigger |

TODO: Currently xdebug is not working yet

The follow environment variables from [ILIAS php-fpm image](../ilias) has a different default value

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| ILIAS_PHP_DISPLAY_ERRORS | Directly display PHP errors | On |
| ILIAS_DEVMODE | ILIAS development mode | true |

Minimal variables required to set are **bold**
