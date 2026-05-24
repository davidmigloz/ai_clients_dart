# Review Checklist

## Toolkit Workflow

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config --checks all --scope all
```

## Package Quality

```bash
cd packages/googleai_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```

## Implementation Review

Read and apply the [core review checklist](../../../../../../.agents/shared/api-toolkit/references/REVIEW_CHECKLIST-core.md) — it contains the full implementation review checklist applicable to all packages.

### Package-Specific Checks

- [ ] **Media download `alt=media`**: Google `download`/media endpoints whose default response is `application/json` (returning a `*Response` envelope) must pass `queryParams: {'alt': 'media'}` to `buildUrl()` when the method is meant to return raw bytes (`response.bodyBytes`). Without it the server returns the JSON envelope, not the media. Apply the change across **all** platform variants (`_io`, `_web`, `_stub`), keep the dartdoc's canonical URL in sync, and assert `req.url.queryParameters['alt'] == 'media'` in the unit test so a dropped parameter fails the test instead of silently returning envelope bytes. See [implementation-patterns.md](implementation-patterns.md#media-download-endpoints-altmedia).
- [ ] **Platform-variant parity**: Any change to a resource split across `_io`/`_web`/`_stub` files (URL building, query params, headers) must be mirrored in all three — a fix landing in only one variant regresses the others.
