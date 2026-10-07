# OpenAI API alignment

Planning started October 7, 2026. Status: Decisions, container configuration,
cache retention, cache controls/diagnostics, and Chat usage/obfuscation merged.
Chat audio merged in [PR #331](https://github.com/davidmigloz/ai_clients_dart/pull/331).
Retry guidance merged in [PR #332](https://github.com/davidmigloz/ai_clients_dart/pull/332);
image model requiredness #326 merged in [PR #333](https://github.com/davidmigloz/ai_clients_dart/pull/333).

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
Its implementation PR is pending creation.

| Ticket | Demonstrable outcome | Dependency |
| --- | --- | --- |
| [#334](https://github.com/davidmigloz/ai_clients_dart/issues/334) ([09](tickets/09-async-tools.md)) | Async function/custom calls and faithful replay | Merged in #346 |
| [#335](https://github.com/davidmigloz/ai_clients_dart/issues/335) ([10](tickets/10-configuration-updates.md)) | Persistent reasoning effort updates | Merged in #347 |
| [#336](https://github.com/davidmigloz/ai_clients_dart/issues/336) ([11](tickets/11-web-search.md)) | GA web-search controls/actions/image results | Merged in #348 |
| [#337](https://github.com/davidmigloz/ai_clients_dart/issues/337) ([12](tickets/12-hosted-shell.md)) | Hosted/local shell configuration, replay and streams | Merged in #349 (#320 merged) |
| [#338](https://github.com/davidmigloz/ai_clients_dart/issues/338) ([13](tickets/13-compaction-progress.md)) | Typed compaction progress | Implemented/reviewed; PR pending |
| [#339](https://github.com/davidmigloz/ai_clients_dart/issues/339) ([14](tickets/14-access-programs.md)) | Select/inspect effective access program | None |
| [#340](https://github.com/davidmigloz/ai_clients_dart/issues/340) ([15](tickets/15-tool-search.md)) | Complete client-discovered tools | [#334](https://github.com/davidmigloz/ai_clients_dart/issues/334) async definitions |
| [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341) ([16](tickets/16-responses-websocket.md)) | Persistent WS sessions, envelopes and named lanes | None; shared shell/compaction events follow their tickets |
| [#342](https://github.com/davidmigloz/ai_clients_dart/issues/342) ([17](tickets/17-responses-steering.md)) | Safe mid-turn steering and continuation | [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341) |
| [#343](https://github.com/davidmigloz/ai_clients_dart/issues/343) ([18](tickets/18-websocket-recovery.md)) | Opt-in reconnect and bounded unsent queue | [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341)/[#342](https://github.com/davidmigloz/ai_clients_dart/issues/342) |
| [#344](https://github.com/davidmigloz/ai_clients_dart/issues/344) ([19](tickets/19-websocket-injection.md)) | Beta multi-agent tool-result injection | [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341) |

Async tools, configuration updates, web search and shell are merged. Complete
compaction progress PR review and merge, then continue with access programs
[#339](https://github.com/davidmigloz/ai_clients_dart/issues/339). Recovery
and injection remain explicit follow-ups to basic transport; do not claim full
WebSocket SDK parity before they are complete. Each ticket includes an offline
example, public fixtures, documentation and independent review. All eleven tickets are native sub-issues of #317; active blockers are linked
with GitHub dependencies. Compaction progress [#338](https://github.com/davidmigloz/ai_clients_dart/issues/338)
is the current implementation slice following merged hosted/local shell #337.

## Remaining roadmap

Phases 1–2 are complete and Phase 3 has its own specification/tickets above.
Later phases remain candidate outcomes pending detailed specifications. Keep
all audited gaps visible even when deferred.

| Phase | Demonstrable outcomes | Dependencies and scope notes |
| --- | --- | --- |
| 1. Decisions | Create typed decisions from text and inline images; receive predicate, choice, score, and refusal answers with complete usage | Merged in #319/#318 |
| 2. Existing API correctness | Correct container wire formats; preserve cache diagnostics, token details, Chat audio chunks, and retry guidance | All tickets merged in #327–#333; shared cache-write usage included in Decisions |
| 3. Responses capabilities | Use async tools, reasoning configuration updates, GA web search controls/results, hosted shell, and Responses WebSocket steering | Specified above; transport precedes steering/recovery/injection, container dependency merged |
| 4. Webhooks and safety | Verify and parse signed events; manage webhook endpoints; retrieve safety alerts/cases and preserve monitoring details | Event parsing/verification is independently useful; supports later Agents and Live workflows |
| 5. Audio and Live | Generate speech with current voice/options; create custom voices; run a Live session and delegation workflows | Separate ordinary speech from Live; prompt-derived voice usage depends on Live |
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
- Responses WebSocket transport/steering and official opt-in reconnect helpers
  are absent; exported beta injection DTOs still need transport integration.
- Hosted/local shell #337 merged in #349 with environment configuration,
  directional calls/results and five stream events.
- Compaction progress #338 implements typed `response.compaction.compacting`
  decoding with required sequence/output/item metadata and optional beta agent;
  final validation and independent reviews remain pending.
- Existing `CompactionTriggerItem` still omits the optional canonical trigger
  `id`. This DTO gap is outside the progress-event slice and stays in the parity
  inventory; raw history replay preserves provider IDs.
- Web search #336 merged in #348 with filters, access controls, return-token budget,
  image settings/results, action metadata and Includes.
- Responses access-program configuration and tool-search output definitions
  need alignment. [Phase 3](responses.md) specifies these and the above gaps.
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

### Missing API families and audio workflows

- Agents: 35 operations covering agents, environments, durable sessions,
  events, artifacts, items, subagents, turns, and traces. Browser use adds
  website approvals and authentication responses.
- Vaults: ten credential/vault operations, including credential networking,
  environment-variable secrets, metadata, and rotation.
- Live: seven HTTP operations plus transport/event and delegation support.
- Safety: alert/case retrieval and structured monitoring details.
- Webhooks: seven endpoint operations, event-type listing, typed events, and
  signature verification.
- Audio: speech instructions and streaming, additional built-in/custom voices,
  sample-derived and prompt-derived voice creation, and consent management.

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
expiry, usage/cost dimensions, and external storage. Federation acquisition and
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
