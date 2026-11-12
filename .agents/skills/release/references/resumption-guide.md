# Resuming an Interrupted Release

Use the approved plan and observed remote state to decide which step to resume.
Keep a release-specific progress record outside the repo. Record the base
commit, package versions, release file paths and hashes, dry-run logs,
approvals, publish outcomes, and any release commit and tags. Update it after
each upload and after the Git and GitHub steps.

## Determine current state

- Review `git status --porcelain`, the release file diff, and `git log -1`.
  Compare files and the base with the recorded plan. Preserve intervening edits.
- Use `git ls-remote origin` with `refs/heads/main` and the exact planned
  tag refs. For annotated tags, check the peeled commit (`^{}`).
- Use `gh release view "$aggregate_tag"` to check the exact GitHub release.
- Check the exact pub.dev version of every package in the plan.

## Verify publication

Request the version metadata and inspect the HTTP status.

```bash
curl -fsS "https://pub.dev/api/packages/$package/versions/$version"
```

A successful response identifies the exact version and its archive. Download
`archive_url`, verify its SHA-256 against `archive_sha256`, and compare the
release files in the archive with the validated hashes. When recovering an
uncertain upload or reusing an existing version, also compare the archive's
file list and contents with the validated candidate. If the checkout moved,
reconstruct the candidate from the recorded base and hash-verified release
files. If the version exists with different contents, stop work on that
package and report the mismatch.

After an attempted upload, a 404 can mean that the version is still propagating.
Check the upload log and recheck the version during the propagation window
reported by pub.dev. If the outcome remains uncertain, keep the release files
and report the pending status. Retry or restore files only after establishing
that the upload did not succeed.

## Resume from the next incomplete step

| State | Next action |
|---|---|
| Plan approved, no release edits | Prepare the release files (Step 5). |
| Release files prepared, dry run incomplete | Verify the diff and finish validation (Step 7). |
| Dry run complete, upload pending | Verify the approved files and continue the approved upload (Step 8). |
| Some uploads succeeded | Reconcile the exact versions and resume Step 8. Keep pending files while an upload is uncertain. Restore release edits for confirmed unpublished packages only if the batch ends. |
| Published set verified | Commit only the matching release files for verified published packages (Step 9). |
| Release commit exists | Verify its files. Create missing tags, then push the exact release refs (Step 10). |
| Remote refs verified | Create the GitHub release if the aggregate tag has no release. If the release exists, verify its content and correct discrepancies within the approved scope (Step 11). |

Reuse existing approvals when the scope still matches. Confirm a partial
release if the user authorized finalization only for the full set. If remote
`main` has moved or an existing tag points to a different commit, inspect
the divergence before pushing. If finalizing a subset advanced `main`,
update the recorded base for the remaining packages after verifying their
validated contents are still the same. Use a new aggregate tag for any
subsequent finalization.
