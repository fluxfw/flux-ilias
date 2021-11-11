#!/usr/bin/env sh

set -e

if [ -f "$ILIAS_FILESYSTEM_INI_PHP_FILE" ]; then
  echo "ILIAS config found"
else
  echo "ILIAS not configured yet"
  exit 1
fi

echo "Generate cron config"
echo "$ILIAS_CRON_PERIOD $_ILIAS_EXEC_AS_WWW_DATA $(which php) $ILIAS_WEB_DIR/cron/cron.php \"$ILIAS_CRON_USER_LOGIN\" \"$ILIAS_CRON_USER_PASSWORD\" \"$ILIAS_COMMON_CLIENT_ID\"" > "$ILIAS_CRON_FILE"
crontab "$ILIAS_CRON_FILE"

echo "Unset ILIAS env variables (For not show in PHP variables or log files)"
for var in $(printenv | grep "ILIAS_" | sed 's/=.*$//'); do
  unset "$var"
done

echo "Start cron"
exec crond -f
