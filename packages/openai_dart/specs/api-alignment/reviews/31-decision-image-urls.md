# Decisions image URL acceptance

Status: implemented and independently approved for [#381](https://github.com/davidmigloz/ai_clients_dart/issues/381),
[ticket 31](../tickets/31-decision-image-urls.md), DEC-URL-01–06.
Independent requirements/publication and engineering reviews approve the final
combined diff with no open findings. [PR #383](https://github.com/davidmigloz/ai_clients_dart/pull/383)
merged October 9, 2026 at 07:54:42 UTC, commit
`bc89ad9a8fb79d889e7945030fa9f6524d73d781`, closing #381. All 14 exact-head
contexts completed (13 successes and the standard Test(all) skip) for reviewed
commit `72d9918bf8f557f40352c2969514b8911385e686`; no review findings remained.
[PR #380](https://github.com/davidmigloz/ai_clients_dart/pull/380) merged at
`a7907e4dc747190cc6ec36ede27b53fda9acb1c5`, closing the last of the 30 original
implementation tickets. This follow-up does not close the remaining parity parent.

## Source and promotion

Fresh toolkit fetch/review inspects OpenAPI
[0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json),
Python [c511a771 / 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08)
and Node [37af8fc9 / 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156).
The newest Node commit changes only mock-daemon cleanup/CI; actual Decisions and
Safety SDK files match the prior reviewed pins. The SDK type prose and original
Decisions guide still describe inline-only images. The current
[HTTP create reference](https://developers.openai.com/api/reference/resources/decisions/methods/create)
agrees with the widened canonical prefix; this source discrepancy is explicit.

The actual 27-component request/response closure has seven normalized changes:
four component descriptions, image_url's description/pattern, and the POST
description. Only the image_url pattern changes wire structure, from `^data:` to
`^(data:|https?://)`. Other 26 component wire structures and all request/response
fields, requiredness, details, question/answer contracts and limits are unchanged.

The reviewed candidate is promoted to canonical JSON with actual immutable-source
fetch at 07:22:02.257304 UTC. Toolkit-normalized candidate SHA256
`3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`
differs in formatting from the raw immutable file SHA256
`ff5a4408cabb13e09430813b67a59f67366a58a4dec1f20bac89e4c96fab7fb5`;
parsed dictionaries are identical. The original toolkit main fetch at 07:10:23
retains its separate receipt; canonical metadata identifies the independently
fetched immutable URL/time. Prior f6 metadata/history entries are preserved,
with its exact prior timestamp/source recorded in the appended history.

Independent global comparison reproduces all 124 normalized differences:
seven Decisions leaves implemented here, one optional nullable Safety property
pending [#382](https://github.com/davidmigloz/ai_clients_dart/issues/382), and 116
Agents leaves pending Phase 6, including shifted array indices/lengths.
Twelve schemas and two environment HTTP operations are new; the candidate has
358 operations/2,039 schemas. Promotion makes those remaining contracts visible
without claiming their runtime implementation or full SDK parity.

## Requirements and public behavior

Existing image factory/constructor, JSON parsers through part/content/message/input
and requests, and copies admit exact case-sensitive `data:`, `http://`, `https://` prefixes.
No URL normalization, URI/host validation, DNS request, image download or base64
sniffing is added. Prefix-only minima (`data:`, `http://`, `https://`) reflect the
schema's actual pattern; the service checks validity and public reachability.
Original URL suffixes/escapes/query/fragment/Unicode remain literal JSON data.

URL-prefix constructor/copy validation raises ArgumentError; JSON raises a private
contextual FormatException. Wrong types, discriminators, detail values and
unsupported prefixes remain covered. Existing detail-copy casting semantics are
outside this additive update. Data URL/imageBytes MIME/base64 output and the four
detail values remain compatible; optional/null detail still normalizes to omission.
Image value/hash contracts and default private diagnostics remain intact.

The actual mock POST sends mixed image/text evidence through the existing public
resource, preserving part order and URLs. No other request/action occurs. The
new offline example exercises HTTP, HTTPS and inline byte references, exact
strings/order/details and a typed predicate answer, then closes its caller-owned
mock transport explicitly. README's literal image snippet and original text
workflow execute offline. README/llms and public request/resource comments reflect
the widened input, alongside the documented source lag and service checks.
The original live Decisions example remains available and was not run.

All 1,083 manifest entries/top-level policies remain intact; only the real
existing image union note changes. Actual describe/scaffold dry-runs for the
canonical DecisionInputImage succeed without generating a replacement. No fake
component, checker edit, new skip, migration break or version bump.

## Validation and independent reviews

The frozen three author files pass all 76 focused cases on stable Dart 3.13.5 VM,
real Chrome JavaScript and real Chrome Wasm. The full package suite passes
21,360 tests with two existing environment-key skips, adding 25 net cases.
Package format processes 635 files (only the new example changes); fix applies
two const quick fixes to that example. Fatal-info analysis is clean on both
Dart 3.12.2 and 3.13.5. The final offline example/README executions cost $0.

Independent engineering executes 1,214 public assertions on both supported VMs,
with identical 56 serialized snapshots. JSON Schema validates all 56 actual
requests, 11 positive canonical prefixes/minima and 18 rejected prefixes.
Independent requirements review adds a 154-string public corpus with 3,015
checks and one literal mock POST. Both reviews bind exact frozen source/test
hashes and actual VM/browser log receipts, without authoring these files.

Full toolkit remains nonzero: 945 errors / 127 warnings / 277 infos and 103
consistency warnings, compared with 937 / 126 / 277 and 103. Exact multiset
comparison adds nine diagnostics and removes none: four Safety property/parser/
serializer/copy errors plus a lexical toString expectation belong to pending #382;
four missing Agents environment event enum values remain Phase 6 inventory.
There is no Decisions diagnostic delta. Docs/exports/README are clean; consistency
identities, prior findings, coverage gaps and endpoint-action mismatches are
retained and checked. No checker or exclusion changes hide these findings.

The separate Safety ticket uses the actual merged #359 prerequisite and remains
unchecked/unimplemented. Agents/Vaults, Administration/storage, authentication,
legacy lifetimes and shared SDK conveniences stay in the roadmap. All 30 old
children are closed; the two new refinement tickets are independently tracked.
Published-head CI, feedback and user-authorized merge passed after this local
acceptance snapshot, as recorded above. The following Safety slice updates its
own current progress without rewriting this review's source/test receipts.
