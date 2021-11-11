#!/usr/bin/env sh

set -e

if [ ! -f "$ILIAS_WEB_DIR/ilias.php" ]; then
  echo "Please provide ILIAS source code to $ILIAS_WEB_DIR (\$ILIAS_WEB_DIR)"
  exit 1
fi

if [ -f "$ILIAS_CHATROOM_SERVER_CONFIG_FILE" ] && [ -f "$ILIAS_CHATROOM_CLIENT_CONFIG_FILE" ]; then
  echo "ILIAS config found"
else
  echo "ILIAS not configured yet"
  exit 1
fi

start_chatroom="$(which node) $ILIAS_WEB_DIR/Modules/Chatroom/chat/chat.js $ILIAS_CHATROOM_SERVER_CONFIG_FILE $ILIAS_CHATROOM_CLIENT_CONFIG_FILE"

echo "Unset ILIAS env variables (For not show in PHP variables or log files)"
for var in $(printenv | grep "ILIAS_" | sed 's/=.*$//'); do
  unset "$var"
done

echo "Start chatroom"
exec $start_chatroom
