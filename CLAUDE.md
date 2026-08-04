# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# General Development & Coding Guidelines

These guidelines apply to all development tasks in this project. Any deviation requires prior approval.

---

## 1. Exceptions & Decision Process
* **No Unauthorized Deviations:** If one or more of these principles cannot be enforced, applied, or are technically not sensible in a specific case, do not deviate on your own initiative under any circumstances.
* **Obligation to Consult:** In case of conflicting goals, constraints, or ambiguities, always consult before proceeding.
* **Explicit Approval:** Deviations from these standards are only permitted after consultation and explicit approval, specifying the location and scope.

## 2. Holistic Project Analysis & Architecture Standards
* **Holistic View of the Project:** Before making any code changes, analyze and understand the entire repository (architecture, dependent modules, directory structures). Avoid isolated fixes or changes without considering the overall system.
* **Boy Scout Rule (Continuous Refactoring):** Leave the code cleaner than you found it. Address small defects while working (e.g., unused imports, typos, outdated comments), as long as it stays within the scope of the current task.
* **Open Standards First:** Always prefer open standards, formats, and protocols over proprietary solutions. Proprietary technologies are only allowed after explicit approval if a clear technical value is demonstrated.
* **Best Practices:** Utilize established design patterns and current state-of-the-art practices for the given programming language/framework (e.g., SOLID, DRY, KISS).

## 3. Character Encoding, Project Structure & Build Reproducibility
* **Strict UTF-8 Requirement:** All source code files, configurations, documentation, data formats (JSON, XML, CSV), and database schemas must strictly use **UTF-8 (without BOM)** encoding.
* **Completeness Within the Project Folder:** All project-related artifacts—including subtasks, temporary files (`temp/` or `.tmp/`), test files (`tests/`), build scripts, and documentation—must reside **exclusively within the current project directory**.
* **File-Based Script Execution & Local Protections:** Avoid relying on inline shell scripts, complex one-liners, or dynamic command evaluation for automation, testing, or subtasks. When executing scripts—especially when local security policies, sandbox controls, or protection mechanisms restrict inline execution—always write them as dedicated script files inside a project-contained temporary directory (e.g., `.tmp/`).
* **Clean Git Ignore:** Temporary files, cache directories, or local test artifacts that do not belong in the Git repository must be strictly excluded via `.gitignore`.
* **Lockfiles & Build Reproducibility:** Dependency lockfiles (e.g., `package-lock.json`, `poetry.lock`, `Cargo.lock`, `Pipfile.lock`) must be committed to Git to guarantee bit-for-bit reproducible builds across environments.
* **Hardened Containers:** When containerizing applications (e.g., Dockerfiles), use multi-stage builds. Container processes must never execute as the `root` user and should rely on minimal, audited base images (e.g., Alpine or Distroless).

## 4. Internationalization (i18n) & Localization
* **Default Languages:** The software architecture must support multi-language capabilities. By default, **German (`de`)** and **English (`en`)** must be provided.
* **No Hardcoded UI Strings:** User-facing text, error messages, notifications, or labels must never be hardcoded directly into the code. Use centralized i18n translation files or localization frameworks instead.

## 5. Documentation Language & Code Comments
* **Documentation Exclusively in English:** All project documentation (`README.md`, `CHANGELOG.md`, architecture guides, API specs, inline docstrings) must be written strictly in **English**.
* **English Code Comments:** All code, functions, classes, and complex logic must be commented exclusively in **English**.
* **Standardized Commenting:** Use established documentation standards relevant to the language (e.g., JSDoc for JavaScript/TypeScript, Python Docstrings/PEP 257, Doxygen for C/C++).
* **Meaningful Comments:** Comment the *why* behind the logic, not the obvious *what*. Code should be self-explanatory; comments provide additional context.

## 6. API Design & Interface Contracts
* **Contract-First Design:** APIs (REST, gRPC, GraphQL) must be designed contract-first using formal specifications (e.g., OpenAPI / Swagger, Protocol Buffers) before implementation begins.
* **No Silent Breaking Changes:** Existing API endpoints must not introduce unannounced breaking changes. Schema modifications affecting active consumers require formal API versioning (e.g., `/v2/`) or explicit deprecation headers.

