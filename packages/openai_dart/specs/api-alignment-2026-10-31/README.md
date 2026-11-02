# OpenAI API alignment — October 31, 2026

Tracking parent: #413.

This is a new, fixed round after completed issue #317. The user requested new
API/official-SDK alignment and carrying forward all remaining open issues before
implementation. Planning is complete when the parent, capability tickets and
existing-issue links are published; no runtime implementation is part of this PR.

The finish line is the 14 capability/closure tickets below and the eight active
carry-over/supporting issues. HTTP/2 #408 is included as a gated follow-up and can
remain open when this round closes. New upstream releases do not grow this list.
The old parent stays closed; issue numbers, discussions and unchecked acceptance
criteria are preserved for carried work.

## Evidence and source authority

Baseline: openai_dart 11.0.1 at `d95c9ef8ee990ce654c647bbb08c60f804a8a519`. Canonical OpenAPI is
`0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9` (October 9).

- [Official changelog](https://developers.openai.com/api/docs/changelog), checked October 31.
- [Pinned OpenAPI](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json), October 30: 376 operations and 2,206 schemas.
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/CHANGELOG.md), October 31.
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/CHANGELOG.md), October 31.

The global comparison has 18 added operations, no removed operations, and two
toolkit-normalized modified operations (session metadata filter and voice JSON
creation). There are 170 added, 124 modified and three removed schemas. These
counts include descriptions/metadata; they are not 297 implementation defects.
The [inventory](inventory.json) assigns every schema delta and all 18 operations
to one primary ticket. Shared event-union roots can also be touched by adjacent
tickets, whose tests must preserve each other's variants.

The toolkit fetch/review was run against a candidate in /tmp. Its JSON equals the
pinned OpenAPI source; byte hashes differ because toolkit fetch normalizes JSON.
Review reports 665 errors, 76 warnings and 183 missing manifest entries. These
are discovery diagnostics across the configured coverage, not a clean verification
claim or a count of new bugs. This planning change does not promote the candidate.

Wire schemas establish fields and direction; official guides establish workflows
and availability; SDK source establishes helper semantics. Pinned sources can
disagree. Record the disagreement and deliberately resolve it per ticket rather
than mechanically copying SDK internals into Dart.

## Ordered work

Start with Decisions GA, then Responses cache/usage and WebSocket workflows.
Voices, image and audio/media tickets are independent. Update Agent settings
before automations and the dependent carried helper workflows. Finish providers,
the bounded Admin slice, and the final source/docs verification.

