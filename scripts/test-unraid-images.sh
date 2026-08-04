#!/bin/sh
# Runtime verification of the images this template ships, against a real Unraid
# host. Non-destructive: scratch appdata paths only, everything removed at the end.
#
# Two scenarios per tag, because they fail differently:
#
#   A) appdata directories do NOT exist yet.
#      This is what a real Community Applications install does: Unraid hands the
#      bind-mount path to Docker, which creates it as root:root 0755. A container
#      running as 99:100 then cannot write. This is the scenario that matters and
#      the one an earlier revision of this script missed by pre-creating dirs.
#
#   B) appdata directories exist and are owned 99:100.
#      The state after a first run, or after the user created them by hand.
#
# Checks per scenario: config.js written, address/ipWhitelist values, the git
# safe.directory error, available shells, and HTTP reachability.

set -u

BASE=/mnt/user/appdata/mm-verify
PORT=8502
CNT=mm-verify
TAGS="${TAGS:-debian-server wolfi-server alpine}"

cleanup() {
  docker rm -f "$CNT" >/dev/null 2>&1 || true
  [ -d "$BASE" ] && find "$BASE" -delete 2>/dev/null
  return 0
}

run_one() {
  tag=$1
  scenario=$2

  cleanup
  if [ "$scenario" = "B" ]; then
    mkdir -p "$BASE/config" "$BASE/modules"
    chown -R 99:100 "$BASE"
  fi
  # Scenario A deliberately leaves $BASE absent so Docker creates it.

  docker run -d --name "$CNT" \
    --user 99:100 \
    -p "${PORT}:8080" \
    -e TZ=Europe/Berlin \
    -v "$BASE/config:/opt/magic_mirror/config" \
    -v "$BASE/modules:/opt/magic_mirror/modules" \
    "karsten13/magicmirror:$tag" >/dev/null 2>&1

  ok=0
  for _ in $(seq 1 40); do
    if curl -sf -o /dev/null "http://127.0.0.1:${PORT}/"; then ok=1; break; fi
    sleep 1
  done

  printf '  scenario %s: ' "$scenario"
  if [ "$ok" -eq 1 ]; then echo "HTTP 200"; else echo "NO HTTP RESPONSE"; fi

  echo "    dir ownership as Docker left it:"
  ls -ldn "$BASE/config" 2>/dev/null | sed 's/^/      /' || echo "      (missing)"

  echo "    entrypoint / config errors:"
  docker logs "$CNT" 2>&1 |
    grep -E "ENTRYPOINT|Could not find config|Permission denied|dubious ownership" |
    head -4 | sed 's/^/      /'

  echo "    config.js:"
  if [ -f "$BASE/config/config.js" ]; then
    grep -hE "(address|ipWhitelist):" "$BASE/config/config.js" | head -2 | sed 's/^/      /'
    if grep -q '10\.0\.0\.0/8' "$BASE/config/config.js"; then
      echo "      10.0.0.0/8 present"
    else
      echo "      10.0.0.0/8 MISSING"
    fi
  else
    echo "      not created"
  fi

  echo "    git as the running user:"
  docker exec "$CNT" sh -c 'cd /opt/magic_mirror && git rev-parse --short HEAD' 2>&1 |
    head -2 | sed 's/^/      /'

  echo "    shells:"
  for s in /bin/bash /bin/sh; do
    if docker exec "$CNT" test -x "$s" 2>/dev/null; then
      echo "      $s present"
    else
      echo "      $s missing"
    fi
  done
  echo
}

for tag in $TAGS; do
  echo "================ karsten13/magicmirror:$tag ================"
  docker pull -q "karsten13/magicmirror:$tag" >/dev/null 2>&1
  docker image inspect "karsten13/magicmirror:$tag" \
    --format '  image user={{.Config.User}} created={{.Created}}' 2>/dev/null
  run_one "$tag" A
  run_one "$tag" B
done

cleanup
echo "cleanup done"
