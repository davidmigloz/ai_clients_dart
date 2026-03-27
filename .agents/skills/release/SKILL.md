---
name: release
description: >-
  Release Dart packages in the ai_clients_dart monorepo. Detects changes since
  last release, bumps semver, writes changelogs, publishes to pub.dev, creates
  git tags, and creates a combined GitHub release. Use for releasing packages,
  publishing, version bumping, or creating releases.
disable-model-invocation: true
---

# Release Skill for ai_clients_dart

This skill handles the full release lifecycle for the ai_clients_dart monorepo.
It supports three execution modes controlled via `$ARGUMENTS`:

- **`/release --plan`** — Plan-only mode: detects changes, computes bumps, shows release plan. No file edits, no publish, no tags. Safe to run on any branch.
- **`/release --dry-run`** — Dry-release mode: does everything including file edits and `dart pub publish --dry-run`, but stops before actual publishing/tagging/committing. Always restores the working tree before exit (on both success and failure).
- **`/release`** — Full release mode: the complete workflow.

Parse `$ARGUMENTS` to determine the mode. If `$ARGUMENTS` contains `--plan`, run in plan-only mode. If it contains `--dry-run`, run in dry-run mode. Otherwise, run in full release mode.

---

## Step 1: Validate Environment

Perform all applicable checks before proceeding. Fail fast with an actionable error message if any check fails.

1. **Branch check** (full release mode only):
   Must be on `main` branch. In `--plan` and `--dry-run` modes, any branch is allowed (but warn the user that results may differ from main).
   ```bash
   git branch --show-current  # must output "main" in full release mode
   ```
2. **Clean working tree**: No uncommitted changes.
   ```bash
   git status --porcelain  # must be empty
   ```
3. **Up-to-date with remote** (full release mode only):
   ```bash
   git fetch origin main
   test "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)"  # HEAD must equal origin/main
   ```
   In `--plan` and `--dry-run` modes, skip this check.
4. **CLI availability**: `dart` and `gh` must be on PATH.
5. **Auth preflight** (skip in `--plan` mode):
   - **GitHub**: `gh auth status` — must show authenticated. If not, tell user to run `gh auth login`.
   - **pub.dev**: There are two authentication mechanisms:
     - **OAuth session** (from `dart pub login`) — this is the primary and recommended method. It does NOT appear in `dart pub token list`.
     - **Token-based** (from `dart pub token add`) — these appear in `dart pub token list` but are less common.
   - **Do not assume unauthenticated just because `dart pub token list` is empty.** An active OAuth session is invisible to that command.
   - **Reliable verification**: Run `dart pub publish --dry-run` in any package directory as the auth smoke test. If it succeeds (exit code 0, no auth errors), authentication is working regardless of the mechanism.
     ```bash
     cd packages/{any_pkg} && dart pub publish --dry-run 2>&1
     ```
   - If the dry-run fails with an authentication error, tell the user to run `dart pub login` (OAuth, recommended) or `dart pub token add https://pub.dev` (token-based, alternative).

---

## Step 2: Detect Changes Per Package

> **IMPORTANT — Working directory**: All `git` and shell commands throughout this skill assume the **repository root** as the working directory. The Bash tool does not persist `cd` between calls, so **always use absolute paths or prefix commands with a quoted repo path, for example `REPO_ROOT="/path/to/repo"` then `cd "$REPO_ROOT" && ...`, when running shell commands**. Never rely on a previous `cd` having set the working directory. This applies to every step, not just this one.

### Discover packages

Read the `workspace` list from the root `pubspec.yaml` (the source of truth). Each entry is a relative path like `packages/foo`. Extract the package directory name from each path (the last segment). If parsing fails, fall back to `ls packages/`.

### For each package

1. **Find last release tag**:
   ```bash
   git tag --list "{pkg}-v*" --sort=-v:refname | head -1
   ```
   This sorts by semver (not creation date) to find the latest version tag.

