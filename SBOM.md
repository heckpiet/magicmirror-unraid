# Software Bill of Materials

Per section 11 of `CLAUDE.md`.

This repository ships no executable code and installs nothing, so there is no dependency
graph to lock or resolve. A generated SPDX or CycloneDX document would describe an empty
build. What it *does* have is a supply chain: the template points Unraid users at a
third-party container image, which in turn packages a third-party application. That chain
is what this document records.

Last verified: **2026-08-04**

## Direct dependency

The template names exactly one external artifact.

| | |
|---|---|
| Image | `karsten13/magicmirror` |
| Registry | Docker Hub (`docker.io`) |
| Source | <https://gitlab.com/khassel/magicmirror> |
| Documentation | <https://khassel.gitlab.io/magicmirror/> |
| Maintainer | Karsten Hassel |
| License | MIT |

### Authenticity (§11, Package Verification)

The image is not vendored, forked or rebuilt here, so authenticity rests on the publisher
chain rather than on a checksum of anything we produce:

1. The official MagicMirror² installation documentation links to
   `gitlab.com/khassel/magicmirror` as the containerised deployment path.
2. That GitLab project publishes `karsten13/magicmirror` to Docker Hub, and its build
   sources (`build/Dockerfile-debian`, `build/Dockerfile-alpine`, `build/entrypoint.sh`)
   are public and readable.
3. Karsten Hassel is a MagicMirror² core contributor, verifiable through the MagicMirror²
   GitHub organisation.

**Any change of image name, registry or namespace must be re-verified against that chain
before it is committed.** A lookalike namespace is the realistic supply-chain risk here,
not a compromised digest.

### Tags referenced by the template

Digests are amd64, the only architecture Unraid runs. They are a point-in-time record;
these are rolling tags and will move.

| Tag | Role | amd64 digest | Size | Updated |
|---|---|---|---|---|
| `debian-server` | default `<Repository>` | `sha256:c55fdbea49d3e3d767e6aa1025e3bfddb5dc11d42f4ec757dbc8288f61068a50` | 107 MB | 2026-08-04 |
| `wolfi-server` | selectable `<Branch>` | `sha256:25d6311b8858a14685ff49763d257ac895c9df93017a8a68d69e1c0b8eafa475` | 95 MB | 2026-08-02 |
| `alpine` | selectable `<Branch>` | `sha256:75c2cd0a1e44fe07d41e11c0d6abfe510618f1f56150a94a133636119c5cd450` | 69 MB | 2026-08-04 |

The `*-electron` tags are not referenced — they need a locally attached display.

## Transitive components

Supplied by the image, not by this repository. Listed so the licence position is auditable,
not to duplicate upstream's own bill of materials.

| Component | Version at verification | License | Notes |
|---|---|---|---|
| MagicMirror² | 2.37.0 (stable tags) | MIT | The application itself |
| Node.js | bundled in image | MIT | Runtime |
| Debian | 13 | mixed, DFSG-compatible | Base of `debian-server` |
| Wolfi | rolling | mixed, Apache-2.0 tooling | Base of `wolfi-server` |
| Alpine | rolling | mixed, MPL-2.0 / MIT | Base of `alpine` |

Third-party MagicMirror² modules are installed by the end user into the modules volume at
runtime. They are outside this repository's control and outside this SBOM; their licences
and their supply chain are the user's responsibility.

## Licence compatibility

| Layer | License |
|---|---|
| This repository | MIT |
| Container image | MIT |
| MagicMirror² | MIT |

MIT throughout. No copyleft obligation is inherited, and §11's "compatible open-source
licensing" requirement is satisfied.

One related licence finding, recorded because it constrains the CA listing: the official
MagicMirror² promotional renders live in `MagicMirrorOrg/MagicMirror-Website`, which
carries **no licence at all**. They are therefore not redistributable and are deliberately
absent from this repository — see `CLAUDE.md` §18.

## Known issues in the dependency

| Issue | Affects | Status |
|---|---|---|
| `fatal: detected dubious ownership in repository at '/opt/magic_mirror'` when running as a UID other than 1000. Breaks `updatenotification`; the application itself serves normally. | `wolfi-server`; not observed on `debian-server` | Reported upstream. Fix belongs in the image: `git config --system --add safe.directory /opt/magic_mirror` |
| Default `ipWhitelist` omits `10.0.0.0/8`, locking out users on a 10.x LAN until they edit `config.js`. | all stable server tags | Reported upstream; documented as the single troubleshooting step in `README.md` |

No CVEs are tracked here. Vulnerability scanning of the image is upstream's
responsibility; `wolfi-server` exists specifically as the reduced-CVE variant.

## Re-verification

Digests and tag metadata:

```powershell
$r = Invoke-RestMethod "https://hub.docker.com/v2/repositories/karsten13/magicmirror/tags?page_size=100"
$r.results | Where-Object { $_.name -in @("debian-server","wolfi-server","alpine") } |
  ForEach-Object {
    $amd = $_.images | Where-Object { $_.architecture -eq "amd64" } | Select-Object -First 1
    "$($_.name)  $($amd.digest)  $([math]::Round($amd.size/1MB))MB"
  }
```

Runtime behaviour, against a real Unraid host:

```powershell
ssh qhec02 'sh -s' < .tmp\test-unraid-images.sh
```
