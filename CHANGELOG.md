# Changelog

All notable changes to this Unraid Community Applications template are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Versioning applies to **the template**, not to MagicMirror² or to the container image.
Those carry their own versions upstream. A MAJOR bump here means an existing Unraid
installation needs manual intervention — a changed volume path, a removed variable, a
different image. A MINOR bump adds optional capability. A PATCH bump is documentation or
metadata only.

## [Unreleased]

Nothing yet.

## [1.0.0] — 2026-08-04

First release. Verified against a real Unraid 7.3.2 host (Docker 29.5.3) rather than
inferred from upstream sources.

### Added

- Unraid CA template for MagicMirror² in server-only mode, the correct mode for a headless
  server: `templates/magicmirror.xml` plus `ca_profile.xml`.
- `--user 99:100` as `<ExtraParams>`. The image declares `USER 1000` while Unraid creates
  appdata as `99:100`, so without the override the entrypoint cannot write its
  configuration and MagicMirror² aborts with `Could not find config file`. This is what
  makes the install a single click with no terminal step.
- Tag selector offering `wolfi-server` and `alpine` alongside the `debian-server` default.
- `SBOM.md` recording the image, its digests, the upstream licence chain and the two known
  upstream defects.
- `scripts/verify-repo.sh`, the repository quality gate: XML well-formedness, UTF-8 without
  BOM, and absence of AI attribution in git metadata.
- `scripts/check-links.sh`, which retries every raw URL the template references, because a
  404 there makes Community Applications serve a broken listing without erroring.
- `scripts/test-unraid-images.sh`, which reproduces the runtime verification against a host
  and cleans up after itself.
- GitHub Actions workflow running the quality gate on every push, plus a weekly link check
  that catches raw-URL rot before Community Applications serves a broken listing.

### Fixed

- Removed two documented setup steps that were wrong or unnecessary.
  - The `chown -R 1000:1000` step is obsolete, replaced by the `--user` override.
  - The instruction to edit `config.js` was based on a misreading. An earlier revision
    claimed the container copies MagicMirrorOrg's stock `config.js.sample`, which binds
    `localhost`. It does not — the entrypoint copies khassel's own sample, which already
    binds `0.0.0.0` and whitelists the common RFC1918 ranges. Image behaviour must be
    verified against the image, never inferred from the application repository.

### Known issues

- The image's default `ipWhitelist` omits `10.0.0.0/8`. Users on a 10.x LAN must extend it
  in `config.js` before the WebUI is reachable. Reported upstream; the single documented
  troubleshooting step.
- Running as a UID other than 1000 makes git reject `/opt/magic_mirror`
  (`fatal: detected dubious ownership`), which breaks the `updatenotification` module.
  Observed on `wolfi-server`, not on `debian-server`. MagicMirror² itself serves normally.
  Reported upstream. This is why `debian-server` remains the default despite the guidelines
  favouring minimal base images.

### Notes

Not yet submitted to Community Applications. The upstream image maintainer was offered the
listing and declined — he has no Unraid system to test on — so this repository remains the
maintainer of record.

[Unreleased]: https://github.com/heckpiet/magicmirror-unraid/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/heckpiet/magicmirror-unraid/releases/tag/v1.0.0