2. **Get commits since that tag**:
   ```bash
   git log --format="%H|||%s|||%b|||END" {tag}..HEAD -- packages/{pkg}/
   ```
   Use `|||` as field delimiter and `|||END` as record terminator. **Parse by splitting on `|||END` first** (to get individual commit records), then discard any empty records from the result (the final terminator produces a trailing empty element). After filtering, split each remaining record on `|||` **into at most three parts** (hash, subject, body) so any additional `|||` sequences in the subject or body remain inside the body field. Do not blindly split on every occurrence of `|||`. Avoid using ASCII control characters (`%x1f`, `%x1e`) as delimiters — they can be silently stripped or mangled by shell processing, leading to empty results.

3. **No previous tag** (first release): use all commits touching `packages/{pkg}/`.

4. **Filter out non-publishable changes**: If `packages/{pkg}/.pubignore` exists, read its lines as ignore entries. `.pubignore` supports gitignore-style syntax, but **for this release filtering step, only treat entries that are simple directory names** (with or without trailing `/`, no wildcards, `!` negation, or additional `/` path separators) as ignore directories relative to `packages/{pkg}/` (typically names like `.agents`, `.claude`, `specs`). Skip blank lines and lines starting with `#` (comments). Any more complex patterns in `.pubignore` should be ignored for this filtering logic and must not cause a commit to be misclassified as non-publishable.

   For each commit found in step 2 (or step 3 for first releases), check which files it actually changed within the package:
   ```bash
   git show --pretty="" --name-only {hash} -- packages/{pkg}/
   ```
   If **every** changed file falls under one of the supported `.pubignore` directory-name entries (i.e., for some listed directory `DIR`, the path starts with `packages/{pkg}/DIR/`, such as `packages/{pkg}/.agents/` or `packages/{pkg}/specs/`), **exclude that commit** — it has no effect on the published package. Only retain commits that touch at least one file outside these ignored directories.

   > This prevents internal tooling changes (AI agent configs, spec files, etc.) from triggering unnecessary releases. The commit is still recorded in git history but is not considered for version bumps or changelog entries.

5. **No commits since tag** (after filtering): provisionally note this package for skipping — but **always continue to Step 6** to check for unreleased version bumps before finalizing the skip decision.

6. **Detect unreleased version bumps**: Compare the `version:` field in `packages/{pkg}/pubspec.yaml` against the version extracted from the latest tag:
   ```bash
   # Extract version from latest tag (e.g., "foo_dart-v1.0.0" → "1.0.0")
   tag_version=$(echo "$latest_tag" | sed "s/^${pkg}-v//")
   # Read pubspec version
   pubspec_version=$(grep '^version:' packages/${pkg}/pubspec.yaml | awk '{print $2}')
   ```
   - If `pubspec_version` > `tag_version`, this package has a **pre-applied version bump** — someone manually set the version in the pubspec but never published it. Flag this package for release even if Step 5 found "no commits since tag" would normally skip it.
   - If `pubspec_version` == `tag_version` and there are no new commits, skip as normal.

   > **Caution**: The git tag is the definitive indicator of whether a version has been published, not the pubspec. A pubspec may show `version: 1.0.0` while no `{pkg}-v1.0.0` tag exists — this means 1.0.0 was never actually released. Always check tags to determine published state.

---

## Step 3: Parse Commits and Determine Version Bumps

### Parse each commit subject as a conventional commit

Format: `type(scope)!: description`

- Extract `type`, optional `scope`, optional `!` (breaking indicator), and `description`.
- Also check the commit **body** for `BREAKING CHANGE:` footer (case-insensitive).

### Classify changes

**Release-triggering types** (only these cause a version bump):
| Type | Bump |
|------|------|
| `feat` | minor |
| `fix` | patch |
| `refactor` | patch |
| `perf` | patch |
| `docs` | patch |

> Note: `docs` and `perf` as patch bumps are intentional and match this repo's conventions, even though some tools treat them as non-release.

**Non-release types** (include in changelog notes but do NOT trigger a version bump):
| Type |
|------|
| `test`, `chore`, `build`, `style`, `ci` |

**Breaking change override**: If a commit has a breaking change (`!` suffix OR `BREAKING CHANGE:` in body), it **always triggers a release** regardless of type — override bump to **major**. This applies to non-release types too (e.g., `build!: Require Dart >=3.8.0` triggers a major bump). Historically this repo has `**BREAKING** **BUILD**:` entries that triggered releases.

