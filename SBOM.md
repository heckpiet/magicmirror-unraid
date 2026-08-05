# Software Bill of Materials

Per section 11 of `CLAUDE.md`.

This repository ships no executable code and installs nothing, so there is no dependency
graph to lock or resolve. A generated SPDX or CycloneDX document would describe an empty
build. What it *does* have is a supply chain: the template points Unraid users at a
third-party container image, which in turn packages a third-party application. That chain
is what this document records.

Last verified: **2026-08-05**, against the images as actually pulled, not against
registry metadata.

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

These are rolling tags and will move; the digests are a point-in-time record.

**Two digests per tag, because they identify different objects.** The *index* digest is
the multi-arch manifest list — this is what `docker pull` prints and what
`docker image inspect --format '{{index .RepoDigests 0}}'` returns, so it is the one to
compare against a running host. The *amd64* digest identifies the single-architecture
image inside that list, which is what Docker Hub's tags API reports. They never match, and
mistaking one for the other looks exactly like a tampered image.

| Tag | Role | Index digest (what `docker pull` reports) | amd64 digest | Size |
|---|---|---|---|---|
| `wolfi-server` | default `<Repository>` | `sha256:661e4edf55b97fe9508e4e15155dff4e3bff278043fe58c31e9e7660350fd9f3` | `sha256:1ade98af39129eaab97f09de77162c8a82ccfcb7fcaecf5f8f6db408aa88909b` | 95 MB |
| `debian-server` | selectable `<Branch>` | `sha256:ca2a5bcdc0161b48a11863c9b0982ccc8d8eb6a025dae6abae8f017fc9dfa075` | `sha256:018a57ddec3c9f18543e9d5adea7e5c5099e376cb8c791e05dda737bb4e797a8` | 108 MB |
| `alpine` | selectable `<Branch>` | `sha256:8348ce4a1a31a081932817a0260915d9662f871c90e32d535d08a3c869b96650` | `sha256:3509874e9332ce8b8cb03b2cccf341e2f9eaa552fdc11b65922d8d7207a89bbe` | 69 MB |

All three carry the permission and `safe.directory` fixes listed below, confirmed by
inspecting the pulled images rather than by trusting registry metadata. `wolfi-server` is
the default under §3's preference for minimal, audited bases.

**Do not date a rebuild from Docker Hub's `last_updated`.** It reported all three tags as
published roughly an hour *before* the upstream commits they demonstrably contain. The
field is cached or means something other than "content pushed". Probe the image:

```sh
docker run --rm --entrypoint sh karsten13/magicmirror:wolfi-server -c 'cat /etc/gitconfig'
```

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

## Issues found and resolved in the dependency

Both were found while verifying this template on real hardware, reported upstream, and
fixed the same day. Recorded because the fixes are what allow the template to require no
setup at all.

| Issue | Affected | Resolution |
|---|---|---|
| `fatal: detected dubious ownership in repository at '/opt/magic_mirror'` when running as a UID other than 1000, breaking `updatenotification` | `wolfi-server` | [`065f3b8b`](https://gitlab.com/khassel/magicmirror/-/commit/065f3b8b457a5da65e70f1bddc710cd4201576f7) ships `/etc/gitconfig` with a `safe.directory` entry. Verified fixed on all three tags. |
| Application directory not writable for arbitrary UIDs; default `ipWhitelist` omitted `10.0.0.0/8` and IPv6 loopback | all server tags | [`64be145b`](https://gitlab.com/khassel/magicmirror/-/commit/64be145b4fbdb56d7a15d5b33080a405a5597734) sets `chmod 0777` on the app directory and widens the whitelist. Verified. |

No open issues in the dependency at the time of writing.

No CVEs are tracked here. Vulnerability scanning of the image is upstream's
responsibility; `wolfi-server` exists specifically as the reduced-CVE variant.

## Re-verification

Index digests and the presence of both upstream fixes, read from the images themselves:

```sh
for TAG in wolfi-server debian-server alpine; do
  docker pull -q "karsten13/magicmirror:$TAG"
  docker image inspect "karsten13/magicmirror:$TAG" --format "$TAG {{index .RepoDigests 0}}"
  docker run --rm --entrypoint sh "karsten13/magicmirror:$TAG" -c 'cat /etc/gitconfig'
  docker run --rm --entrypoint sh "karsten13/magicmirror:$TAG" \
    -c 'grep -h "ipWhitelist:" /opt/magic_mirror/__config/config.js.sample'
done
```

The amd64 sub-digests, for the table above:

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
ssh qhec02 'sh -s' < scripts\test-unraid-images.sh
```
