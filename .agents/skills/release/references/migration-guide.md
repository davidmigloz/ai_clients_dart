# Migration Guide Updates

Procedure for **Step 5b** of the release skill (skipped when no package has breaking
changes, and in `--plan` mode). For each package with breaking changes, update
`packages/{pkg}/MIGRATION.md` with migration instructions extracted from the
`breaking_changes` PR field collected in Step 4b, so consumers have a single,
up-to-date document for navigating breaking changes across versions.

### Source material

Use the `breaking_changes` field from Step 4b as a starting point. Compare each
change with the last published package. Omit migration instructions for APIs
introduced and removed between releases. Include verified changes in defaults,
validation, or serialization that affect existing callers.

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

If the guide already contains unversioned sections for this release, move them
under the new version heading and merge overlapping instructions. Preserve
linked heading anchors or update the links when a heading changes.

### Quality check

Check each **before** example against the last published version and each
**after** example against the release candidate. Use a temporary Dart package
to analyze snippets when the public API changed. Use local fixtures or mocks
to check behavior when a signature check is insufficient.
