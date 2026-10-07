# OpenAI API alignment

Planning started October 7, 2026. Status: Decisions and container configuration
merged; Phase 2 is specified and ticketed, with cache retention implemented and reviewed.

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
| [#321](https://github.com/davidmigloz/ai_clients_dart/issues/321) | Emit the canonical cache-retention wire value | None; implemented and reviewed |
| [#322](https://github.com/davidmigloz/ai_clients_dart/issues/322) | Configure cache controls and inspect diagnostics | #321 |
| [#323](https://github.com/davidmigloz/ai_clients_dart/issues/323) | Preserve Chat token details and stream obfuscation | None |
| [#324](https://github.com/davidmigloz/ai_clients_dart/issues/324) | Preserve complete and streamed Chat audio | None |
| [#325](https://github.com/davidmigloz/ai_clients_dart/issues/325) | Honor retry hints and stop replaying permanent quota failures | None |
| [#326](https://github.com/davidmigloz/ai_clients_dart/issues/326) | Require explicit model selection where the image API requires it | None |

Container [acceptance evidence and independent reviews](reviews/02-container-configuration.md)
record the 1,841 passing unit tests, clean analysis, bounded live lifecycle, resolved
findings, migration, and deliberately visible toolkit diagnostics.
Container [PR #327](https://github.com/davidmigloz/ai_clients_dart/pull/327) merged
after all CI checks passed, closing #320.

Cache-retention [acceptance evidence and independent reviews](reviews/03-cache-retention.md)
record 1,872 passing unit tests, clean analysis, canonical/legacy compatibility,
public request/response fixtures, and the separate Chat equality correction
required by #322.

## Proposed roadmap

This is a candidate dependency map, not an accepted implementation spec. Keep
all audited gaps visible even when they are deferred from a milestone.

| Phase | Demonstrable outcomes | Dependencies and scope notes |
| --- | --- | --- |
| 1. Decisions | Create typed decisions from text and inline images; receive predicate, choice, score, and refusal answers with complete usage | Implemented and reviewed in #318; does not require Agents or Live |
| 2. Existing API correctness | Correct container wire formats; preserve cache diagnostics, token details, Chat audio chunks, and retry guidance | Mostly independent changes; the shared cache-write counter is already included in Decisions |
| 3. Responses capabilities | Use async tools, reasoning configuration updates, GA web search controls/results, hosted shell, and Responses WebSocket steering | Establish transport behavior before steering; complete shared container configuration before dependent shell changes |
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
- Request cache options omit `comparison_response_id` and `prewarm`; response
  options/diagnostics omit related metadata. Shared Responses
  `cache_write_tokens` usage is implemented with Decisions in #318.
- Function/custom definitions and call items omit `async`.
- Input/output parsers do not support `configuration_update`.
- Responses WebSocket transport and steering are absent.
- Hosted shell environment configuration, item metadata, and stream events
  are incomplete; compaction progress also needs alignment.
- Web search lacks newer filters, access controls, return-token budget, image
  settings/results, action metadata, and corresponding include values.
- Responses access-program configuration and tool-search output definitions
  need alignment.
- Chat streaming omits audio chunks and obfuscation controls; detailed usage
  omits additional token counts.
- Review the required image-generation model field against the existing nullable
  client field/default behavior. Shared usage model convenience methods and
  diagnostics also have existing limitations surfaced by the new manifest entries.
- Retry decisions treat all 429s as transient, cap server delays, and do not
  expose Retry-After guidance consistently for overload errors. Preserve the
  repository's deliberate conservative treatment of non-idempotent requests
  unless a documented decision changes it.

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
