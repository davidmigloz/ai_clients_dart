# Cache-retention review and acceptance evidence

Reviewed October 7, 2026 against CACHE-005 in the
[Phase 2 specification](../correctness.md).
Tracking: [#321](https://github.com/davidmigloz/ai_clients_dart/issues/321),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Implementation branch: `fix/openai-cache-retention`.
Merged in [PR #328](https://github.com/davidmigloz/ai_clients_dart/pull/328)
at `6d378a0cb46c03b8c3c36fad92d13c6af7fba24c`, closing #321 after all CI checks passed.

## Outcome and contract

`PromptCacheRetention.inMemory.value` and `toJson()` emit `in_memory`.
Both `in_memory` and legacy `in-memory` inputs parse as `inMemory` and normalize
to canonical output. Enum names/order, `24h`, and the existing unknown fallback
remain unchanged. Compaction delegates to the same parser/serializer, removing
its separate spelling workaround. Existing Chat requests and returned Responses,
including completed events, receive the corrected shared mapping.

The fresh candidate is semantically identical to canonical
[ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
Canonical and beta retention enums both specify `in_memory | 24h`; inherited
Chat/Responses and compaction fields agree. Official
[Python Chat parameters](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/chat/completion_create_params.py),
[Python compaction parameters](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/responses/response_compact_params.py),
and [Node contracts](https://github.com/openai/openai-node/blob/v7.30.0/src/resources/responses/responses.ts)
confirm the spelling. No spec promotion or metadata-history change was needed.
Fetch/review/describe and an enum scaffold dry-run preceded final verification.
The obsolete manifest skip is replaced by canonical/beta enum coverage.

Retention is the deprecated maximum-policy control; modern cache-options alignment
and the missing Responses creation-request retention field remain #322. The
README, runnable Chat example, migration guide, and refreshed agent index use
accurate model guidance: the GPT-5.5 example selects `24h`, rather than unsupported
`inMemory`. The unsupported server-restart eviction claim was removed.

## Validation

| Check | Result |
| --- | --- |
| `dart format --show=none --summary=line .` | Passed |
| `dart fix --apply` | No remaining fixes |
| `dart analyze --fatal-infos` | Passed, no issues |
| `dart test --reporter=failures-only test/unit/` | 1,872 passed, two existing environment-dependent skips |
| Initial affected-model/public-fixture suite | 492 passed before beta and final parsed-null additions |
| Final focused public resource fixtures | 27 passed, including four beta-compaction variants |
| Toolkit `verify --checks all --scope all` | Exports/docs/README pass; no new retention diagnostics or retention errors/warnings |
| `generate-llms-txt` | Refreshed descriptions and token estimates |
| `git diff --check` | Passed |

Dart commands run from `packages/openai_dart`; toolkit commands run from the
repository root with
`--config-dir packages/openai_dart/.agents/skills/openapi-openai/config`.

Public MockClient fixtures compare exact Chat create/stream and GA/beta compaction
bodies, beta query/header opt-in, returned Response/completed-event echoes,
canonical and legacy input, `24h`, unknown fallback, omission, and explicit
clearing. Response fixtures contain all flattened required canonical fields.
Model regressions directly verify parsed-null fields and wire omission.
There are 31 additional deterministic tests. No live APIs were called or new
API charges incurred for this slice.

## Independent reviews and resolved findings

Requirements and repository-standards reviewers authored none of this slice.
They inspected actual source, manifests, public fixtures, documentation, and
the source contracts. Both approved after these findings were resolved:

- The initial migration snippet cast an optional JSON member unconditionally.
  A String pattern now preserves absent/null/nonstring input behavior.
- README/migration guidance initially omitted API deprecation. They now identify
  the legacy control, its independent maximum-policy semantics, and the separate
  #322 minimum-TTL milestone.
- A parsed-null Chat assertion relied on existing partial equality; it now
  checks the field and JSON directly. An explicit compaction parsed-null
  regression verifies exact omitted output.
- Acceptance names GA/beta compaction. Both routes now have exact fixtures,
  including query/header assertions and identical bodies.

Testing also exposed pre-existing Chat request equality/hash comparing only
model/messages. This ticket changes neither that model nor its field set.
The complete correction is explicitly required by CACHE-004/#322 when adding
Chat cache options; a one-field partial fix is excluded here. No validated
CACHE-005 findings remain unresolved.

## Wider diagnostics and boundaries

Toolkit output remains at the container baseline: 21 implementation errors,
four implementation warnings, 86 infos, and one consistency warning. Two unchanged
infos suggest String instead of the typed retention enum on Chat requests and
Response echoes; exact fixtures validate the deliberate enum mapping. There are
no retention errors/warnings or new retention diagnostics. The report still
exposes missing API families, existing cache/usage/
image gaps, and two intentional nullable container-pagination exceptions; see
[container evidence](02-container-configuration.md). No new exclusions were added.

This ticket adds no new endpoint, request field, transport behavior, package
version, or release. The serialized-string correction has migration guidance;
modern cache options/diagnostics and full Chat equality remain in #322.