### Determine version bump per package

Take the **highest** bump across all commits that trigger a release for each package:
- major > minor > patch
- If the package has ONLY non-release commits **with no breaking changes** (test, chore, etc.) → skip the package (no release).

### Pre-1.0 packages (current major version is 0)

- Breaking change → bump **minor** (not major)
- `feat` → bump **patch** (not minor)
- Ask user if they want to promote to 1.0.0 instead

### Handle build metadata

If the current version has `+N` build metadata (e.g., `0.3.0+1`), strip the `+N` before bumping. The new version will not have build metadata.

### Pre-applied version bumps

If Step 2.6 detected that a package's pubspec version is ahead of its latest tag version:

1. **Pubspec version >= computed bump version**: Use the pubspec version as-is. The version was intentionally set (e.g., a 1.0.0 rewrite) and should be respected.
2. **Computed bump would be higher than pubspec version**: Warn the user and ask which version to use. This is unusual and may indicate a mistake (e.g., someone set a patch bump manually but breaking changes were added later).
3. **Changelog scope**: In either case, include **all commits since the last tag** in the changelog, not just commits since the pubspec was changed. The tag marks the last published state, so all changes since then are unreleased.

---

## Step 4: Present Release Plan for Confirmation

**In all modes (`--plan`, `--dry-run`, full):** display the release plan.

Show a summary table:

```
| Package | Current Version | New Version | Bump Type | # Commits |
|---------|-----------------|-------------|-----------|-----------|
| foo_dart | 1.2.3 | 1.3.0 | minor | 5 |
```

Then list commits per package, grouped by:
1. **Release-triggering commits** (feat, fix, refactor, docs, breaking)
2. **Non-release commits** (test, chore, build, etc.) — shown for awareness but labeled as "will not affect version"

**If `--plan` mode**: **Ask user to confirm** (they may override bump types or skip specific packages), then STOP here. Do not proceed to any file edits. Step 4b is skipped in plan mode, so confirmation happens in this step.

**If `--dry-run` or full release mode**: Do not ask for confirmation yet — Step 4b may surface semver adjustments that affect the plan. Display the plan for the user to review; confirmation will happen at the end of Step 4b after semver verification.

---

## Step 4b: Fetch PR Context for Semver Verification and Changelog Summaries

> **Skip this step in `--plan` mode.**

Commit subjects are terse one-liners (e.g., `feat(chromadb): update OpenAPI spec and implement new models`). They tell you *what* file changed but not *why* it matters or what users should know. PR descriptions in this repo conventionally include a `## Summary` section with bullet points describing the full rationale, scope of changes, and migration notes. This step fetches that richer context to (1) verify that the semver bump from Step 3 is correct and (2) give Step 5 the information it needs to write meaningful changelog summaries.

### Collect PR numbers

From the commits parsed in Step 3, extract unique PR numbers. PR references appear as `(#N)` in commit subjects. Deduplicate across all packages — a single PR may appear in commits for multiple packages.

### Fetch PR descriptions via subagent

Spawn a **single subagent** (using the Agent tool) with:

- The deduplicated list of PR numbers
- Instructions to run `gh pr view {N} --json title,body,author` for each PR
- For each PR, extract the author's GitHub login from `author.login`
- For each PR body, extract the structured sections created by the `/create-pr` skill:
  1. **`## Summary`**: Extract the bullet points (up to the next `##` heading or end of body). This is the primary source for changelog entries.
  2. **`## Details`**: Extract the full content of this section. Contains extended context — API examples, architecture decisions, configuration changes — that enriches changelog summaries beyond what the bullets provide.
  3. **`## Breaking Changes`**: Extract this section if present. This is the most reliable signal for breaking changes — more precise than heuristic phrase matching in the general body. Contains migration paths and before/after code examples.
  4. **`## References`**: Extract this section if present. Contains links to official announcements, blog posts, or documentation. Each list item follows the format `- [title](url) — description`. Parse per list item: extract `title` and `url` from the markdown link, and `description` from the trailing text after the em dash. As a fallback for PRs without this section, scan `## Summary` and `## Details` for markdown links whose domains match known provider sites (blog.google, openai.com/blog, docs.anthropic.com, mistral.ai/news, ollama.com/blog, docs.trychroma.com); for these fallback links, use the link text as `title` and set `description` to an empty string.
  5. **Strip boilerplate**: Remove review tool badges, HTML comments (`<!-- ... -->`), `## Test Plan` sections, and other template noise.
  6. **Fallback**: If no `## Summary` heading exists (older PRs or external contributors), use the first substantive paragraph of the PR body (skip blank lines, HTML comments, and badge images at the top). Wrap the paragraph as a single entry in `summary_bullets` so downstream handling is uniform.
  7. **Error fallback**: If `gh pr view` fails for a PR (e.g., PR was from a fork, or was deleted), log a warning and skip that PR — do not fail the release.