## 7. Configuration & Environment Variables
* **No Hardcoding:** Configuration values (e.g., IPs, ports, paths, feature flags, API endpoints) must never be hardcoded directly in the source code.
* **Env Templates:** Every repository must contain an `.env.example` or `config.example.json` documenting all required environment variables with sensible default/example values.

## 8. Git, Versioning & Documentation Audit
* **Git Authorship & Human User Identity:** All code modifications, commits, pull requests, and Git operations must be authored and committed exclusively under the current human developer/user account credentials. Never attribute commits, co-authorships, sign-offs, or Git metadata to AI agents, AI bots, or specific AI tools (e.g., Claude, ChatGPT, Copilot, etc.). AI identities must never appear in the commit history or contributor lists.
* **Versioning on Changes:** Every change to the software requires a transparent and correct version update according to Semantic Versioning (`MAJOR.MINOR.PATCH`).
* **Synchronous Documentation Audit:** Whenever software or version changes occur, **all** affected files and documentation must be reviewed and updated within the same pull request/commit context.
* **Repository Cleanliness:** Keep the Git repository consistent and up to date with every change. Commits must be cleanly split and traceable.
* **CI/CD Compliance:** All tooling, linters, and automated pipelines must run error-free both locally and on the server. Standardized commit messages (e.g., Conventional Commits) are required.

## 9. Security, Privacy & Database Integrity
* **Data Minimization:** Only collect, store, and process data strictly required for the specific feature or function.
* **Data Protection (GDPR):** Comply with applicable data protection regulations. Personally Identifiable Information (PII) must never be processed unencrypted or written to log files.
* **Security Essentials:** Never commit passwords, API keys, or secret tokens to code. Validate and sanitize all user input strictly.
* **Versioned Database Migrations:** Direct manual schema or data alterations on databases are strictly forbidden. All structural changes must be executed via version-controlled migration scripts (e.g., Alembic, Flyway, Prisma Migrations) supporting automated upgrades and rollbacks.

## 10. UI/UX Design
* **Modern Design Guidelines:** Align user interaction concepts with modern UI/UX standards and established design systems.
* **Accessibility & Usability:** Build interfaces to be intuitive, accessible (WCAG guidelines), and consistent across various screen sizes.

## 11. Code Quality, Tooling & AI Safety
* **Strict Typing:** Use explicit typing wherever supported by the language (e.g., TypeScript, Python Type Hints) to catch runtime errors early.
* **Linting & Formatting:** Linter and formatter rules must be strictly obeyed. Linter warnings must be fixed and must not be ignored or suppressed.
* **Dependency Checks & SBOM Management:**
  * Maintain, document, and continuously update a **Software Bill of Materials (SBOM / BOM)** covering all direct and transitive dependencies.
  * Regularly audit dependencies for security vulnerabilities (CVEs), newer versions, and available features. Ensure compatible open-source licensing (e.g., MIT, Apache-2.0).
* **Package Verification & AI Safety:** Before adding any new external library or package, verify its authenticity and presence in official package registries (PyPI, npm, crates.io, etc.) to prevent supply-chain vulnerabilities and AI package hallucinations.
* **Test Coverage:** Write unit and integration tests for new features and bug fixes. Builds must fail if regressions occur.

## 12. Observability, Logging & Telemetry
* **Standardized Health Checks:** Applications and microservices must expose standard endpoints for `/healthz` (liveness) and `/readyz` (readiness) checks.
* **Structured JSON Logging & Tracing:** Production logs must be emitted in a structured JSON format and include a unique `trace_id` / `request_id` propagated across function calls and service boundaries for end-to-end telemetry.

## 13. Performance, Resilience & Resource Management
* **Resource Cleanup:** All opened resources (e.g., file handles, network sockets, database connections, memory) must be explicitly and safely released (e.g., via `try-finally` or context managers).
* **Graceful Shutdown:** Applications must catch system termination signals (`SIGTERM`, `SIGINT`), complete in-flight requests, and cleanly close active connections before exiting.
* **System Resilience & Idempotency:** Background jobs, execution scripts, and state-mutating APIs should be idempotent. Remote network calls must implement retry logic with exponential backoff.

