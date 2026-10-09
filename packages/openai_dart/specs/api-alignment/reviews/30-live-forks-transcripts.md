# Stored Live forks and transcript acceptance

Status: implemented and independently approved for [#372](https://github.com/davidmigloz/ai_clients_dart/issues/372),
[ticket 30](../tickets/30-live-forks-transcripts.md). Independent combined
requirements/publication and cross-author engineering reviews have no open
findings. Published-head CI and merge remain pending. The user-authorized
[PR #379](https://github.com/davidmigloz/ai_clients_dart/pull/379) merge closed #371
at `d00ee5cfc4a61df04b4e7c59c6ea4e8e34c79648`, the base of this slice.

## Sources and compatibility

Fresh toolkit fetch/review on October 9 inspects immutable
[OpenAPI 0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json),
358 operations and 2,039 schemas. All 287 prior Live client/server/sideband/fork
and InputItem components and all seven Live HTTP path objects equal adopted
[f6f80b90](https://github.com/openai/openai-openapi/blob/f6f80b90bb96d74c22b05a68295af6e7359a48a6/openapi.json).
The compact adapter's independent 307-component closure also remains unchanged.
All 37 flattened Response property contracts, 53 granular event roots, and all
20 active structural keyword families match the canonical projection, retaining
actual property names such as description/title/type/default/format.

[Python c511a771 / 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08)
and [Node 5e70623d / 7.31.0](https://github.com/openai/openai-node/tree/5e70623d6df4596bf39bcb9d2c93d8e8a50b856f)
are fresh immutable heads. Thirteen actual Live helper/runtime files are
byte-identical to the previous reviewed SDK pins; Node 7.31 did not introduce
these existing media helpers. Actual source receipts include fork routes,
compact declarations, transcript grouping/grouper, data channel and media examples.

Publication-time [Node 88bb9848](https://github.com/openai/openai-node/tree/88bb98485668c50a22fba9c0e04dfb5f784db239)
remains 7.31.0. All 13 affected runtime/helper files, package.json, LICENSE and
the actual transcript-playback example equal the reviewed pins. Its only new
change fixes detailed usage aggregation in the automatic Chat runner, with docs
and regressions. Dart's absent equivalent aggregation helper remains shared SDK
inventory; this is separate from existing per-completion wire usage and Live.

Twelve new components and 124 normalized leaves since f6 are inventoried, including
array index shifts rather than 124 features. Decisions HTTP(S) images, nullable
SafetyAlertResource.detailed_explanation, and Agents environment/session lifecycle
contracts remain [explicit follow-ups](../README.md). The last fd15→0ef delta
adds four suspended/expired Agent session/webhook event components and modifies
four related statuses/unions, without path additions. Required nullable turn_id,
closed session-event envelopes and shared webhook envelopes retain distinct
contracts. Adopted canonical bytes and original fetch/source metadata are intact;
this slice claims no implementation of those later API families.

Forty-eight reachable oneOf paths are independently classified: 47 are disjoint
by real type/tag/required/closed-shape contracts. InputItem is the one previously
inventoried overlapping source union. Three ordinary valid message
witnesses validate declared branches but fail canonical root exclusivity under
both pins; compatibility admission is not reported as strict root validation.

## Observable requirements

| Requirement | Public evidence |
| --- | --- |
| LIVE-FORK-01 | `client.live.forkConnection(id)` opens exactly the encoded `/live/sessions/{id}/fork` route with shared auth, timeout, abort, privacy and ownership. Distinct `LiveForkConnection.start` sends `session.start` with an explicit empty session object; no model query or automatic startup. Opaque Unicode IDs round-trip; malformed UTF-16 rejects before auth. |
| LIVE-FORK-02 | New WebSocket writers admit documented root audio/delegation/store and audio.format overrides, excluding inherited model/voice/instructions/history and WebRTC client permissions. This operation guard is separate from the old shared HTTP DTO's canonical open metadata. Delegation mode remains inherited; only existing Responses backend settings change. No audio/tool/action replay, reconnect or side-effect runner. |
| LIVE-FORK-03 | The offline example finalizes two stored originals, downloads two mock stereo WAV recordings and starts distinct client/Responses forks. Model/voice/instructions/history/store inherit; the new format defaults PCM16 24 kHz independently of the original 16 kHz. Saved completed-operation and canceled-delegation state is restored explicitly. Storage, ZDR and recording availability are service policies exercised through injected one-attempt failures; premature close and abort have public fixtures. |
| LIVE-WORK-03 | Six sparse lifecycle views preserve all present 37 Response properties without full Response requiredness/defaults. Fifty-three known granular event kinds validate canonical structure before using compatible ordinary codecs. Missing/future nested types and source-valid incompatible child shapes remain lossless raw views. Known malformed fields throw contextually; no parser exception is converted to raw. All outer IDs/correlation and raw source frames survive copy/serialization. Manual workflows collect every active call through backend finalization, return all results, then send one continuation without an item-create ack. |
| LIVE-TRANSCRIPT-01 | Pure grouping and stateful grouper implement actual SDK speaker/backchannel defaults: 500/2000/1000/2000 ms plus a 50 ms settle window. Independent fake-clock SDK execution matches 41 cases, 158 ordered snapshots and 190 operations, with zero remaining timers. Duplicate/late fragments, gaps, Unicode boundaries, reset/flush, inactivity, reentrancy and listener errors have fixtures. Local IDs are projection values; acknowledgments can be suppressed, so raw taps remain the lossless source. |
| LIVE-TRANSCRIPT-02 | Concurrent helper/application taps remain independent; detach/close cancel only owned subscriptions and timers. `session.closed` confirms finalization; stream end alone does not. Typed `LiveConnection.dataChannel` returns a primary writer usable without casts; it borrows already-started broadcast text media, rejects startup/audio and never closes caller media/listeners or invents peer close metadata. |

`projectLiveTranscriptPlayback` is an additive pure Dart affine mapping from source
timing to a caller clock. The actual SDK has no pure playback projection algorithm;
its PCM/hardware examples remain caller integrations. Neither backend finality,
Live finalization nor this projection proves audible completion.

## Values, mappings and review findings

The manifest preserves all 1,071 prior entries and every top-level policy, adding
12 genuine bindings. Four compact outer-frame views bind the actual LiveResponseEvent
component; eight sparse/local value or enum extensions explicitly have no
independent canonical wire component. No fabricated lifecycle schema or media
engine mapping, checker change, new skip or exclusion. Actual describe/scaffold
dry-runs for LiveResponseEvent succeed without generating replacements.

All changed immutable values cover presence/null/absence, detached finite JSON,
copy/clear and equality/hash. Local enums have ordinary enum value semantics,
without invented JSON/copy interfaces. Compact `type` is a nullable nested
helper discriminator; `source.type` and `toJson()` retain the required outer
response.event contract. All four views parse through the shared aggregate
factory rather than pretending Dart factories are inherited.

Independent public factories serialize 91 values across all 53 granular kinds,
28 canonical OutputItem minima, six lifecycle kinds and four future/typeless/raw
views. JSON Schema validates 420 actual component/outer/OutputItem assertions
against both source pins without failures. Ten valid OutputItem minima deliberately
retain raw views where the existing ordinary codec is incompatible, including
MCP undeclared required fields/error types. Ordinary Responses models remain
unchanged; strict known validation precedes the compatibility fence.

Review resolved startup override admission, sparse snapshot requirements,
all-pending-call collection, authoritative source/copy dispatch, broadcast ownership,
finite browser integers and Unicode segmentation. Actual Node 24.19.0 SDK execution
supplies the fixture goldens. A separately archived Node 26.3.1 V8 anchored Unicode
regex discrepancy was diagnosed against unchanged SDK source; Dart's Unicode
boundary predicate follows Node 24/Python grouping without corrupting expected
fixtures. No existing public constructor/enum/sealed hierarchy is corrected by
this slice; APIs are additive and no breaking migration or version bump is invented.
Independent source review also added the exact upstream Apache-2.0 license,
OpenAI copyright/source attribution and Dart adaptation notices for the ported
transcript helpers and SDK-derived goldens. Package distribution includes
THIRD_PARTY_NOTICES.md and the unchanged license copy.

## Verification and publication

Pinned stable Dart 3.13.5 focused fixtures pass on VM and real Chrome JavaScript
and Wasm. There are 549 new runtime/compact/channel VM cases (495 compact,
44 fork, 10 channel), 551 on each browser compiler, plus 132 transcript cases on
every platform. Combined runtime regressions pass 666 VM and 673 per browser
compiler; helper fixtures also cover 25 additional SDK stress/boundary cases.
Independent engineering review reruns all 549 new runtime cases and adds 44
public assertions; independent requirements review executes actual SDK goldens,
all 41 Dart public golden consumers and the canonical public corpus.

The stable package pipeline formats 634 files with no changes, applies two
curly-brace quick fixes in the new example, and reports clean fatal-info analysis.
The full package unit suite passes 21,335 tests, with two existing environment-
dependent skips. This slice adds 681 VM cases; all 683 new browser cases pass
each Chrome compiler. The root offline workflow and literal README fork snippet
pass without API calls. README/llms expose actual public helpers, source constraints,
ownership and privacy; token annotations use real toolkit o200k_base counts.
The [progress history](../progress-history.md) preserves all 63,987 characters of
the prior tracking-parent body verbatim before its current roadmap is condensed.

Full toolkit diagnostics remain visible and classified. Final verification reports
937 errors / 126 warnings / 277 infos and 103
consistency warnings, exiting nonzero. Docs/exports/README checks are clean
(56 headings and 40 usage subsections). Relative to baseline
912 errors / 126 warnings / 277 infos and 103 consistency warnings, the new four
wire alias bindings add exactly 25 implementation errors with no removal:
15 inherited properties, three inherited toJson methods and three inherited
copyWith methods exceed lexical inspection; three factory expectations deliberately
use the shared aggregate parser (Dart factories are not inherited); one type-name
finding compares the nested helper getter with the authoritative outer source.
The canonical public/source evidence above verifies those actual contracts.
All prior diagnostics, coverage gaps, endpoint-action mismatches and 52 existing
skips remain unchanged. No checker or policy changes hide the toolkit's nonzero exit.

Opt-in reconnect/unsent queues, raw escape hatches, SDK media helpers and remaining
Responses/Realtime/Chat parity remain inventory. Decisions/Safety follow-ups and
Phase 6 Agents planning precede later Administration/legacy slices. Published-head
CI, external review availability and merge are separate from local implementation
acceptance; those gates will be recorded in the PR/issue rather than preclaimed.
