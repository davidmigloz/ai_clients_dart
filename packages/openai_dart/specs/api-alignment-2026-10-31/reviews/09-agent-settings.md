# Agent context settings and session review

Issue #422; parent #413. Reviewed November 4, 2026 against the fixed October 31
source cutoff. No later upstream changes expand this slice.

## Authority and accounting

- OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`.
- Python 3.42.0, `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`.
- Node 7.47.0, `c717857c3151bde92e07e4d396301a9c67163e68`.
- Official Agent session guide and frozen changelog; eight SDK source hashes and
  both guide hashes are recorded in the adjacent manifest.

All 23 assigned schemas are accounted for: 21 class/union/value bindings and two
removed spend-control schemas. GET /agents/sessions gains the specified metadata
filter; no new HTTP operation is introduced. The four automations tool leaves are
necessary prerequisites for this ticket's four modified tool unions. Their primary
inventory ownership remains #423; scheduling/invocation operations are not part of
this change. Canonical spec/global manifest promotion remains #427.

## Context configuration

AgentCompactionConfig implements CompactionParam: optional nullable async, keeping
omitted/null/false/true distinct without serializing a default. Background behavior
is selected when async is omitted/null. A supplied compaction object replaces the
configuration; omitted parent updates retain it, and null or {} resets background
compaction. AgentCompaction requires the resolved nonnull boolean when received.
Background compaction can increase token usage.

AgentExperimentalConfig serves saved-Agent creation, while
AgentExperimentalOverridesConfig serves saved updates and inline session overrides.
Time awareness is optional nonnull: supplied keys merge and omitted update keys
retain current values. Explicit false disables reminders; null is not a wire clear.
AgentExperimental requires its resolved timeAwareness boolean. Received optional
compaction/experimental parents reject null but tolerate absence on older resources.
Python optional received objects allow null more broadly; canonical/Node govern.

Saved create/update/receive and inline/resolved session parents share these exact
leaves. Post-creation AgentSessionAgentUpdate does not acquire unsupported
compaction/experimental fields; its canonical mutable settings remain model,
reasoning, service tier and the newly admitted tools replacement.

All new fields participate in complete effective-JSON value equality, hashing,
copies, null-presence handling and private diagnostics. Request objects remain
closed; received future metadata is finite, deeply owned and subordinate to typed
known fields. No server default is synthesized in request or response JSON.

## Independent review versus removed spending control

SessionReviewParam and SessionReviewResource model none/auto_review independently.
Create omission uses none; receive omission means none without inserting a value;
update omission preserves current behavior. Supplied updates affect new root turns,
while existing turns and their subagents retain their review mode. Automatic review
covers eligible actions and denies manual approval fallbacks; it is not a spending
limit or a local action/approval runner.

Canonical removes SessionSpendControlParam/Resource and spend_control on session
create/update/receive. Both frozen SDKs still expose old spend fields, alongside
the new review field. This slice deliberately follows canonical and the ticket:
remove the old public DTOs and request/clear/getter APIs, reject removed request
keys including null, and never translate a limit into review. Historical received
spend JSON can remain immutable opaque extras without becoming a current request
or review value. MIGRATION.md shows explicit removal and a separate review choice.

Request review values remain closed through parent validation; received future
review strings retain their exact value. The public request enum and all four
duplicated saved/session service-tier validators now admit ultrafast, while future
unknown request tiers continue rejecting before authentication/dispatch. Tier/model
eligibility and pricing remain service-owned.

## Session tools and metadata filters

AgentSessionAgentUpdate.tools replaces the list, with the canonical 0–16384 bound.
Omission retains it, null and [] clear it, and valid lists are snapshotted. Functions
and MCP changes apply on the next model call; built-in changes apply by the next
turn. The four tool unions now admit type:automations through exact closed request
leaves and forward-compatible received leaves, with no scheduling runner or endpoint.

Session list metadata encodes deepObject/explode=true metadata[key]=value, not one
JSON-string query value. All pairs must match. Limits are 0–16 pairs, keys 1–64
Unicode code points and values up to 512; an empty map emits no filter pairs. The
flat query snapshot preserves existing base/per-call filters, cursor, order and
agent ID. Pagination retains filters; source documentation permits index visibility
lag after creates/updates.

Invalid lone UTF-16 surrogates cannot round-trip URI encoding unchanged and now
reject privately before authentication rather than silently selecting a different
metadata string. Valid surrogate pairs and non-BMP boundary strings retain exact
values. No new URI framework or broader model normalization was introduced.

## Independent review and regressions

Separate source, engineering and requirements reviews checked every inventory
entry, receipt hash, class/file binding, all four request-tier validators, public
HTTP/SSE paths and documentation. Reviews found and independently verified fixes
for two concrete issues:

- A new Object?-sentinel tools copy setter rejected ordinary []/const [] literals
  because they lost generic context. A local checked-list conversion now accepts
  empty and valid typed-element lists, preserving nullable clear/omission and
  constructor snapshots. It does not change the shared generic copy helper.
- URI encoding normalized malformed surrogate filter values. A local pre-auth
  exact round-trip guard rejects them; four negative key/value cases and a valid
  pair control prove error privacy, zero auth/send, and unchanged valid strings.

No remaining review blocker was identified. Removed DTO/field fixtures and numeric
spend tests were replaced by current review/context/tools contracts and explicit
legacy request rejection/opaque receive-retention tests. Existing invalid-ultrafast
assertions now use a future unsupported tier, with positive coverage for ultrafast.

## Validation and documentation

- Final full unit suite: **26,073 passed, two skipped, no failures**.
- Chrome: **57 new model/public-path tests passed**.
- Focused selections: 563 saved-Agent/settings tests; 1620 existing corrected
  session model/copy/source-limit/resource tests; 27 new session tests; 16 public
  settings/filter fixtures. Independent selections and probes verify both fixes.
- Package format, dart fix and fatal-info analysis pass. A dart fix changed an
  example cast incorrectly; a typed local helper corrected it and the example
  was reanalyzed and rerun successfully.
- The first concurrent full run reported the already observed HTTP/2 local-peer
  timing timeout. The final run uses lower concurrency after all source fixes;
  the unrelated evaluation test was not changed or excluded.
- The new offline Agent settings example exercises compaction reset, merge-by-key
  time awareness, ultrafast, review/tools updates and exact two-pair filtering.
  It uses only a synthetic HTTP peer, without an API key, live model execution,
  hosted compute or charges. The existing durable-session example no longer uses
  removed spending APIs.
- README topics remain concise and collapsible. Hosted Artifact SDK/skills are
  documented as server-image capabilities; prewarming uses existing environment
  creation rather than a fabricated client endpoint. No version/changelog edits
  or live integration tests are included.

## Toolkit handoff

Fetch/review/describe/scaffold dry run and isolated candidate promotion/full
verification ran under /tmp/openai-issue422-contract. All current and supporting
mappings are in the adjacent receipt, with removed schema dispositions explicit.
No new exclusions or suppressions were introduced; canonical promotion stays #427.

Frozen-overlay diagnostics are implementation **1154 errors, 251 warnings, 330
infos**; consistency zero errors/125 warnings; eight existing export findings.
Docs/readme have no findings, with 60 collapsible topics. This is not a globally
green parity claim. Remaining scoped diagnostics are lexical: value classes with
exact future strings are not Dart enum declarations or synthetic unknown sentinels,
and session/persisted canonical aliases collide with similarly named Dart tool
parents in the scanner. The actual codec inheritance, enum parent validation and
public wire paths are source-checked and tested. Global reconciliation, including
shared enum verification #246, remains part of the bounded closure work.
