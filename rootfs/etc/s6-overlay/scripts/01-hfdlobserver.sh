#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /scripts/common

SCRIPT_NAME="$(basename "$0")"
SCRIPT_NAME="${SCRIPT_NAME%.*}"

# shellcheck disable=SC2034
s6wrap=(s6wrap --quiet --timestamps --prepend="$SCRIPT_NAME" --args)

if [[ -n "${SERVER}" && -z "${SERVER_PORT}" ]]; then
  "${s6wrap[@]}" echo "SERVER is set but SERVER_PORT is not set, exiting"
  exit 1
fi

if [[ -n "$ZMQ_MODE" ]]; then
  if [[ -z "$ZMQ_ENDPOINT" ]]; then
    "${s6wrap[@]}" echo "ZMQ_MODE mode set to '${ZMQ_MODE}, but ZMQ_ENDPOINT is not set, exiting"
    exit 1
  fi
fi

if [[ -n "$ZMQ_ENDPOINT" ]]; then
  if [[ -z "$ZMQ_MODE" ]]; then
    "${s6wrap[@]}" echo "ZMQ_ENDPOINT mode set to '${ZMQ_ENDPOINT}, but ZMQ_MODE is not set, exiting"
    exit 1
  fi
fi

if [[ -z "$FEED_ID" ]]; then
  "${s6wrap[@]}" echo "FEED_ID is not set, exiting"
  #exit 1
fi

# time to update the config in /opt/hfdlobserver/settings.yaml

"${s6wrap[@]}" echo "Updating config file"

# replace address: {}
if [[ -n "$WEB888_URL" ]]; then
  "${s6wrap[@]}" sed -i "s|address: .*|address: ${WEB888_URL}|" /opt/hfdlobserver/settings.yaml
fi

# replace port: {}
if [[ -n "$WEB888_PORT" ]]; then
  "${s6wrap[@]}" sed -i "s|port: .*|port: ${WEB888_PORT}|" /opt/hfdlobserver/settings.yaml
fi

# replace station_id: {}
if [[ -n "$FEED_ID" ]]; then
  "${s6wrap[@]}" sed -i "s|station_id: .*|station_id: ${FEED_ID}|" /opt/hfdlobserver/settings.yaml
else
  "${s6wrap[@]}" sed -i "s|station_id: .*|station_id: |" /opt/hfdlobserver/settings.yaml
fi

# replace ranked_stations: {}

if [[ -n "$RANKED_STATIONS" ]]; then
  "${s6wrap[@]}" sed -i "s|ranked_stations: .*|ranked_stations: [${RANKED_STATIONS}]|" /opt/hfdlobserver/settings.yaml
fi

cat /opt/hfdlobserver/settings.yaml

# Everything is good to go. Exit with 0

exit 0
