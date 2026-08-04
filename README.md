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
| Runs as | UID/GID `1000` |

## Setup

Two one-time steps are required. Skip either one and the container will not work.

### 1. Fix the appdata permissions — *before* the first start

The image runs as UID/GID `1000`, but Unraid creates appdata directories as `99:100`
(`nobody:users`). The container's entrypoint needs write access to create its default
config, and without it you will see this in the log:

```
[ENTRYPOINT] ***ERROR*** No write permission for /opt/magic_mirror/config, skipping copying config.js
```

Open the Unraid terminal and run:

```sh
mkdir -p /mnt/user/appdata/magicmirror/config /mnt/user/appdata/magicmirror/modules
chown -R 1000:1000 /mnt/user/appdata/magicmirror
```

### 2. Make MagicMirror² reachable on your LAN

On first start the container copies MagicMirror²'s stock `config.js` into your config
folder. That stock config listens on `localhost` only and whitelists just the loopback
address, so the WebUI will refuse connections from other machines.

Edit `/mnt/user/appdata/magicmirror/config/config.js`:

```js
address: "0.0.0.0",
ipWhitelist: ["127.0.0.1", "::ffff:127.0.0.1", "::1", "192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"],
```

Restart the container. Narrow the whitelist to your own subnet if you prefer, or set it
to `[]` to allow every address.

MagicMirror² is **not** authenticated. Do not expose port 8080 to the internet — put it
behind a reverse proxy with authentication if you need remote access.

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

| Tag | Base | Notes |
|---|---|---|
| `debian-server` | Debian 13 | Default. Broadest module compatibility. |
| `wolfi-server` | Wolfi | Smaller, reduced CVE surface. |
| `alpine` | Alpine | Smallest. Some native modules may fail to build. |

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

A browser screenshot of your own install represents this server-only container more
honestly than a hardware render anyway.

## Handover checklist

This repo is deliberately written so it can be transferred to, or forked by, the upstream
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
