# ILIAS nginx image

The nginx config is automatic generated based set the follow environment variables

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| ILIAS_WEB_DIR | Path to ILIAS source code<br>This is a volume | /var/www/html |
| ILIAS_NGINX_LOG_DIR | Path to log directory<br>This is a volume | /var/log/nginx |
| ILIAS_NGINX_ACCESS_LOG_FILE | Path to access log file | *%ILIAS_NGINX_LOG_DIR%*/access.log |
| ILIAS_NGINX_ACCESS_LOG_LEVEL | Access log level | main |
| ILIAS_NGINX_ERROR_LOG_FILE | Path to error log file | *%ILIAS_NGINX_LOG_DIR%*/error.log |
| ILIAS_NGINX_ERROR_LOG_LEVEL | Error log level | warn |
| ILIAS_NGINX_HTTPS_CERT | Path to HTTPS certificate file<br>Set this will enable listen on HTTPS and redirect HTTP to HTTPS<br>Should be on a volume | *-* |
| ILIAS_NGINX_HTTPS_KEY | Path to HTTPS key file<br>Should be on a volume | *-* |
| ILIAS_NGINX_HTTPS_DHPARAM | Path to HTTPS pem file<br>Should be on a volume | *-* |
| ILIAS_NGINX_HTTP_PORT | Listen HTTP port | 80 |
| ILIAS_NGINX_HTTPS_PORT | Listen HTTPS port | 443 |
| ILIAS_NGINX_LISTEN | Listen IP | 0.0.0.0 |
| ILIAS_NGINX_PHP_HOST | ILIAS php-fpm host | ilias |
| ILIAS_NGINX_PHP_PORT | ILIAS php-fpm port | 9000 |
| ILIAS_NGINX_SERVER_TOKENS | Show nginx server tokens | off |

Minimal variables required to set are **bold**

Additional this image contains the rewrite rules which ILIAS set on the `.htaccess` file (For Apache)