- Return a structured list: `[{pr: N, title: "...", author_login: "...", summary_bullets: ["..."], details: "...", breaking_changes: "...", has_breaking_signals: true/false, references: [{title: "...", url: "...", description: "..."}]}]`
  - `has_breaking_signals` is `true` if a `## Breaking Changes` section exists, OR if the body contains phrases like "breaking change", "migration required", "removed", "renamed", "changed signature", "no longer supports"

**Why a single subagent**: PR bodies can be large and noisy. Fetching them in a subagent keeps that content out of the main context window. A single subagent (rather than one per PR) avoids spawn overhead while still isolating the data.

### Map PR summaries to packages

After the subagent returns, map each PR's summary to the packages it affects by matching PR numbers back to the per-package commit lists from Step 3. A PR that appears in commits for multiple packages should be available to all of them.

Store the mapping (package → list of PR summaries) for use in Steps 5 and 5b. Also preserve the full PR list (including `author_login` fields) for use in Step 11's Contributors section.

### Verify semver bumps against PR context

Cross-check the version bumps computed in Step 3 against the PR context returned by the subagent. Commit subjects often understate the impact of a change — a commit typed as `fix` or `refactor` may actually introduce breaking API changes that the PR description makes explicit.

For each package, review the PR summaries (especially `has_breaking_signals` and `breaking_changes`) and flag **semver mismatches**:

1. **Undeclared breaking changes**: A PR's body describes breaking changes (removed fields, renamed APIs, changed defaults, dropped platform support) but no commit in that package carries a `!` suffix or `BREAKING CHANGE:` footer. → **Warn the user** and recommend upgrading the bump to major (or minor for pre-1.0 packages).

2. **Feature misclassified as fix**: A PR describes new capabilities, new API surface, or new configuration options, but all commits are typed as `fix` or `refactor`. → **Suggest** upgrading the bump to minor (or patch for pre-1.0 packages).

3. **No action needed**: The PR context confirms the commit-derived bump is appropriate.

Present any flagged mismatches to the user along with the release plan from Step 4, and **ask the user to confirm** the final version bumps before proceeding to changelog writing. The user decides whether to accept or override. If there are no mismatches, confirm the plan as-is. Example:

```
⚠️  Semver check — PR context suggests bump adjustments:

| Package      | Computed Bump | PR Signal          | Suggested Bump | Reason                                      |
|--------------|---------------|--------------------|----------------|----------------------------------------------|
| chromadb     | patch         | breaking signals   | minor (pre-1.0)| PR #99: nullable fields now required          |
| openai_dart  | patch         | new feature        | minor          | PR #95: adds new embedding model support      |

Accept computed bumps, or adjust? [accept / adjust]
```

> **Why this matters**: Semver is a contract with downstream users. A breaking change shipped as a patch version can break builds silently. Commit subjects are written quickly and are often wrong about impact level — PR descriptions, written for reviewers, are more reliable.

---

## Step 5: Write Changelogs

For each released package, **prepend** a new section to `packages/{pkg}/CHANGELOG.md`.

### Changelog section format

