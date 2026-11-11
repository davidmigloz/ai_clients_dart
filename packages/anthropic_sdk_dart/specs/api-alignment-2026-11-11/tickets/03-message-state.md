# Add message threads and signed compaction

[GitHub issue #480](https://github.com/davidmigloz/ai_clients_dart/issues/480).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `03-message-state` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Support beta thread creation and continuation, server-side compaction and current cache and thinking diagnostics.

## Dependencies

- #478

## Acceptance

- [ ] Verify create and SSE paths, returned thread state, partial/refusal handling and retry-safe replay semantics. Keep automatic replay opt-in and bounded.
- [ ] Support signed compaction output and valid multi-turn input replay, including streamed signatures, and model the transformation reports.
- [ ] Verify beta header combinations, current GA diagnostics and per-model fast/effort/thinking differences. Provide runnable examples.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
