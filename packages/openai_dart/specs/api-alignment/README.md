# OpenAI API alignment

Planning started October 7, 2026. Status: Decisions, container configuration,
cache retention, cache controls/diagnostics, and Chat usage/obfuscation merged.
Chat audio merged in [PR #331](https://github.com/davidmigloz/ai_clients_dart/pull/331).
Retry guidance merged in [PR #332](https://github.com/davidmigloz/ai_clients_dart/pull/332);
image model requiredness #326 merged in [PR #333](https://github.com/davidmigloz/ai_clients_dart/pull/333).

Phases 1–4 and Audio/Live HTTP #366–370 are merged. Live HTTP
[PR #378](https://github.com/davidmigloz/ai_clients_dart/pull/378) closed #370;
Live WebSockets #371 is implemented and locally verified, followed by #372 stored fork and
transcript workflows. Agents/Vaults, Administration and remaining parity phases
retain their inventory below.

Tracking parent: [GitHub issue #317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
This parent records planning progress; it is not an implementation ticket.

## Objective and current decisions

Bring `openai_dart` into alignment with the current public API contracts and
official clients through independently usable, reviewed changes.

| Decision | Status |
| --- | --- |
| Use a scope interview, written specs, dependency-linked tickets, implementation, and independent review | Requested |
| Keep specifications in the repository and track work with GitHub issues | Confirmed by the user |
| Target complete parity, including Administration and legacy gaps, with modern APIs/fixes first and Decisions leading | Recorded from the user's scope response |
| Permit targeted breaking corrections with migration guidance, preserving compatibility where practical | Confirmed by the user |
| Publish or release package versions | Outside the current planning request |

Repository documentation records the requirements and decisions. GitHub issues
track the work and dependencies. A ticket is complete only when its acceptance
criteria have evidence and validated review findings have been addressed.

## Evidence baseline

- Package version: `10.0.1`.
- Repository baseline: `6e117fd254d1d8e3f893588957ef5316b4565b48`.
- Previous canonical specification: fetched September 16, 2026. The reviewed
  October 7 snapshot is now canonical, with remaining gaps tracked explicitly.
- Reviewed upstream specification:
  [OpenAPI commit ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
- Official clients:
  [Python 3.26.0](https://github.com/openai/openai-python/releases/tag/v3.26.0)
  and [Node 7.30.0](https://github.com/openai/openai-node/releases/tag/v7.30.0).
- Discovery index: [API changelog](https://developers.openai.com/api/docs/changelog)
  and its linked guides and references.

The upstream comparison contains 19 added operations, four modified operations,
one removed operation, 155 added schemas, 46 modified schemas, and two removed
schemas. These counts describe upstream changes, not the number of package
defects. Existing resource files can still omit individual methods and fields.

Published documentation sometimes leads the specification, notably web-search
return-token budgets and image results. The specification sometimes leads the
checked clients, notably voice-consent management. Each affected ticket must
record which source establishes the contract and any unresolved discrepancy.
Revalidate the affected contract before implementation if upstream has changed.

Before creating this roadmap, open-issue overlap was checked October 7: no prior
alignment work items were found.
[Issue #316](https://github.com/davidmigloz/ai_clients_dart/issues/316) requests
runtime client configuration updates and may inform later authentication or
regional-client work; it is not the Responses `configuration_update` item.

## First milestone

The complete Decisions feature is implemented as one independently usable ticket,
[GitHub #318](https://github.com/davidmigloz/ai_clients_dart/issues/318).
It has no dependency on another implementation ticket and includes the small
shared cache-write usage enhancement.

- [Detailed Decisions specification](decisions.md), requirements DEC-01–DEC-11.
- [Repository ticket and acceptance criteria](tickets/01-decisions.md).
- [Independent planning review and resolved findings](reviews/01-decisions-planning.md).
- [Implementation acceptance evidence and independent reviews](reviews/01-decisions-implementation.md).

Decisions implementation and both independent reviews are complete. The package
unit suite passes (1,783 tests, two existing skips), and analysis is clean. The
subsequently authorized live Decisions smoke test also passed with one request
(387 input tokens, estimated $0.0000387). [PR #319](https://github.com/davidmigloz/ai_clients_dart/pull/319)
merged after all CI checks passed, closing #318. The confirmed general policy permits
targeted breaking fixes with migration guidance; this first feature is additive.

## Phase 2

The [existing API correctness specification](correctness.md) records the next
independently usable slices, source discrepancies, compatibility decisions, and
acceptance boundaries. [Container configuration](containers.md) is first, tracked
by the [repository ticket](tickets/02-container-configuration.md). Cache retention,
cache diagnostics/controls, Chat usage/obfuscation, Chat audio, retry guidance, and
image model requiredness follow as separate tickets.

| Ticket | Independently usable outcome | Dependency |
| --- | --- | --- |
| [#320](https://github.com/davidmigloz/ai_clients_dart/issues/320) | Correct container memory/network configuration, secrets, skills, and returned settings | Merged in #327 |
| [#321](https://github.com/davidmigloz/ai_clients_dart/issues/321) | Emit the canonical cache-retention wire value | None; merged in #328 |
| [#322](https://github.com/davidmigloz/ai_clients_dart/issues/322) | Configure cache controls and inspect diagnostics | #321; merged in #329 |
| [#323](https://github.com/davidmigloz/ai_clients_dart/issues/323) | Preserve Chat token details and stream obfuscation | None; merged in #330 |
| [#324](https://github.com/davidmigloz/ai_clients_dart/issues/324) | Preserve complete and streamed Chat audio | Merged in #331 |
| [#325](https://github.com/davidmigloz/ai_clients_dart/issues/325) | Honor retry hints and stop replaying permanent quota failures | Merged in #332 |
| [#326](https://github.com/davidmigloz/ai_clients_dart/issues/326) | Require explicit model selection where the image API requires it | Merged in #333 |

Container [acceptance evidence and independent reviews](reviews/02-container-configuration.md)
record the 1,841 passing unit tests, clean analysis, bounded live lifecycle, resolved
findings, migration, and deliberately visible toolkit diagnostics.
Container [PR #327](https://github.com/davidmigloz/ai_clients_dart/pull/327) merged
after all CI checks passed, closing #320.

Cache-retention [acceptance evidence and independent reviews](reviews/03-cache-retention.md)
record 1,872 passing unit tests, clean analysis, canonical/legacy compatibility,
public request/response fixtures, and the separate Chat equality correction
required by #322. Cache retention [PR #328](https://github.com/davidmigloz/ai_clients_dart/pull/328)
merged after all CI checks passed, closing #321.

Cache controls/diagnostics [acceptance evidence](reviews/04-cache-controls-diagnostics.md)
records 2,121 passing unit tests, clean analysis, independent approvals, modern
examples/migration, and a two-request live smoke (conservative $0.00040525),
with both stored responses deleted. Implementation [PR #329](https://github.com/davidmigloz/ai_clients_dart/pull/329)
merged after all CI checks passed, closing #322.

Chat usage/obfuscation [acceptance evidence](reviews/05-chat-usage-obfuscation.md)
records 2,199 passing unit tests, clean analysis, independent approvals, updated
streaming examples/migration, and an authorized one-request unstored live smoke
(conservative $0.000003375). Implementation [PR #330](https://github.com/davidmigloz/ai_clients_dart/pull/330)
merged after all CI checks passed, closing #323.

Chat audio [acceptance evidence](reviews/06-chat-audio.md) records 2,282 passing
unit tests, clean analysis, independent approvals, complete output/replay/stream
examples and migration, and an authorized single-request live smoke (conservative
$0.008544). Implementation [PR #331](https://github.com/davidmigloz/ai_clients_dart/pull/331) merged
after all CI checks passed, closing #324. Retry guidance #325 merged in #332.

Retry guidance [acceptance evidence](reviews/07-retry-guidance.md) records 2,454
passing unit tests, clean analysis, independent approvals, complete server minima
and permanent-quota behavior, precise pre-stream metadata, and a runnable local
example verified without API cost. Implementation [PR #332](https://github.com/davidmigloz/ai_clients_dart/pull/332) merged
after all CI checks passed, closing #325. Image model requiredness #326 merged in #333.

Image model selection [acceptance evidence](reviews/08-image-model-selection.md)
records 2,537 passing unit tests, clean analysis, independent approvals, required
generation/multipart models with retained JSON-edit omission, complete changed-model
contracts, migration/current examples and a local demo verified without API cost.
Implementation [PR #333](https://github.com/davidmigloz/ai_clients_dart/pull/333) merged
after all CI checks passed, closing #326. All Phase 2 tickets are complete.

## Phase 3

The [Responses specification](responses.md) records the next source-backed
contracts, source discrepancies, compatibility/platform decisions and dependency
boundaries. [Planning review](reviews/09-responses-planning.md) records the
independent review. Planning PR #345 merged after all CI checks passed. Async
[#334](https://github.com/davidmigloz/ai_clients_dart/issues/334) is implemented and
independently reviewed with [acceptance evidence](reviews/09-async-tools.md) in
[PR #346](https://github.com/davidmigloz/ai_clients_dart/pull/346), now merged with
#334 closed. Configuration updates #335 merged in
[PR #347](https://github.com/davidmigloz/ai_clients_dart/pull/347), closing #335;
[acceptance evidence](reviews/10-configuration-updates.md) records validation and
independent reviews. GA web search #336 merged in
[PR #348](https://github.com/davidmigloz/ai_clients_dart/pull/348), closing #336;
[acceptance evidence](reviews/11-web-search.md) records validation and reviews.
Hosted/local shell #337 merged in
[PR #349](https://github.com/davidmigloz/ai_clients_dart/pull/349), closing #337;
[acceptance evidence](reviews/12-hosted-shell.md) records validation and reviews.
Compaction progress #338 is implemented, validated and independently reviewed
with 205 new deterministic tests; [acceptance evidence](reviews/13-compaction-progress.md)
records the contracts, offline example, migration guidance and retained parity gaps.
Implementation [PR #350](https://github.com/davidmigloz/ai_clients_dart/pull/350)
merged after green CI, closing #338. Access programs #339 merged in
[PR #351](https://github.com/davidmigloz/ai_clients_dart/pull/351), closing #339;
[acceptance evidence](reviews/14-access-programs.md) records 784 new tests,
the example, independent approvals and retained gaps. Tool search #340 is
implemented with 4,000 new deterministic tests;
[acceptance evidence](reviews/15-tool-search.md) records directional item and
discovered-definition fidelity, compatibility decisions and public transport
coverage. Package validation passes with 10,152 unit tests, two existing skips and
clean fatal-info analysis; the two-request offline example costs $0. Full toolkit
diagnostics are classified in the evidence. Independent requirements and
engineering reviews approve the final combined diff. Implementation
[PR #352](https://github.com/davidmigloz/ai_clients_dart/pull/352) merged after green
CI, closing #340. WebSocket transport #341 is implemented, verified and independently reviewed;
implementation [PR #353](https://github.com/davidmigloz/ai_clients_dart/pull/353)
merged after green CI, closing #341. Steering #342 merged after green CI in [PR #354](https://github.com/davidmigloz/ai_clients_dart/pull/354), closing #342.

The #340 source recheck retains
[OpenAPI 234829e](https://github.com/openai/openai-openapi/blob/234829e2b634b8fb159df7fcddbffad204173ffd/openapi.json),
Python 3.26.0 and Node 7.30.0. Its 356 operations and 2,010 schemas have no new
wire changes. Unchanged source does not establish complete implementation parity.

| Ticket | Demonstrable outcome | Status and dependencies |
| --- | --- | --- |
| [#334](https://github.com/davidmigloz/ai_clients_dart/issues/334) ([09](tickets/09-async-tools.md)) | Async function/custom calls and faithful replay | Merged in #346 |
| [#335](https://github.com/davidmigloz/ai_clients_dart/issues/335) ([10](tickets/10-configuration-updates.md)) | Persistent reasoning effort updates | Merged in #347 |
| [#336](https://github.com/davidmigloz/ai_clients_dart/issues/336) ([11](tickets/11-web-search.md)) | GA web-search controls/actions/image results | Merged in #348 |
| [#337](https://github.com/davidmigloz/ai_clients_dart/issues/337) ([12](tickets/12-hosted-shell.md)) | Hosted/local shell configuration, replay and streams | Merged in #349 (#320 merged) |
| [#338](https://github.com/davidmigloz/ai_clients_dart/issues/338) ([13](tickets/13-compaction-progress.md)) | Typed compaction progress | Merged in #350 |
| [#339](https://github.com/davidmigloz/ai_clients_dart/issues/339) ([14](tickets/14-access-programs.md)) | Select/inspect effective access program | Merged in #351 |
| [#340](https://github.com/davidmigloz/ai_clients_dart/issues/340) ([15](tickets/15-tool-search.md)) | Complete client-discovered tools | Merged in #352 |
| [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341) ([16](tickets/16-responses-websocket.md)) | Persistent WS sessions, envelopes and named lanes | Merged in #353 |
| [#342](https://github.com/davidmigloz/ai_clients_dart/issues/342) ([17](tickets/17-responses-steering.md)) | Safe mid-turn steering and continuation | Merged in #354 |
| [#343](https://github.com/davidmigloz/ai_clients_dart/issues/343) ([18](tickets/18-websocket-recovery.md)) | Opt-in reconnect and bounded unsent queue | Merged in #355 |
| [#344](https://github.com/davidmigloz/ai_clients_dart/issues/344) ([19](tickets/19-websocket-injection.md)) | Beta multi-agent tool-result injection | Merged in #356 |

Async tools, configuration updates, web search, shell, compaction progress,
access programs, tool search #340, Responses WebSocket sessions #341, steering
#342 and recovery #343 are merged after green CI. Beta injection #344 is
merged in [PR #356](https://github.com/davidmigloz/ai_clients_dart/pull/356) after green CI. Each ticket includes an offline
example, public fixtures, documentation and independent review. All eleven
Phase 3 tickets are native sub-issues of #317. These specified slices do not
establish complete WebSocket or Responses SDK parity; remaining shared model
and later-family gaps stay in the inventory.


## Phase 4

The [Webhooks and safety specification](webhooks-safety.md) records 17 requirement
IDs, exact received/subscription inventories, signature policy, permission and
error-shape boundaries. [Planning review](reviews/20-webhooks-safety-planning.md)
records independent source/architecture checks. Planning [PR #361](https://github.com/davidmigloz/ai_clients_dart/pull/361) merged October 8, 2026 at `886659c3c11cbee89335788ba918eeecd528fce0` after green CI. Receiver #357 merged in [PR #362](https://github.com/davidmigloz/ai_clients_dart/pull/362)
at `eea142bf9b100448f5216572e4db2d50a7ad0f5b` after green CI.
Its [acceptance evidence](reviews/20-webhook-receiver.md) records runtime checks.
Endpoint management [PR #363](https://github.com/davidmigloz/ai_clients_dart/pull/363) merged October 8, 2026 at
`b5159171218e8feb9f720c5db7d1d82ea3cf1a80` after green CI, closing #358; [acceptance evidence](reviews/21-webhook-endpoints.md) records its checks.
Safety retrieval #359 is merged, independently reviewed and verified;
[acceptance evidence](reviews/22-safety-retrieval.md) records 13,236 passing unit
tests with two existing skips and all three focused runtimes. Safety retrieval [PR #364](https://github.com/davidmigloz/ai_clients_dart/pull/364) merged October 8, 2026 at `a466e8500aae91347f9c2d004a0854c969c6e779` after all 14 final-head contexts completed (13 successes and the standard Test(all) skip), closing #359. Monitoring errors #360 are implemented with [acceptance evidence](reviews/23-monitoring-errors.md): 305 new focused cases pass VM/Chrome JavaScript/Wasm, shared typed details and flat SSE corrections have migration guidance, and the offline investigation example costs $0. Implementation [PR #365](https://github.com/davidmigloz/ai_clients_dart/pull/365) merged October 8, 2026 at `fca1a3f4e453d88caed9ffa573d4ec665126c3cb` (2026-10-08T14:20:48Z) after all 14 final-head contexts completed (13 successes and the standard Test(all) skip), closing #360.

| Ticket | Demonstrable outcome | Prerequisite |
| --- | --- | --- |
| [#357](https://github.com/davidmigloz/ai_clients_dart/issues/357) ([20](tickets/20-webhook-receiver.md)) | Verify original bytes and parse 26 source-backed webhook variants | None |
| [#358](https://github.com/davidmigloz/ai_clients_dart/issues/358) ([21](tickets/21-webhook-endpoints.md)) | Manage endpoints, signing secrets, tests and event-type discovery | None |
| [#359](https://github.com/davidmigloz/ai_clients_dart/issues/359) ([22](tickets/22-safety-retrieval.md)) | Explicitly retrieve project alerts/organization cases from verified notices | 20 for signed-notice example |
| [#360](https://github.com/davidmigloz/ai_clients_dart/issues/360) ([23](tickets/23-monitoring-errors.md)) | Preserve typed HTTP/failed-response monitoring details and canonical flat SSE errors | 22 for investigation example |

The first receiver ticket includes verification so its example handles signed
notifications end to end. Endpoint management remains independently usable.
Safety detail retrieval and structured errors are separate slices. The receiver now provides public offline fixtures, complete value/copy contracts,
README/llms documentation and a runnable local HTTP example. All four slices have their own runtime acceptance and independent reviews.

## Phase 5

The [Audio and Live specification](audio-live.md) records seven independently
usable slices, exact canonical/guide/SDK disagreements, protocol ownership and
public offline acceptance boundaries. The [planning review](reviews/24-audio-live-planning.md)
records source checks and independent findings. Planning [PR #373](https://github.com/davidmigloz/ai_clients_dart/pull/373)
merged October 8, 2026 at `4058318979cf8ab999e8138015b52b3dc75ffbf6` after
all 14 CI contexts completed (13 successes, standard Test(all) skip). Speech #366 merged in [PR #374](https://github.com/davidmigloz/ai_clients_dart/pull/374)
at `f76a2e8cbb8de0469310c4c0c0f31fc1ad13bbeb` on October 8, 17:41:41 UTC,
after all 14 final-head CI contexts completed (13 successes, standard Test(all) skip).
Its [acceptance evidence](reviews/24-speech.md) is complete. Existing Audio #367
merged in [PR #375](https://github.com/davidmigloz/ai_clients_dart/pull/375)
at `98e67ac93bc524a6a40a49ffb04a3c38c00f89ec` on October 8 at 19:31:30 UTC,
after all 14 CI contexts passed (13 successes, standard Test(all) skip). Its
[acceptance evidence](reviews/25-existing-audio.md) is complete. Consent management
#368 merged in [PR #376](https://github.com/davidmigloz/ai_clients_dart/pull/376)
at `2856c21eed697b7ec24a79e70e66800fe5ec0b79` on October 8, 20:13:36 UTC,
after all final-head CI contexts passed (13 successes, standard Test(all) skip).
Its [acceptance evidence](reviews/26-voice-consents.md) is complete. Custom voice
creation #369 merged in [PR #377](https://github.com/davidmigloz/ai_clients_dart/pull/377)
on October 8 at 20:49:30 UTC, commit `3e2b488e896f820118b575108c50586ae08ec867`,
after all 14 final-head CI contexts completed (13 successes, standard Test(all) skip).
Its [acceptance evidence](reviews/27-custom-voices.md) records the merge. Live HTTP
#370 is implemented and independently approved; two later Live tickets remain pending.

| Repository ticket | Demonstrable outcome | Prerequisite |
| --- | --- | --- |
| [#366](https://github.com/davidmigloz/ai_clients_dart/issues/366) ([24](tickets/24-speech.md)) | Buffered/byte-streamed/SSE speech, current open/custom voices | None |
| [#367](https://github.com/davidmigloz/ai_clients_dart/issues/367) ([25](tickets/25-existing-audio.md)) | Correct Chat voice/AAC and transcription/translation contracts | 24 for shared voice reference |
| [#368](https://github.com/davidmigloz/ai_clients_dart/issues/368) ([26](tickets/26-voice-consents.md)) | All five consent management operations | None |
| [#369](https://github.com/davidmigloz/ai_clients_dart/issues/369) ([27](tickets/27-custom-voices.md)) | Sample-derived voice creation from explicit consent | 26 for offline workflow |
| [#370](https://github.com/davidmigloz/ai_clients_dart/issues/370) ([28](tickets/28-live-http.md)) | All seven Live HTTP operations and full startup configuration | None; reuses merged signed receiver |
| [#371](https://github.com/davidmigloz/ai_clients_dart/issues/371) ([29](tickets/29-live-websockets.md)) | Primary/sideband WS, role-safe commands and complete events | 28 |
| [#372](https://github.com/davidmigloz/ai_clients_dart/issues/372) ([30](tickets/30-live-forks-transcripts.md)) | Stored WS forks, manual delegation and transcript helpers | 29, transitively 28 |

Speech comes first. Existing file-audio defects get a separate correction PR;
consent and sample creation remain separate usable workflows. Live HTTP includes
canonical outbound SIP beyond current SDK helpers, then transports reuse its
configuration. Forking creates a new stored-history session; application state
and external actions are never implicitly replayed. Documentation-only consent
phrase lookup and SDK reconnect/queue conveniences retain explicit inventory.
These slices do not establish full Realtime/Chat/shared Responses parity.

## Remaining roadmap

Phases 1–4 are complete for their specified tickets. Phase 5 Audio/Live has seven
specified implementation tickets: speech #366, existing Audio #367 and consent
management #368, custom voice creation #369 and Live HTTP #370 are merged.
Live WebSockets #371 is implemented and locally verified; #372 stored fork/transcript workflows
follows. Later phases remain candidate outcomes pending
detailed specifications. Keep all audited gaps visible even when deferred.

| Phase | Demonstrable outcomes | Dependencies and scope notes |
| --- | --- | --- |
| 1. Decisions | Create typed decisions from text and inline images; receive predicate, choice, score, and refusal answers with complete usage | Merged in #319/#318 |
| 2. Existing API correctness | Correct container wire formats; preserve cache diagnostics, token details, Chat audio chunks, and retry guidance | All tickets merged in #327–#333; shared cache-write usage included in Decisions |
| 3. Responses capabilities | Use async tools, reasoning configuration updates, GA web search controls/results, hosted shell, and Responses WebSocket steering | All eleven specified tickets merged in #346–#356; remaining shared gaps inventoried |
| 4. Webhooks and safety | Verify and parse signed events; manage webhook endpoints; retrieve safety alerts/cases and preserve monitoring details | All four specified tickets merged in #362–#365 |
| 5. Audio and Live | Generate speech with current voice/options; create custom voices; run a Live session and delegation workflows | Seven specified slices; speech first, bounded existing-audio fixes, consents/voices, Live HTTP/WS/forks |
| 6. Agents and vaults | Run a durable session; handle tools, environments, artifacts, credentials, subagents, traces, and browser approvals | Slice around working session behaviors; browser approvals build on the basic session/event loop |
| Throughout | Truthful API coverage, current examples, model capability guidance, and sunset notices | Accompany each relevant ticket; do not claim full coverage prematurely |
| 7. Administration and storage | Manage organization/project controls, keys, usage/costs, and external storage | Explicit expansion beyond the current manifest exclusions; specify the Admin namespace and authentication separately |
| 8. Authentication and remaining parity | Federation helpers, mTLS transport extensions, stored Chat management, and still-operational legacy gaps | Reuse or coordinate with existing issue #316 where relevant; prioritize by remaining API lifetime |

The user selected modern APIs/fixes with Decisions first and included complete
parity including Administration/legacy gaps. The recorded interpretation is a
complete-parity target delivered in that priority order. Retired endpoints cannot
be restored by a client: preserve relevant compatibility surfaces and migration
guidance, and implement remaining legacy endpoints only while the API supports
them. Recheck sunset status when drafting their tickets.

## Audit inventory and references

### Decisions

Implemented in [#318](https://github.com/davidmigloz/ai_clients_dart/issues/318):
resource, client accessor, public models and exports. The contract includes
restricted user text/inline-image input, predicate/choice/score questions, ordered
answers including refusal, distinct boolean/string choice values, fractional
scores, and cache-write usage. No model-event streaming is documented.

Sources: [guide](https://developers.openai.com/api/docs/guides/decisions),
[create reference](https://developers.openai.com/api/reference/resources/decisions/methods/create).

Publication-time [OpenAPI fd15e7a8](https://github.com/openai/openai-openapi/blob/fd15e7a8c492008db728bd079d936b7b7bf13e23/openapi.json)
on October 8 broadens DecisionInputImage.image_url from `^data:` to
`^(data:|https?://)`, allowing publicly accessible HTTP(S) images. The existing
client still enforces inline data URLs. A separate Decisions follow-up must align
constructors/parsers/copies, documentation and positive/negative fixtures with
this new contract; #318 remains the completed earlier snapshot, rather than
evidence of this later addition. File IDs and other unsupported input kinds remain
excluded.

The same commit adds optional nullable SafetyAlertResource.detailed_explanation:
a generated explanation temporarily available for eligible zero data retention
alerts and omitted when unavailable. This is a Safety alert field, despite the
commit message referring to decision responses. Preserve absence versus null,
copy/clear behavior and private diagnostics in a separate Safety follow-up.
Fresh toolkit fetch/review and immutable-source comparison confirm that these
eight normalized leaves do not affect the 287 Live/input components or seven
Live HTTP paths. Both additions remain pending inventory; the Live WebSocket
slice retains its adopted canonical bytes and metadata.

### Existing API correctness and Responses

- Merged in [#327](https://github.com/davidmigloz/ai_clients_dart/pull/327):
  shared Code Interpreter/container memory now emits `1g`, `4g`,
  `16g`, or `64g`, and allowlists emit `allowed_domains` with typed domain secrets.
- Merged in #327: standalone creation supports memory/network/
  skills configuration and responses preserve their supported returned settings.
- Merged in #329/#322: Responses cache controls gain
  `comparison_response_id`/`prewarm` and typed diagnostics; Chat gains narrow options. Shared Responses
  `cache_write_tokens` usage is implemented with Decisions in #318.
- Async function/custom definitions/calls, direct custom replay and conversation
  metadata merged in #334/PR #346.
- Configuration updates #335 merged in #347 with typed input/list-input/conversation
  contracts and an offline demonstration.
  Canonical OutputItem has no such variant or dedicated streaming event.
- Real Responses input-list mappings expose existing optional pagination ID
  tolerance against required upstream `first_id`/`last_id`; this stays in the
  remaining complete-parity inventory.
- Responses WebSocket transport #341 merged in #353. Typed steering #342 is
  merged after green CI in [PR #354](https://github.com/davidmigloz/ai_clients_dart/pull/354). Opt-in
  recovery #343 merged in #355; beta injection #344 is implemented, verified and
  merged after green CI in [PR #356](https://github.com/davidmigloz/ai_clients_dart/pull/356).
- Injection retains the legacy shared `Item` request codec: some generated input
  variants are unsupported, known extra fields may be trimmed and nested defaults/
  collection ownership remain legacy behavior. Full generated input-union parity
  remains in the inventory. Raw failed reporting and validated raw continuation
  preserve future JSON without claiming writable admission for arbitrary values.
- Hosted/local shell #337 merged in #349 with environment configuration,
  directional calls/results and five stream events.
- Compaction progress #338 merged in #350 with typed nonterminal decoding,
  migration guidance and deterministic public stream fixtures.
- Existing `CompactionTriggerItem` still omits the optional canonical trigger
  `id`. This DTO gap is outside the progress-event slice and stays in the parity
  inventory; raw history replay preserves provider IDs.
- Web search #336 merged in #348 with filters, access controls, return-token budget,
  image settings/results, action metadata and Includes.
- Responses access-program configuration #339 merged in #351 with distinct
  request/returned contracts and documented provider omission tolerance.
- Tool-search calls/results, discovered namespace definitions and stored input
  resource/conversation shapes #340 are implemented, verified and independently
  merged in #352. Writable calls require objects; returned calls
  retain arbitrary JSON and required nullable call IDs. Contextual definitions
  preserve dotted names and complete options without changing ordinary parser
  signatures. Targeted constructor and sealed-Item changes require migration.
- Returned discovered namespace parsing deliberately follows writable discovery
  shapes and SDK string typing, with loaded-tool continuation from the guide,
  despite the canonical ordinary namespace reference. Top-level functions retain
  canonical required-nullable parameters
  and strict keys. The older `apply_patch` branch is still missing from the
  ResponseTool union and remains an explicit complete-parity gap.
- Real GA/beta Responses parent mappings expose older request `user`, `prompt`
  and `conversation` gaps, plus returned safety identifier, top log probabilities,
  maximum tool calls, prompt/text/tool settings, completed time and conversation.
  These remain in the complete-parity inventory for later specification; current
  Dart fields retain their full contracts. Flattened-allOf mappings also surface
  existing type/requiredness choices and scanner limits for diagnostic helpers.
  [Phase 3](responses.md) specifies the current slices and the above gaps.
- Chat usage/obfuscation merged in #330/#323; complete/streamed audio is
  merged in #331/#324.
- Registering real Chat completion/message/delta mappings exposed older missing
  completion metadata, response annotations, and typed legacy function-call
  fields. These remain in the complete-parity inventory for later specification;
  audio finalization preserves legacy delta fields opaquely.
- Image generation/multipart model requiredness merged in #333/#326. JSON
  editing retains its distinct optional/nullable model contract.
- Existing JSON-edit copy/value/diagnostic conveniences remain a parity gap
  exposed by its real manifest mapping; multipart serialization is tested at the
  resource boundary rather than through invented JSON byte encodings.
- Shared usage model convenience methods and diagnostics also have existing
  limitations surfaced by the new manifest entries.
- Retry guidance merged in #332/#325: structured permanent quota failures stop
  replay, eligible waits honor the full server minimum, and error paths preserve
  precise retry metadata. Conservative verb/cloneability policy remains intact.

Sources: [cache diagnostics](https://developers.openai.com/api/docs/guides/prompt-caching/diagnostics),
[async tools](https://developers.openai.com/api/docs/guides/async-tool-calling),
[reasoning updates](https://developers.openai.com/api/docs/guides/reasoning#change-reasoning-mid-conversation),
[WebSockets](https://developers.openai.com/api/docs/guides/websocket-mode),
[steering](https://developers.openai.com/api/docs/guides/steering),
[web search](https://developers.openai.com/api/docs/guides/tools-web-search),
[shell](https://developers.openai.com/api/docs/guides/tools-shell),
[errors](https://developers.openai.com/api/docs/guides/error-codes).

- Earlier reviewed Node main `534e691da6979e75c17a14bc04f1daff81fdbeef` (still 7.30.0)
  adds structured-output parsing only for absent/null/final_answer message phases.
  Its WebSocket/recovery sources are unchanged. Dart has no equivalent Responses
  `outputParsed`/structured-output parser helper; this SDK convenience gap remains
  in the complete-parity inventory for the later shared-utilities phase.

### Missing API families and audio workflows

- Agents: 35 operations covering agents, environments, durable sessions,
  events, artifacts, items, subagents, turns, and traces. Browser use adds
  website approvals and authentication responses.
- Fresh OpenAPI 506aff0a changes pagination parameters on five Agents/Vault lists:
  agents, sessions, session artifacts, vaults and vault credentials. Supplied limits
  are nonnull integers 1–100 with default 20; parameter-order/description changes are
  also reviewed. No schemas or Phase 4 routes changed. Toolkit review missed the
  parameter delta; independent normalized comparison records it for Phase 6.
- A final October 8 check found newer [OpenAPI 35b0d4e](https://github.com/openai/openai-openapi/commit/35b0d4ebb841f2706e1c0aa31c7d47ecdd43c71d),
  published at 16:33:26 UTC. Five normalized additions concern Agents session
  spending control: optional nullable `spend_control` on create/update, optional
  returned control, and distinct closed request/resource components. Request
  `limit` is required nullable; positive limits are USD cents 1–4,503,599,627,370,495.
  Create omission/null is unlimited; update omission retains and null or a null limit removes the
  limit without resetting recorded spend. Returned `limit` is required nonnull;
  `consumed` is required nullable, nonnegative best-effort whole USD cents.
  Unlimited sessions omit returned control. These contracts join Phase 6 inventory.
  All Speech request/voice/event contracts remain unchanged; #366 keeps its
  reviewed 506aff0a canonical pin and does not implement the Agents additions.
- Vaults: ten credential/vault operations, including credential networking,
  environment-variable secrets, metadata, and rotation.
- Live: seven HTTP operations plus transport/event and delegation support.
- Safety: project alert/organization case retrieval is implemented/verified in
  #359; structured monitoring details are merged in #360/PR #365. Enterprise workspace alert notifications are
  included in its receiver, while api.chatgpt.com administrator-key lookup with
  chatgpt.enterprise.safety_alerts.read remains in Phase 7 administration inventory.
  No silent project-key routing or unsupported workspace-response guarantee.
- Video Error-2 headers/misalignment and shared inline-stream error/logging fidelity
  remain in media/shared-utility inventory; they do not define failed ResponseError.
- Python-only safety_identifier.blocked is absent from canonical/Node/unwrap unions;
  video event subscriptions lack typed inbound schemas. Phase 4 preserves those
  received values as unknown raw events until authoritative shapes are established.
- Webhooks: signed verification and 26 typed received events merged in #357/#362.
  Seven endpoint operations plus event-type discovery merged in #358/#363.
- Audio: the late October 8 [OpenAPI b2751c66](https://github.com/openai/openai-openapi/commit/b2751c6625493c9c64db21b1b26a4d9300e589e3)
  narrows VoiceResource.type to audio_sample, aligning with SDKs. This updates
  [merged custom voices #369](tickets/27-custom-voices.md); file-Audio/Chat
  closures were unchanged, and that bounded Audio implementation retained reviewed
  239c canonical before consent management adopted b275.
  Speech instructions and streaming, additional built-in/custom voices,
  sample-derived voice creation and consent management. The earlier
  [OpenAPI 3c4759c1](https://github.com/openai/openai-openapi/commit/3c4759c1ecc98a2ac3d3df85d54f4eb409f5957d)
  removes text-prompt creation and its request schema; no implemented Dart voice
  DTO is affected. This supersedes the initial prompt-derived candidate outcome.

Sources: [Agents](https://developers.openai.com/api/docs/guides/agents-api/overview),
[Agents computer use](https://developers.openai.com/api/docs/guides/agents-api/tools/computer-use),
[Live](https://developers.openai.com/api/docs/guides/live),
[safety monitoring](https://developers.openai.com/api/docs/guides/safety-checks/misalignment-monitoring),
[webhooks](https://developers.openai.com/api/docs/guides/webhooks),
[speech](https://developers.openai.com/api/docs/guides/text-to-speech).

### Administration, authentication, legacy, and documentation work

Administration is explicitly excluded by the current package manifest. The
selected complete-parity scope includes expanding coverage to spend limits/alerts,
model/tool permissions, data retention, key
expiry, usage/cost dimensions, and external storage. The reviewed October 8
[OpenAPI 239c481c](https://github.com/openai/openai-openapi/commit/239c481c5fd75052acb3e93cf72c15a7b4a45e74)
adds OCI external-storage request/response components and branches to three
provider unions. These five normalized additions remain Phase 7 inventory;
promoting the canonical source does not claim runtime OCI/Admin coverage. Federation acquisition and
renewal need authentication helpers; injected certificate-capable REST clients
already provide part of mTLS support. Regional domains are configurable today.

Remaining legacy gaps include stored Chat Completions management and still-live
fine-tuning pause/resume, grader, and checkpoint-permission operations. Give these
their own tickets and sunset checks rather than recreating already-retired APIs.

Build/Launch/Grow are server-managed organization usage tiers. They are distinct
from request `service_tier`; no new usage-tier client enum is needed.
`ServiceTier('ultrafast')` already works; a convenience constant/docs remain.
Text model IDs accept strings, so new GPT-6 identifiers need capability guidance
and examples rather than closed-enum updates.

Update Assistants shutdown guidance, upcoming Evals/fine-tuning/audio/model
sunsets, and inaccurate full-coverage statements. Existing Fast mode, Image 2.5,
modern transcription, GA Realtime calls/translations, moderation, programmatic
tools, Responses multi-agent, MCP tunnels, and corrected Evals cancellation
should not be reimplemented.

Sources: [Administration](https://developers.openai.com/api/docs/guides/admin-apis),
[federation](https://developers.openai.com/api/docs/guides/workload-identity-federation),
[mTLS](https://developers.openai.com/api/docs/guides/mutual-tls),
[usage tiers](https://developers.openai.com/api/docs/guides/rate-limits#usage-tiers),
[deprecations](https://developers.openai.com/api/docs/deprecations).

## Specification and ticket discipline

For each phase, settle the relevant scope/compatibility choices, then record
stable requirement IDs, observable behaviors, exclusions, source pins, and test
boundaries in a phase specification. Keep unresolved proposals visibly separate
from accepted decisions.

Each GitHub ticket should include:

1. A usable outcome and demonstration path.
2. Requirement IDs and links to the repository specification and official sources.
3. Explicit blockers and compatibility impact.
4. Acceptance criteria that fail before the change and can be checked independently.
5. Tests, documentation, manifest/export work, and completion evidence.

Prefer complete feature slices through models, resources, exports, examples, and
tests. Avoid tickets for all models, all resource methods, or all tests across
the effort. Split a large API around working user workflows, not source layers.

## Verification and review

Use public client methods with `MockClient`, exact wire fixtures, public stream
boundaries, and local HTTP/WebSocket servers. Local servers are unit tests. Live
integration tests require a separate explicit user request.

Follow the package's current architecture and dependency declarations. The core
spec's older dependency list does not accurately enumerate this package's
existing dependencies; do not remove them merely to satisfy that sentence.

Each implemented ticket receives two independent reviews: requirements against
its accepted specification, and engineering standards against repository/package
instructions. Verify reported findings against the actual diff, fix valid
findings, and record acceptance evidence before marking the ticket complete.
Review the final combined branch for interactions between tickets as well.

Run focused unit checks during implementation. At completion, run formatting,
automatic fixes, analysis, the package unit suite, and applicable toolkit checks.
Record unrelated known coverage gaps explicitly; do not suppress missing APIs to
make the report appear clean. Follow the OpenAPI skill's candidate promotion
workflow when an implementation adopts the reviewed specification.

## Workflow references

This adapts the requested principles; it does not install or invoke the external
skills, nor copy their automatic commit/release behavior.

- [Scope interview and documentation](https://www.aihero.dev/skills-grill-with-docs)
- [Written specifications](https://www.aihero.dev/skills-to-spec)
- [Feature tickets and blockers](https://www.aihero.dev/skills-to-tickets)
- [Implementation](https://www.aihero.dev/skills-implement)
- [Independent review](https://www.aihero.dev/skills-code-review)


WebSocket #341 [acceptance evidence](reviews/16-responses-websocket.md) records
persistent caller-owned connections, full lane/error envelopes, native/browser/
stub connectors, warm-up and continuation. Both client packages correct required
nullable annotation events with migration guidance. All package checks pass
(OpenAI 10,676 tests, sibling 506); JS/Wasm browser verification and the offline
four-frame example pass for $0. Independent requirements and engineering peer reviews approve the final
combined change; implementation [PR #353](https://github.com/davidmigloz/ai_clients_dart/pull/353)
merged after green CI, closing #341. Steering #342 merged after green CI in [PR #354](https://github.com/davidmigloz/ai_clients_dart/pull/354), closing #342.

Steering #342 [acceptance evidence](reviews/17-responses-steering.md) records
user-only text/image/file requests, all seven identifying pending stubs, full
accepted/pending/failed contracts and public continuation races with actual write
counts. Final package checks pass 11,158 tests/two existing skips; 484 new
model/browser protocol cases pass in both Chrome JavaScript and Wasm. The exact
README and migration After block compile; the offline six-frame example costs
$0. Independent requirements and engineering peer reviews approve the final
combined diff. Implementation [PR #354](https://github.com/davidmigloz/ai_clients_dart/pull/354) merged after green CI; recovery #343 is implemented, verified and independently reviewed.


Recovery #343 [acceptance evidence](reviews/18-websocket-recovery.md) records
explicit opt-in preparation/auth refresh, SDK close/timing policy, strict UTF-8
FIFO snapshots, nonterminal overflow, prompt cancellation and no attempted-frame
replay. All 104 new cases pass on VM and real Chrome JavaScript/Wasm; package
checks pass 11,262 tests/two existing skips with clean formatting/fix/analysis.
The exact README wrapper compiles and the offline four-write example costs $0.
Independent requirements and engineering reviews approve the combined diff.
Full toolkit diagnostic sets remain exactly unchanged; no exclusions were added.
Implementation [PR #355](https://github.com/davidmigloz/ai_clients_dart/pull/355) merged after green CI, closing #343. Beta injection #344 merged in PR #356.


Injection #344 [acceptance evidence](reviews/19-websocket-injection.md) records
beta tool-result submission and typed acknowledgment races, caller-owned tools,
raw failed reporting/explicit continuation, full value/copy contracts and no
automatic replay. All 11,448 package unit tests pass with two existing skips;
656 focused cases pass on VM and real Chrome JavaScript/Wasm. All 512 Dart files
format unchanged; fix/fatal-info analysis and the offline $0 example pass. Literal
README/migration snippets compile. Requirements and cross-author engineering
reviews approve the final diff. Toolkit diagnostics remain visible with a
classified delegated-serializer/value-scanner delta; no exclusions were added.
Implementation [PR #356](https://github.com/davidmigloz/ai_clients_dart/pull/356) merged October 8, 2026 at `1e63d6b93bdf0028eb6925d45371b1f36deb5d7b`, closing #344, after all applicable final-head checks passed (14 contexts completed: 13 successes and the standard Test(all) skip).
All eleven specified Phase 3 implementation tickets are merged. Phase 4 now has
its own specification/tickets, merged receiver #357 and endpoint management #358,
and merged safety retrieval #359; monitoring errors #360 are merged in PR #365. Remaining parity inventory persists.

## Live HTTP source refinement

Live HTTP ticket 28/#370 promotes reviewed
[OpenAPI f6f80b90](https://github.com/openai/openai-openapi/blob/f6f80b90bb96d74c22b05a68295af6e7359a48a6/openapi.json),
published October 8 at 20:44:03 UTC, with its actual fetch timestamp and immutable
source URL. The prior b275 metadata retains its original fetch receipt. Independent
normalized comparison finds 16 changed leaves: 14 added tool-choice components
and two backend tool_choice unions. The 13 tool input schemas and all seven Live
HTTP operations are unchanged. There are 356 operations and 2,027 schemas.

This pin replaces the planning enum-or-arbitrary-object tool selection with typed
scalar modes, 12 specific object choices and allowed_tools (1–128 specific choices).
Function, MCP and custom choices have declared fields; the other specific choices
are type-only open objects. The allowed set excludes namespace choices, scalar
entries and recursive allowed_tools. Preserve finite open extras without inventing
input tool configuration fields from these selection schemas. Python 8e1fd258
(3.26.1) and Node bc6c0bfb (7.30.1) runtime heads remain unchanged and their create
helpers remain narrower WebRTC-only. Canonical governs full WebRTC/SIP creation.

The current SIP guide still says 200 for outbound creation, while the canonical
contract and method reference specify 201 after initialization. The canonical
status is used. Request SIP credentials/SDP are distinct from receive-only SIP
metadata: the response declares only type:sip but its open object preserves any
finite future keys without exposing typed trunk credentials or SDP properties.
The documented outbound SIP request limit is 1 MiB of serialized UTF-8 JSON;
ticket 28 validates that exact aggregate body before dispatch. Ringing is limited
to three minutes and connected calls to two hours by the service, with no request
duration override or client timer. These SIP limits do not narrow WebRTC bodies
or the independent canonical backend tool configuration schemas.

## Late Agents environment inventory

The final October 8 source check found
[OpenAPI 978d0571](https://github.com/openai/openai-openapi/commit/978d0571e61ab2b18b80a84d17276f05403aace7),
published at 21:10:05 UTC: 358 operations and 2,035 schemas. Fifteen normalized
changes add GET/POST `/agents/environments`, eight component roots, two environment
lifecycle webhooks and hosted-environment reference/status refinements. All 100
Live closure components and every Live path are unchanged; SDK heads are unchanged.
The late candidate and its actual fetch receipt are retained separately. Ticket 28
keeps reviewed f6 canonical bytes and their original metadata.

Phase 6 must include owned-environment pagination (limit/order/after/type),
prewarming-beta access, explicit hosted configuration/template inheritance,
optional nullable vault IDs and the documented 24-hour scoped Idempotency-Key
creation contract. Model `CreateAgentEnvironmentParams`, its single hosted branch,
the list and event envelopes, environment reference exclusions and the new ready status.
Handle `agent.environment.ready` and `agent.environment.failed` as typed lifecycle
notifications during that slice, with caller-selected environment lookup/action.
They currently remain receive-only unknown webhook values in this package; the
existing 26 typed webhook branches retain their reviewed f6 source claims.

## Live WebSocket source review

The next Live slice rechecks immutable
[OpenAPI c7224137](https://github.com/openai/openai-openapi/blob/c72241375fbe33a7192f5660b173e541b56e4b2f/openapi.json),
published October 8 at 21:46:20 UTC (358 operations, 2,035 schemas). A fresh
candidate and its actual fetch receipt remain separate from the adopted f6 pin.
All 287 components reachable from primary/sideband/fork client and server unions
and InputItem, plus all seven Live HTTP path objects, are unchanged. Canonical f6
bytes and original metadata are preserved. The comparison records 27 differing
normalized paths, including shifted enum indices; these are Agents environment
additions already inventoried above. The later refinement adds
`agent.environment.ready` and `agent.environment.failed` to ProjectEventTypeEnum.
Typed lifecycle events and endpoint discovery remain Phase 6 work; unknown
received events remain passively preserved meanwhile.

Python 8e1fd258 (3.26.1) and Node bc6c0bfb (7.30.1) remain unchanged. Canonical
LiveServerEvent resolves through its allOf alias to the full 22-event union;
canonical sideband declares 18, SDK sideband 15. Shared received codecs admit the
full union with documented reflected audio/DTMF/progress delivery and directional
constraints. SDK automatic reconnection/queue helpers remain inventory entries;
this slice deliberately exposes application-controlled connections without replay.

The existing Responses Item helper covers a narrower set of backend input
contracts. Live's source-derived adapters retain the complete canonical InputItem
union and its typed reachable payloads independently, including optional/null
fields and omitted easy-message/reference discriminators. Existing Item/OutputItem
conversion detaches their serialized values only when the canonical contract fits.
This does not claim wider standalone Responses/legacy parity outside the slice.
