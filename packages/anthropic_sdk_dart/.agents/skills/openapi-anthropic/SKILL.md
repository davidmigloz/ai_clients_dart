---
name: openapi-anthropic
description: Update anthropic_sdk_dart from Anthropic OpenAPI changes. Use for spec refresh, change review, scaffolding, and verification.
---

# Anthropic OpenAPI Workflow

## Prerequisites

- Auth: No auth env vars required.
- CLI: `python3 .agents/shared/api-toolkit/scripts/api_toolkit.py`
- Existing-package commands: run the repo-relative examples from the repository root. If you run them elsewhere, invoke the script via an absolute path and pass an absolute `--config-dir`.

## Workflow

1. Audit the Claude Platform release notes and API guides. Record the cutoff,
   official SDK commit SHAs, and both candidate digests before implementing.
2. Prepare the candidate from the official bundles as shown below. The toolkit
   expects it at `/tmp/openapi-anthropic-dart/latest-<spec>.json`.
3. Review the candidate against the committed snapshot.

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config
```

4. Implement and verify the changes using the package references and
   `scaffold` where appropriate. After review, copy the verified candidate to
   `packages/anthropic_sdk_dart/specs/openapi.yaml` without reformatting it.
   Set `pinned_hash` in `config/specs.json` to the decompressed file's SHA-256.
   Record the two SDK revisions and archive digest in `specs/spec_metadata.json`,
   move the previous pin to its version history, and update manifest mappings.
5. Verify the promoted snapshot and documentation.

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config --checks all --scope all
```

### Prepare a candidate

Anthropic's official SDKs publish the OpenAPI fixture at
`scripts/mock-spec.json.gz`. The [spec source change](https://github.com/anthropics/anthropic-sdk-python/commit/f9b0cf281932512e6b40cd1a887a44542c883468)
replaced the public Stainless URL in `.stats.yml`. Use immutable Git commit
references and compare the archives before updating the canonical snapshot.
The values below reproduce the November 11, 2026 pin. For a later round,
download both fixed revisions to temporary files, compare their bytes,
record their compressed and decompressed SHA-256 values, then substitute
the new refs and digests.

```bash
(
  set -eu
  python_ref=5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9
  typescript_ref=590783078cd961a0df698d9fddc0275c65ff3afd
  bundle_sha=3e2a4bbb5c9cfad58b39bb801086ce65436a7f88c6b04b9dca0f626d6113537e
  spec_sha=690622377a5eedc0e9f2265ed755ee34dc0c52d35b47327f425777a550f45e1e
  candidate_dir=/tmp/openapi-anthropic-dart
  mkdir -p "$candidate_dir"
  staging_dir=$(mktemp -d "$candidate_dir/.candidate.XXXXXX")
  trap 'rm -r "$staging_dir"' EXIT
  cd "$staging_dir"
  curl -fsSL --retry 2 -o python.json.gz "https://raw.githubusercontent.com/anthropics/anthropic-sdk-python/$python_ref/scripts/mock-spec.json.gz"
  curl -fsSL --retry 2 -o typescript.json.gz "https://raw.githubusercontent.com/anthropics/anthropic-sdk-typescript/$typescript_ref/scripts/mock-spec.json.gz"
  printf '%s  %s\n' "$bundle_sha" python.json.gz "$bundle_sha" typescript.json.gz | shasum -a 256 -c
  cmp python.json.gz typescript.json.gz
  gzip -dc python.json.gz > latest-main.json
  printf '%s  %s\n' "$spec_sha" latest-main.json | shasum -a 256 -c
  python3 -m json.tool latest-main.json > /dev/null
  mv latest-main.json "$candidate_dir/latest-main.json"
)
```

The toolkit's `fetch` command in `local_file` mode stages the committed
`specs/openapi.yaml` for offline use. Run it when you need a copy of the current
snapshot. It writes to the same candidate path, so use the bundle preparation
above as the last preparation step before comparing a newer snapshot.

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config
```

## Specs

| Spec | Description |
| --- | --- |
| `main` | Anthropic API for Claude models |

## Package References

- [references/package-guide.md](references/package-guide.md)
- [references/implementation-patterns.md](references/implementation-patterns.md)
- [references/REVIEW_CHECKLIST.md](references/REVIEW_CHECKLIST.md)

## Documentation Artifacts

After implementation and before opening a PR, update documentation to reflect new types:

1. **Example** — add an `example/<feature>_example.dart` if the change introduces a new tool, content block type, or API surface. Follow the pattern of existing examples (e.g., `web_search_example.dart`). Verify with `dart analyze`.
2. **README** — update `README.md`:
   - Features section: mention the new capability in the relevant bullet.
   - Examples table: add a row for the new example file.
3. **llms.txt** — regenerate with the toolkit so the new example is indexed with its token count:
   ```bash
   python3 .agents/shared/api-toolkit/scripts/api_toolkit.py generate-llms-txt \
     --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config
   ```

## Separate Dart Quality Steps

```bash
cd packages/anthropic_sdk_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```