```markdown
## {new_version}

> [!CAUTION]                                                                                                           ← only if breaking
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

{AI-written summary of main changes, 1-3 sentences}

- **BREAKING** **FEAT**: Description ([#N](https://github.com/davidmigloz/ai_clients_dart/issues/N)). ([abcd1234](https://github.com/davidmigloz/ai_clients_dart/commit/{full_40_char_hash}))
- **FEAT**: Description. ([abcd1234](https://github.com/davidmigloz/ai_clients_dart/commit/{full_40_char_hash}))
- **FIX**: Description. ([abcd1234](https://github.com/davidmigloz/ai_clients_dart/commit/{full_40_char_hash}))
```

### Formatting rules

1. **Remove package scope** from entries: `feat(googleai_dart): Foo` → `**FEAT**: Foo`
2. **Short hash** in display = first **8 characters** of the commit hash
3. **Full 40-char hash** in the commit URL
4. **Extract issue numbers** from:
   - `(#N)` in the commit subject — there may be **multiple** references (e.g., `(#913) (#914)`); collect all of them
   - `Closes #N`, `Fixes #N`, `Resolves #N` in the commit body
   - Render all collected issue numbers in the order they appear: `([#913](...)) ([#914](...))`
   - If no issue number found, omit the issue link portion entirely
5. **Ordering within the changelog section**:
   - BREAKING entries first (any type with breaking change)
   - Then release-triggering types: FEAT, FIX, REFACTOR, PERF, DOCS
   - Then non-release types (if included): BUILD, STYLE, CI, TEST, CHORE
   - Within each type group, sort by **commit date descending** (newest first)
6. **All links in new changelog entries** must point to `https://github.com/davidmigloz/ai_clients_dart` (older historical entries may still reference `davidmigloz/langchain_dart` — leave those as-is)
7. **Standard markdown list**: `- **TYPE**: ...` (no leading space)
8. **Breaking note**: Only include the following if there are breaking changes:
   ```
   > [!CAUTION]
   > This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.
   ```
9. **AI summary**: Write 1-3 sentences summarizing the main changes in plain English. Place it between the breaking note (if any) and the entry list.

   **Primary source**: Use the PR summaries collected in Step 4b as the primary source for writing the summary. PR descriptions contain the rationale, scope, and user-facing impact that commit subjects lack. Synthesize across multiple PRs into a coherent narrative — do not simply parrot PR titles or concatenate bullet points.

   **Quality guidance**:
   - Focus on **user-facing impact**: what changed, why it matters, and any migration notes
   - Mention specific capabilities added or problems fixed, not just "updated X"
   - If a release includes breaking changes, call out what broke and what users need to do

   **Announcement links**: If PR references include links to official
   announcements or blog posts (from the `references` field collected in
   Step 4b), weave them naturally into the summary prose using inline
   markdown links — e.g., "Added [Gemini Embedding 2](https://blog.google/...)
   support." Do not create a separate references list; embed the links where
   they add context to the narrative.

   **Fallback**: If PR context is unavailable for some or all commits (e.g., Step 4b was skipped, PRs failed to fetch, or commits have no PR references), fall back to commit messages. Synthesize commit subjects into the best summary possible.

   **Before/after example** — commit-only summary (current quality):
   > Updated OpenAPI spec and added new models.

   **PR-enriched summary (target quality):**
   > Update ChromaDB client to latest API spec — adds quantization support, spanned index config, and read-level controls for queries. Collection fields that were previously nullable are now required, matching the upstream API contract.

### Pre-existing changelog sections

Before writing a new changelog section, check if `## {new_version}` already exists in `CHANGELOG.md`:

1. **Detection**: Match `^## {new_version}` (exact version, at start of line) in the file.
2. **If the section already exists**:
   1. **Review the existing content for quality**: Pre-existing sections may be draft notes, rough bullet points, or incomplete text from a PR. Read the content carefully and ensure it is polished, well-structured, and presentable as a published changelog. Fix grammar, formatting, missing links, or unclear descriptions. Ensure it follows the same formatting conventions as the rest of the changelog (bold type prefixes, issue/commit links, ordering rules defined above).
   2. **Append** a `### Commits` subsection at the end of the existing section with the auto-generated commit entries (using the standard formatting rules above). This preserves the hand-written narrative while adding the structured commit log.
   3. If the existing section lacks a breaking change note but the commits include breaking changes, add the `> [!CAUTION]` / `> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.` admonition at the top of the section (after the `## {version}` heading).
