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

## Acceptance

- [ ] Update pin, immutable source metadata and manifest mappings. Compare all toolkit diagnostics against the recorded baseline.
- [ ] Verify the complete package unit suite, format, fatal-info analysis and toolkit. Verify other managed packages if shared tooling changes.
- [ ] Refresh Messages-first documentation, runnable example index, llms.txt, and migration guidance. Record proposed semver and remaining gaps with explicit unblock conditions. Record SDK helper decisions individually, including provider and credential support, telemetry, worker loops, raw responses, MCP, structured parsing and tool runners.
- [ ] Close the parent after integrated verification and reviewed exact-head CI. Leave publication and versioning for separately approved release work.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
