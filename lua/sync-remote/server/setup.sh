#!/bin/bash

REMOTE_USER="nabil.ashraf"
REMOTE_HOST="172.39.39.114"
REMOTE_SERVER_PATH="~/.sync-remote/"
LOCAL_SERVER_PATH="$(cd "$(dirname $0)" && pwd)/app/"

# rsync -rzu -e 'ssh -o ControlPath=~/.ssh/control-syncremote' $LOCAL_SERVER_PATH $REMOTE_USER@$REMOTE_HOST:$REMOTE_SERVER_PATH

ssh "$REMOTE_USER@$REMOTE_HOST" <<EOF
cd ~
ls
  # sudo apt update
  # sudo apt install -y nodejs npm watchman
  # node -v
  # npm -v
  # watchman -v
  #
  # mkdir -p ~/.sync-remote
  # cd ~/.sync-remote
  # npm i fb-watchman
EOF
