# Chat usage and stream-obfuscation review and acceptance evidence

Reviewed October 7, 2026 against CHAT-001–002 in the
[Phase 2 specification](../correctness.md).
Tracking: [#323](https://github.com/davidmigloz/ai_clients_dart/issues/323),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Implementation branch: `feat/openai-chat-usage-obfuscation`.

## Outcome and contracts

Chat prompt details now preserve unadjusted cache-write, image, and text token
counts alongside existing audio/cached counts. Completion details preserve text
counts alongside existing audio/reasoning/prediction counts. Zero remains zero;
omitted counters remain absent. Ordinary completions and final usage-only stream
chunks share the same models, including `choices: []` and provider/embedding
payloads that omit completion counts or detail objects.

`StreamOptions.includeObfuscation` sends either boolean explicitly or omits the
control to preserve server defaults. `ChatStreamEvent.obfuscation` preserves
padding, including an empty string, as metadata. Accumulators and text extensions
use content deltas; padding does not enter text, refusal, reasoning, or tool
arguments. Interrupted streams may end before final usage arrives.

All six new members are optional but nonnullable on the canonical wire.
Their parsers reject supplied null/wrong types contextually. Constructor/copy null
clears by omission. Existing counter, completion-count, detail-object, includeUsage,
and provider-field null tolerance remains unchanged. No counter minimum or
synthetic zero/default is invented.

Stream events now compare every field. Choice finish reasons/logprobs, tool-call
delta type/function, and nested token logprob bytes/alternatives participate in
full equality/hash too. Copies preserve/replace/clear nullable fields; empty
list replacements normalize their runtime type. Const constructors and existing
caller-owned collection behavior remain. Opaque stream contents and padding are
summarized in expanded diagnostics; ordinary token logprob diagnostics retain
their previous token-string behavior.

The existing shared StreamOptions also forwards the new flag in Responses
holders; two nested request regressions verify this incidental wiring.
`includeUsage` remains Chat-specific. This ticket does not add Chat audio or
claim broader Responses streaming parity.

## Sources and workflow

The freshly fetched candidate is semantically identical to canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
No spec promotion or metadata-history update was needed. Fetch/review, options
describe, and a scaffold dry-run preceded final verification.

Contracts were checked against the canonical inline `CompletionUsage` details,
`ChatCompletionStreamOptions`, and `CreateChatCompletionStreamResponse`, plus
[Python usage](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/completion_usage.py),
[Python chunks](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/chat/chat_completion_chunk.py),
[Node Chat types](https://github.com/openai/openai-node/blob/v7.30.0/src/resources/chat/completions/completions.ts),
and the [current streaming reference](https://developers.openai.com/api/reference/resources/chat/subresources/completions/streaming-events).
There are no beta Chat usage/chunk schema aliases.

The manifest replaces stale skipped/stub entries with real Usage/ChatStreamEvent
object mappings and registers inline detail models. StreamOptions represents the
object body of a nullable `anyOf` wrapper; the generic verifier cannot extract
its properties, so an extension entry names the actual canonical contract and
points to exact public/model fixtures. No new API skip/exclusion was added.

## Validation

| Check | Result |
| --- | --- |
| `dart format --show=none --summary=line .` | Passed, final run unchanged |
| `dart fix --apply` | Nothing to fix on final run |
| `dart analyze --fatal-infos` | Passed, no issues |
| `dart test --reporter=failures-only test/unit/` | 2,199 passed, two existing environment-dependent skips |
| Focused changed-model/resource suite | 383 passed before two additional shared-Responses regressions |
| Model contracts | All added/old detail fields, zero/absence, strict new null/type boundaries, nullable clearing, full stream/child equality/hash, empty lists, const preservation, diagnostic summaries |
| Public fixtures | Ordinary completion, final empty-choice usage chunk, nonzero/zero/provider profiles, true/false/omitted request controls, empty/omitted padding, public parse-error wrapping, accumulation separation |
| Toolkit `verify --checks all --scope all` | Exports/docs/README pass; expected legacy nullability diagnostics remain visible |
| `generate-llms-txt` | Descriptions and token estimates refreshed |
| Isolated authorized live smoke | Passed, one unstored request with retries disabled |
| `git diff --check` | Passed |

Dart commands run from `packages/openai_dart`; toolkit commands run from the
repository root with
`--config-dir packages/openai_dart/.agents/skills/openapi-openai/config`.
There are 78 additional deterministic unit tests relative to merged #329.
Public completion/chunk fixtures include every canonical required field.
Separate provider fixtures exercise the intentional older-field omissions/nulls.

Only `test/integration/chat_usage_obfuscation_test.dart` was run live under the
user's standing authorization for inexpensive API tests. It permits at most one
POST, uses `gpt-6-luna`, no reasoning, Standard service tier, 16 output tokens,
and `store: false`; clients close in teardown and no stored object is created.
Only counts are logged, never keys, headers, content, or padding. It validates
final empty-choice usage and compares accumulated output with content deltas,
without requiring every modality/cache counter or a specific generated string.
Empty/refusal output is normalized consistently when comparing final content.

Observed usage: 11 input/four output tokens and four padding-bearing events.
At [current Standard rates](https://developers.openai.com/api/docs/models/gpt-6-luna),
billing every input at the higher $0.125/million cache-write rate plus output at
$0.50/million gives a conservative $0.000003375 estimate. No additional paid call
was made after review broadened the empty-output assertion.

The README and existing streaming example show both padding controls, detailed
usage, safe usage-only access, and accumulator behavior. The example makes three
bounded requests with retries disabled. Migration guidance records targeted
new-member parsing and full stream/child equality corrections.

## Independent reviews and resolved findings

The requirements reviewer authored none of this slice. Usage and stream authors
cross-reviewed the other implementation and root's shared models, docs, fixtures,
and live source. Resolved findings include:

- Complete Event/Choice/ToolCallDelta/logprob equality/hash rather than extending
  partial identity contracts for one new field.
- Match strict optional-nonnull parsing of all new members while retaining
  intentional older provider/embedding null compatibility.
- Assert public malformed-event errors as ParseException with FormatException
  cause; the resource already wraps parsing errors at that boundary.
- Replace `.choices?.first` in event dartdoc with `event.textDelta`, safe for the
  legal final empty-choice usage chunk.
- Allow legal empty/refusal output in the live content comparison; don't infer
  padding exclusion by substring search or require every optional usage counter.
- Replace stale manifest skip notes and the nonexistent ChatStreamChunk mapping;
  register real wrappers and explain nullable-anyOf verifier limitations.

The independent requirements reviewer and both cross-author engineering
reviewers approved the final implementation, fixtures, docs, mappings, and live
source. No validated findings remain unresolved.

## Wider diagnostics and boundaries

Toolkit output has 23 implementation errors, one implementation warning,
86 infos, and one unchanged consistency warning. Compared with the #329 baseline
of 17 errors, the six newly visible errors are intentional older provider/embedding
exceptions: nullable Usage.completionTokens and nullable event id/object/created/
model/choices. They were previously hidden behind whole-model skips, and the
exact canonical plus provider fixtures verify the accepted behavior.

The other 17 errors and both warnings are unchanged wider gaps/exceptions recorded
in [the previous slice](04-cache-controls-diagnostics.md). New usage counters,
obfuscation fields, copy/value contracts, docs, and exports have no unresolved
findings. Verification scope remains all; coverage gaps are not suppressed.

The required sibling check found existing `open_responses` logprob hashes using
list identity despite content equality, and its obfuscation parser accepts null.
Those separate-package follow-ups are not changed here. Chat audio, retries,
image requiredness, missing APIs, Administration, and release remain separate
milestones. Package version/publishing state is unchanged.