3. **If the section does not exist**: Proceed with normal prepend behavior as described above.

---

## Step 5b: Update Migration Guides

> **Skip this step if no packages in this release have breaking changes.**
> **Also skip in `--plan` mode.**

For each package with breaking changes, update `packages/{pkg}/MIGRATION.md`
with migration instructions extracted from PR descriptions. This ensures
consumers have a single, up-to-date document for navigating breaking changes
across versions.

### Source material

Use the `breaking_changes` field from the PR summaries collected in Step 4b.
This contains the `## Breaking Changes` section from the PR description,
which includes migration paths with before/after code examples.

If `breaking_changes` is empty for a package that has breaking commits (e.g.,
older PRs without a `## Breaking Changes` section), synthesize migration
content from commit messages and PR summaries — focus on what changed and
what the consumer needs to update.

### Entry format

Insert a new section after any introductory paragraph(s) that appear
immediately under the `# Migration Guide` heading, and before any existing
`## Migrating from...` sections (reverse chronological — newest on top):

    ## Migrating from v{prev}.x to v{new_version}

    {1-3 sentence summary of what broke and why}

    ### 1) {Breaking change title}

    {Description and migration path, including before/after code examples}

    ---

Where `{prev}` is derived from the previous release tag version:
- **Major version packages (>=1.0)**: Use the major version. E.g., if previous
  tag was `1.3.0` and bumping to `2.0.0`: "Migrating from v1.x to v2.0.0"
- **Pre-1.0 packages**: Use the major.minor version. E.g., if previous tag
  was `0.3.2` and bumping to `0.4.0`: "Migrating from v0.3.x to v0.4.0"

`{new_version}` is the version being released.

### Handling multiple breaking PRs

If multiple PRs contribute breaking changes to the same package, combine them
into a single migration section with numbered subsections (one per distinct
breaking change). Synthesize into a coherent guide rather than concatenating
PR sections verbatim.

### File does not exist

If `packages/{pkg}/MIGRATION.md` does not exist, create it:

    # Migration Guide

    This guide covers breaking changes between major versions of `{pkg}`.

    For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).

    ---

    ## Migrating from v{prev}.x to v{new_version}

    {content}

    ---

Track newly created files so dry-run cleanup (Step 7) can remove them.

### Pre-existing section

If `## Migrating from v{prev}.x to v{new_version}` already exists
(e.g., manually added), review and merge. Prefer the existing text where it
conflicts but add any missing migration paths from the PR descriptions.

### Quality check

Verify that before/after code examples reference correct class names and
method signatures from the actual released package version.

---

## Step 6: Update pubspec.yaml Versions

For each released package, update the `version:` field in `packages/{pkg}/pubspec.yaml` to the new version.

---

## Step 6b: Update README Quickstart Versions

For each released package, update the version in the Quickstart pubspec snippet in `packages/{pkg}/README.md`. Find the `dependencies:` block inside the `## Quickstart` section and replace the version constraint:

```
dependencies:
  {pkg}: ^{new_version}
```

This keeps the README install snippet in sync with the published version.

---

## Step 7: Dry-Run Publish (before committing!)

Run `dart pub publish --dry-run` from each package directory:
```bash
cd packages/{pkg} && dart pub publish --dry-run
```

Present the results and **ask user to confirm** before actual publishing.

If there are **errors** (not warnings):
- Stop and **restore the working tree** (revert tracked changes and remove generated artifacts):
  ```bash
  git checkout HEAD -- packages/
  git clean -fdX packages/    # remove ignored/generated files (e.g., .dart_tool/, build outputs)
  # Also remove any newly created MIGRATION.md files from Step 5b:
  rm -f packages/{pkg}/MIGRATION.md  # only for packages where the file was newly created
  ```
- Report which packages had errors and what the errors were.

**If `--dry-run` mode**: After showing the dry-run results, **restore the working tree** and STOP:
```bash
git checkout HEAD -- packages/
git clean -fdX packages/
# Also revert or remove any MIGRATION.md files modified or created by Step 5b:
# For newly created files (not in HEAD), git checkout will fail — remove them explicitly:
rm -f packages/{pkg}/MIGRATION.md  # only for packages where the file was newly created
```