---

## 14. Open Deviations — Approval Required (per §1)

This repository is packaging data, not a software product: it ships no executable code, no
runtime, no API, no database and no dependencies it installs. Many guidelines above
therefore have no technical anchor here. Per §1 these are **not** silently waived — they
are open items awaiting explicit approval, and this section is updated when a decision is
made.

### Awaiting a decision

| # | Guideline | Status | Question for the maintainer |
|---|---|---|---|
| §3 | Hardened containers, minimal audited base images | **Conflict** | §3 prefers Alpine/Distroless, and the upstream image maintainer also prefers `wolfi-server`. The template nonetheless defaults to `debian-server`, because it is currently the only variant free of the git `safe.directory` bug (§19) and the only one shipping `bash` for the Unraid console. Approve keeping `debian-server` until that bug is fixed upstream, then switching? |
| §4 | i18n, German **and** English | **Blocked, cannot comply** | Unraid CA has no localization mechanism. `<Overview>`, `<Requires>` and `<Profile>` are single-value fields and CA renders exactly one string to every user worldwide. Providing `de` is technically impossible without CA support. Approve English-only? |
| §7 | `.env.example` required | **Open** | This repo has no runtime configuration of its own. The container's environment variables are declared as `<Config Type="Variable">` entries in `templates/magicmirror.xml`, which is the canonical machine-readable equivalent that Unraid actually consumes. Approve omitting a separate `.env.example`, or add one purely as documentation? |
| §8 | SemVer on every change | **Not implemented** | The repo carries no version. Sibling repo `find-my-timeline-unraid` maintains `CHANGELOG.md` and versioned releases. Adding both here, with the version reflected in the template's `<Changes>`, would align the two. Approve? |
| §8 | Conventional Commits | **Partially violated** | The four earliest commits predate the ruleset and use plain imperative subjects. Everything since uses `type: subject`. History has already been rewritten once (to strip AI co-author trailers), so converting the early subjects costs one further force-push. Approve, or leave the early history as is? |
| §8 | CI/CD must run error-free | **Not implemented** | No pipeline exists. `.tmp/verify-repo.sh` already performs the full gate locally; promoting it to a GitHub Actions workflow on every push would satisfy this cheaply. Approve? |
| §11 | SBOM | **Not implemented** | The only dependency is the upstream container image and its two upstream projects. A short `SBOM.md` recording image, tags, upstream repositories and licenses is meaningful; a generated SPDX/CycloneDX document is not, since nothing is built here. Approve the lightweight form? |

### Not applicable — confirm this reading

| # | Guideline | Why it has no anchor here |
|---|---|---|
| §3 | Lockfiles | Nothing is installed or built. There is no dependency graph to lock. |
| §6 | Contract-first API design | This repo exposes no API. The XML schema it targets is defined by Unraid CA, not by us; `<Container version="2">` is CA's own contract version. |
| §9 | Versioned database migrations | No database. |
| §10 | UI/UX, WCAG | No UI. The rendered interface belongs to MagicMirror² upstream. |
| §11 | Strict typing, linting, test coverage | No executable code. The equivalent gate is XML well-formedness plus URL reachability plus encoding, automated in `.tmp/verify-repo.sh` (§16). |
| §12 | Health check endpoints, JSON logging | Belongs to the image, not the packaging. The upstream image does ship a healthcheck (`node /opt/healthcheck.js`), but Unraid templates expose no field to configure or override it. |
| §13 | Graceful shutdown, idempotency, backoff | No process of ours runs. Signal handling is the image's concern. |

Do not resolve any row above unilaterally. Ask, then record the decision here.

### Satisfied — do not regress

**§3 encoding and structure.** All tracked files are UTF-8 without BOM, verified by
`.tmp/verify-repo.sh`. Scratch scripts live in the project-contained `.tmp/`, which is
gitignored.

