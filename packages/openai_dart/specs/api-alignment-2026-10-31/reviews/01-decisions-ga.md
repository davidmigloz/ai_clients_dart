# Decisions GA — implementation and review

Issue: #414. Parent: #413. Reviewed November 4, 2026.

## Source boundary

This slice uses the roadmap's frozen October 31 sources:

- [OpenAPI 2e9ebb3](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json).
  Raw SHA-256: `73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc`.
- [Python 3.42.0 Decisions parameters](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/types/decision_create_params.py).
- [Node 7.47.0 Decisions resource](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/decisions.ts).
- [Decisions guide](https://developers.openai.com/api/docs/guides/decisions).

The SDKs and schema allow question JSON parts as well as text/images. Decisions
cache options and markers are separate from Responses' cache types: only `30m`
is admitted, and only shared-input text/images can carry explicit boundaries.
No additional HTTP operation or automatic tool execution is introduced.

## Requirements review

| Requirement | Implementation and evidence |
| --- | --- |
| Legacy construction | Existing string questions (including const predicates), user messages, text and HTTP(S)/data image calls remain valid. Existing Decisions tests remain green. |
| Complete history | Four message roles plus function/custom calls and outputs, with role-specific content. Public POST fixture exercises all eight variants, IDs, namespaces, phases and statuses. Tool outputs admit text/images; developer/system admit text; assistant admits output text/refusal. |
| JSON evidence | Deep immutable object/object-array snapshots reject non-finite values, cycles, non-string keys and custom non-JSON values. Exact 32-container, 10,000-value and 256-KiB compact UTF-8 boundaries are tested. |
| Multimodal questions | All three question kinds support nonempty text/image/JSON instruction arrays through typed factories; old string factories remain. Separate question parts reject shared-input cache markers. |
| 400 questions | Snapshot/serialization tests and one public POST cover 400 questions. Ordered predicate/choice/score/refusal answers and usage round-trip unchanged. Existing aggregate request-limit validation remains server-owned. |
| Cache controls | Request key/options, nullable omission, strict `30m` TTL, implicit/explicit mode, and shared text/image boundaries. Copies can clear optional controls. Invalid `12h`, mode, and question breakpoint shapes are rejected. |
| Consumer guidance | Runnable offline GA example, existing collapsible README topic/example index, llms entry and upcoming-release migration section. |

## Engineering review

Self-review applied the package/core checklists; this is not an independent
review or a claim of complete OpenAI API parity.

- Public models are reachable from `package:openai_dart/openai_dart.dart`.
  Library parts keep the role/content hierarchies sealed without exposing
  additional top-level libraries. The example and fixtures consume only the
  public barrel.
- Required fields and known discriminators fail with contextual format errors.
  Writable request unions/enums reject unsupported variants; received answer
  unknown variants retain their existing forward-compatible behavior.
- Collections own immutable snapshots. JSON equality/hashing uses the existing
  deep helpers; typed list equality uses the existing value helpers. New model
  equality compares the same fields used by hashing, including runtime type
  when used in the hash. A subclass regression covers that contract.
- Nullable copies support explicit clearing. Diagnostics include cache/history
  metadata but redact captured text, JSON, URLs and tool arguments. Tests cover
  cache-boundary clearing and diagnostic redaction.
- Review corrections added concrete assistant evidence parsers and discriminator
  checks, consistent oversized-cache-key parsing, and subclass-safe equality.
- No shared Responses codec or `open_responses` model is changed. Decisions
  role/content contracts deliberately remain independent of Responses items.
- No release version or changelog changes are included.

## Validation

- Focused models/resource tests: **92 passed**. These include all old Decisions
  tests, every new input variant and a public 400-question HTTP fixture.
- Full package unit suite, before the final focused review additions:
  **25,251 passed, 2 skipped, 1 failed**. The failure is the pre-existing local
  HTTP/1 connection-reuse assertion at
  `test/unit/resources/http2_evaluation_test.dart:509` (expected one connection,
  observed two), previously reproduced on the unchanged PR #430 base. No
  transport implementation or HTTP/2 test changes are included here.
- `dart fix --apply`: nothing to fix; `dart analyze --fatal-infos`: clean.
- Package `dart format --set-exit-if-changed`: 727 files, no changes.
- `dart run example/decisions_ga_example.dart`: succeeds with one MockClient
  POST, synthetic answer and no network/image fetch/tool execution/API charges.

## Toolkit verification and #427 handoff

Fetch/review/scaffold/verify used an isolated `/tmp/openai-decisions-ga` copy to
preserve the roadmap's explicit assignment of canonical spec, manifest and
source-metadata promotion to #427. The reviewed candidate was promoted in that
copy before verification. `scaffold --target schema --name DecisionInputJson
--dry-run` succeeded; hand-written models supply the role/content constraints
and immutable ownership that generated skeletons cannot provide.

[Manifest mappings](01-decisions-ga-manifest.json) record the Decisions entries
for #427, including wrappers and inline cache/instruction contracts. Apply them
alongside the canonical October 31 spec promotion, rather than binding the new
classes to the older user-only message schema or Responses cache schemas.

`verify --checks all --scope all` against the frozen candidate and these mappings:

- No implementation errors under `lib/src/models/decisions/`.
- Docs and README: no errors or warnings (52 collapsible usage subsections).
- Whole-snapshot implementation: 1,124 errors, 181 warnings, 289 infos across the
  repository's mappings. This is not a passing global alignment gate; other API
  slices and final inventory reconciliation remain with the roadmap.
- Exports: eight internal helper files flagged, including the existing Decisions
  helper library. All new public types compile through the public barrel.
- Consistency: no errors, 116 warnings. Role-specific content types deliberately
  differ. Decisions warnings include the finite `Object` JSON root union and
  synthetic input-part inference against the similarly shaped question union;
  both are covered by explicit codec/public request tests. Status/phase naming
  and fixed message-discriminator optionality produce informational diagnostics.

There is no spec promotion, blanket suppression, new follow-on issue, live API
suite, release or merge in this slice. CI and normal PR review remain required.
