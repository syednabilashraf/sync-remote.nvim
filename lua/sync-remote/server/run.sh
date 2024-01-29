#!/bin/bash

REMOTE_USER=$1
REMOTE_HOST=$2
REMOTE_SERVER_PATH="~/.sync-remote/"

ssh "$REMOTE_USER@$REMOTE_HOST" <<EOF
pkill -f $REMOTE_SERVER_PATH/server.js
node $REMOTE_SERVER_PATH/server.js > ~/.sync-remote/port.log 2>&1 &
EOF
