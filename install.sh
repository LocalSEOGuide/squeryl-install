#!/bin/sh
# Installs Squeryl on this computer. It needs only Docker Desktop and your license key, and it is short on purpose, so
# you can read it.
#
# What it does: checks Docker is running, asks for your license key, checks that key with Squeryl's license service, makes a
# folder (~/Squeryl), downloads the Squeryl image, copies the real installer out of that image, and runs it. Nothing is
# installed outside that folder and Docker. Your key is kept in that folder and goes nowhere else.
#
#   curl -fsSL <address of this file> | sh
#
# SQUERYL_LICENSE_KEY_FILE names a file holding your key, instead of being asked. SQUERYL_DIR chooses another folder.
# SQUERYL_VERSION chooses another version.
set -eu

RELEASE=""   # the current release, such as 0.1.0: set here each time one is published. Empty means none yet.
VERSION=${SQUERYL_VERSION:-$RELEASE}
DIR=${SQUERYL_DIR:-$HOME/Squeryl}
IMAGE=ghcr.io/localseoguide/squeryl-tracker:$VERSION
SERVICE=${SQUERYL_LICENSE_SERVICE:-https://squeryl-license.family-care.cloud/squeryl}
SUPPORT=support@localseoguide.com
PROJECT=${SQUERYL_PROJECT:-squeryl}
# A login that is not a terminal's may not have Docker Desktop's folders on its PATH.
PATH="$PATH:/usr/local/bin:/opt/homebrew/bin:/Applications/Docker.app/Contents/Resources/bin"

say()  { printf '%s\n' "$*"; }
fail() { printf '❌ %s\n' "$*" >&2; exit 1; }
field() { printf '%s' "$1" | sed -n "s/.*\"$2\": *\"\([^\"]*\)\".*/\1/p" | head -n 1; }

# Before anything else, and before asking for a key: until the first release, there is nothing to install.
if [ -z "$VERSION" ]; then
  say "Squeryl isn't ready to install yet, so nothing was changed on this computer."
  say "Write to $SUPPORT and we'll let you know when it is."
  exit 1
fi

command -v docker >/dev/null 2>&1 || fail "Docker Desktop is not installed. Get it from https://www.docker.com/products/docker-desktop/, open it once, then run this again."
if ! docker info >/dev/null 2>&1; then
  [ "$(uname -s)" = Darwin ] || fail "Docker is installed but not running. Start it, then run this again."
  say "▶ Starting Docker Desktop…"
  open -a Docker 2>/dev/null || true
  tries=0
  until docker info >/dev/null 2>&1; do
    tries=$((tries + 1))
    [ "$tries" -le 60 ] || fail "Docker Desktop did not start within two minutes. Open it, wait until it says it is running, then run this again."
    sleep 2
  done
fi

[ ! -f "$DIR/.env" ] || fail "Squeryl is already installed in $DIR. See how it is doing with: cd \"$DIR\" && ./squeryl status"
[ -z "$(docker ps -aq --filter "label=com.docker.compose.project=$PROJECT" </dev/null)$(docker volume ls -q --filter "label=com.docker.compose.project=$PROJECT" </dev/null)" ] \
  || fail "Squeryl is already installed on this computer, and one computer takes one installation. Run ./squeryl status in its folder to see how it is doing."

# This script may be arriving on stdin (curl | sh), so the key is asked for on the terminal itself.
if [ -n "${SQUERYL_LICENSE_KEY_FILE:-}" ]; then
  [ -r "$SQUERYL_LICENSE_KEY_FILE" ] || fail "Cannot read $SQUERYL_LICENSE_KEY_FILE."
  key=$(tr -d ' \r\n' < "$SQUERYL_LICENSE_KEY_FILE")
elif ( : < /dev/tty ) 2>/dev/null; then
  printf 'Your license key, from the email it came in: ' > /dev/tty
  read -r key < /dev/tty
  key=$(printf '%s' "$key" | tr -d ' \r\n')
else
  fail "There is no terminal to ask for your license key on. Save it in a file, and run this again with SQUERYL_LICENSE_KEY_FILE set to that file."
fi
case "$key" in
  "" | *[!A-Za-z0-9-]*) fail "That does not look like a license key. Copy it again from the email it came in." ;;
esac

say "▶ Checking your license key…"
answer=$(curl -s -m 30 -w '\n%{http_code}' -X POST -H 'Content-Type: application/json' -d "{\"key\":\"$key\"}" "$SERVICE/download" </dev/null) \
  || fail "Could not reach the license service. Check that this computer is online and try again. If it keeps happening, write to $SUPPORT."
status=$(printf '%s\n' "$answer" | tail -n 1)
body=$(printf '%s\n' "$answer" | sed '$d')
if [ "$status" != 200 ]; then
  reason=$(field "$body" error)
  fail "${reason:-The license service answered $status. Please try again shortly, or write to $SUPPORT.}"
fi

mkdir -p "$DIR"
cd "$DIR"

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  say "▶ Downloading Squeryl $VERSION. The first time, this can take a few minutes…"
  user=$(field "$body" user); token=$(field "$body" token)
  # A throwaway Docker login, used for this one download, so the read token stays nowhere on this computer.
  login=""
  if [ -n "$token" ]; then
    login=$(mktemp -d)
    printf '{"auths":{"ghcr.io":{"auth":"%s"}}}\n' "$(printf '%s:%s' "$user" "$token" | base64 | tr -d '\n')" > "$login/config.json"
  fi
  pulled=0
  docker ${login:+--config "$login"} pull "$IMAGE" </dev/null || pulled=1
  [ -z "$login" ] || rm -rf "$login"
  [ "$pulled" = 0 ] || fail "Could not download Squeryl $VERSION. Check that this computer is online. If it keeps happening, write to $SUPPORT."
fi

# The real installer travels inside the image, so it always matches the version it installs.
for file in squeryl compose.yaml README.md; do
  docker run --rm --entrypoint cat "$IMAGE" "/app/install/$file" > "$file" </dev/null || fail "Squeryl $VERSION does not carry its installer, so nothing was installed."
done
chmod +x squeryl

say "▶ Squeryl's folder is $DIR"
umask 077
printf '%s\n' "$key" > .license-key
result=0
# What it runs must not read from this script's stdin.
./squeryl install --version "$VERSION" --key-file .license-key </dev/null || result=$?
rm -f .license-key
exit "$result"
