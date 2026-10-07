# Image model selection review and acceptance evidence

Reviewed October 7, 2026 against IMG-01–04 in the
[Phase 2 specification](../correctness.md).
Tracking: [#326](https://github.com/davidmigloz/ai_clients_dart/issues/326),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Implementation branch: `fix/openai-image-model-required`.
Implementation [PR #333](https://github.com/davidmigloz/ai_clients_dart/pull/333) merged
October 7, 2026 after all final-head CI checks passed, closing #326. Merge commit:
`5eae6db755775d904cfe19df3f22e1bd26dedb73`.
Package validation and independent reviews passed.

## Outcome and contracts

ImageGenerationRequest and multipart ImageEditRequest require explicit nonnull
String models. Generation JSON always emits the model and validates required
model/prompt strings with contextual FormatException for missing/null/wrong types.
Multipart edit and editStream share the builder that always writes selected model.
Arbitrary IDs and empty strings are forwarded unchanged; no injected default,
enum allowlist, or additional backend model validation is introduced.

Required copy model null/omission retains the previous model, consistent with
other required fields; strings replace it. All 14 generation fields have full
serialization/copy/value/hash/diagnostic coverage and all 12 optional clears.
All 18 multipart-edit fields participate in copy/value/hash/diagnostics, including
source/mask byte contents, with all 14 optional clears. Different images with equal
filenames/options no longer compare equal. Caller buffer ownership and const
constructors remain. Diagnostics summarize opaque contents safely. Multipart
bytes serialize at the resource boundary; no invented JSON upload-byte model
encoding/parsing is added.

JSON editing retains its distinct optional nullable model: omission/null remains
omitted in editJson and editJsonStream, so the API can apply its documented
sunburst default. Explicit arbitrary models remain unchanged. Existing variations
and the Responses image-generation tool keep their separate optional contracts.
No unrelated model convenience or legacy endpoint change is introduced.

## Sources and workflow

A fresh candidate is semantically identical to canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
No promotion or metadata-history change was necessary. Fetch/review and generation
describe preceded implementation; canonical request bodies were inspected directly
for the previously unregistered edit schemas. Both new mappings were then
described, and a generation scaffold dry-run completed before final verification.
No beta image-request alias was invented.

The canonical schemas are CreateImageRequest (generation), CreateImageEditRequest
(multipart), and EditImageBodyJsonParam (JSON edits). The
[generation reference](https://developers.openai.com/api/reference/resources/images/methods/generate)
explicitly requires model selection; the
[editing reference](https://developers.openai.com/api/reference/resources/images/methods/edit)
and exact schema distinguish content types. Checked
[Python 3.26 generation parameters](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/image_generate_params.py)
and [Node 7.30 image parameters](https://github.com/openai/openai-node/blob/v7.30.0/src/resources/images.ts)
still expose optional nullable generation/multipart model signatures. This targeted
breaking correction follows the canonical/documented API under the user's accepted
compatibility policy instead of copying that discrepancy.

## Validation

| Check | Result |
| --- | --- |
| `dart format --show=none --summary=line .` | Passed, zero changes on final run |
| `dart fix --apply` | Nothing to fix |
| `dart analyze --fatal-infos` | Passed, no issues, including examples/integration source |
| `dart test --reporter=failures-only test/unit/` | 2,537 passed, two existing environment-dependent skips |
| Focused image model/contract suites | 98 passed |
| Focused resource/stream/multipart suites | 134 passed |
| Public fixtures | 27 added fixtures verify exact generation/edit/stream model fidelity, all options, multipart bytes/MIME/filenames, omitted/null JSON-edit models, response/event results and preserved variation behavior |
| Model contracts | All 14 generation/18 multipart fields, independent exact replacement/clear expectations, byte-content equality/hash, const/caller ownership and safe diagnostics |
| Toolkit `verify --checks all --scope all` | Exports/docs/README pass; wider diagnostics explained below |
| `generate-llms-txt` | Example descriptions/token estimates refreshed |
| Runnable local example | Passed, no key/network/API cost |
| `git diff --check` and final format check | Passed |

There are 83 additional deterministic unit tests relative to merged #332.
Public canonical response and SSE fixtures include required metadata; image data
is synthetic and no external service is contacted.

The local `example/image_model_selection_example.dart` executed successfully:
explicit generation and multipart IDs, omitted JSON-edit model, and an arbitrary
explicit JSON-edit ID. It uses MockClient, drains request bytes, and needs no key,
network, or API cost. After-migration construction appears in the analyzed/runnable
example. Existing image examples, integration source, and client dartdoc were
analyzed; the affected examples already selected explicit models. No live image
integration suite or paid image example was executed. Existing legacy DALL-E live
cases are outside this slice; documentation now uses current GPT models and notes
the official May 12, 2026 retirement without removing compatibility identifiers.

Dart commands run from packages/openai_dart; toolkit commands run from repository
root with --config-dir packages/openai_dart/.agents/skills/openapi-openai/config.

## Independent reviews and resolved findings

A requirements reviewer authored none of this slice. Model/resource authors
cross-reviewed source and fixtures plus root's docs/example/manifest. Resolved
findings include:

- Complete source/mask byte-content equality/hash instead of retaining partial
  filename/options identity in the changed multipart model.
- Make copy replacement tables assert independent exact JSON/getter values and
  every untouched field, rather than inequality that could miss same-type miswires.
- Consume MockClient.streaming ByteStream before decoding JSON in the local
  example; drain multipart content too.
- Separate historical Before and valid After migration fences so the new example
  is independently compile-checkable.
- Preserve arbitrary/empty model values, explicit-null JSON edit omission, streaming
  overrides, source/mask MIME/bytes/filenames, and unrelated variation behavior.
- Register actual generation/multipart/JSON schemas and explain multipart JSON
  verifier limitations instead of inventing an upload-byte JSON representation.
- Replace stale client DALL-E generation advice with current GPT image examples
  while keeping legacy API identifiers and options for compatibility.

The requirements reviewer and both cross-author standards reviewers approve the
combined source, fixtures, docs, and mappings. No validated findings remain.

## Wider diagnostics and boundaries

Toolkit reports 41 implementation errors, ten implementation warnings, 103 infos,
and one consistency warning. Exports/docs/README pass. Relative to #332's
39 errors/88 infos, the generation-model requiredness error is resolved (-1),
while real mappings expose two generic multipart missing-JSON-method diagnostics
and one existing missing JSON-edit copy method (+3). Additional infos describe
existing typed enums, binary/reference representations, and model names. Full
public multipart fixtures verify actual serialization outside JSON model methods;
the separate JSON-edit copy/value/diagnostic gaps remain in the parity inventory.
No skip/exclusion or verification-scope reduction was added. Remaining wider
findings are unchanged from [retry guidance](07-retry-guidance.md).

The required sibling audit found no typed image DTO/tool counterpart in
open_responses. Existing openai_dart Responses ImageGenerationTool optional model
has a separate schema and is untouched. Retired OpenAI models cannot be restored
by keeping client identifiers; service availability is not claimed by this patch.

This is the last specified Phase 2 ticket. Phase 3 Responses capabilities require
their own refreshed specification and independently useful implementation tickets.
Administration, other API families, package versioning, and release remain
separate milestones.
