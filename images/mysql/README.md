# ILIAS mysql image

The follow environment variables are available

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| ILIAS_MYSQL_BIND_ADDRESS | Listen IP | 0.0.0.0 |
| ILIAS_MYSQL_PORT | Listen Port | 3306 |
| ILIAS_MYSQL_CHARACTER_SET_SERVER | Character set server | utf8 |
| ILIAS_MYSQL_COLLATION_SERVER | Collation server | utf8_general_ci |
| ILIAS_MYSQL_MAX_ALLOWED_PACKET | Maximal allowed packet size<br>This setting is needed for ILIAS 6 or higher | 67108864 |
| ILIAS_MYSQL_DEFAULT_AUTHENTICATION_PLUGIN | Authentication type<br>This setting is needed for MySQL 8 or higher | mysql_native_password |
| ILIAS_MYSQL_LOG_DIR | Path to log directory<br>This is a volume | /var/log/mysql |
| ILIAS_MYSQL_ERROR_LOG | Path to error log file | *%ILIAS_MYSQL_LOG_DIR%*/error.log |
| MYSQL_DATABASE | Database name | ilias |
| **MYSQL_ROOT_PASSWORD** | Database root password | *-* |
| MYSQL_USER | Database user | ilias |
| **MYSQL_PASSWORD** | Database password | *-* |

Minimal variables required to set are **bold**
