# Safety retrieval implementation acceptance

Status: implemented, independently reviewed and verified; PR #364 open, merge pending.
Implementation [PR #364](https://github.com/davidmigloz/ai_clients_dart/pull/364) is open for review; #359 stays open until merge.
Tracking: [#359](https://github.com/davidmigloz/ai_clients_dart/issues/359),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [SAFETY-READ-01–03](../webhooks-safety.md).

## Source evidence

Fresh October 8 reads confirm unchanged affected contracts at
[OpenAPI 506aff0a](https://github.com/openai/openai-openapi/blob/506aff0a8099581b50e119b87f8f2692cdad043f/openapi.json),
[Python 3.26.1 / 9301e319](https://github.com/openai/openai-python/blob/9301e319ea33ef28fba380f39a289dedc14652c1/src/openai/resources/safety/alerts.py)
and [Node 7.30.1 / bc6c0bfb](https://github.com/openai/openai-node/blob/bc6c0bfb70f253d5caa3f335699e9713ea9067b5/src/resources/safety/cases.ts).
Thirteen pinned official files have independently checked hashes. Canonical
JSON equals the fresh candidate; toolkit fetch/review reports no wire changes.
The existing pin and historical metadata remain intact, with actual fetch time
`2026-10-08T12:41:10.594544Z`. Five describe/scaffold pairs cover the five real
components; no fabricated schema, exclusion or checker change is introduced.

The alert, case and notice schemas omit `additionalProperties`: these are open
objects. Both nullable reasons are required in OpenAPI and Node. Python's
omission default does not override canonical requiredness. The two closed
canonical enums contain four alert categories and two notice types. Received
future strings are an explicit compatibility tolerance, retained through known
`unknown` choices and exact `rawErrorType` / `rawType` companions.

## Accepted contracts and public behavior

| Requirement | Runtime implementation and evidence |
| --- | --- |
| SAFETY-READ-01 | Cached `client.safety.alerts.retrieve` and `safety.cases.retrieve` implement only the two GET routes. IDs are encoded once, with maxima 38/128 Unicode scalar characters and no invented prefix grammar. Empty, `.` and `..` are rejected only because URI normalization cannot route them as individual resources; `...`, percent text, slash, query/fragment characters and emoji are tested. Shared authentication, headers, status/request-ID exceptions, retries, abortion, close guard and borrowed transport ownership remain intact. |
| SAFETY-READ-02 | Nine alert fields, six case fields and notice type remain required, including nullable reasons and false paused state. Fixed object values, all known enum choices, safe malformed JSON/UTF-8 diagnostics, deeply immutable finite future JSON, full copy/clear/replacement, effective equality/hash and redacted diagnostics have public fixtures. Typed fields override stale raw fields; replacing a child drops the old child's metadata. |
| SAFETY-READ-03 | Verified notifications drive explicitly scoped lookups using `data.id`. Notification `event.id` and application `entityIdentifier` remain distinct. Project keys require `api.safety.alerts.read`; organization cases use a restricted key for the notified organization with `api.safety.read`. The parser never authenticates or fetches. Workspace notices retain the separate host/administrator permission boundary and Phase 7 inventory. |

All five real manifest mappings, both public enum/model exports, the namespace
and child resources, constructor/client-factory paths, README coverage/usage,
llms links and [offline example](../../../example/safety_example.dart) are verified.
This read-only addition requires no migration or version bump.

`requestPaused` describes block registration, without confirming execution
stopped or earlier effects were reversed. Alert reason is a category description,
not a transcript or full investigation report; null includes Zero Data Retention.
Workspace `safety.org_alert.created` lookup remains at
`https://api.chatgpt.com/v1/safety/alerts/{id}` with a workspace administrator key
and `chatgpt.enterprise.safety_alerts.read`. No project-key routing or unsupported
workspace response guarantee is added. Structured monitoring HTTP/failed-response
details and flat SSE corrections remain [#360](https://github.com/davidmigloz/ai_clients_dart/issues/360).

## Verification evidence

- Focused public fixtures: 210 cases (118 model and 92 resource) on Dart VM,
  real Chrome JavaScript and Chrome Wasm; all three runtime receipts pass on the corrected final code.
- Independent actual Dart serialization: 106 canonical schema cases across all
  five components (69 alerts, 18 cases, 13 notices, four alert enum choices and
  two notice choices). Nine additional future-enum cases each have exactly the
  expected canonical closed-enum rejection, classified as receive-only tolerance.
  All schemas are the pinned originals; no reconstructed permissive substitutes.
- Independent runtime probes: 309 canonical/value/ownership checks plus 259
  separate engineering checks on the corrected final models.
- The runnable example uses exactly two separately scoped MockClient GETs after
  original-byte signature verification. Duplicate, workspace and tampered
  notices cause no additional lookup. Reasons and identifiers are not printed.
- The exact README function compiles and runs in two independent fixture drivers:
  two scoped GETs in the package driver, three in the reviewer driver covering
  both warning and deactivation. Workspace routing and pre-lookup tamper rejection
  are checked independently. Neither driver contacts an external API.
- All 542 Dart files format unchanged; fix reports nothing to apply and
  fatal-info analysis reports no issues. The full package suite passes
  **13,236 tests with two existing environment skips**.
- Full toolkit scope passes exports, docs and README checks. Existing implementation
  diagnostics remain visible at **270 errors / 74 warnings / 213 infos**, with
  **35 consistency warnings**. Identity comparison against the merged endpoint
  baseline (271 errors) has **zero additions and one removal**: the previous
  missing Safety resource. The serializers reference their actual typed fields;
  unrelated gaps are retained without fake schemas, exclusions or toolkit changes.

No live API request, real credential, test delivery, enforcement change, general
resume action or paid operation was performed. Cost: **$0**.

## Review findings and resolution

Independent source/requirements review corrected the notice manifest note:
`SafetyCaseNotice` requires type, without a reason field. Resource wording now
names only the exact unusable `.` and `..` segments; `...` has a regression test.
Compile verification corrected OR-pattern bindings to preserve the concrete
nonnullable notification data type in both example and literal README.

During serializer organization, a mechanical edit introduced case recursion.
Independent engineering review caught it before publication. Explicit complete
typed serializers corrected it; all model/resource fixtures and both independent
schema/runtime corpora were rerun on the corrected model hash. Effective value
comparison delegates to actual serialization, keeping typed/raw precedence and
equality/hash aligned without adding duplicate serialization or scanner exclusions.


The first CI run identified a formatter-version difference: local Dart 3.12.2
had accepted one fixture layout that CI's stable Dart 3.13.5 reformatted.
The single resource-test call layout was updated with the CI SDK; stable root
format checking and focused VM fixtures were rerun. Product/model behavior is
unchanged. Current published documentation has 159 valid local file links.

Independent requirements and cross-author engineering reviews approve the final
23-file combined diff with no open findings, after validating the corrections and
current source/model/runtime hashes. All 159 local documentation links resolve.
PR/CI status is recorded separately. #359 remains open until its
implementation PR merges; #360 follows it.
