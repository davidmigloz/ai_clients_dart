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
   - `gh auth status` — must show authenticated. If not, tell user to run `gh auth login`.
   - `dart pub token list` — must show a token for `pub.dev`. If not, tell user to run `dart pub token add https://pub.dev`.

---

## Step 2: Detect Changes Per Package

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
   git log --format="%H%x1f%s%x1f%b%x1e" {tag}..HEAD -- packages/{pkg}/
   ```
   Use ASCII Unit Separator (`%x1f`) between fields and ASCII Record Separator (`%x1e`) after each commit. **Parse by splitting on `\x1e` first** (to get individual commit records), then split each record on `\x1f` (to get hash, subject, body). This is critical because commit bodies can contain blank lines that would otherwise make commit boundaries ambiguous.

3. **No previous tag** (first release): use all commits touching `packages/{pkg}/`.

4. **No commits since tag**: skip this package — no release needed.

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

**Ask user to confirm** before proceeding. They may override bump types or skip specific packages.

**If `--plan` mode**: STOP here. Do not proceed to any file edits.

---

## Step 5: Write Changelogs

For each released package, **prepend** a new section to `packages/{pkg}/CHANGELOG.md`.

### Changelog section format

```markdown
## {new_version}

> Note: This release has breaking changes.          ← only if breaking

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
8. **Breaking note**: Only include `> Note: This release has breaking changes.` if there are breaking changes
9. **AI summary**: Write 1-3 sentences summarizing the main changes in plain English. Place it between the breaking note (if any) and the entry list.

---

## Step 6: Update pubspec.yaml Versions

For each released package, update the `version:` field in `packages/{pkg}/pubspec.yaml` to the new version.

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
  ```
- Report which packages had errors and what the errors were.

**If `--dry-run` mode**: After showing the dry-run results, **restore the working tree** and STOP:
```bash
git checkout HEAD -- packages/
git clean -fdX packages/
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
   ```
4. Only packages that were **successfully published** proceed to the commit/tag steps

> **Warning**: Published packages cannot be unpublished from pub.dev. If a partial failure occurs, the already-published packages will be live on pub.dev but the repo won't yet have the corresponding commit/tags. The operator **must** continue with Steps 9-11 for the successfully published packages to bring the repo into a consistent state. Do not abandon the process after a partial publish.

---

## Step 9: Commit Changes

**Only in full release mode.**

Create a single commit with all `pubspec.yaml` and `CHANGELOG.md` changes (only for successfully published packages):

```bash
git add packages/{pkg1}/pubspec.yaml packages/{pkg1}/CHANGELOG.md \
       packages/{pkg2}/pubspec.yaml packages/{pkg2}/CHANGELOG.md \
       ...
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
```

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
