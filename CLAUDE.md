# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# General Development & Coding Guidelines

These guidelines apply to all development tasks in this project. Any deviation requires prior approval.

---

## 1. Exceptions & Decision Process
* **No Unauthorized Deviations:** If one or more of these principles cannot be enforced, applied, or are technically not sensible in a specific case, do not deviate on your own initiative under any circumstances.
* **Obligation to Consult:** In case of conflicting goals, constraints, or ambiguities, always consult before proceeding.
* **Explicit Approval:** Deviations from these standards are only permitted after consultation and explicit approval, specifying the location and scope.

## 2. Holistic Project Analysis & Standards
* **Holistic View of the Project:** Before making any code changes, analyze and understand the entire repository (architecture, dependent modules, directory structures). Avoid isolated fixes or changes without considering the overall system.
* **Boy Scout Rule (Continuous Refactoring):** Leave the code cleaner than you found it. Address small defects while working (e.g., unused imports, typos, outdated comments), as long as it stays within the scope of the current task.
* **Open Standards First:** Always prefer open standards, formats, and protocols over proprietary solutions. Proprietary technologies are only allowed after explicit approval if a clear technical value is demonstrated.
* **Best Practices:** Utilize established design patterns and current state-of-the-art practices for the given programming language/framework (e.g., SOLID, DRY, KISS).

## 3. Character Encoding & Project Structure
* **Strict UTF-8 Requirement:** All source code files, configurations, documentation, data formats (JSON, XML, CSV), and database schemas must strictly use **UTF-8 (without BOM)** encoding.
* **Completeness Within the Project Folder:** All project-related artifacts—including subtasks, temporary files (`temp/` or `.tmp/`), test files (`tests/`), build scripts, and documentation—must reside **exclusively within the current project directory**.
* **Logical Directory Structure:** Nothing may be stored outside the project folder. Create and maintain a clear, logical folder hierarchy inside the project.
* **Clean Git Ignore:** Temporary files, cache directories, or local test artifacts that do not belong in the Git repository must be strictly excluded via `.gitignore`.

## 4. Internationalization (i18n) & Localization
* **Default Languages:** The software architecture must support multi-language capabilities. By default, **German (`de`)** and **English (`en`)** must be provided.
* **No Hardcoded UI Strings:** User-facing text, error messages, notifications, or labels must never be hardcoded directly into the code. Use centralized i18n translation files or localization frameworks instead.

## 5. Documentation Language & Code Comments
* **Documentation Exclusively in English:** All project documentation (`README.md`, `CHANGELOG.md`, architecture guides, API specs, inline docstrings) must be written strictly in **English**.
* **English Code Comments:** All code, functions, classes, and complex logic must be commented exclusively in **English**.
* **Standardized Commenting:** Use established documentation standards relevant to the language (e.g., JSDoc for JavaScript/TypeScript, Python Docstrings/PEP 257, Doxygen for C/C++).
* **Meaningful Comments:** Comment the *why* behind the logic, not the obvious *what*. Code should be self-explanatory; comments provide additional context.

## 6. Configuration & Environment Variables
* **No Hardcoding:** Configuration values (e.g., IPs, ports, paths, feature flags, API endpoints) must never be hardcoded directly in the source code.
* **Env Templates:** Every repository must contain an `.env.example` or `config.example.json` documenting all required environment variables with sensible default/example values.

## 7. Git, Versioning & Documentation Audit
* **Git Authorship & Human User Identity:** All code modifications, commits, pull requests, and Git operations must be authored and committed exclusively under the current human developer/user account credentials. Never attribute commits, co-authorships, sign-offs, or Git metadata to AI agents, AI bots, or specific AI tools (e.g., Claude, ChatGPT, Copilot, etc.). AI identities must never appear in the commit history or contributor lists.
* **Versioning on Changes:** Every change to the software requires a transparent and correct version update according to Semantic Versioning (`MAJOR.MINOR.PATCH`).
* **Synchronous Documentation Audit:** Whenever software or version changes occur, **all** affected files and documentation must be reviewed and updated within the same pull request/commit context.
* **Repository Cleanliness:** Keep the Git repository consistent and up to date with every change. Commits must be cleanly split and traceable.
* **CI/CD Compliance:** All tooling, linters, and automated pipelines must run error-free both locally and on the server. Standardized commit messages (e.g., Conventional Commits) are required.

## 8. Security & Privacy (Privacy & Security by Design)
* **Data Minimization:** Only collect, store, and process data strictly required for the specific feature or function.
* **Data Protection (GDPR):** Comply with applicable data protection regulations. Personally Identifiable Information (PII) must never be processed unencrypted or written to log files.
* **Security Essentials:** Never commit passwords, API keys, or secret tokens to code. Validate and sanitize all user input strictly.

