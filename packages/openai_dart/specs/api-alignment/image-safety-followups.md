# Decisions image URLs and Safety explanations: source refinements

Status: Decisions URL ticket 31 is being implemented; Safety explanation ticket 32
is specified separately. Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
All 30 original implementation tickets merged through PR #380; these are later
source refinements, not evidence that Phases 6–8 or complete SDK parity are finished.

## Sources and discrepancy decisions

Fresh October 9 toolkit fetch/review pins OpenAPI
[0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json),
Python [c511a771 / 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08)
and Node [37af8fc9 / 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156).
The new Node commit changes mock test cleanup/CI only, without production SDK
changes; actual Decisions and Safety resource/type files equal the previous pins.
The candidate has 358 operations/2,039 schemas. Promotion and global delta
classification are recorded in the implementation acceptance review.

The 27-schema Decisions request/response closure changes only four component
descriptions, the DecisionInputImage.image_url pattern and the POST description:
seven normalized leaves: four component descriptions, the image_url property
description, its pattern, and the POST description. The current [HTTP create reference](https://developers.openai.com/api/reference/resources/decisions/methods/create)
agrees with canonical `^(data:|https?://)`. The original guide/examples and
Python/Node type prose still describe inline-only inputs; follow current canonical
schema/reference rather than the stale prose. All other 26 component wire structures remain
unchanged. No new endpoint, file reference, model or streaming mode is introduced.

Safety changes only optional nullable SafetyAlertResource.detailed_explanation;
removing that property makes the component equal the earlier pin. Its GET path
and eight actual related Safety case/enum/webhook components are unchanged.
[The HTTP retrieve reference](https://developers.openai.com/api/reference/resources/safety/subresources/alerts/methods/retrieve)
and canonical field establish the contract; neither pinned SDK has a typed field
yet. The generated explanation is temporarily available for eligible zero data
retention alerts and omitted when unavailable; reason being null does not prove
eligibility. Keep this separate from Responses MisalignmentDetails.detailed_explanation,
which is optional nonnull and has its own established contract.

## Decisions URL requirements

- **DEC-URL-01:** Existing image constructor/factory, part/message/input parsers and
  copies admit exactly case-sensitive prefixes `data:`, `http://`, `https://`.
  Preserve the original string, including escapes/query/fragment/Unicode.
  Canonical prefix-only minima remain admitted; validity and public accessibility
  are checked by the service. Do not add URI normalization, host checks, local
  image downloads, base64 sniffing or a different URL grammar.
- **DEC-URL-02:** Existing data URLs and imageBytes MIME/base64 output remain
  unchanged. Preserve detail/null-to-omission, all four detail variants, mixed
  part order, equality/hash and redacted diagnostics. No existing API break.
- **DEC-URL-03:** Known malformed discriminators/fields and unsupported schemes,
  uppercase/whitespace prefixes, raw base64 and file IDs remain contextual errors.
  URL-prefix validation uses ArgumentError in factories/copies and FormatException
  in JSON parsers, without including private image URLs. Existing detail-copy
  casting behavior is outside this additive change. Existing request limits/roles remain unchanged.
- **DEC-URL-04:** Public mock POST fixtures transmit exact remote URLs alongside
  data/text evidence to the existing endpoint. The client sends one selected
  request; it does not fetch the referenced URL or add another transport action.
- **DEC-URL-05:** README/llms and a runnable offline example demonstrate both
  supported remote schemes plus inline bytes, with $0 API cost. The original live
  example remains available. Update real manifest descriptions, without fake
  schema mappings, checker edits or new skips. Canonical/public assertions and
  independent requirements/engineering review cover the final diff.
- **DEC-URL-06:** Format → fix → fatal-info analysis on supported SDKs, package
  unit tests, focused VM/Chrome JS/Wasm and exact final-head CI pass before merge.
  Record all existing/new toolkit diagnostics honestly, and preserve later
  Safety/Agents/Admin/legacy gaps separately.

## Safety explanation requirements (separate pending slice)

- **SAFETY-EXPLANATION-01:** Typed optional nullable string accessor and presence
  preserve absent/null/string from public retrieval, including empty text.
- **SAFETY-EXPLANATION-02:** Constructor/parser/copy reject malformed known types
  contextually; raw future JSON cannot override or resurrect the known field.
- **SAFETY-EXPLANATION-03:** Copy omission preserves, explicit null retains null,
  and deliberate clear removes the key. Preserve immutable raw ownership and
  complete equality/hash semantics; do not conflate absent with explicit null.
- **SAFETY-EXPLANATION-04:** Default diagnostics redact explanation and private
  metadata; callers access the actual explanation explicitly.
- **SAFETY-EXPLANATION-05:** Actual mock GET fixtures exercise all presence states
  and errors through existing retrieval; no new alert list/webhook field, local
  eligibility validator, retention promise, automatic caching or control action.
- **SAFETY-EXPLANATION-06:** Additive docs/offline example, genuine manifest,
  focused/public value fixtures, supported-platform quality, independent reviews
  and exact published-head CI. Preserve the separate nonnull Responses field.

## Ordering and retained work

[Ticket 31](tickets/31-decision-image-urls.md) depends on merged Decisions #318;
[ticket 32](tickets/32-safety-explanations.md) depends on merged Safety #359.
They are independently usable and get separate PRs; neither requires the other.
No live smoke, publishing or version bump is required. The user's existing bounded
low-cost live-test authorization remains available if later needed.

Safety, durable Agents/Vaults, Administration/external storage, federation/mTLS,
legacy lifetime migrations, shared models and SDK helper conveniences remain
visible in [the roadmap](README.md). Completing these two small refinements will
not establish full parity or close the parent prematurely.
