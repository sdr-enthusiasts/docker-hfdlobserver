#!/command/with-contenv bash
#shellcheck shell=bash

# shellcheck disable=SC1091
source /scripts/common

SCRIPT_NAME="$(basename "$0")"
SCRIPT_NAME="${SCRIPT_NAME%.*}"

# shellcheck disable=SC2034
s6wrap=(s6wrap --quiet --timestamps --prepend="$SCRIPT_NAME" --args)
#"${s6wrap[@]}" pushd /opt/hfdlobserver || exit 69

source /opt/hfdlobserver/.virtualenvs/hfdlobserver888/bin/activate

# get the first argument
if [ -z "$1" ]; then
  echo "Usage: $SCRIPT_NAME <lat> <lon>"
  exit 1
fi
lat="$1"

# get the second argument
if [ -z "$2" ]; then
  echo "Usage: $SCRIPT_NAME <lat> <lon>"
  exit 1
fi

lon="$2"

env HOME=/opt/hfdlobserver python3 /opt/hfdlobserver/extras/guess_station_ranking.py "$lat" "$lon"
