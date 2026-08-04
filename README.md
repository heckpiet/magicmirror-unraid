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
| Image | `karsten13/magicmirror:debian-server` |
| Port | `8080` |
| Config volume | `/opt/magic_mirror/config` |
| Modules volume | `/opt/magic_mirror/modules` |
| Extra Parameters | `--user 99:100` |

## Setup

**There is none.** Install from Community Applications, open the WebUI, done.

The one thing that makes this work is the `--user 99:100` in *Extra Parameters*. The image
declares `USER 1000`, while Unraid creates appdata as `99:100` (`nobody:users`). Without
the override the entrypoint cannot write to the config volume and the container starts
with no configuration at all. **Do not remove that setting.**

On first start the image writes a working `config.js` that already listens on all
interfaces, so no manual editing is needed to reach the WebUI.

### If the WebUI does not load

Check your subnet. The `config.js` shipped by the image permits:

```js
ipWhitelist: ["127.0.0.1", "192.168.0.0/16", "172.0.0.0/8"],
```

**Networks in the `10.x.x.x` range are not covered.** Edit
`/mnt/user/appdata/magicmirror/config/config.js`, add your range, and restart:

```js
ipWhitelist: ["127.0.0.1", "192.168.0.0/16", "172.0.0.0/8", "10.0.0.0/8"],
```

Setting `ipWhitelist: []` allows every address.

MagicMirror² has **no authentication**. Anyone who can reach the port sees your calendar
and whatever else you configure. Keep it on a trusted network and do not forward the port —
use a VPN or an authenticated HTTPS reverse proxy for remote access.

## Verified on Unraid

Tested on a real server, not assumed:

| | |
|---|---|
| Unraid | 7.3.2 |
| Docker | 29.5.3, x86_64 |
| Images | `debian-server`, `wolfi-server` (both stable) |
| Result | HTTP 200 within seconds, `config.js` / `custom.css` / `basepath.js` created and owned `99:100` |

A control run on identical directories **without** `--user 99:100` fails exactly as
expected, which is why the parameter is not optional:

```
[ENTRYPOINT] ***ERROR*** No write permission for /opt/magic_mirror/config, skipping copying config.js
touch: /opt/magic_mirror/config/custom.css: Permission denied
[ERROR] [utils] Could not find config file: /opt/magic_mirror/config/config.js
```

### Known upstream issue

Running as any UID other than 1000 makes `git` reject the application directory, because
`/opt/magic_mirror` is owned by `1000:1000` inside the image:

```
fatal: detected dubious ownership in repository at '/opt/magic_mirror'
```

Observed on `wolfi-server`, not on `debian-server`. The `updatenotification` module uses
git to detect new releases, so on the affected variants it cannot report updates.
MagicMirror² itself is unaffected and serves normally. Reported upstream; the fix belongs
in the image (`git config --system --add safe.directory /opt/magic_mirror`).

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

| Tag | Base | Shell | Notes |
|---|---|---|---|
| `debian-server` | Debian 13 | `bash`, `sh` | Default. Broadest module compatibility. |
| `wolfi-server` | Wolfi | `sh` only | Smaller, reduced CVE surface. |
| `alpine` | Alpine | `sh` only | Smallest. Some native modules may fail to build. |

The template's *Console Shell Command* is set to `bash`, which only exists in
`debian-server`. Switch it to `sh` if you select one of the other two, otherwise opening a
container console fails.

The `*-electron` tags are intentionally not offered — they require a local display.

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