| Ticket | Outcome | Dependencies |
| --- | --- | --- |
| [#414 01-decisions-ga](tickets/01-decisions-ga.md) | Evaluate structured evidence and conversation/tool history with the generally available Decisions API, including up to 400 questions. | None. |
| [#415 02-responses-cache-usage](tickets/02-responses-cache-usage.md) | Control each Responses cache breakpoint lifetime and inspect billable hosted-tool usage and error diagnostics. | None. |
| [#416 03-responses-websocket-workflows](tickets/03-responses-websocket-workflows.md) | Warm up a Responses connection, change output formats mid-session, and consume bounded per-lane final results. | None. |
| [#417 04-websocket-recovery](tickets/04-websocket-recovery.md) | Recover supported WebSocket connections explicitly and report uncertain or unsent delivery without replaying attempted work. | None. |
| [#418 05-custom-voices](tickets/05-custom-voices.md) | Create a saved voice from a text description, inspect its metadata, and explicitly delete it. | None. |
| [#419 06-live-decisions](tickets/06-live-decisions.md) | Delegate from Live to Decisions, evaluate transcript triggers, and manage shared decision items. | #414 |
| [#420 07-live-media](tickets/07-live-media.md) | Play a bounded audio fixture and distinguish SIP DTMF commands from delivery notifications. | None. |
| [#421 08-realtime-audio](tickets/08-realtime-audio.md) | Use current Realtime input references/noise controls and the official Translation WebSocket flow. | None. |
| [#422 09-agent-settings](tickets/09-agent-settings.md) | Configure current Agent/session context and review behavior, and use ultrafast requests successfully. | None. |
| [#423 10-agent-automations](tickets/10-agent-automations.md) | Create, pause, resume and inspect scheduled Agent work and its invocations. | #422 |
| [#424 11-image-contracts](tickets/11-image-contracts.md) | Attach image safety identifiers, inspect tool moderation errors, and guide edits with markup overlays. | None. |
| [#425 12-vertex-residency](tickets/12-vertex-residency.md) | Route Responses through Vertex using request-scoped Google credentials and current regional endpoints. | #316 |
| [#426 13-admin-delta](tickets/13-admin-delta.md) | Use the new Admin key/Decisions-usage operations and inspect current external-storage providers/statuses. | None. |
| [#427 14-docs-verification](tickets/14-docs-verification.md) | Finish this fixed round with accurate API coverage, current examples, source receipts and explicit remaining limits. | #414, #415, #416, #417, #418, #419, #420, #421, #422, #423, #424, #425, #426, #392, #393, #394, #395, #396, #397, #316, #246 |

## Existing issues carried forward

| Issue | Role | Ordering |
| --- | --- | --- |
| #392 Environment lifecycle webhooks | Active; preserve four typed lifecycle deliveries/subscriptions | Existing raw dependencies already merged |
| #393 Browser approvals/recovery | Active; explicit current-state recovery without replay | Agent settings, then existing raw inputs |
| #394 Idle Agent session observation | Active; opt-in bounded run handle | Agent settings |
| #395 Local Agent function dispatch | Active; manual path preserved | #394 |
| #396 Completed Agent results/parsing | Active; parser metadata stays local | #394, #395 |
| #397 Agent file/artifact helpers | Active; portable core, optional filesystem adapter | #396 |
| #316 Runtime configuration | Active; retained resource references/concurrency/auth need design and fixtures | Independent; coordinate with provider ticket |
| #246 Toolkit enum verification | Supporting active issue; cross-package compatibility required | Independent; used by closure verification |
| #408 Optional HTTP/2 adoption | Gated follow-up, existing blockers must be revalidated | Do not assume upstream blockers are fixed; can stay deferred |

The six formerly deferred Agent tickets retain their detailed repository specs
and acceptance criteria, with current-source revalidation required before code.
Their old text about not starting automatically is superseded by this new user
request and parent; #408 retains its explicit compatibility gate. The global
issue search found exactly these nine open repository issues, so none is copied
or lost. #246 is shared infrastructure and stays separately identified.

## Source disagreements and already supported behavior

- Responses breakpoint TTL accepts `30m`/`12h` in the pin. The changelog/guide
  advertise 12-hour caching, while top-level `PromptCacheTTLEnum` and SDK request
  options still permit only `30m`. Ticket 02 must document/resolve this distinction;
  Decisions only permits `30m` in this snapshot.
- Decisions question-part schemas and both SDKs include JSON as well as images;
  the GA guide emphasizes text/images. Ticket 01 uses the broader pinned union.
- Agent receive service tiers already include ultrafast, but request validators
  reject it. This is a request-path correction in ticket 09. Generic Responses
  service-tier value classes already accept future strings.
- Existing environment create/list operations already provide prewarming; the
  October 9 announcement does not require duplicate resource methods. Hosted
  Artifact SDK/skills availability is a server-image/documentation update.
- Model IDs are strings. GPT-6.1 Terra and restricted Rosalind guidance belongs
  in docs, not an invented closed model enum. Credits and project service-tier
  settings do not create SDK endpoints. Build/Launch/Grow are account usage tiers.
- Existing Responses recovery, voice consent CRUD and prior image/Safety changes
  are retained. SDK release notes can lag the existing Dart implementation; each
  ticket audits actual behavior before adding duplicate helpers.

## Boundaries and acceptance

Each implementation needs public-path deterministic fixtures, appropriate Dart
quality checks, exports, a runnable example, concise collapsible README/llms
updates and targeted migration guidance. Changes to shared models must check
open_responses; shared toolkit changes must check the other managed packages.
Use the existing review checklist and record engineering/requirements review.
Default tests incur no API cost; do not run the full live integration suite.

The final ticket owns canonical spec promotion, manifest and source metadata,
cross-ticket verification and current sunset/coverage guidance. Individual feature
tickets still own their examples and documentation. A release is a later task.

Historical un-ticketed full Admin/legacy/authentication parity is not automatically
reopened. The Admin ticket explicitly includes 12 operations (seven new and five
external-storage prerequisites), and preserves other exclusions. Stored Chat CRUD,
remaining fine-tuning/graders/checkpoint helpers, federation/mTLS acquisition,
general-purpose Responses/Decisions/browser/computer tool runners and other
historical SDK conveniences remain named deferred inventory from the old roadmap.
No resurrecting shut-down Assistants APIs or expanding Evals ahead of its
November 30 shutdown. No additional tickets without a user-requested scope change.

## Planning validation

The [validation receipt](planning-validation.json) checks schema/operation accounting,
SDK source paths, official guide links, local Markdown links and an acyclic dependency
graph. [GitHub relationships](relationships.json) records all 23 attached children
and 30 dependency links. All implementation acceptance remains unchecked.
