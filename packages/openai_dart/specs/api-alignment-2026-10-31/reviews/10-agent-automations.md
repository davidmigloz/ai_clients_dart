# Agent automations and invocation delivery

Issue #423; parent #413. Reviewed November 4, 2026 against the fixed October 31
source cutoff. The scope remains the assigned ten operations and 35 schemas.

## Authority and accounting

- OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`.
- Python 3.42.0, `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`.
- Node 7.47.0, `c717857c3151bde92e07e4d396301a9c67163e68`.
- The adjacent manifest maps all 35 assigned schemas, all ten operations and the
  two contextual inline cursor pages. It records twelve SDK source hashes and
  the official automation guide recheck. Four automations tool leaves were
  already implemented as #422 prerequisites and are reused without duplicates.

Canonical schemas govern field direction and presence; the guide establishes
workflow and the SDKs corroborate routing and helper behavior. The guide recheck
does not expand the frozen API scope. Canonical/global manifest promotion remains
#427; no new exclusion or suppression is introduced here.

## Requests and schedules

`CreateAgentAutomationRequest.once` saves a future Unix timestamp in seconds;
`.periodic` saves a five-field cron expression and IANA timezone. Fixed type tags
are getters. Names, strings, metadata and collection bounds follow the canonical
request schemas. No local wall-clock, cron parser, timezone database or scheduler
shadows service validation. Creation and update only submit saved configuration.

`UpdateAgentAutomationRequest` has no type/status/provenance fields. All supplied
fields are nonnull; omission retains current values, supplied target and metadata
replace the complete field, and an empty metadata map clears it. Timing must match
the stored schedule kind; target type, creator binding and whether a one-time
scheduled invocation already exists depend on server state. No hidden GET or
manual invocation is used to infer that state.

Request targets are separate from received snapshots. Existing-session targets
carry a session ID and instructions. New-session targets select exactly one
inline agent or saved agent ID and reuse the existing session-agent/environment
request leaves. Their input is a required message array, not the ordinary session
creation string shorthand. They expose no unrelated review/stream fields.
Nested target metadata/vault IDs preserve absent, explicit null and empty values;
top-level automation metadata is optional nonnull.

Two documented source ambiguities are deliberate:

- The prose requires exactly one agent selection, although the generated schema
  required-list cannot express it and SDK structural tests omit both. The target
  enforces the documented selection rule. It does not invent an inline model
  requirement beyond the reusable canonical session-agent configuration schema.
- Canonical target/message arrays allow zero items. The guide asks applications
  to supply at least one message with nonempty text or an image URL for useful
  scheduled work. The parser retains the canonical shape bounds; examples supply
  meaningful input and do not claim that empty input is service-usable.

## Received resources and ownership

One-time and periodic schedules have distinct typed statuses; exact future strings
remain readable. Their common status interface supports inspection without
assigning known semantics to future schedule kinds. Stored provenance distinguishes
developer/API creation from Agent tool creation, independently of schedule type.

Saved targets preserve required nullable agent/agent-ID fields and use a distinct
inline Agent configuration with no fabricated session-local identity. Saved
environment selection differs from a provisioned session environment: hosted
references and overrides are required nullable keys; self-hosted selection has a
required nullable environment reference. Existing credential-safe resource leaves
are reused, including template skill/file views rather than active-session aliases.
The stored message wrapper implements `InputMessageResource-2`, with required
message/user tags and the received 2,000-element bound, separately from requests.

Python accepts missing keys for several required nullable fields; canonical and
Node require their presence. Dart follows canonical for stored targets,
environment overrides, inline instructions and invocation nullable fields. Optional
nonnull compaction/experimental fields reject explicit null. No request default or
received status/skip reason is synthesized.

New models inherit complete effective-JSON equality/hash/private diagnostics.
Collections and finite future JSON are deeply owned, known typed fields cannot be
shadowed, copies revalidate and nullable copies distinguish omission from explicit
null. Unknown receive unions retain exact JSON and do not become writable requests.
Future common fields fail contextually when absent instead of inventing facts.

## HTTP and lifecycle

`client.agents.automations` exposes create/list/retrieve/update/delete/pause/resume;
its cached `invocations` resource exposes create/list/retrieve. Automation creation
requires HTTP 201; manual invocation creation and the other operations require
HTTP 200. Delete returns typed JSON, not a fabricated 204 success. Pause, resume
and invocation creation send no request body. Unexpected success status remains
a parse failure; actual HTTP failures retain their normal concrete classification.

All ten routes force `agents=v1` and JSON acceptance, preserve ordinary auth/project
and base-query policy, snapshot per-call headers, validate exact opaque path/query
strings before authentication and carry abort/closed-client checks. The automation
route classifier covers all ten operations, including eight nested paths previously
outside private Agents classification. Provider refresh cannot replace required
beta/media headers or caller-supplied idempotency keys. No new key API or
deduplication policy is introduced. Exact callback/transport-origin guards extend
only from child
inspection to the new automation routes; externally thrown typed exceptions retain
explicit causes with private automatic diagnostics while local HTTP/timeout/abort
policy remains intact.

Both lists return one canonical ID-cursor page, preserving required nullable
first/last cursors. The SDK auto-iterators derive cursors from the final data item;
Dart preserves explicit wire cursors and performs no hidden pagination. Examples
and fixtures retain filters and stop/report absent or nonadvancing cursors.

Saving, updating, pausing or resuming a schedule does not request manual execution.
An explicit invocation queues delivery, including while paused, without changing
the schedule or consuming a one-time scheduled occurrence. Invocation completion
means input delivery was accepted; one-time schedule completion means its schedule
finished. Neither proves Agent work finished. Applications follow the returned
session ID separately. Source snapshots, scheduled time, session ID, skip reason
and error remain independent received facts. Pause/delete leave target sessions and
accepted work intact; delivery in progress may still reach a session. Existing
shared HTTP retry policy remains in force without an exactly-once guarantee.

## Review, examples and validation

The offline example exercises all ten operations with both schedule/target variants,
explicit pagination, a manual delivery while paused and scheduled skip/error history.
It performs thirteen synthetic requests, creates no real jobs, requires no key and
incurs no API charges. Independent review corrected its provenance fixture so both
REST-created schedules report developer creation rather than coupling provenance
to the schedule type. Agent-created provenance is covered by stored model fixtures.

README usage remains concise and collapsible, with the new example linked from the
example table and llms guide. The package documentation configuration maps the
nested resources to that example, with no new exclusions. Old text deferring
automation HTTP operations is updated. The change is additive; no version or
changelog file is edited.

- Complete serial unit suite: **26,331 passed, two skipped, no failures**.
- Chrome: **258 new model/public HTTP tests passed**.
- Focused selections: 15 request tests, 182 receive tests and 110 public/resource
  plus existing shared transport regressions. The independent receive probe built
  fixtures directly from canonical schemas: 24 shapes round-trip and all 79
  individually removed required keys reject. Seventy-two field-copy fixtures
  cover the concrete receive models and contextual pages.
- Package format, dart fix, fatal-info analysis and git diff checks pass. The
  offline lifecycle example passes after final source changes.
- The initial concurrent full run passed 26,330 tests with two skips and the
  unchanged HTTP/2 bounded-peer timing timeout. That test passed in isolation;
  the complete serial rerun passed without changing or excluding any test.
- Independent receive engineering and request/requirements/documentation reviews
  found no remaining blockers. Root separately reviewed the HTTP boundary and
  callback-origin guards. Review-driven fixes preserve typed external-failure
  privacy and caller idempotency headers; regressions cover both. Documentation
  and REST-created provenance fixture findings were corrected and independently
  verified. The PR description/template/API snippets/source links were reviewed.
- No live external API/integration suite, real schedules, version bump or
  publication was performed. This is a library change with no running debug app;
  DTD discovery found none, and the offline example runs in a fresh CLI process.

## Toolkit handoff

Frozen fetch/review, describe and scaffold dry run use the isolated configuration
under `/tmp/openai-issue423-contract`. The reviewed normalized candidate is promoted
only inside that scratch package. The adjacent scoped bindings are overlaid for
verification; repository canonical schemas and global type manifest remain
unchanged for #427. Only the documentation resource/example mappings are updated.
Final overlay verification reports implementation **1157 errors, 251 warnings,
330 infos**; consistency **zero errors/127 warnings**; and **eight existing export
findings**. Docs/README have **zero findings**, with 61 collapsible topics. This
is not a globally green parity claim. The three new scoped implementation findings
expect literal Dart enum declarations; these status value classes intentionally
retain exact future strings. The two scoped consistency warnings describe actual
canonical differences: nullable hosted versus required self-hosted capability
directories, and distinct one-time/periodic status types. Remaining global and
previous Agent alias diagnostics stay recorded for #427/#246. No new exclusion or
suppression hides them.
