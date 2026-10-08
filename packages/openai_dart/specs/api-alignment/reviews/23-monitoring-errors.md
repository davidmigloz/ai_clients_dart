# Structured monitoring errors implementation acceptance

Status: implemented, independently reviewed and runtime verified; PR creation pending.
Tracking: [#360](https://github.com/davidmigloz/ai_clients_dart/issues/360),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [SAFETY-ERROR-01–04](../webhooks-safety.md).
Safety retrieval [PR #364](https://github.com/davidmigloz/ai_clients_dart/pull/364)
merged October 8, 2026 at `a466e8500aae91347f9c2d004a0854c969c6e779`, closing #359.

## Sources and separate wire contracts

Fresh October 8 reads and 18 independently hashed official source files confirm
[OpenAPI 506aff0a](https://github.com/openai/openai-openapi/blob/506aff0a8099581b50e119b87f8f2692cdad043f/openapi.json),
[Python 3.26.1 / 9301e319](https://github.com/openai/openai-python/blob/9301e319ea33ef28fba380f39a289dedc14652c1/src/openai/types/responses/response_error.py)
and [Node 7.30.1 / bc6c0bfb](https://github.com/openai/openai-node/blob/bc6c0bfb70f253d5caa3f335699e9713ea9067b5/src/resources/responses/responses.ts).
The [official monitoring guide](https://developers.openai.com/api/docs/guides/safety-checks/misalignment-monitoring)
is rechecked. Toolkit fetch/review finds unchanged canonical JSON; promotion
preserves the source pin and historical metadata while recording actual fetch
`2026-10-08T13:55:51.919445Z`. Ten real component describe/scaffold pairs and mappings
cover GA/beta details, steer, failed errors, flat SSE errors and genuine stream
unions. No fake HTTP error DTO, enum, schema, exclusion or checker change is added.

| Surface | Canonical shape and explicit compatibility |
| --- | --- |
| HTTP `Error` | Required type/message and nullable code/param; optional nonnull misalignment. Original public exception body remains available; typed optional extraction is best effort, never a new strict HTTP DTO. |
| GA/beta failed `ResponseError` | Required nonnull closed-enum code/message; optional nonnull misalignment. Legacy type/param, omitted/null code and future code strings are receive-only tolerance. Absent type stays omitted; explicit legacy type:null normalizes to the old `'error'` fallback. No typed headers. |
| GA/beta SSE `ErrorEvent` | Flat nullable code/param, message and integer sequence; beta agent optional nullable. Parsed legacy flat/nested omitted nullable fields/sequence retain explicit presence as receive-only compatibility, with no invented code/message. Nested input normalizes flat. Negative integer sequence is valid. Future metadata is opaque; no typed SSE misalignment/headers. |
| GA/beta WS `ErrorPayload` | Required type/message and nullable code/param; optional nonnull headers/misalignment. Existing omitted nullable-key tolerance is preserved; no change to the WS envelope. |

Affected objects omit `additionalProperties`, so future metadata is permitted.
`error_type` is an open string anyOf, unlike the closed failed-response code enum.
Review targets distinguish absence/null and require exactly 1–96 allowed ASCII
characters; terminal newline, Unicode, empty and oversized targets reject.
Steer requires a string message (empty is valid), never an executable client action.
`Error-2` video, Agents/Live envelope and Admin gaps remain inventoried.
The sibling `open_responses` uses a genuinely nested canonical SSE error and
receives no mirrored flat-output change.

## Requirement evidence

| Requirement | Implementation and public proof |
| --- | --- |
| SAFETY-ERROR-01 | Central HTTP factory/subclasses and pre-stream failures share typed details, preserve status/code/message/type/param/request ID/raw body/cause/retry classification, and ignore malformed optional metadata. Policy 403 does not retry even with retry enabled. |
| SAFETY-ERROR-02 | Failed REST and response.failed streams expose the shared details. Names, const construction, public exports and old direct WS imports remain compatible. Parsed finite future JSON is deeply immutable; direct const collections stay caller-owned. |
| SAFETY-ERROR-03 | Canonical flat SSE nullable fields, optional beta agent and explicit legacy presence are retained through serialization, copies and value semantics. Required malformed known fields and public missing/nonstring discriminators fail contextually without values; unknown string dispatch stays lossless. |
| SAFETY-ERROR-04 | Public WS blocked-lane fixtures retain another lane and explicit subsequent writes without reconnect/replay/tool execution/acknowledgment/continuation. Offline example combines failures with exactly two explicit scoped lookups from verified notice data.id; review tokens/steer remain passive. |

Complete copies/clears/fresh nested replacements remove stale effective future
metadata; explicit parent raw overrides retain priority. Nonnull code/param cannot
be hidden by presence flags. AgentTag is typed only: explicit agent replacement
removes parent-held future keys, while omission or explicit parent raw preserves
them. Default diagnostics and automatic response/inline-error logs redact private
text, tokens and echoed identifiers before truncation. Original values remain
readable. Diagnostic decoding is best effort and preserves binary response identity
and bytes, including malformed UTF-8. Unrelated error formatting remains intact.

[README](../../../README.md#how-do-i-inspect-monitoring-failures), llms links,
[offline example](../../../example/monitoring_errors_example.dart),
[migration guidance](../../../MIGRATION.md#upcoming-structured-monitoring-errors)
and all ten manifest mappings are verified. Nullable `ErrorEvent.code` and flat
output are targeted breaking corrections; no package version or release changes.

## Verification

- **305 new focused cases pass on VM, real Chrome JavaScript and Wasm**: 120
  shared-model/WS cases, 123 SSE cases, nine public WS cases and 53 HTTP/REST/SSE/logging cases.
- Full package unit suite passes **13,541 tests with two existing environment skips**.
  Existing retry, webhook-secret privacy and recovery cases remain in this suite.
- All **550 package Dart files** and **2,673 repository Dart files** format unchanged
  with CI-stable Dart 3.13.5. Fix has nothing to apply; fatal-info analysis passes
  on Dart 3.12.2 and 3.13.5.
- Independent actual public runtime corpus: **183 cases / 682 assertions**,
  including **85 canonical serializations** (82 DTOs and three original HTTP
  envelopes plus separate typed extraction), two nullable component containers,
  16 explicit receive-only rows, 75 strict malformed-known rows and five invalid
  best-effort HTTP rows. Exact pinned schemas are used; compatibility deviations
  are never mislabeled canonical. Additional author corpora validate 45 shared
  outputs and 26 GA/beta flat SSE outputs against the same original schemas.
- Independent cross-author probes verify 54 HTTP combinations, 40 shared-model
  checks, monitoring parent privacy and binary response decoding. All validated
  findings are fixed with public regressions: escaped malformed metadata/policy
  markers, echoed headers, parent response/cache diagnostics, binary logging,
  malformed discriminator/error objects, nonnull presence consistency and stale
  nested agent metadata. Migration text records precise legacy normalization.
- Runnable offline example verifies three distinct POST failures followed by
  two scoped MockClient GETs from locally signed/verified notices. Literal README
  code compiles and runs independently with HTTP403, flat nullable error and
  failed response fixtures. No live request, real key or paid operation: **$0**.
- Full toolkit exports/docs/README checks pass. Diagnostics stay visible at
  **274 implementation errors / 78 warnings / 212 infos** and **35 consistency
  warnings**, compared with 270/74/213 and 35. Identity delta is eight additions,
  one removal and 12 unchanged diagnostics relocated to the shared file.
  Two new required-sequence reports describe explicit legacy omission tolerance;
  four equality/hash reports miss helper-based effective JSON; two GA/beta failed
  error reports cannot extract the nullable anyOf object. The old beta response
  type-alias info resolves. Runtime/schema evidence addresses these scanner limits;
  unrelated gaps remain visible without exclusions or checker changes.

Independent requirements and cross-author engineering reviewers approve the final
combined diff, docs/example/manifest and evidence with no open findings. All 253
local documentation file/anchor links resolve. The implementation issue remains
open until merge; Phase 5 Audio/Live requires its next planning specification and
ticket breakdown after this final Phase 4 ticket merges.
