# MagicMirror² for Unraid

An [Unraid Community Applications](https://ca.unraid.net/) template for
**[MagicMirror²](https://github.com/MagicMirrorOrg/MagicMirror)**, the open source
modular smart mirror platform.

This repository contains **only the Unraid packaging**. The container image it points
at — [`karsten13/magicmirror`](https://hub.docker.com/r/karsten13/magicmirror) — is built
and maintained by [Karsten Hassel](https://gitlab.com/khassel/magicmirror). Nothing here
forks, rebuilds or modifies that image.

## What this template does

It runs MagicMirror² in **server-only mode**. That is the correct mode for a headless
Unraid box: MagicMirror² serves its interface over HTTP, and you view it in a browser or
on a separate client device such as a Raspberry Pi. The `electron` scenario, which draws
to a locally attached display, will not work on Unraid and is deliberately not offered.

| | |
|---|---|
| Image | `karsten13/magicmirror:wolfi-server` |
| Port | `8080` |
| Config volume | `/opt/magic_mirror/config` |
| Modules volume | `/opt/magic_mirror/modules` |
| Extra Parameters | `--user 99:100` |

## Setup

**There is none.** Install from Community Applications, open the WebUI, done.

On first start the image writes a working `config.js` that listens on all interfaces and
already permits the private ranges you are likely on:

```js
address: "0.0.0.0",
ipWhitelist: ["127.0.0.1", "::ffff:127.0.0.1", "::1", "192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"],
```

Edit that file at `/mnt/user/appdata/magicmirror/config/config.js` to enable modules and
change the layout. `ipWhitelist: []` allows every address if your network sits outside
those ranges.

### Why `--user 99:100` is in Extra Parameters

The image runs as UID 1000. Unraid's appdata belongs to `99:100` (`nobody:users`). Without
the override the container still starts — Unraid creates the host paths world-writable —
but every file it writes lands owned `1000:1000`, which is wrong for an Unraid user share
and confuses the file manager and backup plugins. **Leave the setting in place.**

MagicMirror² has **no authentication**. Anyone who can reach the port sees your calendar
and whatever else you configure. Keep it on a trusted network and do not forward the port —
use a VPN or an authenticated HTTPS reverse proxy for remote access.

## Verified on Unraid

Tested on a real server, not assumed. `scripts/test-unraid-images.sh` reproduces it.

| | |
|---|---|
| Unraid | 7.3.2 |
| Docker | 29.5.3, x86_64 |
| Images | `wolfi-server`, `debian-server`, `alpine` (all stable) |
| Result | HTTP 200 within seconds on all three; `config.js`, `custom.css` and `basepath.js` created and owned `99:100` |

Two details worth recording, because both look like problems until you check how Unraid
actually behaves.

**Unraid creates the host paths itself, and does it correctly.** A plain `docker run`
against a non-existent bind-mount path lets Docker create it as `root:root 0755`, and the
container then cannot write. That is *not* what happens on install: Unraid's docker manager
creates missing paths with `mkdir 0777` followed by `chown 99` / `chgrp 100`
(`dynamix.docker.manager/include/Helpers.php`). So the first run works with no
intervention.

**The `--user` override is about ownership, not about starting.** Because those paths are
world-writable, the container also runs without it — but the files it writes end up owned
`1000:1000` instead of `99:100`.

### Previously reported, now fixed upstream

Running as a UID other than 1000 used to make git reject the application directory
(`fatal: detected dubious ownership in repository at '/opt/magic_mirror'`), which broke the
`updatenotification` module. Fixed in
[065f3b8b](https://gitlab.com/khassel/magicmirror/-/commit/065f3b8b457a5da65e70f1bddc710cd4201576f7)
by shipping `/etc/gitconfig` with a `safe.directory` entry. Verified: `git rev-parse` now
succeeds as UID 99 on all three variants.

The same round of upstream fixes
([64be145b](https://gitlab.com/khassel/magicmirror/-/commit/64be145b4fbdb56d7a15d5b33080a405a5597734))
made the application directory writable for arbitrary UIDs and widened the default
`ipWhitelist` to cover `10.0.0.0/8`, `172.16.0.0/12` and IPv6 loopback — which is why this
template no longer documents a subnet workaround.

## Installing modules

Third party modules go into `/mnt/user/appdata/magicmirror/modules`, then get enabled in
`config.js`. See the
[module documentation](https://docs.magicmirror.builders/modules/introduction.html) and
the [third party module list](https://modules.magicmirror.builders/).

Modules with native dependencies may need a rebuild inside the container. Open a console
on the container and run `npm install` in the module's directory.

## Image variants

The template's tag selector offers three server-only variants. All are amd64-capable,
which is all Unraid needs.

| Tag | Base | Size | Shell | Notes |
|---|---|---|---|---|
| `wolfi-server` | Wolfi | 95 MB | `sh` | Default. Minimal, regularly rebuilt, reduced CVE surface. |
| `debian-server` | Debian 13 | 108 MB | `bash`, `sh` | Broadest compatibility for modules that compile native dependencies. |
| `alpine` | Alpine | 69 MB | `sh` | Smallest. Some native modules may fail to build against musl. |

The template's *Console Shell Command* is set to `sh`, which all three provide. Switch it
to `bash` only if you select `debian-server` and want it.

The `*-electron` tags are intentionally not offered — they require a local display.

## Repository contents

| File | Purpose |
|---|---|
| `templates/magicmirror.xml` | The Unraid container template |
| `ca_profile.xml` | Community Applications repository metadata |
| `CHANGELOG.md` | Versioned history of the template |
| `SBOM.md` | Software bill of materials and licence chain |
| `scripts/verify-repo.sh` | Quality gate: XML, encoding, git metadata |
| `scripts/check-links.sh` | Raw-URL reachability |
| `scripts/test-unraid-images.sh` | Reproduces the runtime verification on a host |

The quality gate and link check run in CI on every push.

## Where to report problems

| Problem | Where |
|---|---|
| This Unraid template (paths, ports, permissions, CA listing) | [Issues in this repo](https://github.com/heckpiet/magicmirror-unraid/issues) |
| The container image | [khassel/magicmirror on GitLab](https://gitlab.com/khassel/magicmirror/-/issues) |
| MagicMirror² itself or a module | [MagicMirror² forum](https://forum.magicmirror.builders/) |

## Screenshots

The CA listing currently ships without screenshots. MagicMirror²'s official promotional
renders come from the
[MagicMirror-Website](https://github.com/MagicMirrorOrg/MagicMirror-Website) repository,
which carries **no license**, so they are deliberately not bundled here.

To add screenshots, drop your own PNGs of a running instance into this repo and reference
them from `templates/magicmirror.xml`:

```xml
<Screenshot>https://raw.githubusercontent.com/heckpiet/magicmirror-unraid/main/preview.png</Screenshot>
```

## Handover checklist

This repo is deliberately written so it can be transferred to, or forked by, another
maintainer. If you take it over, update these values so they point at your copy:

- [ ] `templates/magicmirror.xml` → `<TemplateURL>`, `<ReadMe>`, `<Icon>`, `<Support>`
- [ ] `ca_profile.xml` → `<Icon>`, `<WebPage>`, the support links in `<Profile>`
- [ ] `README.md` → the repo URLs in the tables above
- [ ] `LICENSE` → copyright holder
- [ ] Re-run **Validate** and **Scan** at <https://ca.unraid.net/submit/new>, then submit

## Credits

- **MagicMirror²** — [MagicMirrorOrg](https://github.com/MagicMirrorOrg/MagicMirror), MIT
- **Container image** — [Karsten Hassel](https://gitlab.com/khassel/magicmirror), MIT
- **Unraid template** — this repo, MIT

The MagicMirror² name and logo belong to the MagicMirror² project.
