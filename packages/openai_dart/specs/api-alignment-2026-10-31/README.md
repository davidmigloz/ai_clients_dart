# OpenAI API alignment — October 31, 2026

Tracking parent: [#413](https://github.com/davidmigloz/ai_clients_dart/issues/413).
Final closure: [#427](tickets/14-docs-verification.md) and its
[verification receipt](reviews/14-docs-verification.md).

The feature and carry-over implementations for this fixed round are complete.
The closure ticket records the promoted source, integrated validation, remaining
coverage limits and parent closeout. Completed parent #317 stays closed. New
upstream releases do not grow this scope; HTTP/2 #408 remains a separate gated
follow-up. Version selection, release preparation and publication require later
user approval and are not part of this round.

## Frozen source and accounting

The starting package was openai_dart 11.0.1 at
`d95c9ef8ee990ce654c647bbb08c60f804a8a519`, with the October 9 canonical source
`0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9`. The reviewed October source is now
promoted into the canonical specification and source metadata:

- [Official changelog](https://developers.openai.com/api/docs/changelog), reviewed at the October 31 cutoff.
- [OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json): 376 operations and 2,206 schemas.
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/CHANGELOG.md), commit `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`.
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/CHANGELOG.md), commit `c717857c3151bde92e07e4d396301a9c67163e68`.

The fixed comparison contains 18 added operations, no removed operations, two
toolkit-normalized modified operations, and 170 added/124 modified/three removed
schemas. These include documentation and metadata changes, rather than 297
implementation defects. The [inventory](inventory.json) gives every delta its
primary owner, source hash and explicit disposition. The
[closure manifest](reviews/14-docs-verification-manifest.json) links real component
bindings, contextual representations and implementation receipts. Raw-source and
normalized checked-in JSON hashes are distinguished in the verification receipt.

Wire schemas govern fields and direction, guides govern workflows and
availability, and SDK code establishes helper behavior. Per-feature receipts
record disagreements and deliberate Dart policies. Advisory toolkit findings
include historical gaps and scanner limitations; their final classification is
recorded in the closure receipt, without claiming complete historical API/SDK
parity or suppressing unknown gaps.

## Implementation evidence

The original dependency order is retained below. These are implementation and
review references, not an automatically expanding backlog. Detailed tickets
remain requirements snapshots; this table, feature receipts and the final
verification receipt establish current completion status.

| Ticket | Capability | Implementation PR | Original dependency |
| --- | --- | --- | --- |
| [#414](tickets/01-decisions-ga.md) | Decisions GA inputs, history and caching | [#435](https://github.com/davidmigloz/ai_clients_dart/pull/435) | None |
| [#415](tickets/02-responses-cache-usage.md) | Responses cache lifetime, hosted-tool usage and errors | [#440](https://github.com/davidmigloz/ai_clients_dart/pull/440), [#464](https://github.com/davidmigloz/ai_clients_dart/pull/464) | None |
| [#416](tickets/03-responses-websocket-workflows.md) | Responses WebSocket warm-up and bounded results | [#442](https://github.com/davidmigloz/ai_clients_dart/pull/442) | None |
| [#417](tickets/04-websocket-recovery.md) | Explicit WebSocket recovery without attempted-work replay | [#446](https://github.com/davidmigloz/ai_clients_dart/pull/446) | None |
| [#418](tickets/05-custom-voices.md) | Prompt-created voices and saved-voice deletion | [#448](https://github.com/davidmigloz/ai_clients_dart/pull/448) | None |
| [#419](tickets/06-live-decisions.md) | Live Decisions delegation, triggers and shared items | [#449](https://github.com/davidmigloz/ai_clients_dart/pull/449) | #414 |
| [#420](tickets/07-live-media.md) | Live audio fixtures and SIP DTMF delivery | [#450](https://github.com/davidmigloz/ai_clients_dart/pull/450) | None |
| [#421](tickets/08-realtime-audio.md) | Realtime input/noise controls and Translation WebSockets | [#452](https://github.com/davidmigloz/ai_clients_dart/pull/452) | None |
| [#422](tickets/09-agent-settings.md) | Agent/session context, review and ultrafast settings | [#453](https://github.com/davidmigloz/ai_clients_dart/pull/453) | None |
| [#423](tickets/10-agent-automations.md) | Agent automations and invocations | [#454](https://github.com/davidmigloz/ai_clients_dart/pull/454) | #422 |
| [#424](tickets/11-image-contracts.md) | Image safety, markup and typed tool failures | [#458](https://github.com/davidmigloz/ai_clients_dart/pull/458), [#462](https://github.com/davidmigloz/ai_clients_dart/pull/462) | None |
| [#425](tickets/12-vertex-residency.md) | Vertex Responses and named regional routing | [#460](https://github.com/davidmigloz/ai_clients_dart/pull/460) | #316 |
| [#426](tickets/13-admin-delta.md) | Isolated Admin keys, Decisions usage and external storage | [#457](https://github.com/davidmigloz/ai_clients_dart/pull/457) | None |
| [#392](../api-alignment/tickets/40-environment-webhooks.md) | Typed environment lifecycle webhooks/subscriptions | [#456](https://github.com/davidmigloz/ai_clients_dart/pull/456) | Existing raw webhook/environment APIs |
| [#393](../api-alignment/tickets/41-browser-recovery.md) | Explicit browser responses and current-state recovery | [#459](https://github.com/davidmigloz/ai_clients_dart/pull/459) | Agent settings and existing raw inputs |
| [#394](../api-alignment/tickets/42-idle-run-helper.md) | Lazy idle-session observation and controlled cursor | [#463](https://github.com/davidmigloz/ai_clients_dart/pull/463) | Agent settings |
| [#395](../api-alignment/tickets/43-local-dispatch.md) | Opt-in sequential local function dispatch | [#465](https://github.com/davidmigloz/ai_clients_dart/pull/465) | #394 |
| [#396](../api-alignment/tickets/44-result-parser.md) | Completed results and local output validation | [#466](https://github.com/davidmigloz/ai_clients_dart/pull/466) | #394, #395 |
| [#397](../api-alignment/tickets/45-file-helpers.md) | Portable selected files/artifacts and optional IO | [#467](https://github.com/davidmigloz/ai_clients_dart/pull/467) | #396 and existing raw files/artifacts |
| [#316](https://github.com/davidmigloz/ai_clients_dart/issues/316) | Immutable runtime configuration generations | [#455](https://github.com/davidmigloz/ai_clients_dart/pull/455) | Independent; used by #425 |
| [#246](https://github.com/davidmigloz/ai_clients_dart/issues/246) | Toolkit enum completeness and managed-package checks | [#461](https://github.com/davidmigloz/ai_clients_dart/pull/461), [#468](https://github.com/davidmigloz/ai_clients_dart/pull/468) | Shared verification infrastructure |

[#427](tickets/14-docs-verification.md) closes the round after all rows above and
its own integrated review/CI gate. Supporting merged corrections include computer
input (#430), image option types (#436), streaming cancellation (#439), native MCP
output (#443), reasoning replay (#444) and named custom choices (#451). Their
compatibility guidance is included in [MIGRATION.md](../../MIGRATION.md).

## Resolved distinctions and retained behavior

- Responses per-breakpoint `30m`/`12h` controls remain distinct from the top-level
  `PromptCacheTTLEnum` and Decisions contexts that permit only `30m` in this pin.
  Live cache contexts retain their own source-defined rules.
- Decisions supports the pinned text/image/JSON question union and up to 400
  questions; Live's corresponding question/context limits remain separate.
- Agent request validation now accepts ultrafast. Removed session spend-control
  fields have migration guidance, while review/context
  controls retain their separate semantics. Canonical wire requirements govern
  the SDK discrepancies recorded in the feature receipt.
- Existing environment creation supplies prewarming. Hosted Artifact SDK/skills
  availability is a server-image feature, independent of the new portable file
  helpers and without a duplicate prewarming endpoint.
- Model IDs remain strings. GPT-6.1 Terra/Rosalind access, credits and project
  controls do not create client-side entitlements. Build/Launch/Grow are account
  usage tiers, distinct from request service-tier values.
- Raw APIs remain available alongside opt-in workflow helpers. Observer closure,
  backend session cancellation and environment/artifact lifetimes remain distinct;
  helpers do not automatically replay actions or credentials.

## Closure evidence and remaining boundaries

The [verification receipt](reviews/14-docs-verification.md) is the authoritative
record of final source promotion, assigned-diagnostic classification, integrated
unit/browser/package/toolkit checks and remaining limits. The
[original planning validation](planning-validation.json) and
[GitHub relationship ledger](relationships.json) preserve discovery counts,
23 original children, 30 dependency links and the original acyclic plan; their
planning-time unchecked acceptance/state is historical evidence.

Consumer documentation keeps common Responses calls first and Usage topics
collapsible, with runnable examples and concise feature guidance. Shared changes
are checked against open_responses and the other managed toolkit packages.
Retired/read-only example entrypoints carry offline notices; preserved legacy
APIs do not guarantee current availability. Evals' November 30 shutdown and other
model/API sunsets remain documented against official deprecation guidance.
Validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures rather than
a full live integration suite or billable API calls.

The Admin delivery is the bounded 12-operation slice: seven new operations plus
five existing external-storage prerequisites. The named project-residency and
older completion-usage exclusions, and historical stored Chat CRUD,
fine-tuning/graders/checkpoint helpers, federation/mTLS acquisition and broad
provider/tool runners remain explicit exclusions. This round does not resurrect
shut-down Assistants APIs, expand Evals or create new alignment tickets.

[HTTP/2 #408](https://github.com/davidmigloz/ai_clients_dart/issues/408) remains the
separately gated adoption follow-up to the earlier evaluation. Its upstream
blockers and compatibility must be revalidated before any future implementation;
it can remain open without blocking #413 closure. No transport dependency change,
automatic follow-on work, version bump or publication is implied.
