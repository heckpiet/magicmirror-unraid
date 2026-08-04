#!/bin/sh
# Repository quality gate (CLAUDE.md section 16).
#
# This repository ships no executable code, so there is nothing to unit-test.
# These three checks are the equivalent gate, and they are what CI enforces:
#   1. XML well-formedness of the two files the Unraid CA portal parses
#   2. UTF-8 without BOM across every tracked file (section 3)
#   3. no AI attribution anywhere in git metadata (section 8)
#
# Exits non-zero on the first failure so it can gate a commit or a pipeline.
# Deliberately POSIX sh with no dependencies beyond git and one XML parser, so
# it runs identically on the maintainer's Windows box and on ubuntu-latest.

set -u
cd "$(dirname "$0")/.." || exit 1
rc=0

echo "=== 1. XML well-formedness ==="
for f in ca_profile.xml templates/magicmirror.xml; do
  if xmllint --noout "$f" 2>/dev/null ||
     python3 -c "import xml.dom.minidom,sys; xml.dom.minidom.parse(sys.argv[1])" "$f" 2>/dev/null ||
     python -c "import xml.dom.minidom,sys; xml.dom.minidom.parse(sys.argv[1])" "$f" 2>/dev/null; then
    echo "  OK    $f"
  else
    echo "  FAIL  $f"
    rc=1
  fi
done

echo "=== 2. UTF-8 without BOM ==="
bom_found=0
for f in $(git ls-files); do
  # A UTF-8 BOM is the byte sequence EF BB BF at offset 0.
  if [ "$(head -c 3 "$f" | od -An -tx1 | tr -d ' \n')" = "efbbbf" ]; then
    echo "  BOM!  $f"
    bom_found=1
  fi
done
if [ "$bom_found" -eq 0 ]; then
  echo "  OK    no BOM in any tracked file"
else
  rc=1
fi

echo "=== 3. no AI attribution in git metadata ==="
# Author and committer identities must be human only.
if git log --all --pretty=format:'%an <%ae> %cn <%ce>' |
   grep -Eiq 'claude|anthropic|copilot|chatgpt|\[bot\]'; then
  echo "  FAIL  AI identity found in author or committer fields"
  rc=1
else
  echo "  OK    author and committer fields clean"
fi

# Trailers are the other half. Match the trailer form, not prose that merely
# mentions the rule, otherwise CLAUDE.md's own wording trips the check.
if git log --all --pretty=format:'%B' |
   grep -Eiq '^[[:space:]]*(co-authored-by|signed-off-by):.*(claude|anthropic|copilot|chatgpt)'; then
  echo "  FAIL  AI co-author or sign-off trailer found"
  rc=1
else
  echo "  OK    no AI trailers"
fi

echo
if [ "$rc" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
else
  echo "CHECKS FAILED"
fi
exit "$rc"
