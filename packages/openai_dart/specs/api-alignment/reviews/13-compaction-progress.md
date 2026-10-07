# Compaction progress acceptance

Status: implementation, validation and independent reviews complete; merged.
Implementation [PR #350](https://github.com/davidmigloz/ai_clients_dart/pull/350)
merged October 7, 2026 at 19:49:04 UTC after green CI, closing #338.
Merge commit: `4110c174b6b84947cd609f59a0104cacc8b6373c`.
Tracking: [#338](https://github.com/davidmigloz/ai_clients_dart/issues/338),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirement: [RESP-COMPACT-01](../responses.md#compaction).
Implementation branch: `feat/openai-compaction-progress`.

## Outcome and contracts

`ResponseCompactionCompactingEvent` decodes exact
`response.compaction.compacting` events through the public stream union and
Responses SSE resources. Sequence number, output index and item ID are required.
Optional beta agent metadata is omitted when absent and rejects supplied null;
its agent name is required. The fixed discriminator and every field participate
in round-trip serialization, copy/clear, equality/hash and safe diagnostics.
Const construction remains available. Malformed known fields throw contextual
`FormatException`; future event types retain `UnknownEvent` and their raw JSON.

This notification is nonterminal and contains no summary or encrypted content.
The existing accumulator exposes it as `latestEvent` without changing its
response, text, reasoning or status. Fixtures interleave progress with item-added,
item-done and completed lifecycle events; final output preserves the opaque
encrypted compaction item. Public accumulated and plain SSE paths are covered in
GA and beta modes, including malformed and future-event continuation behavior.

Existing compact REST, context management, explicit triggers and encrypted item
replay stay available. Standalone `ResponseCompaction.toInput()` retains the
complete returned output window. The private beta-agent parser is shared with the
five existing shell events without changing its validation; those 197 existing
model tests pass with the 63 new progress model cases.

## Compatibility, documentation and example

Adding a subtype to the public sealed `ResponseStreamEvent` hierarchy can require
an additional case in exhaustive switches. Manual discriminator handlers that
previously inspected `UnknownEvent` must use the typed event. The migration guide
documents both updates; this change uses a breaking conventional commit/PR title.

README usage, the example table and `llms.txt` reference the new public API and
offline example. Exact README and migration Dart snippets compile with fatal-info
analysis, including the existing `compacted.toInput()` helper. Independent review
caught a type-incorrect draft replay expression; the corrected helper was
compiled. Migration wording makes the local example's lack of an API key explicit
without applying that property to the README's live-client snippet.

`example/compaction_progress_example.dart` uses one local MockClient request with
retries disabled. It checks typed progress remains nonterminal, consumes through
completion and verifies the opaque final output is intact. It runs successfully
without an API key, large context, encrypted payload logs or live API charges.

## Official sources and boundaries

Fresh October 7 toolkit fetch/review contains 356 operations and 2,010 schemas,
with no endpoint/schema wire changes. Promoted pinned
[OpenAPI 17f9a66](https://github.com/openai/openai-openapi/blob/17f9a665031777071b26e63356d78280bf7c128c/openapi.json)
matches the fetched candidate. Its only change from ee483b4 is the Decisions
endpoint description. Metadata records the new source/fetch and preserves the
prior snapshot's actual provenance; promotion introduces no Decisions wire or
SDK behavior changes.

The canonical GA and beta `ResponseCompactionCompactingStreamingEvent` schemas,
[Python event](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/response_compaction_compacting_event.py)
and [Node Responses](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/responses.ts)
agree on the progress event. The
[compaction guide](https://developers.openai.com/api/docs/guides/compaction)
distinguishes inline threshold-based compaction from standalone compaction and
complete output-window replay. Describe and scaffold dry-run reviewed the real GA
schema after registering both real GA/beta manifest mappings. No new exclusions
were added.

Persistent Responses WebSocket transport remains #341. The sibling
`open_responses` published schema contains no corresponding progress event, so no
speculative sibling variant is added. The existing `CompactionTriggerItem` DTO's
missing optional canonical trigger `id` remains an out-of-slice parity gap; the
raw history fixture retains the provider ID. This ticket does not claim complete
compaction or SDK parity.

## Validation

- 63 new model contract tests and 142 new public REST/SSE fixtures pass (205 new
  tests); independent engineering review also ran these 205 tests.
- Model contracts cover every field, const construction, copy/clear, contextual
  malformed input, round trips, value/hash equality, subclass symmetry and safe
  diagnostics.
- Public fixtures cover exact method/path/auth/header/query/body, GA/beta stream
  dispatch, context management/triggers, retained compact REST/output replay,
  ordering, accumulator state, malformed fields and unknown fallback.
- Format checked 466 files with zero changes; `dart fix --apply` had nothing to
  fix; package `dart analyze --fatal-infos .` passed.
- Full package unit suite: 5,368 passed, two existing environment-dependent skips.
- The runnable local example and exact documentation snippets passed.
- Full toolkit `--checks all --scope all`: implementation 82 errors, 10 warnings,
  133 infos; consistency 19 warnings. These match the previous slice's baseline.
  No diagnostics mention the new progress schemas. Exports, documentation and
  README checks pass; unrelated diagnostics remain visible.
- `git diff --check` passes. No live API tests, package publication or version bump
  occurred; API cost is $0.

## Independent reviews

Requirements and engineering reviewers inspected the combined implementation,
tests, manifest, pinned spec, README, migration guide and example. The README
replay expression and migration wording findings were resolved. Both reviewers
approved the final combined diff and this acceptance record with no remaining
actionable findings. PR #350 merged, closing #338. Access programs #339 follow this slice.
