#!/bin/sh
# Raw-URL reachability check (CLAUDE.md section 17).
#
# The template hardcodes raw.githubusercontent.com URLs that embed owner, repo
# and branch. If any of them 404s, Community Applications does not error - it
# silently serves a stale or empty listing. That failure mode is invisible from
# the repository side, which is why this runs on a schedule and not only on push.
#
# Retries, because raw.githubusercontent is CDN-cached and can lag a push by a
# few seconds. A flaky check would violate section 8's "pipelines must run
# error-free".

set -u

BASE="https://raw.githubusercontent.com/heckpiet/magicmirror-unraid/main"
FILES="templates/magicmirror.xml ca_profile.xml icon.svg README.md LICENSE CHANGELOG.md SBOM.md"
ATTEMPTS=5
rc=0

for f in $FILES; do
  url="$BASE/$f"
  status=""
  n=1
  while [ "$n" -le "$ATTEMPTS" ]; do
    status=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "$url" || echo "000")
    [ "$status" = "200" ] && break
    # Exponential backoff, per section 13.
    sleep $((n * n))
    n=$((n + 1))
  done

  if [ "$status" = "200" ]; then
    echo "  OK    $f"
  else
    echo "  FAIL  $f  (last status $status after $ATTEMPTS attempts)"
    rc=1
  fi
done

echo
if [ "$rc" -eq 0 ]; then
  echo "ALL LINKS RESOLVE"
else
  echo "BROKEN LINKS - the CA listing will be incomplete"
fi
exit "$rc"
