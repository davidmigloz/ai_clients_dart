# Alignment progress history through Live WebSockets

This preserves the GitHub parent issue #317 body after PR #379 merged on
October 9, 2026. Earlier pending states and validation counts describe their
recorded stage. For current work and remaining scope, use the
[alignment roadmap](README.md) and [GitHub parent](https://github.com/davidmigloz/ai_clients_dart/issues/317).

The complete original body follows; no historical receipt is omitted.

---

Decisions PR [#319](https://github.com/davidmigloz/ai_clients_dart/pull/319) merged October 7, 2026 after all CI checks passed, closing #318.

This tracks staged alignment of openai_dart with current OpenAI API contracts and official clients.

**Status: Phases 1–4 and Audio/Live #366–371 are merged. #372 stored forks and transcript helpers is being implemented.** This parent records the roadmap and planning decisions. It is not an implementation ticket or an accepted specification.

## Confirmed

- Follow a scope interview → repository specification → dependency-linked tickets → implementation → independent review workflow.
- Keep repository documents alongside GitHub issues for tracking.
- Target complete parity including Admin/legacy gaps, prioritizing modern APIs and compatibility fixes, with Decisions first.
- Follow repository/package conventions and run unit tests. The user has additionally authorized bounded, low-cost live integration tests using the existing API key; never run the full integration suite.

## Compatibility policy

Targeted breaking corrections with migration guidance are permitted; preserve compatibility where practical.

## Decisions still open
- Phase 3 settles native/browser Responses WebSocket ownership, proxy authentication, envelope routing and explicit recovery/replay boundaries. Later phase transport/authentication details remain to be specified.

## Proposed phases

1. Decisions: text/inline-image inputs, predicate/choice/score/refusal answers, complete usage, public resource and exports.
2. Existing API correctness: container wire formats, cache diagnostics and usage, Chat streaming, and retry guidance.
3. Responses capabilities: async tools, configuration updates, web search, hosted shell, WebSockets and steering.
4. Webhooks and safety: verification/events, endpoint management, alerts/cases and structured monitoring details.
5. Audio and Live: speech/custom voices, Live sessions/transports and delegation workflows.
6. Agents and vaults: durable sessions, tools, environments/artifacts, credentials, subagents/traces and browser approvals.
7. Administration and storage: organization/project controls, keys, usage/costs and external storage.
8. Authentication and remaining parity: federation/mTLS helpers and still-operational legacy gaps.

Documentation, truthful coverage, examples and sunset notices accompany each relevant phase. The complete-parity target includes Admin APIs/external storage, federation/mTLS extensions, stored Chat management and still-operational fine-tuning gaps. Recheck sunset status before legacy tickets; do not recreate already-retired API functionality.

## Planning deliverables

- [x] Settle overall scope: complete parity, modern APIs/fixes first, Decisions leading.
- [x] Settle compatibility policy: targeted breaking corrections with migration guidance.
- [x] Record the source-backed Decisions specification and public test boundaries; independent planning findings addressed.
- [x] Draft the first complete feature ticket with requirement IDs and explicit dependencies: #318 (Decisions).
- [ ] Draft later independently demonstrable tickets as their phase specifications settle.
- [ ] Add later phase specifications and ticket slices as their decisions settle.
- [x] Record Decisions implementation evidence and independent requirements/standards reviews in #318.
- [ ] Record equivalent evidence and independent reviews for later completed tickets.
- [ ] Run a final review for interactions between completed tickets.

## First milestone

#318 is a native sub-issue containing the implemented Decisions ticket, full specification, acceptance evidence, and independent reviews. It covers text/images, all question and answer variants, usage, public integration, and unit tests in one usable feature. Package analysis passes and 1,783 unit tests pass (two existing environment-dependent skips). The subsequently authorized live Decisions test also passed with one request: 387 input tokens, estimated $0.0000387 at the documented Decisions rate. PR #319 merged, closing #318. The October 7 pinned specification is promoted; wider toolkit gaps are recorded explicitly.

The [repository roadmap](https://github.com/davidmigloz/ai_clients_dart/blob/0d85233700ba5f585e0a80ff1045957703e22eb4/packages/openai_dart/specs/api-alignment/README.md) and [Decisions specification](https://github.com/davidmigloz/ai_clients_dart/blob/0d85233700ba5f585e0a80ff1045957703e22eb4/packages/openai_dart/specs/api-alignment/decisions.md) are published in the merged Decisions commit.

## Phase 2 tickets

The repository correctness specification splits the next changes into independently usable tickets; each is a native sub-issue of this parent.

- #320 — Correct container memory/network configuration, secrets, skills, returned settings, and name filtering. Merged in [PR #327](https://github.com/davidmigloz/ai_clients_dart/pull/327), closing #320.
- #321 — Canonical cache-retention wire correction merged in [PR #328](https://github.com/davidmigloz/ai_clients_dart/pull/328); #321 closed.
- #322 — Cache controls/diagnostics and full Chat equality are implemented and independently reviewed in [PR #329](https://github.com/davidmigloz/ai_clients_dart/pull/329); merged after all CI checks passed, closing #322.
- #323 — Preserve Chat token details and stream obfuscation; implemented and independently reviewed in [PR #330](https://github.com/davidmigloz/ai_clients_dart/pull/330); merged after all CI checks passed, closing #323.
- #324 — Complete and streamed Chat audio merged in PR #331.
- #325 — Retry guidance merged in PR #332.
- #326 — Explicit generation/multipart image model selection merged in PR #333.

Full Phase 2 and container specifications are embedded in their issue bodies. Repository [Phase 2 specification](https://github.com/davidmigloz/ai_clients_dart/blob/dec273eab01d8d5164c269f43a7783712d131faf/packages/openai_dart/specs/api-alignment/correctness.md), [container specification](https://github.com/davidmigloz/ai_clients_dart/blob/dec273eab01d8d5164c269f43a7783712d131faf/packages/openai_dart/specs/api-alignment/containers.md), and [acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/dec273eab01d8d5164c269f43a7783712d131faf/packages/openai_dart/specs/api-alignment/reviews/02-container-configuration.md) are published in PR #327. The package has 1, eight41 passing unit tests, two existing skips, clean analysis, and a passed revised live container lifecycle (two creations; both deleted; conservative session estimate $0.06). Phase 3 now has a detailed independently reviewed specification and tickets below. Phases 4–8 still need their own specifications/tickets.

## Audit baseline

- Audited October 7, 2026; package 10.0.1 at repository commit `6e117fd254d1d8e3f893588957ef5316b4565b48`.
- Previous package spec was fetched September 16; the reviewed October 7 snapshot is now canonical. Upstream comparison against the previous snapshot: 19 added operations, four modified, one removed; 155 added schemas, 46 modified, two removed.
- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json), [Python 3.26.0](https://github.com/openai/openai-python/releases/tag/v3.26.0), [Node 7.30.0](https://github.com/openai/openai-node/releases/tag/v7.30.0).
- [API changelog and linked references](https://developers.openai.com/api/docs/changelog). Verify affected contracts before implementation, including docs/spec/client discrepancies.
- Existing issue overlap checked: #316 concerns runtime client configuration, distinct from Responses configuration_update; consider it only if authentication/client configuration work is included.

## Workflow references

[Scope interview](https://www.aihero.dev/skills-grill-with-docs), [specification](https://www.aihero.dev/skills-to-spec), [tickets](https://www.aihero.dev/skills-to-tickets), [implementation](https://www.aihero.dev/skills-implement), [review](https://www.aihero.dev/skills-code-review).


## Cache retention milestone

PR #328 implements CACHE-005: canonical output with legacy-input compatibility, shared compaction mapping, and canonical/beta enum coverage. [Acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/2e4b009b3dd7e8a2b9ae66ada821e7e794394db9/packages/openai_dart/specs/api-alignment/reviews/03-cache-retention.md) records 1, eight72 passing unit tests, two existing skips, clean analysis, exact public GA/beta fixtures, and independent reviews. No live API calls were made for this slice. Full Chat request equality remains required by CACHE-004/#322.


Cache retention PR #328 merged at `6d378a0cb46c03b8c3c36fad92d13c6af7fba24c`, closing #321. Cache controls/diagnostics #322 is implemented and independently reviewed in [PR #329](https://github.com/davidmigloz/ai_clients_dart/pull/329), with 2,121 passing unit tests, clean analysis, updated README/migration/example, and an authorized two-request live smoke (conservative $0.00040525; both stored responses deleted). Chat usage/obfuscation is implemented and independently reviewed in [PR #330](https://github.com/davidmigloz/ai_clients_dart/pull/330).


PR #329 merged at `7da3133539b1e60cdd2a2fbaedbad566cbb6f764`, closing #322. #323 is implemented and independently reviewed in [PR #330](https://github.com/davidmigloz/ai_clients_dart/pull/330): 2,199 unit tests pass, analysis is clean, and the bounded one-request unstored live smoke passed (11 input/four output tokens, conservative $0.000003375). README/migration/example and full stream value contracts are updated. Work is underway on #324 Chat audio completion/streaming.


PR #330 merged at `c65f3e96a91d4a4045068bb31f1197bb2f011f3d`, closing #323. #324 is now underway: complete/reference/partial audio types, real id-only replay, per-choice accumulation, local SSE fixtures, example, and independent review.


## Chat audio implementation completed

[PR #331](https://github.com/davidmigloz/ai_clients_dart/pull/331) implements #324 with complete audio output, actual ID-only replay, per-choice streamed accumulation, stable partial snapshots, exact Node-compatible finalization, and explicit incomplete-audio conversion errors. Independent requirements and standards reviews approved. Validation: 2,282 unit tests passed (two existing skips), analysis clean, README/example/migration/llms refreshed. One authorized unstored live request returned complete audio (11 input/128 output tokens, 41 audio events; conservative $0.008544); no paid replay.

Real Chat mappings also expose prior completion metadata, response annotations, and typed legacy function-call gaps. These stay in the complete-parity inventory for later specification, without adding verification skips. Retry hints/permanent quota behavior #325 follows after #331 merges.


GitHub CI passed on final #331 head `957f08f0558ee91ee57dc9e90491fea7757f8b70`; merge state is CLEAN and no review comments are outstanding. Merged in #331, closing #324.


## Chat audio merged; retry guidance in progress

[PR #331](https://github.com/davidmigloz/ai_clients_dart/pull/331) merged October 7, 2026 at `82232226ec94ba7d37080f8a1b792ff86252e503`, closing #324, after final CI and independent reviews passed. #325 RETRY-01–06 is now being implemented: permanent quota classification, full server retry minima, precise shared hint parsing and 503/pre-stream metadata, with controlled public regression fixtures and no paid API calls.


## Retry guidance completed

[PR #332](https://github.com/davidmigloz/ai_clients_dart/pull/332) implements #325 with permanent quota classification, complete eligible server delays, long-hint deferral without early replay, shared precise header parsing, 503/ordinary/pre-stream metadata, and preserved retry boundaries. Independent requirements and both cross-author reviews approved. Validation: 2,454 unit tests passed (two existing skips), clean analysis, README/migration/local example/llms updated. The local example executed without API access or cost; no live tests were run. Wider diagnostics remain unchanged (39 errors, ten warnings, 88 infos, one consistency warning) with no new exclusions. #326 image model requiredness follows after #332 merges.


GitHub CI passed on final #332 head `6a52561c2ed9d4e2b2864f61f68e75fc1bc17b7b`. Merge state is CLEAN, with no outstanding review comments; merged in #332, closing #325.


## Retry guidance merged; image model selection in progress

[PR #332](https://github.com/davidmigloz/ai_clients_dart/pull/332) merged October 7, 2026 at `aa6ebfaaa34192fa18985d5816cd846bd3dfbe95` after all CI checks passed, closing #325. #326 IMG-01–04 is now being implemented: explicit required generation/multipart model, retained JSON-edit omission, complete changed-model contracts, public fixtures and migration. No paid image generation is needed.


## Image model selection ready for review

[PR #333](https://github.com/davidmigloz/ai_clients_dart/pull/333) implements #326: required generation/multipart models (including streams), retained JSON-edit default omission, complete changed-model contracts including image/mask byte equality, and local public fixtures. Independent requirements and both cross-author reviews approved. 2,537 unit tests passed (two existing skips), analysis clean; README/migration/current examples/manifest/llms updated and local model-selection example verified without API access or cost. No paid image generation was run.

Toolkit generation requiredness error is resolved; real edit mappings expose generic multipart JSON-method limitations and older JSON-edit convenience gaps. Full verification remains visible (41 errors, ten warnings, 103 infos, one consistency warning), without new exclusions. After #333 merges, Phase 2's specified tickets are complete and Phase 3 Responses needs a refreshed specification and independently useful tickets. Broader complete-parity work remains open in this parent.


GitHub CI passed on final #333 head `6d8664e57e3cfc1409ba8b00d2991d65234c15e4`. Merge state is CLEAN and no review comments are outstanding; ready for review/merge.


## Phase 3 Responses tickets

[Planning PR #345](https://github.com/davidmigloz/ai_clients_dart/pull/345). [Repository specification](https://github.com/davidmigloz/ai_clients_dart/blob/69910d9724973893197054f8a5ca775291e9a89c/packages/openai_dart/specs/api-alignment/responses.md), [planning review](https://github.com/davidmigloz/ai_clients_dart/blob/69910d9724973893197054f8a5ca775291e9a89c/packages/openai_dart/specs/api-alignment/reviews/09-responses-planning.md). Eleven complete feature slices map to 27 observable requirements:

- #334 — feat(openai_dart): async function/custom tools and replay. Dependencies: None.
- #335 — feat(openai_dart): persistent reasoning configuration updates. Dependencies: None.
- #336 — feat(openai_dart): GA web-search controls, actions and results. Dependencies: None.
- #337 — feat(openai_dart): hosted/local shell configuration, replay and streams. Dependencies: Container [#320](https://github.com/davidmigloz/ai_clients_dart/issues/320), merged in #327.
- #338 — feat(openai_dart): compaction progress events. Dependencies: None.
- #339 — feat(openai_dart): responses access-program selection. Dependencies: None.
- #340 — fix(openai_dart): client-discovered tool definition and call fidelity. Dependencies: [#334](https://github.com/davidmigloz/ai_clients_dart/issues/334) (nested async definitions).
- #341 — feat(openai_dart): responses WebSocket transport and lane routing. Dependencies: None. Shell [#337](https://github.com/davidmigloz/ai_clients_dart/issues/337) and compaction [#338](https://github.com/davidmigloz/ai_clients_dart/issues/338) typed events join the shared codec when available.
- #342 — feat(openai_dart): mid-turn Responses steering. Dependencies: [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341).
- #343 — feat(openai_dart): opt-in Responses WebSocket reconnection. Dependencies: [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341) and [#342](https://github.com/davidmigloz/ai_clients_dart/issues/342) (submitted-steer replay regression).
- #344 — feat(openai_dart): multi-agent WebSocket tool-output injection. Dependencies: [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341).

All eleven are native sub-issues. Active dependencies are linked natively (#340→#334, #342→#341, #343→#341/#342, #344→#341), plus the completed shell container dependency #337→#320. Requirements/engineering reviews approved the combined plan; Daybreak omission defaults, guide/schema WS errors, close UTF-8 limits and uncertain-write recovery findings were resolved. Local/source links and requirement/dependency mappings pass. No live API calls or cost. Async #334 is implemented/reviewed in PR #346; next implementation #335 configuration updates after merge.


Planning PR #345 final head `69910d9724973893197054f8a5ca775291e9a89c` has all CI checks passing and merge state CLEAN, with no outstanding review comments. Planning PR #345 merged in `4542d04ce2845d646e9401ecfa6d0c7ac2e091f6`; runtime implementation issues remain open.


## Async tools implementation

[PR #346](https://github.com/davidmigloz/ai_clients_dart/pull/346) implements #334 with async flags across function/custom definitions, calls, conversations and GA/beta REST/SSE, typed custom replay, restored function agent metadata and full copy/value/redacted diagnostic contracts. 2,903 unit tests pass, two existing skips; 366 added tests. Analysis is clean; examples/docs/llms and real manifest mappings are current. Independent requirements/engineering reviews approve with validated findings resolved. Local example passed three requests with no API charge; no live API calls. #334 remains open until PR merge; #335 follows. [Acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/8595c6863fed490bf1946e649320a9667dd8da50/packages/openai_dart/specs/api-alignment/reviews/09-async-tools.md).


Final PR #346 head `13dfc57ea1ef526991ec4b1d41b8671d9d3c249d` has a successful complete fresh GitHub workflow, including aggregate Test result, and merge state CLEAN. Prior cancelled-run/GitHub rerun/push failures were recovered with an empty CI-trigger commit via the Git API and a PR refresh; the source tree is identical to the reviewed implementation. No review comments remain. PR ready to merge; #334 stays open until merge.

## Latest Phase 3 progress

Async tools, configuration updates, GA web search, hosted/local shell and compaction progress merged in [PR #346](https://github.com/davidmigloz/ai_clients_dart/pull/346) through [PR #350](https://github.com/davidmigloz/ai_clients_dart/pull/350), closing #334–#338. Access-program selection #339 merged in [PR #351](https://github.com/davidmigloz/ai_clients_dart/pull/351); tool-search fidelity #340 merged in [PR #352](https://github.com/davidmigloz/ai_clients_dart/pull/352).

[PR #353](https://github.com/davidmigloz/ai_clients_dart/pull/353) merged October 8, 2026 at 05:04:30 UTC, commit `b1c7b0238921b25be1f3592f5f4b1cd9cc2479d6`, closing persistent Responses WebSocket transport #341 after green final-head CI and independent reviews. It provides caller-owned native/browser/stub connections, lane/error envelopes and warm-up/continuation. Both packages receive the required-nullable annotation correction and migration guidance. [WebSocket acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/4eefcf22899ff1d79e86cc7138560e3bb530374e/packages/openai_dart/specs/api-alignment/reviews/16-responses-websocket.md).

[PR #354](https://github.com/davidmigloz/ai_clients_dart/pull/354) implements mid-turn steering #342: exact user-only text/image/file requests, explicit sendSteer/steer methods, typed accepted/pending/failed acknowledgments, all seven identifying tool/approval stub kinds and lossless rejected raw input. Acceptance queues server-owned input; successor creation commits it. Public fixtures cover incomplete/normal original completion, saved results once per parent/original lane, matching-create/no-pending races, repeated pending and accepted-then-failed identity. Actual write counts prove no accepted-input resend, tool rerun or automatic replay. Exhaustive-switch/cast migration documents the new sealed variants; HTTP/SSE entry points and create/send signatures stay available.

Validation: **11,158 package unit tests pass with two existing environment skips**. Added 454 model and 31 public/native cases, replacing three old raw-steering placeholders (net +482). All 502 Dart files format unchanged; fix/fatal-info analysis and diff checks pass. **484 new model/protocol cases pass in real Chrome JavaScript and Wasm** per backend. Thirty GA/beta serialized fixtures independently validate against canonical schemas. The exact README and migration After block compile. The runnable offline example verifies both continuation paths with three creates/three steers for **$0**; failure/incomplete probes stop promptly with cleanup. Independent requirements and engineering peer reviews approve the final combined diff after all validated findings were resolved. No live API calls, publishing or version bump.

Source recheck retains [OpenAPI 234829e](https://github.com/openai/openai-openapi/blob/234829e2b634b8fb159df7fcddbffad204173ffd/openapi.json) and Python 3.26.0 / 4e152cd. Node main is now [30d50ab](https://github.com/openai/openai-node/tree/30d50ab301f4c348726d1fcb9c51a84cb8feb71a), still package version 7.30.0, with no Responses/steering/WebSocket changes. Its URL filename helper fix has no counterpart in Dart's explicit bytes/filename APIs. The candidate equals the canonical JSON (356 operations/2,010 schemas). Manifest additions cover 22 real schemas plus 16 actual inline/contextual helpers, with no new exclusions. Full toolkit remains diagnostic: 226 implementation errors, 68 warnings, 213 infos; 32 consistency warnings. The delta is independently classified field/delegation/value scanners, open/shared type names and legitimate heterogeneous unions; all prior diagnostics remain visible. Exports/docs/README checks pass. Open Responses has no steering schema; #342 is OpenAI-only. [Steering acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/4eefcf22899ff1d79e86cc7138560e3bb530374e/packages/openai_dart/specs/api-alignment/reviews/17-responses-steering.md), [current roadmap](https://github.com/davidmigloz/ai_clients_dart/blob/4eefcf22899ff1d79e86cc7138560e3bb530374e/packages/openai_dart/specs/api-alignment/README.md).

The saved PR #354 body passes the exact create-pr template guard: five checked Test Plan lines at EOF, one paired Before/After migration fence and all validation/CI/tracking inside Details. Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37732949171) passes on head `4eefcf22899ff1d79e86cc7138560e3bb530374e`, including formatting, analysis/package tests/code generation on both Dart versions and aggregate Test result. CodeQL and all remaining applicable checks pass; merge state is CLEAN with no outstanding comments or reviews. #342 closed after PR #354 merged on October 8, 2026 at `eeaa8e7b1b8e821fc518287167c5fb06b549cdd8`.

Recovery #343 is now implemented in PR #355; next after its merge is beta injection #344.


## Recovery implementation and latest status

Steering [PR #354](https://github.com/davidmigloz/ai_clients_dart/pull/354) merged at `eeaa8e7b1b8e821fc518287167c5fb06b549cdd8`, closing #342 after all applicable final-head checks passed (14 contexts completed). [PR #355](https://github.com/davidmigloz/ai_clients_dart/pull/355) implements #343 opt-in recovery with explicit preparation, per-dial fresh authentication, SDK close/backoff policy, prompt cancellation and strict immutable UTF-8 FIFO snapshots. Submitted create/steer/inject and attempted uncertain writes never replay; final reporting contains only never-attempted frames. Overflow rejects only the new frame. The helper does not restore cache/history/accepted steering or rerun tools; intentional Node/Python differences are documented.

Validation: **11, 262 package unit tests pass with two existing skips** (104 new helper/runtime/public cases). All **104 new cases pass in real Chrome JavaScript and Wasm**; 119 existing socket/steering/lifecycle/connector regression cases pass. All 508 Dart files format unchanged; fix applies nothing and fatal-info analysis/diff checks pass. The literal README wrapper compiles; the offline example verifies four writes, no sent-frame replay, FIFO/rejection/final immutable reporting for **$0**. Requirements and engineering reviews approve the combined diff after all findings are resolved. No live API calls, release or version bump.

Fresh pins remain OpenAPI 234829e/Python 4e152cd; Node main is 534e691 (still 7.30.0), whose only new change is structured-output phase parsing. Dart lacks that convenience helper and retains it in the later complete-parity inventory. Candidate JSON equals canonical (356 operations/2,010 schemas). All 15 new classes plus preparation typedef use actual SDK extension mappings with schema:null. Full toolkit diagnostic sets are exactly unchanged: 226 implementation errors, 68 warnings, 213 infos; 32 consistency warnings. Exports/docs/README checks pass; no exclusions were added.

[Recovery acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/c4960cfd9ed0ccf8c8cbd2756bbb39b4c4df5af1/packages/openai_dart/specs/api-alignment/reviews/18-websocket-recovery.md), [current roadmap](https://github.com/davidmigloz/ai_clients_dart/blob/c4960cfd9ed0ccf8c8cbd2756bbb39b4c4df5af1/packages/openai_dart/specs/api-alignment/README.md). The saved PR uses the exact create-pr template. Final-head CI passed. Recovery PR #355 merged October 8, 2026 at `22b8cfdace42edd8dbe54e88de0341ee2b73426a`, closing #343. Beta injection #344 is now implemented in PR #356.

Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37743881484) passes on head `c4960cfd9ed0ccf8c8cbd2756bbb39b4c4df5af1`, including formatting, analysis, OpenAI package tests and code generation on both Dart versions plus aggregate Test result. CodeQL and all remaining applicable checks pass (14 contexts total); merge state is CLEAN with no outstanding comments or reviews.


## Injection implementation and latest status

Recovery [PR #355](https://github.com/davidmigloz/ai_clients_dart/pull/355) merged October 8, 2026 at `22b8cfdace42edd8dbe54e88de0341ee2b73426a`, closing #343, after all applicable final-head checks passed (14 contexts completed: 13 successes and the standard Test(all) skip).

[PR #356](https://github.com/davidmigloz/ai_clients_dart/pull/356) implements #344 beta multi-agent tool-result injection: exact explicit beta handshake/three-field request, typed committed/uncommitted acknowledgments, raw failed-input/future error preservation and late-ack races. Application owns developer tools; hosted collaboration remains server-owned. No submitted or delivery-unknown work/tool execution replays automatically. Explicit caller continuation retains raw maps, parent and lane. Existing broad Item request-codec limitations remain inventoried. Nested steering/injection copies correct stale child metadata resurrection with fresh replacements/clears and required-input list values/order. New sealed variants/raw getter have migration guidance.

Validation: **11,448 package unit tests pass with two existing skips**; **656 focused VM, real Chrome JavaScript and WebAssembly cases pass**. All 512 Dart files format unchanged; fix applies nothing, fatal-info analysis and diff checks pass. Twenty-three canonical schema fixtures have zero errors, including the 16,384-item boundary. Literal README/migration snippets compile; offline example verifies two tools/two injections/two acknowledgments/one explicit continuation and awaited cleanup for **$0**. Independent requirements/source and cross-author engineering reviews approve the final combined diff; all validated findings are resolved.

Reviewed OpenAPI advanced to `3c4759c1ecc98a2ac3d3df85d54f4eb409f5957d` (356 operations/2,009 schemas), with unchanged injection contracts; the canonical snapshot now withdraws text-prompt custom voice creation. Audio roadmap requires sample and consent, and actual archived/fresh fetch metadata is retained. Python remains `4e152cd`/3.26.0 and Node `534e691`/7.30.0. Full toolkit stays diagnostic:229 implementation errors/74 warnings/213 infos,32 consistency warnings. Three delegated-serializer errors/six delegated value-scanner warnings and moved generic/heterogeneous messages are independently classified; exports/docs/README pass, with no new exclusions or erased unrelated gaps. No live API calls, publication or version bump.

[Injection acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/7e39acc4821d950327e4e8f4b251a88bd7e5cfa6/packages/openai_dart/specs/api-alignment/reviews/19-websocket-injection.md), [current roadmap](https://github.com/davidmigloz/ai_clients_dart/blob/7e39acc4821d950327e4e8f4b251a88bd7e5cfa6/packages/openai_dart/specs/api-alignment/README.md). The saved PR body uses the exact create-pr template: five literal checked Test Plan lines at EOF, a paired Before/After migration fence, and validation/CI/tracking inside Details. Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37750741288) passes on head `7e39acc4821d950327e4e8f4b251a88bd7e5cfa6`, including formatting, analysis, OpenAI package tests and code generation on both Dart versions plus the aggregate Test result. All applicable checks pass (14 contexts completed, including the standard Test(all) skip). Merge state is CLEAN, with no outstanding comments or reviews. #344 closed after PR #356 merged. All eleven specified Phase 3 implementation tickets are merged. Phase 4 now has its own independently reviewed specification and linked tickets below.


## Phase 3 complete; Phase 4 planning published

[PR #356](https://github.com/davidmigloz/ai_clients_dart/pull/356) merged October 8, 2026 at `1e63d6b93bdf0028eb6925d45371b1f36deb5d7b`, closing #344, after all applicable final-head checks passed (14 contexts: 13 successes and the standard Test(all) skip). Phase 3's eleven specified implementation tickets are complete; wider parity inventory remains.

[Planning PR #361](https://github.com/davidmigloz/ai_clients_dart/pull/361) contains 17 requirements and four independently usable slices:

- #357 — Verify exact original payload signatures and parse 26 source-backed event variants locally. First signed-receiver capability, standalone no-key helper, explicit SDK compatibility, safe exception and VM/browser proof boundaries.
- #358 — Manage project endpoint lifecycle/rotation/test/event discovery. Eight operations, exact nullable fields, secret-log redaction, separate receiver status. Independently usable.
- #359 — Explicit project alert and organization case retrieval from verified notices; blocked by #357 for its example. Required nullable reasons, distinct permissions, no automatic investigation.
- #360 — Shared typed HTTP/failed-response monitoring details and canonical flat SSE error correction with migration/legacy handling; blocked by #359 for its investigation example. Reuses existing WS models and preserves unrelated-lane recovery.

All four are native sub-issues of #317. No runtime source/models/tests/examples/dependencies/manifest change in the plan. Independent Webhooks, Safety and engineering/requirements planning reviews approve the combined spec/tickets/roadmap after validated findings are resolved. Source/link/inventory validation passes 23 distinct spec URLs (HTTP 200), 54 local links, 26 received/23 writable variants, eight endpoint/2 safety operations and acyclic dependencies. The source synthetic signature was independently recomputed; no Dart runtime acceptance is claimed for future capabilities. No API-key access or paid calls; cost $0.

Fresh OpenAPI 506aff0a/Python b9bc5c14(3.26.0)/Node 3edaf0f3(7.30.0) preserve all Phase 4 routes/component/webhook definitions. Canonical 3c4759c1 remains; five Agents/Vault pagination parameter changes missed by toolkit review are independently recorded for Phase 6. Workspace notifications are typed now, while the distinct api.chatgpt.com administrator-key/enterprise-permission lookup remains Phase 7 integration inventory. Video/Python-only legacy safety raw events and media/Agents/Live error boundaries remain explicit. No invented monitoring setting or generic resume/unblock/action runner.

[Phase 4 specification](https://github.com/davidmigloz/ai_clients_dart/blob/7ddacc95eed48de1ddd2515c448842682733ba01/packages/openai_dart/specs/api-alignment/webhooks-safety.md), [planning review](https://github.com/davidmigloz/ai_clients_dart/blob/7ddacc95eed48de1ddd2515c448842682733ba01/packages/openai_dart/specs/api-alignment/reviews/20-webhooks-safety-planning.md), [current roadmap](https://github.com/davidmigloz/ai_clients_dart/blob/7ddacc95eed48de1ddd2515c448842682733ba01/packages/openai_dart/specs/api-alignment/README.md). The planning PR uses the exact create-pr template, with its five literal Test Plan lines at EOF and all validation/CI/tracking inside Details. Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37755808440) passes on head `7ddacc95eed48de1ddd2515c448842682733ba01`, including formatting, analysis, OpenAI package tests and code generation on both Dart versions plus aggregate Test result. All applicable checks pass (14 contexts completed: 13 successes and the standard Test(all) skip). Merge state is CLEAN, with no outstanding comments or reviews. Planning PR #361 merged October 8, 2026 at `886659c3c11cbee89335788ba918eeecd528fce0` after all applicable final-head checks passed. Receiver implementation follows below.


## Phase 4 receiver implemented and verified

[PR #362](https://github.com/davidmigloz/ai_clients_dart/pull/362) implements #357: standalone/local client exact-byte signature verification and all 26 canonical received event variants, immutable/raw future preservation, safe configuration/errors, application-owned acknowledgment/deduplication and complete example/README/llms/public exports. Planning PR #361 is merged; the receiver issue closed after implementation merge.

Validation: **12,604 package unit tests pass with two existing skips**, **1,129 focused VM/Chrome JavaScript/Wasm cases pass**, and 27 isolated synthetic environment cases prove keyless standalone use plus existing client API-key guard preservation. Format/fix/fatal-info analysis clean for 525 Dart files; 50 canonical public serialization fixtures and 33 real component describe/scaffold receipts pass. Independent requirements and cross-author engineering reviews approve the combined diff. No API requests; cost **$0**.

Reviewed canonical promotes 506aff0a; Python 9301e319/3.26.1 and Node bc6c0bfb/7.30.1 retain unchanged webhook contracts. Agents/Vault pagination and endpoint/safety/monitoring implementation remain separate. Toolkit remains diagnostic at 261 / 74 / 213 implementation counts and 35 consistency warnings; the new 31 inherited serializer scanner misses, one strict-enum fallback conflict and three source-required heterogeneous/envelope messages are explicitly classified, without exclusions or fake schemas. Exports/docs/README checks pass.

[Receiver acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/feat/openai-webhook-receiver/packages/openai_dart/specs/api-alignment/reviews/20-webhook-receiver.md). PR #362 uses the exact create-pr template with five literal checked Test Plan lines at EOF. Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37760476673) passes on head `0ec90da1ee3264a51bccae93f9a243348332b893`, including formatting, analysis, package tests and code generation on both Dart versions plus the aggregate Test result. All 14 contexts completed: 13 successes and the standard Test(all) skip. Merge state is CLEAN with no outstanding comments or reviews. #357 closed after implementation merge. Next: independently usable endpoint-management #358, then #359 safety retrieval and #360 monitoring details.


## Phase 4 receiver merged; endpoint management verified

Receiver PR #362 merged October 8, 2026 at `eea142bf9b100448f5216572e4db2d50a7ad0f5b`, closing #357 after all 14 final-head checks passed on `99df2a4ead5f5c0b53240dbbbb44fd5d02ee1d91`. Secret-scanning alert #1 is resolved as used_in_tests with public official SDK fixture provenance.

## Endpoint management implemented and verified

[PR #363](https://github.com/davidmigloz/ai_clients_dart/pull/363) implements all eight endpoint/discovery operations and eleven real request/response/enum components. Typed writable 23 choices, open returned strings, exact required-nullable hints/cursors, empty POST updates, omitted/false/true rotation, receiver-status test results and existing auth/abort/retry/closed-client behavior are verified. Local signed verification remains independent.

Signing-secret diagnostic redaction happens structurally before truncation, with original response/model JSON and raw exception body preserved. Error type/code/param and permanent-quota retry classification stay intact; cyclic/shared caller exception bodies are safe. No scanner exclusion or unrelated logging/auth rewrite.

Validation: **13,026 package unit tests pass with two existing skips**, **422 focused cases pass VM/real Chrome JavaScript/Wasm** (239 models, 161 resources, 22 privacy), **125 canonical public serialization cases** plus **110 independent probes** pass. All 533 Dart files format/fix/fatal-info analysis clean. Exact literal README compiles/runs; offline lifecycle makes ten mocked requests and no external test delivery. Cost **$0**. Independent requirements and cross-author engineering reviews approve the final combined diff, docs/example/manifest/evidence.

Full toolkit exports/docs/README pass; 271 implementation errors/74 warnings/213 infos and 35 consistency warnings remain visible. Compared with 261 baseline errors, ten inherited toJson scanner misses plus strict writable enum fallback conflict are added and one prior missing event-types resource error resolves (net+10), with no exclusions/fake components/checker changes.

[Acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/feat/openai-webhook-endpoints/packages/openai_dart/specs/api-alignment/reviews/21-webhook-endpoints.md) records contracts/source/schema/runtime proof. Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37768493367) passes on head `c6f025b93b9774b7472835a3c48aff1dd525fd81`, with formatting, analysis, package tests and code generation passing on both Dart versions plus aggregate Test result. All 14 contexts completed: 13 successes and standard Test(all) skip. Merge state is CLEAN with no outstanding feedback. PR #363 merged October 8, 2026 at `b5159171218e8feb9f720c5db7d1d82ea3cf1a80`, closing #358 after all applicable final-head checks passed. Next #359 safety retrieval has its signed-receiver prerequisite merged; #360 follows #359.


## Safety retrieval implemented and verified

[PR #364](https://github.com/davidmigloz/ai_clients_dart/pull/364) implements #359: explicit `safety.alerts.retrieve` and `safety.cases.retrieve`, all five canonical components, required nullable reasons/false paused state, finite immutable open-object metadata, complete copy/equality/hash and exact future received enum preservation. Project and organization credentials remain explicitly scoped; signed parsers do not fetch. Workspace alerts retain the separate api.chatgpt.com administrator/enterprise permission lookup in Phase 7.

Receiver #357 and endpoint management #358 are merged. PR #363 merged October 8, 2026 at `b5159171218e8feb9f720c5db7d1d82ea3cf1a80`. No live API calls or paid operations; cost **$0**.

Validation: **13,236 package unit tests pass with two existing skips**, **210 focused cases per runtime** pass VM/real Chrome JavaScript/Wasm, **106 canonical actual serializations plus nine documented receive-only cases**, and **568 independent runtime probes** pass. All 542 package Dart files format unchanged, fix0/fatal-info analysis clear. CI-stable Dart3.13.5 formatting also passes for all 2,665 repository Dart files after its single fixture-layout correction; stable analysis and 210 focused VM tests pass again. Offline signed-notice example makes exactly two scoped mocked GETs; two independent exact-README drivers pass. Independent requirements and cross-author engineering reviews approve all 23 changed files after corrections; 159 local documentation links resolve.

Full toolkit scope exports/docs/README pass. Diagnostics remain 270 implementation errors/74 warnings/213 infos and 35 consistency warnings: zero additions, one old missing Safety resource removed from baseline271. No exclusions, fabricated components or toolkit changes. Fresh canonical506aff/Python3.26.1/Node7.30.1 affected contracts are unchanged.

[Acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/56073666d17df4315cddec2865460dc04a6da9b5/packages/openai_dart/specs/api-alignment/reviews/22-safety-retrieval.md). PR #364 uses the exact create-pr template with five literal checked Test Plan lines at EOF. Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37782134724) passes on head `56073666d17df4315cddec2865460dc04a6da9b5`, including formatting, analysis, package tests and code generation on both Dart versions plus aggregate Test result. All 14 contexts completed: 13 successes and the standard Test(all) skip. Merge state is CLEAN with no outstanding comments or reviews. PR #364 merged October 8, 2026 at `a466e8500aae91347f9c2d004a0854c969c6e779`, closing #359 after all 14 final-head contexts completed. Next: #360 structured monitoring HTTP/failed-response details and flat SSE errors; later parity phases remain inventoried.

## Structured monitoring errors implemented and verified

[PR #365](https://github.com/davidmigloz/ai_clients_dart/pull/365) implements #360: shared typed HTTP/failed-response/WS details, flat nullable SSE errors, explicit legacy receive tolerance, complete nested copy/clear/replacement/value contracts and redacted automatic diagnostics without retry/replay/continuation. Names/const/direct WS imports remain compatible; targeted nullable-code/output changes have migration guidance. Binary response logging remains best effort and preserves bytes.

13,541 package unit tests pass with two existing skips; 305 new focused cases pass VM/real Chrome JS/Wasm. Independent actual183-case corpus/682 assertions validates85 canonical serializations and explicit tolerances; additional45 shared+26 SSE serialization corpora pass. All550 package/2,673 repository Dart files match stableformat; fixnothing/fatalanalysis3.12.2+3.13.5clear. Literal README compiles/runs; offline example makes five mock requests with explicitly scoped investigation from verified notice data.id. API cost $0. Independent requirements and cross-author engineering reviews approve the final combined implementation;253 localdoclinks resolve.

Toolkit exports/docs/README pass;274errors/78warnings/212infos and 35consistencywarnings remain visible. Identity delta8add/1remove/12relocated is classified, without fake schemas/exclusions/checker edits. Ten genuine GA/beta manifest components verified. Prerequisite #359 is closed by merged PR #364 at a466e8500aae91347f9c2d004a0854c969c6e779. PR #365 merged October 8, 2026 at `fca1a3f4e453d88caed9ffa573d4ec665126c3cb` (2026-10-08T14:20:48Z), closing #360. All four Phase 4 implementation tickets are complete. Next: Phase 5 Audio/Live source review, specification and implementation tickets; later complete-parity inventory remains in scope.

[Monitoring acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/f73de9c8ad972b83f57760acdefcf39a9cede9f8/packages/openai_dart/specs/api-alignment/reviews/23-monitoring-errors.md). PR365 final head `f73de9c8ad972b83f57760acdefcf39a9cede9f8`; Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37790237804) passes on head `f73de9c8ad972b83f57760acdefcf39a9cede9f8`: all 14 contexts completed, with 13 successes and the standard Test(all) skip. Formatting, analysis, package tests and code generation pass on both Dart versions; aggregate Test, CodeQL and review checks pass. Merge state is CLEAN with no outstanding feedback.

## Phase 5 Audio and Live specified

[Planning PR #373](https://github.com/davidmigloz/ai_clients_dart/pull/373) merged October 8, 2026 at 15:23:59 UTC, squash `4058318979cf8ab999e8138015b52b3dc75ffbf6`, after green final-head CI. It records seven independently usable slices and 38 requirements with 82 unchecked implementation criteria. [Specification](https://github.com/davidmigloz/ai_clients_dart/blob/80489e5d16d1a6932f87dd2731fdb476755f8327/packages/openai_dart/specs/api-alignment/audio-live.md) · [Independent planning review](https://github.com/davidmigloz/ai_clients_dart/blob/80489e5d16d1a6932f87dd2731fdb476755f8327/packages/openai_dart/specs/api-alignment/reviews/24-audio-live-planning.md).

| Issue | Outcome | Native dependency |
| --- | --- | --- |
| [#366](https://github.com/davidmigloz/ai_clients_dart/issues/366) | Buffered/byte/SSE speech and current voices | None; implement first |
| [#367](https://github.com/davidmigloz/ai_clients_dart/issues/367) | Chat AAC/custom voices and file audio corrections | #366 |
| [#368](https://github.com/davidmigloz/ai_clients_dart/issues/368) | All five voice consent operations | None |
| [#369](https://github.com/davidmigloz/ai_clients_dart/issues/369) | Sample-derived custom voices | #368 |
| [#370](https://github.com/davidmigloz/ai_clients_dart/issues/370) | All seven Live HTTP operations/startup models | None; merged receiver reused |
| [#371](https://github.com/davidmigloz/ai_clients_dart/issues/371) | Primary/sideband WS and full commands/events | #370 |
| [#372](https://github.com/davidmigloz/ai_clients_dart/issues/372) | Stored WS forks/manual delegation/transcript utilities | #371, transitively #370 |

All seven are open native sub-issues, labeled and assigned. Source pins are OpenAPI 506aff0a, Python 3.26.1/9301e319 and Node 7.30.1/bc6c0bfb. The 128 unique hashed primary sources cover nine Audio/seven Live HTTP operations, 124 Live components/300-schema closure, 38 Audio components, 22 received events and 11/9 writable primary/sideband commands. All 94 local links and 32 specification URLs pass; requirements are assigned once and the graph is acyclic. Independent Audio, Live engineering and combined requirements reviews approve with no open findings.

Planning head `80489e5d16d1a6932f87dd2731fdb476755f8327`; Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37797638495) passes on planning head `80489e5d16d1a6932f87dd2731fdb476755f8327`: all 14 contexts completed (13 successes, standard Test(all) skip). Exact create-pr template used, ending in its five literal unchecked runtime Test Plan lines with documentation-only applicability explained. No runtime files/tests/canonical/metadata/version/dependency change, live API request, recording upload or call. API cost $0. Phase 4 is merged and complete; next implementation is #366 speech. Phases 6–8 and explicit consent-phrase/recovery/Realtime/shared-model gaps remain in the complete-parity inventory.

## Phase 5 speech implementation before merge

[#366](https://github.com/davidmigloz/ai_clients_dart/issues/366) is implemented in [PR #374](https://github.com/davidmigloz/ai_clients_dart/pull/374), reviewed head `1f7975ae8d2ffc3ca898f5f071ae502619996199`. [Acceptance record](https://github.com/davidmigloz/ai_clients_dart/blob/1f7975ae8d2ffc3ca898f5f071ae502619996199/packages/openai_dart/specs/api-alignment/reviews/24-speech.md) covers all four speech requirements, current typed voices/options, buffered/byte/SSE output, ownership/cancellation/privacy, migration and the offline example. Independent requirements and cross-author engineering reviews approve; 13,814 unit tests/two existing skips, 273 new cases on VM/JS/Wasm, all formatter/fix/fatal-info checks, 90 canonical cases/363 assertions and 333 local links pass. Two short explicitly authorized live PCM requests passed; the full integration suite did not run.

PR #374 CI is green on the reviewed head. All seven Phase 5 issues remain open; #366 awaits merge, then #367 is next. Native graph of 30 children/dependencies remain intact; phases 6–8 and inventoried gaps remain in scope. No release/version bump.

## Speech source disposition before merge

[OpenAPI 35b0d4e](https://github.com/openai/openai-openapi/commit/35b0d4ebb841f2706e1c0aa31c7d47ecdd43c71d), published October 8 at 16:33:26 UTC, adds exactly five Agents session spend-control contracts. Independent fresh normalized comparison verifies all six Speech schemas and its POST operation unchanged. Distinct closed spending-limit request/returned models and create/update/null semantics are now recorded in Phase 6 inventory. Python/Node source heads are unchanged; Speech keeps its adopted 506aff0a canonical snapshot. The last commit updates documentation only, preserving all reviewed production/test/example/manifest hashes. Current published head `1f7975ae8d2ffc3ca898f5f071ae502619996199`; [CI rerun](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37810626961) is green on the published head. #366 remains open until merge, then #367 is next.

Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37810626961) passes on reviewed head `1f7975ae8d2ffc3ca898f5f071ae502619996199`: all 14 contexts completed, with 13 successes and the standard Test(all) skip. Formatting, analysis, package tests and code generation pass on Dart 3.12 and stable; aggregate Test, CodeQL and review checks pass. The PR is CLEAN with no outstanding feedback. Exact create-pr headings and the five literal checked Test Plan lines at EOF are verified; the PR is attached to this chat.


## Speech merged; existing Audio published

[PR #374](https://github.com/davidmigloz/ai_clients_dart/pull/374) merged October 8, 2026 at 17:41:41 UTC, squash `f76a2e8cbb8de0469310c4c0c0f31fc1ad13bbeb`, closing #366. Reviewed head `1f7975ae8d2ffc3ca898f5f071ae502619996199` passed all 14 CI contexts (13 successes, standard Test(all) skip).

[PR #375](https://github.com/davidmigloz/ai_clients_dart/pull/375) implements #367 on `47baee607ba4feea48b5965354b39202a20a1190` with typed open/custom Chat voices/AAC, complete existing 14-field multipart and immutable file-audio contracts, buffered abort, prompt SSE teardown, caller error fidelity/private diagnostics and explicit verbose/raw English translation. [Acceptance record](https://github.com/davidmigloz/ai_clients_dart/blob/47baee607ba4feea48b5965354b39202a20a1190/packages/openai_dart/specs/api-alignment/reviews/25-existing-audio.md) and [migration/example guidance](https://github.com/davidmigloz/ai_clients_dart/blob/47baee607ba4feea48b5965354b39202a20a1190/packages/openai_dart/MIGRATION.md#upcoming-chat-voices-and-file-audio-corrections) are published. Independent requirements and cross-author engineering reviews approve, with no open findings.

14,482 unit tests/two existing skips, 668 new three-platform cases, 207 public schema rows/720 assertions, 344 local links, clean format/fix/fatal-info analysis and literal offline examples all pass. Example cost $0; no live request, real recording upload, release or version bump. Exact create-pr template and remote 32-file identity pass; final-head CI **passes** on the reviewed published head. #367 remains open until merge. Native graph has 30 children:24 closed/six open (#367–#372); #366 prerequisite is closed. Next independently usable slice is #368 (all five voice consent operations). Phases 6–8 remain in scope.

Adopted OpenAPI 239c481c includes reviewed Agents spending control and OCI storage additions, inventoried in Phases 6/7 without runtime completion claims. A later b2751c66 changes only VoiceResource.type to the closed audio_sample enum (three normalized leaves); #369 specification/ticket is refined, file-Audio/Chat closures are unchanged and adopted 239 fetch/source metadata remains exact. Toolkit 275 errors/112 warnings/215 infos and 35consistency warnings remain visible; 30 scanner/binary/enum additions are classified with no exclusions/checker edits/fake schemas.


Final [GitHub workflow](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37827335113) passes on reviewed head `47baee607ba4feea48b5965354b39202a20a1190`: all 14 contexts completed, with 13 successes and the standard Test(all) skip. Formatting, analysis, package tests and code generation pass on Dart 3.12 and stable; aggregate Test and CodeQL pass. The PR is CLEAN with no outstanding feedback. Independent reviews supply the engineering approval; the external review service context reports success while its full review is skipped for unavailable credits.

Exact create-pr template and 32 remote path/blob identities are verified. No new code/doc/test commit was needed for this CI status update. Actual user-authorized merge remains pending; #367 stays open until PR #375 merges.


## Existing Audio merged; voice consent management implemented

[PR #375](https://github.com/davidmigloz/ai_clients_dart/pull/375) merged October 8 at 19:31:30 UTC, squash `98e67ac93bc524a6a40a49ffb04a3c38c00f89ec`, closing #367 after all final-head CI contexts passed (13 successes and the standard Test(all) skip).

[PR #376](https://github.com/davidmigloz/ai_clients_dart/pull/376) implements #368 with all five consent operations, original multipart bytes/MIME, explicit pagination, immutable received metadata and private automatic diagnostics. [Acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/cadd3f39ba82e12cb0764a87dc5808f01894e5b4/packages/openai_dart/specs/api-alignment/reviews/26-voice-consents.md) records 14,808 passing unit tests, two existing skips, 326 new cases on VM/Chrome JavaScript/Wasm, README/schema/offline checks and independent requirements/engineering approvals. Five default/six explicitly selected deletion mock requests cost $0; no live uploads. Final-head [CI 37836884914](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37836884914) passes for `cadd3f39ba82e12cb0764a87dc5808f01894e5b4`: 14 contexts completed (13 successes and the standard Test(all) skip), merge state CLEAN; no unresolved feedback. Actual merge remains pending. The exact create-pr template, labels and assignee are applied.

The native roadmap still has 30 children: 25 closed, five open (#368–372), and four Phase 5 dependency edges; #369 remains blocked by #368 until merge. Canonical b2751c66 is adopted with actual fetch metadata; unrelated custom-voice/Admin/OCI gaps and toolkit scanner limitations remain explicit. Next implementation: #369 sample-derived voice creation.


## Voice consent merged; custom voice creation implemented

[PR #376](https://github.com/davidmigloz/ai_clients_dart/pull/376) merged October 8 at 20:13:36 UTC, squash `2856c21eed697b7ec24a79e70e66800fe5ec0b79`, closing #368 after all 14 final-head contexts completed (13 successes and the standard Test(all) skip).

[PR #377](https://github.com/davidmigloz/ai_clients_dart/pull/377) implements #369: one multipart custom voice creation branch with explicit consent/sample, fixed typed response, original bytes/MIME, Unicode name limit, scoped private diagnostics and no upload replay. [Acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/0bdb022bf59fe4ca6713aad902a139a7c40d7dfc/packages/openai_dart/specs/api-alignment/reviews/27-custom-voices.md) records 14,989 passing unit tests/two existing skips, 180 new shared VM/Chrome JavaScript/Wasm cases and one native socket fixture, exact README/canonical/offline checks and independent requirements/engineering approvals. Two mock POSTs select a reference without a consuming API call; cost $0 and no live upload. Final-head [CI 37841092240](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37841092240) passes for `0bdb022bf59fe4ca6713aad902a139a7c40d7dfc`: 14 contexts completed (13 successes and the standard Test(all) skip), merge state CLEAN; no unresolved feedback. Actual merge remains pending; exact create-pr template, labels and assignee are applied.

The native parent still has 30 children: 26 closed, four open (#369–372), with all four Phase 5 dependency edges preserved. #369's consent prerequisite is now closed; its own actual merge remains pending. Live HTTP #370 has no artificial dependency on custom voice creation and is next in the planned order. Candidate/source heads match adopted OpenAPI b2751c66, Python 8e1fd258 and Node 7.30.1; canonical bytes/original metadata and remaining inventory are preserved.


## Custom voice merged; Live HTTP implemented

[PR #377](https://github.com/davidmigloz/ai_clients_dart/pull/377) merged October 8 at 20:49:30 UTC, squash `3e2b488e896f820118b575108c50586ae08ec867`, closing #369 after all 14 final-head contexts completed (13 successes and the standard Test(all) skip).

[PR #378](https://github.com/davidmigloz/ai_clients_dart/pull/378) implements #370 with all seven HTTP operations, canonical WebRTC/SIP creation, original WAV downloads, explicit call controls/REST fork and full shared startup/tool models. [Acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/a439b6ae1e9ea92545ce1592a023ad6a7b2832bd/packages/openai_dart/specs/api-alignment/reviews/28-live-http.md) records 16,934 passing unit tests/two existing skips, 1,945 new VM cases/1,941 common VM-Chrome JavaScript-Wasm cases, 243 actual public canonical outputs covering all 100 components, source/docs/offline evidence and independent requirements/engineering approvals. Default/accept/reject/503 examples make 7/8/8/6 mocks and cost $0, with no live call/media/upload. The exact create-pr template, labels and assignee are verified; published-head CI and actual merge remain pending.

The native roadmap has 30 children: 27 closed, three open (#370–372), with the four Phase 5 dependency edges preserved. Live HTTP has no custom-voice dependency; #371 depends on #370, #372 on #371. Adopted OpenAPI f6 has exact metadata; late OpenAPI 978d0571 Agents environments additions are inventoried for Phase 6 and all Live contracts remain unchanged. SDK heads remain Python 8e1fd258 / Node 7.30.1. All unrelated toolkit gaps stay visible; no new exclusions or fake schemas.


## Published-head CI gate

[PR #378](https://github.com/davidmigloz/ai_clients_dart/pull/378) was checked at the initial head `a439b6ae1e9ea92545ce1592a023ad6a7b2832bd`. [CI 37848782766](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37848782766) passed: all 14 contexts completed, 13 successes and the standard Test(all) skip; merge state CLEAN. The exact create-pr template, labels, assignee and committed scope are verified. Independent requirements and cross-author engineering reviews approve; no unresolved inline feedback. Actual merge remains pending, so #370 stays open.

Native graph: 30 children, 27 closed and three open (#370–372); four Phase 5 dependency edges remain unchanged. Next after merging #378: #371 Live WebSockets, followed by #372 forks/delegation/transcripts. Later Agents environment additions remain inventoried for Phase 6.


## Corrected Live HTTP publication head

Final publication review found that JavaScript Infinity can satisfy a Dart int type check. Targeted finite guards for backend token limits and snapshot expiry are now committed, with constructor/copy/parse regressions on VM, real Chrome JavaScript and Wasm. The corrected PR #378 head is `3e277a5c66f54abac4f9def7d273489953f00a81`; the package suite passes 16,967 tests with two existing skips, and 1,978 new VM cases / 1,974 common cases cover the change. Valid canonical output is unchanged. Independent requirements and engineering reviews approve the corrected diff. [Final-head CI 37850463596](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37850463596) passed on this exact head: all 14 contexts completed, 13 successes and the standard Test (all) skip; merge state CLEAN. Exact published template, labels, assignee and scope are verified, with no unresolved review feedback. Prior a439 green CI is historical evidence. Actual merge remains pending, so #370 stays open. Native graph remains 30 children / 27 closed / three open (#370–372), with four unchanged Phase 5 edges.


## Live HTTP merged; Live WebSockets underway

[PR #378](https://github.com/davidmigloz/ai_clients_dart/pull/378) merged at 2026-10-08T22:06:50Z (UTC), squash `98b32e699bd61532c948a910ad9869e91fb23a73`, closing #370 after independent approvals and all 14 final-head CI contexts completed (13 successes, standard Test (all) skip). The native roadmap now has 30 children, 28 closed and two open (#371–372); dependency edges are preserved. #371 is being implemented with primary/sideband connections and complete event codecs; no runtime acceptance is claimed yet.

## Live WebSocket publication receipt

[PR #379](https://github.com/davidmigloz/ai_clients_dart/pull/379) implements #371 at immutable head `9e886dc75c04a3bf9b1909e62a7064d2ba6649cc`. [Acceptance evidence](https://github.com/davidmigloz/ai_clients_dart/blob/9e886dc75c04a3bf9b1909e62a7064d2ba6649cc/packages/openai_dart/specs/api-alignment/reviews/29-live-websockets.md) records 20,654 passing package unit cases with two existing skips, 3,687 new VM cases, 2,882 client/input and 688 received model cases on VM/real Chrome JavaScript/Wasm, exact public canonical coverage of all 287 components, classified toolkit diagnostics and offline workflow cost $0. Independent requirements and engineering reviews approve the combined implementation. Final-head [CI](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37858439288) passes on `9e886dc75c04a3bf9b1909e62a7064d2ba6649cc`: all 14 contexts completed,13 successes and the standard Test(all) skip. Actual merge remains pending; #371 stays open until its PR merges.

The native roadmap retains 30 children: 28 closed and two open (#371, #372). All four Phase 5 edges remain intact; #370 is closed, #371 remains the prerequisite for #372. Stored fork/transcript workflows are next in #372. Adopted f6 canonical bytes/original metadata and Python 8e1fd258 / Node bc6c0bfb heads remain unchanged; later Agents environment/lifecycle changes stay inventoried.

Publication-time OpenAPI fd15 leaves all Live contracts unchanged. Later Decisions HTTP(S) image acceptance and optional nullable Safety alert detailed_explanation remain pending [follow-up inventory](https://github.com/davidmigloz/ai_clients_dart/blob/9e886dc75c04a3bf9b1909e62a7064d2ba6649cc/packages/openai_dart/specs/api-alignment/README.md#decisions). Earlier completed Decisions/Safety tickets do not imply these later additions are implemented.

## Live WebSockets merged; fork/transcript workflows underway

[PR #379](https://github.com/davidmigloz/ai_clients_dart/pull/379) merged 2026-10-09T05:02:13Z, squash `d00ee5cfc4a61df04b4e7c59c6ea4e8e34c79648`, closing #371. Reviewed head `9e886dc75c04a3bf9b1909e62a7064d2ba6649cc` passed all 14 CI contexts (13 successes, standard Test(all) skip) with independent requirements/engineering approvals and exact create-pr template. Native roadmap: 30 children, 29 closed, #372 open; dependency edges are preserved. #372 is being implemented; no new runtime acceptance is claimed yet. Later Decisions HTTP(S) images, Safety alert explanation and Phases 6–8 remain pending inventory.
