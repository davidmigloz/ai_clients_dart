# Safety alert explanation acceptance

Status: implemented and independently approved for
[#382](https://github.com/davidmigloz/ai_clients_dart/issues/382),
[ticket 32](../tickets/32-safety-explanations.md), SAFETY-EXPLANATION-01–06.
Independent requirements and engineering reviews approve the final combined diff
with no open findings. [PR #384](https://github.com/davidmigloz/ai_clients_dart/pull/384)
merged October 9, 2026 at 12:34:17 UTC, squash
`08f9594dc73703e521aae4cb070a0be34509642a`, closing #382. All 14 exact-head
contexts completed (13 successes and the standard Test(all) skip) for reviewed
head `a35c993818a413cc93be89fef1f1b20faa704868`; no review findings remained.
The external status skipped full review for unavailable credits; the independent
local reviews supply the actual review evidence.

## Source contract and preservation

Fresh toolkit fetch/review and source heads retain OpenAPI
[0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json),
Python [c511a771 / 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08)
and Node [37af8fc9 / 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156).
The fetched normalized candidate equals the already-adopted canonical JSON
byte-for-byte, SHA256
`3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`.
No new source promotion or history entry is needed. The fresh toolkit metadata is
recorded separately; immutable adoption metadata is restored exactly from merged
HEAD, SHA256 `9eaafea8b1b0f922e6c063b1982858b83e8146bc4fde36bab81e420ab20b6d63`.
Actual describe/scaffold dry-runs target SafetyAlert/SafetyAlertResource without
creating replacement types or changing the toolkit.

Only SafetyAlertResource's optional nullable `detailed_explanation` is added to
the runtime. Removing this property makes the component equal the prior f6 pin;
the GET path and eight related Safety components are unchanged. The current
[HTTP retrieve reference](https://developers.openai.com/api/reference/resources/safety/subresources/alerts/methods/retrieve)
confirms the field. Neither pinned Python nor Node has the typed property yet.
It is temporarily available for eligible Zero Data Retention alerts and omitted
when unavailable; the sources give no duration. A null reason does not establish
eligibility. GA/Beta Responses MisalignmentErrorDetailsResource explanations
remain optional nonnull strings with their existing runtime behavior.

## Public behavior and compatibility

SafetyAlert exposes `String? detailedExplanation` and
`bool hasDetailedExplanation`. Parsing and serialization preserve absent,
explicit null, empty text and nonempty text without normalization. A constructor
with both new arguments omitted adopts a valid known field in legacy rawJson,
preserving existing raw-only construction. Explicit typed/presence arguments
take precedence, while malformed known raw values remain contextual errors.

Copy omission preserves both value and presence; `detailedExplanation: null`
retains a JSON null and `hasDetailedExplanation: false` removes the effective key
and value. True presence without a supplied value promotes absence to explicit
null. Nonnull text with false presence is rejected. Replacing rawJson on a copy
does not adopt, override or resurrect an explanation. Raw received metadata
remains finite, deeply immutable and separate from the effective serialized view;
it can still contain the original received explanation after effective clear.
Equality/hash cover complete effective JSON, including presence and future values.
Default diagnostics redact explanation/private metadata; contextual errors omit
private values. The existing required nullable reason is unchanged.

Actual MockClient GET fixtures use the public client and existing project route,
with project scoping, malformed-response privacy and changing availability across
explicit lookups. No new alert list, webhook field, control action, eligibility
validator, retention promise or automatic cache is added.

The runnable offline example covers absent/null/text/empty responses through four
GETs and verifies explicit copy/null/clear and redacted diagnostics. It closes its
caller-owned mock transport. README's literal public snippet demonstrates presence
and copy behavior. README, llms and the real existing SafetyAlert manifest note
track the additive API; no schema mappings, policies, exclusions or checker changes
hide remaining work. No release/version bump or live API cost.

## Validation gates

Package format processes 636 files with zero changes; fix finds nothing to apply.
Fatal-info analysis is clean on Dart 3.12.2 and 3.13.5, final format is clean, and
the full package suite passes 21,395 tests with two existing environment-dependent
skips. This adds 35 cases: 22 model and 13 public resource tests. All 140 model and
105 resource fixtures pass independently on VM, real Chrome JavaScript and real
Chrome Wasm. Frozen author source/test hashes remain unchanged by root quality.
The final offline example and literal README snippet both execute at $0 API cost.

Independent engineering executes 541 public assertions on both supported VMs,
with identical 35 serialized response snapshots validated against the actual
SafetyAlertResource GET schema and six explicit mock GETs. It separately reviews
the resource author's 105-case fixture and real runtime log hashes. Independent
requirements review covers the model/public contract, docs/source ownership,
retained 100-case Responses monitoring suite and unchanged GA/Beta nonnull field.
The resource author does not approve their own fixture; engineering covers it.
Final combined approvals bind exact source/docs/test/quality hashes.

All 60 llms source token annotations use the actual o200k_base encoder, totaling
143,610 tokens (displayed ~144k), while retaining the curated API prose. All 363
local file links across README/llms/notices and current alignment Markdown resolve;
the verbatim progress-history archive retains its prior historical content.
Only the existing SafetyAlert manifest note changes; all 1,083 type entries,
coverage policies, skips and checker behavior remain intact.

Full toolkit remains nonzero for retained later work: 941 errors / 126 warnings /
277 infos and 103 consistency warnings. Baseline is 945 / 127 / 277 with the same
103 consistency warnings. Exact issue multiset comparison adds no diagnostics and
removes four missing Safety field/parser/serializer/copy errors plus one default
representation warning. No current SafetyAlert finding remains; docs/exports/
README and existing consistency identities remain clean or unchanged as recorded.
Existing Agents/environment enum and later Administration/legacy coverage gaps
remain visible, without new exclusions or weakened verification.

Parent #317 remains open for Phases 6–8, durable Agents/Vaults,
Administration/storage, authentication and remaining SDK parity. No integration
or live smoke call was needed or run; no migration break or release/version bump.
