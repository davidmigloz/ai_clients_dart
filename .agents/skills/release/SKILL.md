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

5. **Detect unreleased version bumps**: After checking commits, compare the `version:` field in `packages/{pkg}/pubspec.yaml` against the version extracted from the latest tag:
   ```bash
   # Extract version from latest tag (e.g., "foo_dart-v1.0.0" → "1.0.0")
   tag_version=$(echo "$latest_tag" | sed "s/^${pkg}-v//")
   # Read pubspec version
   pubspec_version=$(grep '^version:' packages/${pkg}/pubspec.yaml | awk '{print $2}')
   ```
   - If `pubspec_version` > `tag_version`, this package has a **pre-applied version bump** — someone manually set the version in the pubspec but never published it. Flag this package for release even if Step 4 found "no commits since tag" would normally skip it.
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

If Step 2.5 detected that a package's pubspec version is ahead of its latest tag version:

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

### Pre-existing changelog sections

Before writing a new changelog section, check if `## {new_version}` already exists in `CHANGELOG.md`:

1. **Detection**: Match `^## {new_version}` (exact version, at start of line) in the file.
2. **If the section already exists**:
   1. **Review the existing content for quality**: Pre-existing sections may be draft notes, rough bullet points, or incomplete text from a PR. Read the content carefully and ensure it is polished, well-structured, and presentable as a published changelog. Fix grammar, formatting, missing links, or unclear descriptions. Ensure it follows the same formatting conventions as the rest of the changelog (bold type prefixes, issue/commit links, ordering rules defined above).
   2. **Append** a `### Commits` subsection at the end of the existing section with the auto-generated commit entries (using the standard formatting rules above). This preserves the hand-written narrative while adding the structured commit log.
   3. If the existing section lacks a breaking change note but the commits include breaking changes, add the `> Note: This release has breaking changes.` line at the top of the section (after the `## {version}` heading).
3. **If the section does not exist**: Proceed with normal prepend behavior as described above.

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

---

## Resuming an Interrupted Release

If the release process is interrupted (e.g., context window exhausted, network failure, user abort), use the following guidance to determine current state and resume safely.

### Determine current state

Run these commands to assess where the release stopped:

```bash
# 1. Check for uncommitted release changes (pubspec.yaml, CHANGELOG.md edits)
git status --porcelain

# 2. Check for a release commit on HEAD
git log -1 --oneline  # look for "chore(release): publish packages"

# 3. Check for per-package tags on HEAD
git tag --points-at HEAD

# 4. Check if tags have been pushed
git fetch origin --tags
git log -1 --oneline origin/main  # compare with local HEAD

# 5. Check for a GitHub release
gh release list --limit 5

# 6. Check pub.dev for published versions
# For each package in the release plan:
dart pub global activate pana  # if needed
curl -s https://pub.dev/api/packages/{pkg} | grep '"version"' | head -1
```

### Progress checkpoints

To enable safe resumption, write a progress file after each major step:

```bash
cat > /tmp/release-progress.md <<'EOF'
# Release Progress — {date}

## Plan
| Package | Target Version | Status |
|---------|----------------|--------|
| foo_dart | 1.0.0 | published |
| bar_dart | 2.1.0 | changelog written, not published |
| baz_dart | 0.5.0 | pending |

## Completed Steps
- [x] Step 1: Environment validated
- [x] Step 2-3: Changes detected, bumps computed
- [x] Step 4: Plan confirmed
- [x] Step 5: Changelogs written (all packages)
- [x] Step 6: pubspec.yaml updated (all packages)
- [x] Step 7: Dry-run passed
- [x] Step 8: Published foo_dart
- [ ] Step 8: Publish bar_dart, baz_dart
- [ ] Step 8b: Reconciliation
- [ ] Step 9: Commit
- [ ] Step 10: Tags
- [ ] Step 11: GitHub release

## Last Updated
{timestamp}
EOF
```

Update this file after completing each step. A new session can read it to resume.

### Recovery table

| Interrupted After | State | Recovery Procedure |
|---|---|---|
| **Step 4** (plan confirmed) | No files modified yet. | Start fresh from Step 5. |
| **Steps 5-6** (changelogs/pubspec written) | Working tree has uncommitted changes. | Verify the changes with `git diff`. Resume from Step 7 (dry-run publish). |
| **Step 7** (dry-run passed) | Working tree has uncommitted changes, dry-run validated. | Resume from Step 8 (publish). |
| **Step 8** (some packages published) | Some packages live on pub.dev, uncommitted changes in tree. | **Critical**: Check which packages are published (`curl -s https://pub.dev/api/packages/{pkg}`). For unpublished packages, revert their files (`git checkout HEAD -- packages/{pkg}/pubspec.yaml packages/{pkg}/CHANGELOG.md`). Resume from Step 8b with only the published packages. |
| **Step 8b** (reconciliation done) | All publishes complete, user confirmed, uncommitted changes. | Resume from Step 9 (commit). |
| **Step 9** (committed) | Release commit exists locally, not pushed. | Resume from Step 10 (create tags). |
| **Step 10** (tags created) | Commit and tags exist locally, not pushed. | Resume from the push command in Step 10 (`git push origin main --tags`). Then proceed to Step 11. |
| **Step 11** (GitHub release) | Everything done except GitHub release. | Check `gh release list`. If the release doesn't exist, create it per Step 11. If it exists but is incomplete, use `gh release edit` to update the body. |

> **Critical rule**: If **any** packages have been published to pub.dev (Step 8), you **must** complete Steps 9-11 for those packages. Published packages without corresponding tags and commits leave the repository in an inconsistent state. Never abandon the process after a partial publish.