**§8 commit authorship.** Commits are authored and committed as
`heckpiet <heckpiet@gmail.com>`, set in this repository's local git config. **Never add a
`Co-Authored-By:` trailer naming an AI tool, never add `Signed-off-by` on an AI's behalf,
and never set author or committer metadata to anything but the human maintainer.** The
history was rewritten on 2026-08-04 to remove such trailers; do not reintroduce them.
`.tmp/verify-repo.sh` checks both the identity fields and the trailer form. Match the
trailer form, not the bare word — prose describing this very rule otherwise produces false
positives, and `CLAUDE.md` is a filename, not authorship metadata.

**§9 security.** No secrets in the repo. The template must keep telling users that
MagicMirror² is unauthenticated and that port 8080 belongs on a trusted LAN or behind an
authenticated reverse proxy. Do not soften that wording. The container runs non-root
(`--user 99:100`), which also satisfies the non-root half of §3.

**§11 package verification.** The single external artifact is `karsten13/magicmirror` on
Docker Hub. It is the image the official MagicMirror² documentation links to, its source is
public at `gitlab.com/khassel/magicmirror`, and it is MIT licensed. Any change of image,
registry or namespace must be re-verified against that chain before it is committed.

---

## 15. What this repository is

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
belong upstream at khassel/magicmirror, not here. That split is also why §11's dependency
auditing lands on the upstream image rather than on anything vendored locally.

The upstream maintainer was asked to take the CA listing over and declined — he has no
Unraid system to test on — so this repository stays with heckpiet.

## 16. Verification commands

`.tmp/verify-repo.sh` runs the full gate and exits non-zero on the first failure. Per §3 it
is a script file, not an inline one-liner.

```powershell
sh .tmp\verify-repo.sh
```

It covers XML well-formedness of the two files CA parses, UTF-8-without-BOM across every
tracked file, and the absence of AI attribution in git metadata (§8).

Separately, every raw URL referenced from the XML must resolve — CA silently serves a
broken listing if one 404s:

```powershell
@("templates/magicmirror.xml","ca_profile.xml","icon.svg","README.md") | ForEach-Object {
  $u = "https://raw.githubusercontent.com/heckpiet/magicmirror-unraid/main/$_"
  try { "$((Invoke-WebRequest $u -UseBasicParsing).StatusCode)  $_" } catch { "FAIL  $_" }
}
```

Then run **Validate** and **Scan** at <https://ca.unraid.net/submit/new>. That portal is the
source of truth, not any third-party guide.

Note that `[xml]$x; $x.DocumentElement.Name` reports `MagicMirror`, not `Container` —
PowerShell's XML adapter lets the child `<Name>` element shadow the `.Name` property. The
root element is `<Container>`.

## 17. The critical invariant: URLs encode owner, repo and branch

`<TemplateURL>`, `<ReadMe>`, `<Icon>`, `<Support>`, `<Project>`, `<WebPage>` and `<Forum>`
are hardcoded `raw.githubusercontent.com/heckpiet/magicmirror-unraid/main/...` URLs. They
break silently — CA keeps serving a stale or empty listing — if the repo is renamed,
transferred, forked, or the default branch changes away from `main`.

This is the one place where §7's "no hardcoding" rule genuinely bites: CA offers no
variable substitution in template XML, so these values cannot be externalized. The handover
checklist at the bottom of `README.md` is the substitute — it enumerates every value that
must change on transfer. Keep it in sync when adding any new URL-bearing tag.

Sibling repo `heckpiet/find-my-timeline-unraid` uses `master`, not `main`. Do not copy URLs
between the two without changing the branch segment.

## 18. Template conventions

Matched to `heckpiet/find-my-timeline-unraid`, the maintainer's other CA repository:

- **`<Overview>` only, no `<Description>`.** CA renders `<Overview>`; carrying both means
  maintaining duplicate prose, which violates DRY (§2).
- **Self-closing `<Config .../>` entries** with no inner text.
- **`<Config Name>` is human-readable** ("Timezone", "Run mode"), not the variable name.
- **`[br]` and `[b]`**, not HTML, for markup inside `<Overview>`.
- **`&#178;`** for the ² in MagicMirror². A literal ² is a portability risk even though the
  file itself is UTF-8 (§3).
