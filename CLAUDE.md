# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

An Unraid Community Applications (CA) packaging repository — **data, not code**. There is
nothing to build, lint or test. The deliverable is two XML files that Unraid's CA portal
parses: `ca_profile.xml` (repository metadata) and `templates/magicmirror.xml` (the Docker
container template).

Three separate projects are involved. Keep them straight:

| Layer | Owner | Where |
|---|---|---|
| MagicMirror² app | MagicMirrorOrg | github.com/MagicMirrorOrg/MagicMirror (MIT) |
| Container image `karsten13/magicmirror` | Karsten Hassel | gitlab.com/khassel/magicmirror (MIT) |
| Unraid packaging | this repo | github.com/heckpiet/magicmirror-unraid |

This repo does **not** fork, rebuild or modify the image. Changes to runtime behaviour
belong upstream at khassel/magicmirror, not here.

## Verification commands

Run both after any XML change. The CA portal rejects malformed XML and silently produces a
broken listing if a raw URL 404s.

```powershell
# 1. XML well-formedness
foreach ($f in @("ca_profile.xml", "templates\magicmirror.xml")) {
  try { [xml](Get-Content $f -Raw); "OK   $f" } catch { "FAIL $f: $($_.Exception.Message)" }
}

# 2. Every raw URL referenced from the XML must resolve
$urls = @(
  "https://raw.githubusercontent.com/heckpiet/magicmirror-unraid/main/templates/magicmirror.xml",
  "https://raw.githubusercontent.com/heckpiet/magicmirror-unraid/main/ca_profile.xml",
  "https://raw.githubusercontent.com/heckpiet/magicmirror-unraid/main/icon.svg",
  "https://raw.githubusercontent.com/heckpiet/magicmirror-unraid/main/README.md"
)
foreach ($u in $urls) {
  try { "$((Invoke-WebRequest $u -UseBasicParsing).StatusCode)  $u" } catch { "FAIL  $u" }
}
```

Note that `[xml]$x; $x.DocumentElement.Name` reports `MagicMirror`, not `Container` —
PowerShell's XML adapter lets the child `<Name>` element shadow the `.Name` property. The
root element is `<Container>`.

Then run **Validate** and **Scan** at <https://ca.unraid.net/submit/new> after each
meaningful XML change. That portal is the source of truth, not any third-party guide.

## The critical invariant: URLs encode owner, repo and branch

`<TemplateURL>`, `<ReadMe>`, `<Icon>`, `<Support>`, `<Project>`, `<WebPage>` and `<Forum>`
are hardcoded `raw.githubusercontent.com/heckpiet/magicmirror-unraid/main/...` URLs. They
break silently — CA keeps serving a stale or empty listing — if the repo is renamed,
transferred, forked, or the default branch changes away from `main`.

The repo is deliberately written to be handed over to the upstream image maintainer. The
handover checklist at the bottom of `README.md` enumerates every value that must change.
Keep that checklist in sync when adding any new URL-bearing tag.

Sibling repo `heckpiet/find-my-timeline-unraid` uses `master`, not `main`. Do not copy URLs
between the two without changing the branch segment.

## Template conventions

Matched to `heckpiet/find-my-timeline-unraid`, the maintainer's other CA repository:

- **`<Overview>` only, no `<Description>`.** CA renders `<Overview>`; carrying both means
  maintaining duplicate prose.
- **Self-closing `<Config .../>` entries** with no inner text.
- **`<Config Name>` is human-readable** ("Timezone", "Run mode"), not the variable name.
- **`[br]` and `[b]`**, not HTML, for markup inside `<Overview>`.
- **`&#178;`** for the ² in MagicMirror². A literal ² in the XML is a portability risk.
- **No `<MaxVer>`** — deliberate. Setting it makes the listing vanish on later Unraid
  releases. `<MinVer>` is `6.12.0`.
- **No `<Screenshot>`** — deliberate. The official MagicMirror² renders live in
  `MagicMirrorOrg/MagicMirror-Website`, which carries **no license**, so they cannot be
  redistributed. Only add screenshots taken from an actual install.

## Two upstream facts the template documents

Both were derived by reading upstream source, not from any documentation. They are the
reason the container fails for Unraid users, and they are duplicated in three places —
`<Overview>`, `<Requires>` and `README.md`. Editing one means editing all three.

1. **UID mismatch.** The image runs as UID/GID 1000; Unraid creates appdata as `99:100`.
   `build/entrypoint.sh` upstream only copies `config.js.sample` into the config directory
   `if [ -w "${config_dir}" ]`, otherwise it logs
   `***ERROR*** No write permission for /opt/magic_mirror/config` and starts with no
   config. Upstream's compose setup solves this with a `post_start` hook in
   `run/includes/base.yaml`; Unraid templates have no equivalent, so a one-time
   `chown -R 1000:1000` is documented instead.

2. **Localhost binding.** The stock `config.js.sample` from MagicMirrorOrg ships
   `address: "localhost"` and `ipWhitelist: ["127.0.0.1", "::ffff:127.0.0.1", "::1"]`. The
   container therefore starts healthy but the WebUI refuses LAN connections until the user
   edits it.

Only the `*-server` and `alpine` tags are offered. The `*-electron` variants need a locally
attached display and cannot work on a headless Unraid server.

To re-verify upstream behaviour, these are the files worth fetching (the GitLab default
branch is `master`):

```
https://gitlab.com/khassel/magicmirror/-/raw/master/build/entrypoint.sh
https://gitlab.com/khassel/magicmirror/-/raw/master/run/original.env
https://gitlab.com/khassel/magicmirror/-/raw/master/run/includes/base.yaml
```

## Where issues belong

Template problems (paths, ports, permissions, the CA listing) → this repo's issues.
Image problems → gitlab.com/khassel/magicmirror. MagicMirror² or module problems →
forum.magicmirror.builders. `ca_profile.xml`, `templates/magicmirror.xml` and `README.md`
each state this split; keep them consistent.