---

## Step 8: Publish

**Only in full release mode.**

Publish packages **one at a time**, in workspace order (as listed in root `pubspec.yaml`). Currently no packages depend on each other, but if inter-package dependencies are added in the future, dependencies must be published before their dependents.

```bash
cd packages/{pkg} && dart pub publish --force
```

If any package **fails** to publish:
1. Stop immediately
2. Report which packages succeeded and which failed
3. **For unpublished packages**, restore their files from HEAD:
   ```bash
   git checkout HEAD -- packages/{pkg}/pubspec.yaml packages/{pkg}/CHANGELOG.md
   # If MIGRATION.md was modified or newly created by Step 5b, revert or remove it:
   git checkout HEAD -- packages/{pkg}/MIGRATION.md 2>/dev/null || rm -f packages/{pkg}/MIGRATION.md
   ```
4. Only packages that were **successfully published** proceed to the commit/tag steps

> **Warning**: Published packages cannot be unpublished from pub.dev. If a partial failure occurs, the already-published packages will be live on pub.dev but the repo won't yet have the corresponding commit/tags. The operator **must** continue with Steps 9-11 for the successfully published packages to bring the repo into a consistent state. Do not abandon the process after a partial publish.

---

## Step 8b: Reconciliation Checkpoint

**Only in full release mode.** Perform this checkpoint after all publish attempts (Step 8) and before committing (Step 9).

1. **Display a checklist** of all packages from the release plan with their publish status:
   ```
   | Package | Planned Version | Status |
   |---------|-----------------|--------|
   | foo_dart | 1.0.0 | Published |
   | bar_dart | 2.1.0 | Published |
   | baz_dart | 0.5.0 | FAILED |
   | qux_dart | 1.3.0 | Skipped (user request) |
   ```

2. **Verify completeness**: Every package from the release plan must be accounted for with one of these statuses:
   - **Published** — successfully published to pub.dev
   - **Failed** — publish attempted but failed (files reverted per Step 8)
   - **Skipped** — user explicitly chose to skip during Step 4

3. **Flag any unaccounted packages**: If any planned package is missing from the checklist (neither published, failed, nor skipped), this is an error. The package was likely overlooked. Stop and resolve before proceeding.

4. **Require user confirmation** before proceeding to Step 9.

> **Why this checkpoint exists**: Discovering a missed package after committing and tagging (Steps 9-10) requires messy fixups — amending commits, re-tagging, force-pushing. Catching omissions here is far cheaper. Take 30 seconds to verify completeness now to avoid 30 minutes of cleanup later.

---

## Step 9: Commit Changes

**Only in full release mode.**

Create a single commit with all `pubspec.yaml`, `CHANGELOG.md`, `README.md`, and `MIGRATION.md` changes (only for successfully published packages):

```bash
git add packages/{pkg1}/pubspec.yaml packages/{pkg1}/CHANGELOG.md packages/{pkg1}/README.md \
       packages/{pkg2}/pubspec.yaml packages/{pkg2}/CHANGELOG.md packages/{pkg2}/README.md \
       ...
# Also include MIGRATION.md for packages that had breaking changes:
git add packages/{pkg}/MIGRATION.md  # for each package with breaking changes
```

Commit message format:
```
chore(release): publish packages

 - {pkg1}@{version1}
 - {pkg2}@{version2}
```

**Why commit after publish**: If publish fails for some packages, we don't pollute main with version bumps for unpublished packages.

---

## Step 10: Create Git Tags

**Only in full release mode.**

1. **Per-package tags**:
   ```bash
   git tag -a "{pkg}-v{version}" -m "{pkg} v{version}"
   ```

2. **Aggregate release tag** — compute once and reuse in Step 11:
   ```bash
   # Determine the aggregate tag name
   base_tag="release-$(date +%Y-%m-%d)"
   aggregate_tag="$base_tag"
   if git rev-parse "$aggregate_tag" >/dev/null 2>&1; then
     counter=1
     while git rev-parse "${base_tag}.${counter}" >/dev/null 2>&1; do
       counter=$((counter + 1))
     done
     aggregate_tag="${base_tag}.${counter}"
   fi
   git tag -a "$aggregate_tag" -m "Release ${aggregate_tag#release-}"
   ```
   Store `$aggregate_tag` for use in Step 11.

