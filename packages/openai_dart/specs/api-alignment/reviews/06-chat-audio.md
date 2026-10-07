# Chat audio review and acceptance evidence

Reviewed October 7, 2026 against CHAT-003–005 in the
[Phase 2 specification](../correctness.md).
Tracking: [#324](https://github.com/davidmigloz/ai_clients_dart/issues/324),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Implementation branch: `feat/openai-chat-audio`.
Implementation PR and final validation evidence will be recorded before handoff.

## Outcome and contracts

Chat completions preserve required output audio ID, opaque base64 data, transcript,
and expiry. Assistant audio accepts distinct structural `ChatAudioReference` and
`ChatCompletionAudio` variants. Generic parsing accepts either; the public
ChatChoice response parser requires all four complete members if audio is supplied.
Outer request/response audio may be null. Actual create/createStream serialization
projects either variant to `{id}`, retaining existing provider reasoning fields.
`toApiJson()` keeps its separate explicit reasoning omission behavior. Response
message serialization emits required nullable content; request/generic omission
behavior remains.

Streamed `ChatDelta.audio` is an optional nonnull object with independently
optional nonnull members. Empty objects, empty strings, and zero expiry remain
supplied values. The new audio parsers reject null/wrong types contextually.
Strict null boundaries follow the canonical schema; Python generated Optional
annotations are more permissive, so SDK agreement is claimed only for shape.

Audio accumulates independently per choice. Data and transcript concatenate
opaquely and separately; supplied ID/expiry replace earlier values. Stable partial
snapshots preserve missing versus empty fields, and reset clears every audio state.
Final conversion retains complete output and fails with StateError for any choice
with incomplete audio, rather than dropping or inventing output. Text-only
conversion keeps its existing behavior.

Node-compatible finish inference occurs only during final conversion. A pure
expiry-only last processed delta can infer stop when all output members exist and
no explicit finish reason does. Later nonnull deltas, including empty objects,
invalidate the marker. Missing/null deltas and usage-only chunks preserve it.
Explicit known-null siblings permit purity; known nonnull siblings and any unknown
outer key, including null provider reasoning keys, inhibit it. Unknown inner audio
keys do not inhibit it. Raw events, flat getters, and partial snapshots retain
wire finish metadata. Parsed delta-presence/provider-null provenance and frozen
unknown outer keys survive serialization, copies, equality, and hashing.

Complete value/copy/diagnostic contracts cover the changed completion, choice,
assistant, partial delta, and accumulated snapshot models. Const constructors and
existing caller-owned model collections remain available. Accumulated collections
are readonly captured snapshots. Audio IDs, data, transcripts, and other opaque
contents are summarized or redacted in expanded diagnostics.

## Sources and workflow

The freshly fetched candidate is semantically identical to canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
No spec promotion or metadata-history update was needed. Fetch/review, delta
describe, and a scaffold dry-run preceded verification.

Contracts were checked against canonical inline assistant output/reference audio
and streaming delta audio, plus
[Python complete audio](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/chat/chat_completion_audio.py),
[Python chunks](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/chat/chat_completion_chunk.py),
[Node Chat types](https://github.com/openai/openai-node/blob/v7.30.0/src/resources/chat/completions/completions.ts),
[Node accumulation/finalization](https://github.com/openai/openai-node/blob/v7.30.0/src/lib/ChatCompletionStream.ts),
and the [audio guide](https://developers.openai.com/api/docs/guides/audio-chat-completions).
No beta schema alias or audio wire discriminator is invented.

Real completion/message/delta object mappings replace hidden or missing manifest
coverage. Typed inline audio entries name their actual contracts. Exact public
fixtures verify contexts and required fields where the generic verifier cannot
inspect inline shapes or follow shared parsing helpers. No new API skip/exclusion
was added.

## Validation

| Check | Result |
| --- | --- |
| `dart format --show=none --summary=line .` | Passed, zero changes on final run |
| `dart fix --apply` | Nothing to fix on final run |
| `dart analyze --fatal-infos` | Passed, no issues |
| `dart test --reporter=failures-only test/unit/` | 2,282 passed, two existing environment-dependent skips |
| Focused completion/model/replay suites | 264 passed; 68 additional legacy regressions passed |
| Focused streaming suites | 147 passed |
| Public fixtures | Exact UTF-8 create/createStream replay bodies; canonical full completion; local SSE independent partial shapes, interleaved choices, malformed audio wrapping, late expiry, tools/refusal/reasoning/logprobs/usage/padding |
| Value contracts | Complete modeled fields, nullable clearing, empty/zero/missing distinction, full equality/hash, structural variants, const preservation, redacted diagnostics, captured snapshots and reset |
| Toolkit `verify --checks all --scope all` | Exports/docs/README pass; wider diagnostics recorded below |
| `generate-llms-txt` | Example descriptions/token estimates refreshed |
| Authorized isolated live smoke | Passed, one unstored request, zero retries, 128 output-token cap |
| `git diff --check` and final format check | Passed |

There are 83 additional deterministic unit tests relative to merged #330. Public
canonical completion and SSE fixtures include every required field; separate
provider cases retain existing older-field omissions/nulls.

Only `test/integration/chat_audio_test.dart` was executed live under the user's
standing permission for cheap integration testing. The transport permits one
POST, using `gpt-audio-1.5`, Standard service tier, 128 output tokens, PCM16 audio,
and store:false. It compares independently collected fragments and text with the
accumulator, validates complete conversion and base64 decoding when present,
permits partial/empty legitimate bounded outcomes, and checks replay serialization
locally without a second request. Clients close in teardown; no stored completion
was created. Logging includes counters only, never a key, transcript, audio ID,
or generated data. The runnable three-request example was not executed live.

Observed usage: 11 input/128 output tokens, 41 audio-bearing events, complete
output. At [current model rates](https://developers.openai.com/api/docs/models/gpt-audio-1.5),
billing every input/output token at the higher audio rates ($32/$64 per million)
gives a conservative $0.008544 estimate, under one cent. No additional paid call
was made.

Dart commands run from `packages/openai_dart`; toolkit commands run from the
repository root with
`--config-dir packages/openai_dart/.agents/skills/openapi-openai/config`.

## Independent reviews and resolved findings

A requirements reviewer authored none of this slice. Model and streaming authors
cross-reviewed the other implementation, and reviewed root's docs/example/live
fixture. Resolved findings include:

- Preserve actual id-only replay on public create and createStream paths, while
  retaining existing provider reasoning serialization.
- Match the Node pure-expiry predicate, including later-delta invalidation,
  provider-null/unknown-key presence, and missing/null delta round trips.
- Accumulate choice logprobs before ignoring an absent/null delta, preserving
  metadata-only events without invalidating prior audio completion markers.
- Assert final conversion finish metadata when testing inference suppression;
  raw finish metadata alone cannot detect an incorrectly inferred stop.
- Exercise transcript-only audio through local public SSE, alongside independent
  empty/id/data/expiry updates and mixed interleaved choices.
- Permit a valid bounded live result without audio or text. Test wire/accumulator
  behavior without requiring a stochastic generated word or every output member.

The independent requirements reviewer and cross-author standards reviewer
approved the combined implementation, fixtures, docs, mappings, and live-test
source. The root agent ran final package validation and the authorized live
smoke. No validated finding remains unresolved.

## Wider diagnostics and boundaries

Toolkit reports 39 implementation errors, ten implementation warnings, 88 infos,
and one unchanged consistency warning. Compared with merged #330's 23 errors,
one warning, and 86 infos, the newly visible diagnostics are:

- Two intentional older nullable completion ID/created provider exceptions.
- Older completion metadata and response annotations/legacy function-call gaps,
  retained explicitly in the complete-parity inventory.
- The typed legacy delta function-call gap; this slice preserves it opaquely for
  finish inference but does not implement legacy function-call accumulation.
- Generic fromJson field-reference checks cannot follow AssistantMessage's shared
  parsing helper; exact canonical public/model fixtures verify the modeled fields.

The remaining baseline diagnostics are unchanged wider gaps/exceptions recorded
in [the previous slice](05-chat-usage-obfuscation.md). Coverage scope remains all;
none of these diagnostics was suppressed to make verification green.

The required sibling check found no Chat-audio or Chat-stream accumulator
counterpart in `open_responses`. Audio voice/format expansion, stored Chat APIs,
retry guidance, image requiredness, remaining API families, Administration, and
release remain separate milestones. Package version/publishing state is unchanged.
