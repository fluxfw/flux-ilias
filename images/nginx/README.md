# ILIAS nginx image

The follow environment variables are available

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| ILIAS_WEB_DIR | Path to ILIAS source code | /var/www/html |
| ILIAS_NGINX_HTTPS_CERT | Path to HTTPS certificate file<br>Set this will enable listen on HTTPS and redirect HTTP to HTTPS<br>Should be on a volume | *-* |
| ILIAS_NGINX_HTTPS_KEY | Path to HTTPS key file<br>Should be on a volume | *-* |
| ILIAS_NGINX_HTTPS_DHPARAM | Path to HTTPS pem file<br>Should be on a volume | *-* |
| ILIAS_NGINX_HTTP_PORT | Listen HTTP port | 80 |
| ILIAS_NGINX_HTTPS_PORT | Listen HTTPS port | 443 |
| ILIAS_NGINX_LISTEN | Listen IP | 0.0.0.0 |
| ILIAS_NGINX_PHP_HOST | ILIAS php-fpm host | ilias |
| ILIAS_NGINX_PHP_PORT | ILIAS php-fpm port | 9000 |
| ILIAS_NGINX_SERVER_TOKENS | Show nginx server tokens | off |
| ILIAS_NGINX_CLIENT_MAX_BODY_SIZE | Maximal upload size | 200M |
| ILIAS_NGINX_PHP_READ_TIMEOUT | Maximal execution time | 900 |

Minimal variables required to set are **bold**
