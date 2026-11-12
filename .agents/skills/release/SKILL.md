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

For an interrupted release, use the [resumption guide](references/resumption-guide.md) before starting a new plan.

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
   git fetch --tags origin main
   # If clean main is behind origin/main, fast-forward it.
   git merge --ff-only origin/main
   test "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)"  # HEAD must equal origin/main
   ```
   If local `main` is ahead or diverged, stop and report the discrepancy. Skip this check in `--plan` and `--dry-run` modes.
4. **CLI availability**: `dart` and `gh` must be on PATH.
5. **Auth preflight** (skip in `--plan` mode):
   - **GitHub**: `gh auth status` — must show authenticated. If not, tell user to run `gh auth login`.
   - **pub.dev**: The [publish dry run](https://dart.dev/tools/pub/cmd/pub-lish#--dry-run-or--n) validates the package locally. The upload checks credentials and publishing permissions. An OAuth session is invisible to `dart pub token list`. If the upload reports an authentication error, use `dart pub login` or the configured `dart pub token add https://pub.dev` flow.

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
   - If `pubspec_version` > `tag_version`, treat it as a **pre-applied version bump** for planning. Flag the package even if Step 5 found no commits.
   - If `pubspec_version` == `tag_version` and there are no new commits, skip as normal.

   Use package tags as Git history baselines. Confirm publication against the exact pub.dev version in Step 8, since an interrupted release can leave a published version without its tag.

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

Compare candidate breaking changes against the last released tag and the release candidate. A change between two unreleased PRs may need no migration for consumers. Capture verified breaks for the migration guide even when the planned bump already covers them.

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

For each released package, **prepend** a new `## {new_version}` section to `packages/{pkg}/CHANGELOG.md`.

Use the PR summaries collected in Step 4b as the **primary source** for the AI-written summary (1–3 sentences of user-facing impact, weaving in any announcement links from the PR `references` field); fall back to commit messages when PR context is unavailable.

For the exact section template, formatting rules (8-char display hash, full-40-char commit URL, issue-link extraction, entry ordering, the `> [!CAUTION]` breaking admonition), summary quality guidance, and how to merge into a pre-existing `## {new_version}` section, follow [references/changelog-format.md](references/changelog-format.md).

---

## Step 5b: Update Migration Guides

> **Skip this step if no packages in this release have breaking changes.**
> **Also skip in `--plan` mode.**

For each package with breaking changes, update `packages/{pkg}/MIGRATION.md` using the verified changes from Step 4b. Track any newly created `MIGRATION.md` files for cleanup in Step 7.

For the source material, the entry format and `{prev}`-version heading derivation, handling of multiple breaking PRs in one package, the file-creation template, pre-existing-section merge behavior, and the before/after code-example quality check, follow [references/migration-guide.md](references/migration-guide.md).

---

## Step 6: Update pubspec.yaml Versions

For each released package, update the `version:` field in `packages/{pkg}/pubspec.yaml` to the new version.

---

## Step 6b: Update README Quickstart Versions

Update the existing installation example in `packages/{pkg}/README.md`. Set a Quickstart `dependencies:` entry to `{pkg}: ^{new_version}` or update the command to `dart pub add '{pkg}:^{new_version}'`. Preserve the existing format.

---

## Step 7: Dry-Run Publish

Apply any copyediting skill the user requested to the release prose. Record the base commit, planned versions, and exact release file paths, including new files. Run `dart pub publish --dry-run` from each package directory before committing.

Review the archive listing and validation output. Warnings can cause exit code 65. If the only warning lists exactly the expected release edits, report it as expected. To investigate an ambiguous result, validate in a temporary workspace snapshot with the same release files and compare the archive listings.

On a validation error or at the end of `--dry-run` mode, restore only the changes made by this release. Restore tracked files from the recorded base and remove only files created by this run. Check for intervening edits first. Preserve unrelated and ignored files. Report the result and stop.

In full mode, record the validated release file hashes. Present the results and get approval to publish if the user has not already authorized the upload.

---

## Step 8: Publish

**Only in full release mode.**

Recheck the release base and file hashes. Publish packages one at a time in workspace order, with dependencies before their dependents.

Check the [exact pub.dev version](references/resumption-guide.md#verify-publication) before each upload. If it already exists, verify its archive before marking it published.

```bash
cd packages/{pkg} && dart pub publish --force
```

After upload, verify the exact version and its archive against the validated release files. Allow time for a successful upload to become visible on pub.dev. If an archive differs from the validated candidate, stop the remaining uploads and reconcile the plan.

If a publish command fails, pause the remaining uploads and check the exact version. A connection failure can occur after the server accepts the upload. If the archive matches, record success and continue. If the outcome is uncertain, keep the release files and leave the remaining uploads pending. If the batch ends after a confirmed failure, use Step 7 to restore release edits for packages left unpublished, including README edits. Continue through Steps 9–11 for the verified published packages after a partial failure.

---

## Step 8b: Reconciliation Checkpoint

**Only in full release mode.** Report every package from the plan with its version and status before committing.

- **Published** — exact version and archive verified on pub.dev.
- **Failed** — upload failed and the version is confirmed unpublished.
- **Not attempted** — uploads stopped after an earlier package failed or became uncertain.
- **Skipped** — the user excluded the package.
- **Pending verification** — the upload outcome is uncertain. Preserve its files for recovery.
- **Archive mismatch** — the version exists with different release files. Report the discrepancy and preserve the files for investigation.

Resolve any missing rows. Get confirmation to finalize the verified published set if the user has not already approved it.

---

## Step 9: Commit Changes

**Only in full release mode.**

Confirm the release files still match the published archive. Create a single commit with the `pubspec.yaml`, `CHANGELOG.md`, `README.md`, and `MIGRATION.md` changes for verified published packages:

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

2. **Aggregate release tag** — choose `release-YYYY-MM-DD` using the release date. If the tag exists locally or on `origin`, use the first available `.1`, `.2`, or later suffix. Store the exact name in `$aggregate_tag` for Step 11.
   ```bash
   git tag -a "$aggregate_tag" -m "Release ${aggregate_tag#release-}"
   ```

3. **Push** `main` and only the tags created for this release. Include one package tag ref per published package:
   ```bash
   git push --atomic origin refs/heads/main "refs/tags/{pkg}-v{version}" "refs/tags/$aggregate_tag"
   ```
   Verify that remote `main` contains the release commit and each remote tag points to it before creating the GitHub release.

---

## Step 11: Create GitHub Release

**Only in full release mode.**

Create one combined GitHub release using the `gh` CLI. Use the **exact `$aggregate_tag` value** computed in Step 10 (which may include a `.N` counter suffix for same-day re-releases).

- **Tag**: `$aggregate_tag` (from Step 10)
- **Title**: the date portion of the tag (e.g., `2026-03-03`)
- **Body**: summary table of all published packages and their full changelog sections. In the GitHub notes, point relative migration links to the guide at the matching package tag.

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

Write the release notes to a file and create the release:
```bash
gh release create "$aggregate_tag" \
  --verify-tag \
  --title "${aggregate_tag#release-}" \
  --notes-file "$release_notes_file"
```

Verify the GitHub release by its exact tag and report its URL with the versioned pub.dev changelogs.

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
