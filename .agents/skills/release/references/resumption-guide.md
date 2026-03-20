# Resuming an Interrupted Release

If the release process is interrupted (e.g., context window exhausted, network failure, user abort), use the following guidance to determine current state and resume safely.

## Determine current state

Run these commands to assess where the release stopped:

```bash
# 1. Check for uncommitted release changes (pubspec.yaml, CHANGELOG.md, MIGRATION.md edits)
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

## Progress checkpoints

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
- [x] Step 4: Plan displayed
- [x] Step 4b: PR context fetched, semver verified, plan confirmed
- [x] Step 5: Changelogs written (all packages)
- [x] Step 5b: Migration guides updated (packages with breaking changes)
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

## Recovery table

| Interrupted After | State | Recovery Procedure |
|---|---|---|
| **Step 4** (plan displayed) | No files modified yet. | Start fresh from Step 4b (PR context fetch and confirmation). |
| **Step 4b** (plan confirmed) | No files modified yet. PR context fetched, semver verified. | Start fresh from Step 5. |
| **Steps 5-5b** (changelogs/migration guides written) | Working tree has uncommitted changes to CHANGELOG.md and possibly MIGRATION.md. | Verify the changes with `git diff`. Resume from Step 6 (pubspec update). |
| **Step 6** (pubspec updated) | Working tree has uncommitted changes. | Verify the changes with `git diff`. Resume from Step 7 (dry-run publish). |
| **Step 7** (dry-run passed) | Working tree has uncommitted changes, dry-run validated. | Resume from Step 8 (publish). |
| **Step 8** (some packages published) | Some packages live on pub.dev, uncommitted changes in tree. | **Critical**: Check which packages are published (`curl -s https://pub.dev/api/packages/{pkg}`). For unpublished packages, revert their files (`git checkout HEAD -- packages/{pkg}/pubspec.yaml packages/{pkg}/CHANGELOG.md` then `git checkout HEAD -- packages/{pkg}/MIGRATION.md 2>/dev/null \|\| rm -f packages/{pkg}/MIGRATION.md`). Resume from Step 8b with only the published packages. |
| **Step 8b** (reconciliation done) | All publishes complete, user confirmed, uncommitted changes. | Resume from Step 9 (commit). |
| **Step 9** (committed) | Release commit exists locally, not pushed. | Resume from Step 10 (create tags). |
| **Step 10** (tags created) | Commit and tags exist locally, not pushed. | Resume from the push command in Step 10 (`git push origin main --tags`). Then proceed to Step 11. |
| **Step 11** (GitHub release) | Everything done except GitHub release. | Check `gh release list`. If the release doesn't exist, create it per Step 11. If it exists but is incomplete, use `gh release edit` to update the body. |

> **Critical rule**: If **any** packages have been published to pub.dev (Step 8), you **must** complete Steps 9-11 for those packages. Published packages without corresponding tags and commits leave the repository in an inconsistent state. Never abandon the process after a partial publish.
