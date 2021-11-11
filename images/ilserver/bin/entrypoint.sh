#!/usr/bin/env sh

set -e

if [ ! -f "$ILIAS_WEB_DIR/ilias.php" ]; then
  echo "Please provide ILIAS source code to $ILIAS_WEB_DIR (\$ILIAS_WEB_DIR)"
  exit 1
fi

if [ -f "$ILIAS_FILESYSTEM_INI_PHP_FILE" ]; then
  echo "ILIAS config found"
else
  echo "ILIAS not configured yet"
  exit 1
fi

mkdir -p "$ILIAS_ILSERVER_INDEX_PATH"

echo "Generate ilserver config"
echo "[Server]
IndexMaxFileSizeMB = $ILIAS_ILSERVER_INDEX_MAX_FILE_SIZE
IndexPath = $ILIAS_ILSERVER_INDEX_PATH
IpAddress = $ILIAS_ILSERVER_IP_ADDRESS
LogFile = $ILIAS_ILSERVER_LOG_FILE
LogLevel = $ILIAS_ILSERVER_LOG_LEVEL
NumThreads = $ILIAS_ILSERVER_NUM_THREADS
Port = $ILIAS_ILSERVER_PORT
RamBufferSize = $ILIAS_ILSERVER_RAM_BUFFER_SIZE
[Client1]
ClientId = $ILIAS_COMMON_CLIENT_ID
IliasIniPath = $ILIAS_FILESYSTEM_INI_PHP_FILE
NicId = $ILIAS_ILSERVER_NIC_ID" > "$ILIAS_ILSERVER_PROPERTIES_PATH"

start_ilserver="$(which java) -jar $ILIAS_WEB_DIR/Services/WebServices/RPC/lib/ilServer.jar $ILIAS_ILSERVER_PROPERTIES_PATH start"

echo "Unset ILIAS env variables (For not show in PHP variables or log files)"
for var in $(printenv | grep "ILIAS_" | sed 's/=.*$//'); do
  unset "$var"
done

echo "Start ilserver"
exec $start_ilserver