## 9. UI/UX Design
* **Modern Design Guidelines:** Align user interaction concepts with modern UI/UX standards and established design systems.
* **Accessibility & Usability:** Build interfaces to be intuitive, accessible (WCAG guidelines), and consistent across various screen sizes.

## 10. Code Quality, Typing & Tooling
* **Strict Typing:** Use explicit typing wherever supported by the language (e.g., TypeScript, Python Type Hints) to catch runtime errors early.
* **Linting & Formatting:** Linter and formatter rules must be strictly obeyed. Linter warnings must be fixed and must not be ignored or suppressed.
* **Dependency Checks & SBOM/BOM Management:**
  * Maintain, document, and continuously update a **Software Bill of Materials (SBOM / BOM)** covering all direct and transitive dependencies, external libraries, and modules.
  * Regularly audit dependencies for security vulnerabilities (CVEs), newer versions, and available features.
  * Ensure compatible open-source licensing (e.g., MIT, Apache-2.0) and minimize unnecessary external packages.
* **Test Coverage:** Write unit and integration tests for new features and bug fixes. Builds must fail if regressions occur.
* **Error Handling & Logging:** Use structured logging and clean error handling. Errors must never leak internal system details to end-users.

## 11. Performance & Resource Management
* **Resource Cleanup:** All opened resources (e.g., file handles, network sockets, database connections, memory) must be explicitly and safely released (e.g., via `try-finally` or context managers).
* **Efficiency & Asynchrony:** Blocking operations (I/O, network) should be handled asynchronously where possible. Avoid unnecessary polling or CPU-intensive infinite loops.

---

## 12. Open Deviations — Approval Required (per §1)

This repository is packaging data, not a software product: it ships no executable code, no
runtime, no UI and no dependencies it installs. Several guidelines above therefore have no
technical anchor here. Per §1 these are **not** treated as silently waived — they are listed
as open items awaiting explicit approval, and this section must be updated when a decision
is made.

| # | Guideline | Status | Question for the maintainer |
|---|---|---|---|
| §4 | i18n, German **and** English | **Blocked, cannot comply** | Unraid CA has no localization mechanism. `<Overview>`, `<Requires>` and `<Profile>` are single-value fields and CA renders exactly one string to every user worldwide. Providing `de` is technically impossible without CA support. Approve English-only? |
| §6 | `.env.example` required | **Open** | This repo has no runtime configuration of its own. The container's environment variables are declared as `<Config Type="Variable">` entries in `templates/magicmirror.xml`, which is the canonical, machine-readable equivalent. Approve omitting a separate `.env.example`, or add one purely as documentation? |
| §7 | SemVer on every change | **Not yet implemented** | The repo currently carries no version. Sibling repo `find-my-timeline-unraid` maintains `CHANGELOG.md` and versioned releases. Adding `CHANGELOG.md` plus a version reflected in `<Changes>` would align the two. Approve? |
| §7 | Conventional Commits | **Open** | The four commits predating this ruleset use plain imperative subjects rather than `type: subject`. History has already been rewritten once (to strip AI co-author trailers), so converting the subjects costs one further force-push. Approve, or leave the early history as is? |
| §7 | CI/CD must run error-free | **Not yet implemented** | No pipeline exists. The two verification steps in §14 are currently manual. A GitHub Actions workflow running both on every push would satisfy this cheaply. Approve? |
| §10 | SBOM / BOM | **Not yet implemented** | The only "dependency" is the upstream container image and its two upstream projects. A short `SBOM.md` recording image, tags, upstream repositories and their licenses is meaningful here; a generated SPDX/CycloneDX document is not, since nothing is built. Approve the lightweight form? |
| §10 | Test coverage, strict typing, linting | **Not applicable** | No executable code exists to type, lint or unit-test. The equivalent quality gate is XML well-formedness plus URL reachability (§14). Confirm this reading? |
| §9, §11 | UI/UX, resource management | **Not applicable** | No UI and no runtime in this repository. The rendered UI belongs to MagicMirror² upstream. |

Do not resolve any row above unilaterally. Ask, then record the decision here.

### Enforced: commit authorship (§7)

Commits are authored and committed as `heckpiet <heckpiet@gmail.com>`, configured in this
repository's local git config. **Never add a `Co-Authored-By:` trailer naming an AI tool,
never add `Signed-off-by` on an AI's behalf, and never set author or committer metadata to
anything other than the human maintainer.** The history was rewritten on 2026-08-04 to
remove such trailers; do not reintroduce them. Verify before pushing:

```powershell
git log --all --pretty=format:"%an <%ae>|%B" | Select-String -Pattern "claude|anthropic|copilot|chatgpt|co-authored" -CaseSensitive:$false
```

