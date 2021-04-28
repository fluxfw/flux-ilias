#!/bin/sh
set -e

if [ ! -f "$ILIAS_WEB_DIR/ilias.php" ]; then
  echo "Please init ILIAS source code and add a volume to $ILIAS_WEB_DIR"
  exit 1
fi

echo "Generate nginx config"
if [ -n "$ILIAS_NGINX_HTTPS_CERT" ]; then
  echo "With https"
  if [ "$ILIAS_NGINX_HTTPS_PORT" != "443" ]; then
    https_redirect_port=:$ILIAS_NGINX_HTTPS_PORT
  else
    https_redirect_port=
  fi
  if [ -n "$ILIAS_NGINX_HTTPS_DHPARAM" ]; then
    ssl_dhparam="
	ssl_dhparam $ILIAS_NGINX_HTTPS_DHPARAM;"
  else
    ssl_dhparam=
  fi
  listen="listen $ILIAS_NGINX_LISTEN:$ILIAS_NGINX_HTTP_PORT;
  return 301 https://\$host$https_redirect_port\$request_uri;
}
server {
  listen $ILIAS_NGINX_LISTEN:$ILIAS_NGINX_HTTPS_PORT ssl;
	ssl_certificate $ILIAS_NGINX_HTTPS_CERT;
	ssl_certificate_key $ILIAS_NGINX_HTTPS_KEY;$ssl_dhparam"
else
  echo "Without https"
  listen="listen $ILIAS_NGINX_LISTEN:$ILIAS_NGINX_HTTP_PORT;"
fi
echo "server_tokens $ILIAS_NGINX_SERVER_TOKENS;
access_log $ILIAS_NGINX_ACCESS_LOG_FILE $ILIAS_NGINX_ACCESS_LOG_LEVEL;
error_log $ILIAS_NGINX_ERROR_LOG_FILE $ILIAS_NGINX_ERROR_LOG_LEVEL;
server {
	$listen

	index index.php index.html;

	root $ILIAS_WEB_DIR/;

	location ~ \.php$ {
		try_files \$uri =404;
		include fastcgi_params;
		fastcgi_pass $ILIAS_NGINX_PHP_HOST:$ILIAS_NGINX_PHP_PORT;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		fastcgi_param SERVER_NAME \$host;
	}

	include ilias-rewrites.conf;
}" > /etc/nginx/conf.d/ilias.conf

mkdir -p "$ILIAS_NGINX_LOG_DIR"

echo "Unset ILIAS env variables (For not show in PHP variables or log files)"
for var in $(printenv | grep "ILIAS" | sed 's/=.*$//'); do
  unset "$var"
done

echo "Start nginx"
exec /docker-entrypoint.sh nginx -g "daemon off;"
