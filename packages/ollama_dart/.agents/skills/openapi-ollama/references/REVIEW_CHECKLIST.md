# Review Checklist

## Toolkit Workflow

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config --checks all --scope all
```

## Package Quality

```bash
cd packages/ollama_dart
dart format --show=none --summary=line .
dart fix --apply
dart analyze --fatal-infos
dart test --reporter=failures-only test/unit/
```

## Implementation Review

Read and apply the [core review checklist](../../../../../../.agents/shared/api-toolkit/references/REVIEW_CHECKLIST-core.md) — it contains the full implementation review checklist applicable to all packages.

## Ollama Checks

- Compare public native fields against the matching stable Go types and documented hosted APIs; record source SHAs when OpenAPI's version is unchanged.
- Verify new model fields through constructor, JSON, copyWith clearing, equality/hash, and toString; ensure existing constructors and experimental/legacy compatibility fields remain available.
- Cover cached token counts in chat/generate responses and both final stream events, including old responses that omit the field.
- Preserve arbitrary thinking strings and show-model boolean/string values/defaults. Keep enum factories compatible.
- Verify assistant content/thinking/tool-call replay plus tool names, IDs, and function indices.
- Exercise blob uploads with non-UTF8 bytes through bearer authentication, request-ID cloning, and retry paths. Check empty 200/201 bodies, HEAD 404, other errors, and configured proxy subpaths/query parameters.
- Verify hosted web routing with explicit cloud configuration and bearer auth, omitted result limits, empty results, response equality, and service failures.
- Cover every System One question/answer variant, content shapes, limits, insertion order, local/cloud and image/audio documentation, probability semantics, and non-streaming behavior.
- Analyze runnable examples and maintained README snippets; check factory invocations and nullable collection access. Do not run live examples or integration tests without explicit user authorization.

## Intentional Verification Warnings

- `CreateRequest.license` retains its existing `Object?` string/list union for source compatibility; replacing it is outside this API refresh.
- System One question `criteria` intentionally has different types and nullability: required ordered choice map, optional Noul criteria object, and required score list. Consistency warnings reflect the wire contract, not model drift.
- `ModelThinking.defaultValue` maps to the reserved JSON key `default`; unit tests cover the property excluded from name-based toolkit verification.
- `CreateRequest.capabilities` is stable in v0.40.14 and must remain implemented; do not restore the former deferred exclusion.

## Audio, reporting, and manifest checks

- Check audio against stable server handlers as well as documentation: binary
  WAV/PCM fidelity, multipart field scoping, JSON/text/verbose JSON, SSE boundaries,
  Unicode chunk splitting, done-event teardown, cancellation, auth, retries, and
  nested compatibility error envelopes.
- Cover current/legacy/unknown balance variants, UTC usage periods, omitted query
  selectors, and local signed-in account versus direct-cloud authentication.
- Preserve runner selectors through streaming request copies; round-trip voices,
  template source and manifest metadata. Separate all-manifest response parsing
  and retain copy warning status strings.
- Check equality/hash contracts for model lists, progress totals/completed values,
  and push/pull request options.
