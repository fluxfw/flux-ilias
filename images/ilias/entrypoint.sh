#!/bin/sh
set -e

ensureDataDirectories () {
  echo "Ensure data directories exists and the owner is $_ILIAS_WWW_DATA"

  mkdir -p "$ILIAS_FILESYSTEM_DATA_DIR"
  chown "$_ILIAS_WWW_DATA" -R "$ILIAS_FILESYSTEM_DATA_DIR"

  mkdir -p "$ILIAS_FILESYSTEM_WEB_DATA_DIR"
  chown "$_ILIAS_WWW_DATA" -R "$ILIAS_FILESYSTEM_WEB_DATA_DIR"

  if [ -f "$ILIAS_FILESYSTEM_INI_PHP_FILE" ]; then
    chown "$_ILIAS_WWW_DATA" "$ILIAS_FILESYSTEM_INI_PHP_FILE"
  fi

  mkdir -p "$ILIAS_LOG_DIR"
  chown "$_ILIAS_WWW_DATA" -R "$ILIAS_LOG_DIR"

  ln -sfT "$ILIAS_FILESYSTEM_WEB_DATA_DIR" "$_ILIAS_WEB_DATA_DIR"
  chown -h "$_ILIAS_WWW_DATA" "$_ILIAS_WEB_DATA_DIR"

  ln -sfT "$ILIAS_FILESYSTEM_INI_PHP_FILE" "$_ILIAS_WEB_PHP_FILE"
  chown -h "$_ILIAS_WWW_DATA" "$_ILIAS_WEB_PHP_FILE"
}

if [ -f "$_ILIAS_AUTO_SKIP_CONFIG_TEMP_FILE" ]; then
  echo "Auto skip config (This is not a new container (re)creation)"
else
  echo "Run config"

  if [ ! -f "$ILIAS_WEB_DIR/ilias.php" ]; then
    echo "Please init ILIAS source code and add a volume to $ILIAS_WEB_DIR"
    exit 1
  fi

  if [ -z "$ILIAS_HTTP_PATH" ]; then
    if [ -n "$ILIAS_NGINX_HTTPS_CERT" ]; then
      if [ -n "$ILIAS_NGINX_HTTPS_PORT" ] && [ "$ILIAS_NGINX_HTTPS_PORT" != "443" ]; then
        ILIAS_HTTP_PATH=https://$(hostname):$ILIAS_NGINX_HTTPS_PORT
      else
        ILIAS_HTTP_PATH=https://$(hostname)
      fi
    else
      if [ -n "$ILIAS_NGINX_HTTP_PORT" ] && [ "$ILIAS_NGINX_HTTP_PORT" != "80" ]; then
        ILIAS_HTTP_PATH=http://$(hostname):$ILIAS_NGINX_HTTP_PORT
      else
        ILIAS_HTTP_PATH=http://$(hostname)
      fi
    fi
    export ILIAS_HTTP_PATH
    echo "Auto set empty ILIAS_HTTP_PATH to $ILIAS_HTTP_PATH (May not work)"
  fi

  if [ -z "$ILIAS_CHATROOM_ILIAS_PROXY_ILIAS_URL" ]; then
    if [ -n "$ILIAS_CHATROOM_HTTPS_CERT" ]; then
      ILIAS_CHATROOM_ILIAS_PROXY_ILIAS_URL=https://chatroom:$ILIAS_CHATROOM_PORT
    else
      ILIAS_CHATROOM_ILIAS_PROXY_ILIAS_URL=http://chatroom:$ILIAS_CHATROOM_PORT
    fi
    export ILIAS_CHATROOM_ILIAS_PROXY_ILIAS_URL
    echo "Auto set empty ILIAS_CHATROOM_ILIAS_PROXY_ILIAS_URL to $ILIAS_CHATROOM_ILIAS_PROXY_ILIAS_URL"
  fi

  if [ -z "$ILIAS_CHATROOM_CLIENT_PROXY_CLIENT_URL" ]; then
    if [ -n "$ILIAS_CHATROOM_HTTPS_CERT" ]; then
      ILIAS_CHATROOM_CLIENT_PROXY_CLIENT_URL=https$(echo "$ILIAS_HTTP_PATH" | sed 's/^https\?//'):$ILIAS_CHATROOM_PORT
    else
      ILIAS_CHATROOM_CLIENT_PROXY_CLIENT_URL=http$(echo "$ILIAS_HTTP_PATH" | sed 's/^https\?//'):$ILIAS_CHATROOM_PORT
    fi
    export ILIAS_CHATROOM_CLIENT_PROXY_CLIENT_URL
    echo "Auto set empty ILIAS_CHATROOM_CLIENT_PROXY_CLIENT_URL to $ILIAS_CHATROOM_CLIENT_PROXY_CLIENT_URL"
  fi

  echo "Generate php config"
  echo "[www]
