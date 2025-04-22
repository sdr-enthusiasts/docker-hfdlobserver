#!/command/with-contenv bash
#shellcheck shell=bash

# shellcheck disable=SC1091
source /scripts/common

SCRIPT_NAME="$(basename "$0")"
SCRIPT_NAME="${SCRIPT_NAME%.*}"

# shellcheck disable=SC2034
s6wrap=(s6wrap --quiet --timestamps --prepend="$SCRIPT_NAME" --args)

"${s6wrap[@]}" echo "Starting $SCRIPT_NAME..."
#"${s6wrap[@]}" pushd /opt/hfdlobserver || exit 1
env HOME=/opt/hfdlobserver "${s6wrap[@]}" /opt/hfdlobserver/hfdlobserver888.sh --headless

"${s6wrap[@]}" echo "Adnormal exit of $SCRIPT_NAME."
"${s6wrap[@]}" pkill -f kiwirecoder
