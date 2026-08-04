#!/bin/sh
# Ad-hoc verification run against a real Unraid host.
#
# Question under test: does passing --user 99:100 alone make the CURRENT stable
# images usable on Unraid, or is Karsten's not-yet-released permission fix
# required as well? Unraid creates appdata as 99:100 while the images declare
# USER 1000, so the entrypoint's `[ -w "${config_dir}" ]` check is the pivot.
#
# Non-destructive: uses a scratch appdata path and removes every artifact.

set -u

TEST_DIR=/mnt/user/appdata/mm-stable-test
PORT=8502
CONTAINER=mm-stable-test

cleanup() {
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  [ -d "$TEST_DIR" ] && find "$TEST_DIR" -delete 2>/dev/null
}

for TAG in debian-server wolfi-server; do
  echo "================ stable $TAG, run as --user 99:100 ================"
  cleanup
  mkdir -p "$TEST_DIR/config" "$TEST_DIR/modules"
  chown -R 99:100 "$TEST_DIR"

  docker pull -q "karsten13/magicmirror:$TAG" >/dev/null 2>&1
  docker run -d --name "$CONTAINER" \
    --user 99:100 \
    -p "${PORT}:8080" \
    -e TZ=Europe/Berlin \
    -v "$TEST_DIR/config:/opt/magic_mirror/config" \
    -v "$TEST_DIR/modules:/opt/magic_mirror/modules" \
    "karsten13/magicmirror:$TAG" >/dev/null

  # Poll rather than sleep blindly, so a fast start is not padded.
  for i in $(seq 1 40); do
    curl -sf -o /dev/null "http://127.0.0.1:${PORT}/" && break
    sleep 1
  done

  echo "--- relevant log lines ---"
  docker logs "$CONTAINER" 2>&1 |
    grep -E "ENTRYPOINT|Could not find config|Ready to go|Permission denied|dubious" |
    head -6

  echo "--- files created in config volume ---"
  ls "$TEST_DIR/config" 2>/dev/null | tr '\n' ' '
  echo

  echo "--- address / ipWhitelist in generated config.js ---"
  if [ -f "$TEST_DIR/config/config.js" ]; then
    grep -hE "(address|ipWhitelist):" "$TEST_DIR/config/config.js" | head -2
  else
    echo "  no config.js was created"
  fi

  echo "--- shells present ---"
  for s in /bin/bash /bin/sh; do
    if docker exec "$CONTAINER" test -x "$s" 2>/dev/null; then
      echo "  $s present"
    else
      echo "  $s missing"
    fi
  done

  echo "--- http ---"
  curl -s -o /dev/null -w "  status=%{http_code}\n" --max-time 5 "http://127.0.0.1:${PORT}/" ||
    echo "  no response"
  echo
done

cleanup
echo "cleanup done"