listen = $ILIAS_PHP_LISTEN:$ILIAS_PHP_PORT" > "$PHP_INI_DIR/../php-fpm.d/zz_ilias.conf"
  echo "display_errors = $ILIAS_PHP_DISPLAY_ERRORS
error_reporting = $ILIAS_PHP_ERROR_REPORTING
expose_php = $ILIAS_PHP_EXPOSE
log_errors = $ILIAS_PHP_LOG_ERRORS
max_execution_time = $ILIAS_PHP_MAX_EXECUTION_TIME
max_input_time = $ILIAS_PHP_MAX_INPUT_TIME
max_input_vars = $ILIAS_PHP_MAX_INPUT_VARS
memory_limit = $ILIAS_PHP_MEMORY_LIMIT
post_max_size = $ILIAS_PHP_POST_MAX_SIZE
upload_max_filesize = $ILIAS_PHP_UPLOAD_MAX_SIZE" > "$PHP_INI_DIR/conf.d/ilias.ini"

  if [ -f "$ILIAS_WEB_DIR/composer.json" ]; then
    echo "Install composer dependencies"
    case $PHP_VERSION in
      8.*)
        composer install -d "$ILIAS_WEB_DIR" --no-dev --ignore-platform-reqs
      ;;
      *)
        composer install -d "$ILIAS_WEB_DIR" --no-dev
      ;;
    esac

    host_owner="$(stat -c %u "$ILIAS_WEB_DIR")":"$(stat -c %g "$ILIAS_WEB_DIR")"
    echo "Ensure the owner of composer files is $host_owner (Like other ILIAS source code)"
    chown "$host_owner" -R libs/composer/vendor
    chown "$host_owner" composer.lock
    chown "$host_owner" composer.json
  fi

  ensureDataDirectories

  if echo "$ILIAS_DATABASE_TYPE" | grep -q "postgres"; then
    echo "WARNING: Waiting for ensure database is ready only works with mysql like database"
    echo "Further config may will fail"
  else
    mysql_query="mysql --host=$ILIAS_DATABASE_HOST --port=$ILIAS_DATABASE_PORT --user=$ILIAS_DATABASE_USER --password=$ILIAS_DATABASE_PASSWORD $ILIAS_DATABASE_DATABASE -e"
    until $mysql_query "SELECT VERSION()" 1>/dev/null; do
      echo "Waiting 3 seconds for ensure database is ready"
      sleep 3
    done
    echo "Database is ready"
  fi

  if [ -f "$ILIAS_WEB_DIR/setup/cli.php" ]; then
    echo "(Re)generate ILIAS $(basename "$ILIAS_CONFIG_FILE")"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/generate_ilias_config/generate_ilias_config.php

    if [ -d "$ILIAS_FILESYSTEM_WEB_DATA_DIR/$ILIAS_COMMON_CLIENT_ID/usr_images" ]; then
      echo "Already installed ILIAS detected"

      echo "Call ILIAS update setup cli"
      php "$ILIAS_WEB_DIR/setup/cli.php" update --yes "$ILIAS_CONFIG_FILE"

      if [ ! -d "$ILIAS_WEB_DIR/setup/templates" ]; then
        echo "Call ILIAS migrate setup cli"
        php "$ILIAS_WEB_DIR/setup/cli.php" migrate --yes
      fi
    else
      echo "Call ILIAS install setup cli"
      php "$ILIAS_WEB_DIR/setup/cli.php" install --yes "$ILIAS_CONFIG_FILE"
    fi
  else
    echo "ILIAS setup cli only works with ILIAS 6 or higher"
    echo "Older ILIAS versions are not supported anymore"
    exit 1
  fi

  ensureDataDirectories

  if [ -n "$ILIAS_ROOT_USER_PASSWORD" ]; then
    if echo "$ILIAS_DATABASE_TYPE" | grep -q "postgres"; then
      echo "WARNING: Set ILIAS $ILIAS_ROOT_USER_LOGIN user password only works with mysql like database"
      echo "Further config may will fail"
    else
      echo "Set ILIAS $ILIAS_ROOT_USER_LOGIN user password"
      $mysql_query "UPDATE usr_data SET passwd='$(echo -n "$ILIAS_ROOT_USER_PASSWORD" | md5sum | awk '{print $1}')',passwd_enc_type='md5' WHERE login='$ILIAS_ROOT_USER_LOGIN'"
    fi
  else
    echo "Skip set ILIAS $ILIAS_ROOT_USER_LOGIN user password"
    echo "Further config may will fail"
  fi

  if [ "$ILIAS_DEVMODE" = "true" ] || [ "$ILIAS_DEVMODE" = "1" ]; then
    echo "Enable ILIAS development mode"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_client_ilias_setting.php system DEVMODE 1
  else
    echo "Disable ILIAS development mode"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_client_ilias_setting.php system DEVMODE 0
  fi

  if [ -n "$ILIAS_CRON_USER_PASSWORD" ]; then
    echo "Ensure ILIAS $ILIAS_CRON_USER_LOGIN user exists"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/ensure_ilias_user_exists.php "$ILIAS_CRON_USER_LOGIN" "$ILIAS_CRON_USER_PASSWORD"
  else
    echo "Skip ensure ILIAS $ILIAS_CRON_USER_LOGIN user exists"
  fi

  if [ -d "$ILIAS_WEB_DIR/setup/templates" ]; then
    echo "Manually set ilserver server for ILIAS 6"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common rpc_server_host "$ILIAS_WEBSERVICES_RPC_SERVER_HOST"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common rpc_server_port "$ILIAS_WEBSERVICES_RPC_SERVER_PORT"

    echo "Manually set chatroom server for ILIAS 6"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php address "$ILIAS_CHATROOM_ADDRESS"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php port "$ILIAS_CHATROOM_PORT"
    if [ -n "$ILIAS_CHATROOM_HTTPS_CERT" ]; then
      $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php protocol https
    else
      $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php protocol http
    fi
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php cert "$ILIAS_CHATROOM_HTTPS_CERT"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php key "$ILIAS_CHATROOM_HTTPS_KEY"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php dhparam "$ILIAS_CHATROOM_HTTPS_DHPARAM"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php log "$ILIAS_CHATROOM_LOG"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php log_level "$ILIAS_CHATROOM_LOG_LEVEL"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php error_log "$ILIAS_CHATROOM_ERROR_LOG"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php ilias_proxy 1
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php ilias_url "$ILIAS_CHATROOM_ILIAS_PROXY_ILIAS_URL"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php client_proxy 1
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_chatroom_setting.php client_url "$ILIAS_CHATROOM_CLIENT_PROXY_CLIENT_URL"
  fi

  if [ "$ILIAS_LUEANCE_SEARCH" = "true" ] || [ "$ILIAS_LUEANCE_SEARCH" = "1" ]; then
    echo "Enable lucene search"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common search_lucene 1
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/enable_or_disable_ilias_cron_job.php src_lucene_indexer 1
  else
    echo "Disable lucene search"
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common search_lucene 0
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/enable_or_disable_ilias_cron_job.php src_lucene_indexer 0
  fi

  echo "Set smtp server"
  if [ -n "$ILIAS_SMTP_HOST" ]; then
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common mail_smtp_status 1
  else
    $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common mail_smtp_status 0
  fi
  $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common mail_smtp_host "$ILIAS_SMTP_HOST"
  $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common mail_smtp_port "$ILIAS_SMTP_PORT"
  $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common mail_smtp_encryption "$ILIAS_SMTP_ENCRYPTION"
  $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common mail_smtp_user "$ILIAS_SMTP_USER"
  $_ILIAS_EXEC_AS_WWW_DATA php /scripts/set_ilias_general_setting.php common mail_smtp_password "$ILIAS_SMTP_PASSWORD"

  echo "Config finished"
  echo "Skip it until a new container (re)creation"
  touch "$_ILIAS_AUTO_SKIP_CONFIG_TEMP_FILE"
fi

echo "Unset ILIAS env variables (For not show in PHP variables or log files)"
for var in $(printenv | grep "ILIAS" | sed 's/=.*$//'); do
  unset "$var"
done

echo "Start php-fpm"
/usr/local/bin/docker-php-entrypoint php-fpm