3. **Push**:
   ```bash
   git push origin main --tags
   ```

---

## Step 11: Create GitHub Release

**Only in full release mode.**

Create one combined GitHub release using the `gh` CLI. Use the **exact `$aggregate_tag` value** computed in Step 10 (which may include a `.N` counter suffix for same-day re-releases).

- **Tag**: `$aggregate_tag` (from Step 10)
- **Title**: the date portion of the tag (e.g., `2026-03-03`)
- **Body**: summary table of all packages + full changelog sections per package

Body format:
```markdown
## Packages released

| Package | Version |
|---------|---------|
| [pkg1](https://pub.dev/packages/pkg1) | v1.2.3 |
| [pkg2](https://pub.dev/packages/pkg2) | v2.0.0 |

---

## pkg1 v1.2.3

{changelog content for pkg1}

---

## pkg2 v2.0.0

{changelog content for pkg2}

---

## Contributors

@contributor1 and @contributor2                     ← only if external contributors exist; use actual logins from PR data
```

### Assemble the Contributors section

Before creating the release, build the contributor list from the PR data collected in Step 4b:

1. **Collect** all unique `author_login` values from the PR entries included in this release.
2. **Filter bots**: Exclude any login that contains `[bot]` or matches known bot accounts (`dependabot`, `renovate`, `github-actions`).
3. **Conditional display**: If the only remaining contributor is the repo owner (`davidmigloz`), **omit** the Contributors section entirely — it adds no value on solo releases. If at least one non-owner contributor exists, include the section with **all** non-bot contributors (including the owner).
4. **Format**: Sort logins alphabetically (case-insensitive) and join with natural language: `@a` for one, `@a and @b` for two, `@a, @b, and @c` for three or more. Prefix each login with `@` so GitHub renders them as clickable profile links.

Create the release:
```bash
gh release create "$aggregate_tag" \
  --title "${aggregate_tag#release-}" \
  --notes "$(cat <<'EOF'
{body content}
EOF
)"
```

---

## Edge Cases

1. **No previous tag** → use all commits since the package first appeared in the repo
2. **Only test/chore commits** → skip package (no release)
3. **Build metadata versions** (e.g., `0.3.0+1`) → strip `+N`, bump the base version
4. **Commits with no scope** touching package files → include them, use the full description
5. **Commits with non-matching scope** but touching package files → include them
6. **No issue number** → omit issue link, keep commit link
7. **Pre-1.0 packages** → breaking bumps minor, feat bumps patch (confirm with user if they want to promote to 1.0.0)
8. **Partial publish failure** → report status, revert unpublished packages, only commit/tag published ones
9. **Cross-package commits** → file-path detection handles correctly (same commit may appear in multiple packages)
10. **Aggregate tag collision** → append counter suffix (`.1`, `.2`, etc.)
11. **PR fetch failures** → warn and fall back to commit messages for changelog summaries
12. **Commits without PR references** → use commit message only for that commit's contribution to the summary
13. **PR covers multiple packages** → include its summary bullets in every relevant package's changelog summary
14. **PR signals breaking but commits don't** → warn user and suggest bump upgrade; user decides
15. **Breaking changes but no `## Breaking Changes` PR section** → Step 5b synthesizes migration content from commit messages and PR summaries
16. **MIGRATION.md does not exist yet** → Step 5b creates it with standard structure
17. **No announcement links in PR** → Step 5 writes summary without links (no degradation)
18. **Pre-1.0 migration heading** → Use major.minor in the heading (e.g., "v0.3.x to v0.4.0") since breaking changes bump minor, not major
19. **Solo release (only repo owner contributed)** → omit the Contributors section entirely
20. **Contributors from failed PR fetches or commits without PR references** → contributor info is silently lost; the Contributors section is best-effort (consistent with edge cases #11 and #12)

---

## Resuming an Interrupted Release

If the release process is interrupted, see
[references/resumption-guide.md](references/resumption-guide.md) for
instructions on determining current state and resuming safely.
