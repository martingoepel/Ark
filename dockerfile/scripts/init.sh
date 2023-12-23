#!/bin/bash

APP_ID="2430930"
GAME_DIR="/opt/game-files/ShooterGame/Binaries/Win64"
PROTON_DIR="/app/Steam/compatibilitytools.d/Proton-8.0-4"
ASA_START_PARAMS="$ASA_START_PARAMS"
RCON_PORT="27020"
SERVER_ADMIN_PASSWORD=""

# Thanks to https://github.com/Acekorneya - https://github.com/Acekorneya/Ark-Survival-Ascended-Server/tree/master/scripts
save_complete_check() {
  local log_file="/opt/game-files/ShooterGame/Saved/Logs/ShooterGame.log"
  # Check if the "World Save Complete" message is in the log file
  if tail -n 10 "$log_file" | grep -q "World Save Complete"; then
    echo "Save operation completed."
    return 0
  else
    return 1
  fi
}

update_handler() {
  echo "Initiating graceful shutdown..."
  echo "Notifying players about the immediate shutdown and save..."
  for i in {5..1}
  do
    rcon-cli --host localhost --port $RCON_PORT --password $SERVER_ADMIN_PASSWORD "ServerChat Update available - Server will shutdown in $i min."
    sleep 1m
  done
  echo "Saving the world..."
  rcon-cli --host localhost --port $RCON_PORT --password $SERVER_ADMIN_PASSWORD "saveworld"

  # Initial delay to avoid catching a previous save message
  echo "Waiting a few seconds before checking for save completion..."
  sleep 5  # Initial delay, can be adjusted based on server behavior

  # Wait for save to complete
  echo "Waiting for save to complete..."
  while ! save_complete_check; do
      sleep 5  # Check every 5 seconds
  done

  echo "World saved. Shutting down the server..."

  exit 0
}

# To test
update_check () {
  while true
  do
    sleep 10m
    echo "check for update"
    if $(cat /opt/game-files/version) != curl https://api.steamcmd.net/v1/info/$APP_ID | jq '."data"."$APP_ID"."depots"."branches"."public"."buildid"'; then
      echo "update available"
      update_handler
    else
      echo "running latest version"
    fi
  done
}

/app/steamcmd +@sSteamCmdForcePlatformType linux +force_install_dir /opt/game-files +login anonymous +app_update "$APP_ID" validate +quit
curl https://api.steamcmd.net/v1/info/$APP_ID | jq '."data"."$APP_ID"."depots"."branches"."public"."buildid"' > /opt/game-files/version
cd "$GAME_DIR"

# $STEAM_COMPAT_DIR/proton run ArkAscendedServer.exe $ASA_START_PARAMS