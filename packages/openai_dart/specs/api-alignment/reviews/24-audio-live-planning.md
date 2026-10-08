# Audio and Live planning review

Status: independent Audio, Live engineering and combined requirements reviews approve; no open planning findings.
Specification: [Audio and Live](../audio-live.md).
Scope: seven vertical implementation tickets, repository 24–30. This is a planning
record, not runtime implementation acceptance.

## Source receipts and authority

Fresh October 8 source heads are OpenAPI
`506aff0a8099581b50e119b87f8f2692cdad043f`, Python
`9301e319ea33ef28fba380f39a289dedc14652c1` (3.26.1) and Node
`bc6c0bfb70f253d5caa3f335699e9713ea9067b5` (7.30.1).
Independent Audio, Live and requirements audits fetched 73, 57 and 27 primary
source files respectively. Deduplicated URL/SHA256 receipts contain 128 unique
sources, all hash-verified. Successful actual Audio reference paths supersede
three initial guessed URLs that returned 404; guessed pages are not evidence.

Fresh upstream raw OpenAPI SHA256 is
`051b70dab8dd177b84fd7ec5556eff48894cf3b5246db641632ecbc232ff2777`;
repository serialization SHA256 is
`a35acf6fc9d4e256dd87bedd2bbfb387ea5f2af5447b4f3afb6eab0feb1f5234`.
They are semantically equal JSON, not identical bytes. Candidate re-fetch and
independent pinned downloads agree. Canonical specification and pre-fetch metadata
remain unchanged in this Markdown-only change. Toolkit review reports no new wire
changes; that does not imply implementation parity.

Representative official document receipts (Markdown bodies, bytes and SHA256):

| Source body | Bytes | SHA256 |
| --- | --- | --- |
| docs-guides-speech-to-text.md | 40939 | `7cd43d5cc3f08a38306bbc0bda1c809c8192cf93ca52f8c295c60639f324c637` |
| live-guide-voice-sip.md | 27798 | `54d0a8a67f1c19a007a2dad6b5946fcfaedd660ec65ae6d74d92c65c9a36bea8` |

Pinned SDK sources and tests corroborate Audio/Chat shapes, Live transport/event
roles, transcript algorithms and multipart behavior. Canonical governs wire shape;
guides govern workflow/permissions; helper behavior is explicitly sourced to SDKs.
No email assertion is used to invent API fields or a server contract.

## Resolved independent findings

- Six initial slices became seven when the actual Chat voice/AAC and translation
  defects were confirmed. Existing Audio corrections now have their own usable
  ticket rather than being deferred or folded into speech. All 14 transcription
  request fields already exist and are tested as regressions, not new features.
- Translation's resource is JSON-only today; a standalone verbose DTO requires an
  undeclared task and omits text/segments from value identity. The plan requires
  minimal canonical verbose admission, optional legacy task, output-English
  language documentation and distinct raw/verbose methods with cancellation.
- Speech uses its 13 named choices/open/custom voices, with correct Accept/media
  modes and January 6, 2027 snapshot sunset/workflow migration. Chat adds AAC and
  its own open/custom reference; Live has 31 voice conveniences and an open
  custom-ID component constrained to 1–128, unlike the closed Speech/Chat branch.
- Nullable transcription multipart fields normalize null to omission, matching
  current Dart and pinned Python serialization; Node rejects null. No literal
  null part or server-distinct presence claim is fabricated. REST numeric and SSE
  integer logprob bytes, strict writable sentinels/discriminators, buffered abort
  and safe parse diagnostics have explicit criteria.
- Voice consent management follows five canonical/reference operations despite
  both SDK omissions. Voice creation is sample-only; removed prompt creation and
  nonexistent voice CRUD are excluded. Received VoiceResource.type remains open; writable creation type is audio_sample.
  Consent phrase lookup remains a named documentation-only contract gap.
- Canonical closed Voice/Consent responses have an explicitly labeled receive-only
  future-extra extension; writable closure is unchanged. Optional nullable cursors
  differ from other families' required-nullable IDs and preserve exact presence.
- Canonical Live create supports SIP beyond SDK helpers. Existing conservative
  POST behavior must prevent ambiguous timeout/connection replay; request-count
  fixtures guard duplicate calls and tracing headers never claim deduplication.