- **No `<MaxVer>`** — deliberate. Setting it makes the listing vanish on later Unraid
  releases. `<MinVer>` is `6.12.0`.
- **No `<Screenshot>`** — deliberate, and a licensing decision under §11: the official
  MagicMirror² renders live in `MagicMirrorOrg/MagicMirror-Website`, which carries **no
  license**, so they cannot be redistributed. Only add screenshots taken from an actual
  install.

## 19. Upstream behaviour — verified, not assumed

Everything here was confirmed by running the images on a real Unraid 7.3.2 host
(Docker 29.5.3). These claims are duplicated into `<Overview>`, `<Requires>` and
`README.md`; editing one means editing all three (§8, synchronous documentation audit).

**The one hard requirement: `<ExtraParams>--user 99:100</ExtraParams>`.** The image declares
`USER 1000`; Unraid creates appdata as `99:100`. `build/entrypoint.sh` upstream only copies
its config sample `if [ -w "${config_dir}" ]`, otherwise it logs
`***ERROR*** No write permission for /opt/magic_mirror/config` and MagicMirror² then aborts
with `Could not find config file`. Upstream's compose setup solves this with a `post_start`
hook in `run/includes/base.yaml`; Unraid templates have no equivalent, so the user override
is the fix. Verified by control run: identical directories without `--user 99:100` fail
exactly as above. **Do not remove that parameter.**

**No config editing is required.** An earlier revision of this repo claimed the container
copies MagicMirrorOrg's stock `config.js.sample` with `address: "localhost"` and a
loopback-only whitelist, and documented a manual edit. That was wrong, and the mistake is
worth remembering: the entrypoint copies `${MM_DIR}/__config/config.js.sample`, which is
**khassel's own sample**, not MagicMirrorOrg's. It ships:

```js
address: "0.0.0.0",
ipWhitelist: ["127.0.0.1", "192.168.0.0/16", "172.0.0.0/8"],
```

Do not infer image behaviour from the MagicMirrorOrg repository. The image carries its own
config sample, its own entrypoint and its own defaults — verify against the image itself.

The one real gap in that default: **`10.0.0.0/8` is absent**, so users on a 10.x LAN are
locked out until they extend `ipWhitelist`. That is the only documented troubleshooting
step.

**Known upstream bug.** Running as any UID other than 1000 makes git reject the app
directory, since `/opt/magic_mirror` is owned `1000:1000` inside the image:
`fatal: detected dubious ownership in repository at '/opt/magic_mirror'`. Observed on
`wolfi-server`, not on `debian-server`. It breaks `updatenotification`, which shells out to
git; MagicMirror² itself serves normally. The fix belongs in the image —
`git config --system --add safe.directory /opt/magic_mirror`, since `--system` writes
`/etc/gitconfig` and works for any uid, whereas the `--global` hint git prints is useless
when the running uid has no writable HOME. This bug is why the default tag is still
`debian-server` despite §3 favouring minimal bases — see the conflict row in §14.

**Shells differ per variant.** `/bin/bash` exists only in `debian-server`; `wolfi-server`
and `alpine` ship `/bin/sh` (and `ash`) only. `<Shell>` is a single template-wide value, so
it tracks the default `<Repository>` tag. If the default ever moves to a wolfi or alpine
variant, `<Shell>` must change to `sh` in the same commit.

Only the `*-server` and `alpine` tags are offered. The `*-electron` variants need a locally
attached display and cannot work on a headless Unraid server.

### Reproducing the verification

`.tmp/test-unraid-images.sh` runs the whole check against a host and cleans up after
itself:

```powershell
ssh qhec02 'sh -s' < .tmp\test-unraid-images.sh
```

Inline heredocs trip the local protection that blocks `rm -rf` patterns, which is the
concrete reason §3 mandates script files — the scripts use `find … -delete` instead.

## 20. Where issues belong

Template problems (paths, ports, permissions, the CA listing) → this repo's issues.
Image problems → gitlab.com/khassel/magicmirror. MagicMirror² or module problems →
forum.magicmirror.builders. `ca_profile.xml`, `templates/magicmirror.xml` and `README.md`
each state this split; keep them consistent (§8).
