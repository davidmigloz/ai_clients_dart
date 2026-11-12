# Reconcile the Claude API alignment and release readiness

[GitHub issue #492](https://github.com/davidmigloz/ai_clients_dart/issues/492).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `15-closeout` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Promote the fixed upstream snapshot and reconcile its operation/schema rows and the HTTP-only inventory with merged implementation evidence.

## Dependencies

- #479
- #481
- #482
- #483
- #484
- #485
- #486
- #487
- #488
- #489
- #490
- #491
- #494
- #498
- #503

## Acceptance

- [ ] Update pin, immutable source metadata and manifest mappings. Compare all toolkit diagnostics against the recorded baseline.
- [ ] Verify the complete package unit suite, format, fatal-info analysis and toolkit. Verify other managed packages if shared tooling changes.
- [ ] Reconcile the complete documentation audit from #503 against the integrated package. Record proposed semver and remaining gaps with explicit unblock conditions. Record SDK helper decisions individually, including provider and credential support, telemetry, worker loops, raw responses, MCP, structured parsing and tool runners.
- [ ] Close the parent after integrated verification and reviewed exact-head CI. Leave publication and versioning for separately approved release work.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.

## Static environment credentials

The explicit Dart factories read the API key first, then the OAuth token.
Empty values are absent. Dart retains the environment string as supplied,
matching Python. TypeScript trims its environment strings. Dart reuses
`BearerTokenProvider` and its established OAuth beta header. The pinned SDKs
apply static Bearer credentials directly and inject the beta for their
dynamic token paths. Browser applications configure credentials explicitly.
[Pinned Python precedence](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/_client.py#L98-L112) · [Pinned TypeScript environment reader](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/internal/utils/env.ts)

Effective credential headers are checked before HTTP dispatch so malformed
values cannot appear in the transport's diagnostic. The guard accepts visible
ASCII, spaces and tabs, which are supported by the native Dart transport.
Provider adapters apply it after rewriting their outgoing headers.
[HTTP field value syntax](https://www.rfc-editor.org/rfc/rfc9110.html#section-5.5)