- Full 22-event Live union is resolved through its allOf alias. Canonical sideband
  18/SDK 15 omissions are recorded; reflected audio has no event_id and separate
  timing/format requirements. DTMF send is a received reflection, not a command.
- Nested response.event is an open object even without type. Outer event_id is
  required nonnull, client_event_id optional nonnull, delegation_id optional
  nullable. Raw snapshots remain lossless; compact lifecycle views do not feed
  incomplete data into strict standalone Response parsing.
- Canonical Live error code string conflicts with the guide's null-code handling statement. The
  accepted narrow required-present code:null receive policy is explicit, with
  canonical versus compatibility fixtures. Command/moderation errors do not
  terminate the entire connection automatically.
- All pending function results precede one explicit continuation, without waiting
  for a nonexistent item-create acknowledgment. One application action owner
  handles frontend/sideband duplicate observations; no tool execution is implicit.
- Graceful close installs its final listener before sending, rejects new work and
  tests immediate final events. Socket close alone is unconfirmed; cumulative
  usage is not summed. SIP's three-second progress replay retains original IDs,
  with explicit application deduplication and no implied audio/action replay.
- Stored fork gets a new ID and distinct startup/inheritance rules. Transcript
  helpers use fake clocks and pinned defaults; borrowed data-channel helpers own
  listeners only. SDK reconnect/queues remain visible inventory, not claimed by fork.

## Independent approvals

Independent ordinary Audio requirements/engineering, Live source/engineering and
combined requirements reviews approve the specification, seven tickets, roadmap
and review record after the findings above are resolved. Reviews fingerprinted
all 13 changed Markdown documents and independently checked source hashes, schema
closure, contract facts, requirement assignment and dependency boundaries.
Subsequent publication changes add only real issue links, native graph evidence
and approval provenance; runtime acceptance remains pending.

## Validation and remaining acceptance

Validation checks 38 unique requirements assigned exactly once across seven
vertical tickets, all nine Audio/seven Live HTTP operation IDs, all 22 real
received components and 11/9 primary/sideband commands. Live has 124 prefixed
schemas and a 300-schema transitive closure including existing shared types;
Audio has 38 reachable components. These are source coverage counts, not counts
of new DTOs or implemented features. The dependency graph is acyclic:
25→24, 27→26, 29→28 and 30→29 (transitively 28). Live HTTP is independent
of ordinary voice creation and reuses the merged webhook verifier only in its example.

All 82 implementation acceptance boxes remain unchecked. Each ticket requires
its own exported API, public offline fixtures, example/README/llms/migration,
full toolkit evidence and independent requirements/engineering review. Planning
runs no unit/integration API acceptance and makes no new implementation claim.
The merged baseline remains 13,541 package tests/two skips, 550 package/2,673 repo
Dart files, toolkit 274 errors/78 warnings/212 infos and 35 consistency warnings;
exports/docs/README pass in that implementation evidence. No gap is suppressed.

Final publication-link validation confirms 94 local file links and 32 specification
URLs returning HTTP 200, with whitespace checks clear. GitHub issues [#366](https://github.com/davidmigloz/ai_clients_dart/issues/366)–[#372](https://github.com/davidmigloz/ai_clients_dart/issues/372) are open native children of #317,
with 367 blocked by 366, 369 by 368, 371 by 370 and 372 by 371. All have
package/type labels and the CODEOWNERS assignee. Final publication links/native
graph checks and final-head CI are reported in the planning PR and issue bodies. No runtime,
example, test, dependency, canonical or manifest files change. No release/version
bump, API key use, real recordings/phone calls or paid API request occurs; cost $0.

The create-pr template retains Summary, Details, References and Test Plan in
order, ending with its five literal implementation checklist lines. They remain
unchecked because runtime criteria do not apply to a Markdown planning PR;
Details explains that boundary rather than claiming absent runtime validation.

## Planning merge receipt

[PR #373](https://github.com/davidmigloz/ai_clients_dart/pull/373) merged October 8,
2026 at 15:23:59 UTC, squash `4058318979cf8ab999e8138015b52b3dc75ffbf6`,
after final head `80489e5d16d1a6932f87dd2731fdb476755f8327` completed all
14 CI contexts (13 successes and the standard Test(all) skip). All seven runtime
issues remain open at planning merge. Speech #366 now has a separate
[runtime acceptance record](24-speech.md); the planning counts above remain
historical evidence, not implementation claims.
