#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /scripts/common

SCRIPT_NAME="$(basename "$0")"
SCRIPT_NAME="${SCRIPT_NAME%.*}"

# shellcheck disable=SC2034
s6wrap=(s6wrap --quiet --timestamps --prepend="$SCRIPT_NAME" --args)

if [ ! -f /run/hfdlobserver/settings.yaml ] && [ ! -f /run/hfdlobserver/settings.yml ]; then
  "${s6wrap[@]}" echo "Error: /run/hfdlobserver/settings.yaml not found. Please mount a volume to /run/settings with your settings.yaml file."
  exit 1
fi

"${s6wrap[@]}" echo "Found HFDLobserver settings file, copying to /opt/hfdlobserver/settings.yaml"

mkdir -p /run/hfdlobserver || exit 1
cp -f /run/hfdlobserver/settings.yaml /opt/hfdlobserver/settings.yaml || exit 1

exit 0
