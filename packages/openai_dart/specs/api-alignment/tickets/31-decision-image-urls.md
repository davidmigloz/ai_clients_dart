# Accept remote HTTP(S) Decisions images

Status: merged in [PR #383](https://github.com/davidmigloz/ai_clients_dart/pull/383).
GitHub: [#381](https://github.com/davidmigloz/ai_clients_dart/issues/381).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Source refinements](../image-safety-followups.md), DEC-URL-01–06.
Dependency: merged #318; independent of the other refinement.

## Acceptance criteria

- [x] Public factories/parsers/copies admit exact canonical prefixes and preserve literal strings; old data URLs/imageBytes remain compatible.
- [x] Public JSON/value/detail/privacy and malformed-value fixtures cover real contracts, including prefix-only minima and source-valid edge cases.
- [x] Actual mock POST preserves mixed evidence/order and URLs with no local image downloads or added action.
- [x] README/llms and runnable offline example cover HTTP/HTTPS/data inputs at $0 cost; no invented breaking migration.
- [x] Real manifest/source promotion and all toolkit diagnostics are recorded with no new exclusions; unrelated pending contracts remain visible.
- [x] Supported Dart VM/Chrome JS/Wasm focused fixtures, ordered quality and full package unit suite pass.
- [x] Independent final requirements/engineering reviews approve; exact final-head CI is green before user-authorized merge.

All tests/examples are deterministic offline fixtures. No API key or live API
call is required. No release/version bump or unrelated API-family implementation.

The [acceptance review](../reviews/31-decision-image-urls.md) records actual public
canonical assertions, source promotion, supported-platform quality, the offline
example and honest pending diagnostics. Both independent reviews approved commit
`72d9918bf8f557f40352c2969514b8911385e686`; all 14 final-head contexts completed
(13 successes and the standard Test(all) skip). The user-authorized squash merge
completed October 9, 2026 at 07:54:42 UTC, commit
`bc89ad9a8fb79d889e7945030fa9f6524d73d781`, closing #381.