That search must return nothing. `CLAUDE.md` itself is the one legitimate match for the
word "claude" in the working tree — it is a filename, not authorship metadata.

---

## 13. What this repository is

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
belong upstream at khassel/magicmirror, not here. This split is also why §10's dependency
auditing lands on the upstream image rather than on anything vendored here.

## 14. Verification commands

Run both after any XML change. The CA portal rejects malformed XML and silently produces a
broken listing if a raw URL 404s. These are the repository's quality gate in the absence of
a test suite (see §12).

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

# 3. UTF-8 without BOM (§3) — must report "no BOM" for every file
Get-ChildItem -Recurse -File -Force |
  Where-Object { $_.FullName -notmatch '\\\.git\\' } |
  ForEach-Object {
    $b = [System.IO.File]::ReadAllBytes($_.FullName)
    $hasBom = $b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF
    "{0,-10} {1}" -f $(if ($hasBom) { "BOM !!" } else { "no BOM" }), $_.Name
  }
```

Note that `[xml]$x; $x.DocumentElement.Name` reports `MagicMirror`, not `Container` —
PowerShell's XML adapter lets the child `<Name>` element shadow the `.Name` property. The
root element is `<Container>`.

Then run **Validate** and **Scan** at <https://ca.unraid.net/submit/new> after each
meaningful XML change. That portal is the source of truth, not any third-party guide.

## 15. The critical invariant: URLs encode owner, repo and branch

`<TemplateURL>`, `<ReadMe>`, `<Icon>`, `<Support>`, `<Project>`, `<WebPage>` and `<Forum>`
are hardcoded `raw.githubusercontent.com/heckpiet/magicmirror-unraid/main/...` URLs. They
break silently — CA keeps serving a stale or empty listing — if the repo is renamed,
transferred, forked, or the default branch changes away from `main`.

This is the one place where §6's "no hardcoding" rule genuinely bites: CA offers no
variable substitution in template XML, so these values cannot be externalized. Treat the
handover checklist at the bottom of `README.md` as the substitute — it enumerates every
value that must change on transfer. Keep that checklist in sync when adding any new
URL-bearing tag.

The repo is deliberately written to be handed over to the upstream image maintainer.

Sibling repo `heckpiet/find-my-timeline-unraid` uses `master`, not `main`. Do not copy URLs
between the two without changing the branch segment.

## 16. Template conventions

Matched to `heckpiet/find-my-timeline-unraid`, the maintainer's other CA repository:

- **`<Overview>` only, no `<Description>`.** CA renders `<Overview>`; carrying both means
  maintaining duplicate prose, which violates DRY (§2).
- **Self-closing `<Config .../>` entries** with no inner text.
- **`<Config Name>` is human-readable** ("Timezone", "Run mode"), not the variable name.
- **`[br]` and `[b]`**, not HTML, for markup inside `<Overview>`.
- **`&#178;`** for the ² in MagicMirror². A literal ² in the XML is a portability risk even
  though the file itself is UTF-8 (§3).
- **No `<MaxVer>`** — deliberate. Setting it makes the listing vanish on later Unraid
  releases. `<MinVer>` is `6.12.0`.
- **No `<Screenshot>`** — deliberate, and a licensing decision under §10: the official
  MagicMirror² renders live in `MagicMirrorOrg/MagicMirror-Website`, which carries **no
  license**, so they cannot be redistributed. Only add screenshots taken from an actual
  install.

## 17. Two upstream facts the template documents

Both were derived by reading upstream source, not from any documentation. They are the
reason the container fails for Unraid users, and they are duplicated in three places —
`<Overview>`, `<Requires>` and `README.md`. Editing one means editing all three (§7,
synchronous documentation audit).

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

MagicMirror² ships no authentication. Under §8 the template must keep telling users to keep
port 8080 on a trusted LAN or behind an authenticated reverse proxy; do not soften that
wording.

Only the `*-server` and `alpine` tags are offered. The `*-electron` variants need a locally
attached display and cannot work on a headless Unraid server.

To re-verify upstream behaviour, these are the files worth fetching (the GitLab default
branch is `master`):

```
https://gitlab.com/khassel/magicmirror/-/raw/master/build/entrypoint.sh
https://gitlab.com/khassel/magicmirror/-/raw/master/run/original.env
https://gitlab.com/khassel/magicmirror/-/raw/master/run/includes/base.yaml
```

## 18. Where issues belong

Template problems (paths, ports, permissions, the CA listing) → this repo's issues.
Image problems → gitlab.com/khassel/magicmirror. MagicMirror² or module problems →
forum.magicmirror.builders. `ca_profile.xml`, `templates/magicmirror.xml` and `README.md`
each state this split; keep them consistent (§7).
