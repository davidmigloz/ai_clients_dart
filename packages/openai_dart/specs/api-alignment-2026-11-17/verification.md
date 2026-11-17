# November 17 OpenAI alignment verification

The November 17, 2026 snapshot has 388 HTTP operations, 31 webhook operations
and 2,283 component schemas. The [source pins](README.md#source-pins) identify
the OpenAPI revision and the official Python 3.53.0 and Node 7.58.0 snapshots.
The checked-in canonical file matches the toolkit candidate byte for byte.
Its parsed JSON matches the immutable upstream file. Both digests and the
previous source pin are recorded in [spec metadata](../spec_metadata.json).

## Implementation evidence

The [inventory](inventory.json) retains all 642 source and supplemental
records, including documentary changes and equivalent discriminator syntax.
Each record has one primary owner. Shared image, cache and namespace models
also name Live as a consumer where required. Each implementation below had
an independent adversarial review, including a re-review of subsequent fixes.

The normalized toolkit diff identifies 12 added and one modified HTTP
operation. The modified operation is Agent event streaming with the new
`include_obfuscation` query parameter. The full inventory also captures
three raw operation revisions, the new webhook, and 77 added and 78
normalized modified schema components.

| Issue | Public-path evidence |
| --- | --- |
| [#569](https://github.com/davidmigloz/ai_clients_dart/issues/569) | HTTP background completion windows and constraints, continuation IDs, input transformations and distinct Responses TTLs and cache usage. [PR #581](https://github.com/davidmigloz/ai_clients_dart/pull/581) |
| [#570](https://github.com/davidmigloz/ai_clients_dart/issues/570) | Buffered GIF and SVG requests, image edit rules, context compression, SVG usage and typed Responses and Conversation image history. [PR #582](https://github.com/davidmigloz/ai_clients_dart/pull/582) |
| [#571](https://github.com/davidmigloz/ai_clients_dart/issues/571) | Classifier category, score and applied-input decoding through the moderation resource, with synthetic fixtures and diagnostic redaction. [PR #583](https://github.com/davidmigloz/ai_clients_dart/pull/583) |
| [#572](https://github.com/davidmigloz/ai_clients_dart/issues/572) | Agent event padding preference, spending pauses, cache metadata and automation pause reasons through REST and SSE. [PR #584](https://github.com/davidmigloz/ai_clients_dart/pull/584) |
| [#573](https://github.com/davidmigloz/ai_clients_dart/issues/573) | Agent async functions and MCP approvals through turn input, session state, streams and webhook summaries. [PR #585](https://github.com/davidmigloz/ai_clients_dart/pull/585) |
| [#574](https://github.com/davidmigloz/ai_clients_dart/issues/574) | Live Responses delegation, startup safety identifier, signed transport webhook, protected MCP credentials and shared Live image, cache and namespace replay. [PR #586](https://github.com/davidmigloz/ai_clients_dart/pull/586) |
| [#575](https://github.com/davidmigloz/ai_clients_dart/issues/575) | Both project service-tier routes, partial updates, OCI external-key registration and bodyless validation. [PR #587](https://github.com/davidmigloz/ai_clients_dart/pull/587) |
| [#576](https://github.com/davidmigloz/ai_clients_dart/issues/576) | Ten workload identity routes, paging, nullable updates and credential isolation. [PR #588](https://github.com/davidmigloz/ai_clients_dart/pull/588) |
| [#577](https://github.com/davidmigloz/ai_clients_dart/issues/577) | AU, IN and JP routing, spend-cap errors, model shutdown dates and shared function output namespaces. [PR #589](https://github.com/davidmigloz/ai_clients_dart/pull/589) |
| [#578](https://github.com/davidmigloz/ai_clients_dart/issues/578) | Nullable OpenAPI enum review, verification and Dart codec scaffolding, including an escaped Unicode round trip. [PR #590](https://github.com/davidmigloz/ai_clients_dart/pull/590) |

The 12 newly declared HTTP operations are all exercised through the public
Admin client. The [project fixtures](../../test/unit/resources/admin/admin_service_tiers_and_oci_test.dart)
cover GET and POST service-tier settings. The
[federation fixtures](../../test/unit/resources/admin/admin_workload_identity_test.dart)
cover list, create, retrieve, update and delete for both providers and rules.
The [Live delegation tests](../../test/unit/resources/live_delegation_alignment_test.dart)
cover authenticated decoding of the new `live.transport.connected` event.
Subscription selection also accepts the wire event string through the public
registry API. The pinned project subscription enum has yet to declare it.

## Reconciled scope

- The common Responses entry points accept GPT-6.2 Sol and Astra as model
  strings. The quickstart and first usage examples use Sol. Gated model
  availability, including GPT-6 Cyber, follows the service's account policy.
  Existing Live SIP call creation covers the outbound availability announcement.
- The [README](../../README.md) keeps common Responses usage first and usage
  topics collapsible. The [example index](../../llms.txt) and
  [migration guide](../../MIGRATION.md) cover new entry points and breaking
  model, enum and override changes. Evals, reusable prompts and Agent Builder
  have a November 30, 2026 sunset. Image workflow and model replacements have
  December 1, 2026 and February 10, 2027 dates. The README links to the dated
  notices and model migration guidance. [OpenAI deprecations](https://developers.openai.com/api/docs/deprecations)
- Live applies shared wire parsing to received and replayed tool settings.
  The service validates cross-field GIF and SVG authoring options for Live.
  The Responses HTTP authoring path also performs client-side validation.
- Historical Admin audit-log support, including the new API-key expiry audit
  field, and provider-specific runtime acquisition of workload assertions
  remain deferred. The regular client can use the existing credential
  extension point with externally obtained tokens.
- Rich Responses WebSocket progress snapshots remain an optional SDK
  convenience. The existing overflow isolation was retained and exercised.
  The [October closure](../api-alignment-2026-10-31/README.md) still records
  earlier coverage limits. [HTTP/2 #408](https://github.com/davidmigloz/ai_clients_dart/issues/408)
  remains independent and gated on transport compatibility.

## Integrated checks

Dart 3.13.7 formatted 891 package files with zero changes. Fatal-info analysis
passed for `openai_dart` and `open_responses`. The VM unit suites passed
26,899 and 547 tests respectively, with two and three environment-dependent
skips. Unsetting the credential environment variable exercised the opposite
configuration branches in both packages. Five public-request fixture files
passed 32 tests on each Chrome target, JavaScript and WebAssembly.
The background, classifier, Agent settings and approvals, Live delegation,
Admin, federation and runtime configuration examples ran offline. The Dart
package publication dry run reported zero warnings.

Stock toolkit `review`, `verify --checks all` at both scopes, and the
`complexity` enum scaffold dry run ran against the frozen candidate.
The toolkit unit run for #578 passed all focused tests. The full Python suite
retained its five pre-existing skill-contract failures, reproduced on the
baseline. The eight managed package configurations returned identical
verification output for their existing canonical schemas before and after
the shared toolkit fix.

| Toolkit check | October source and manifest on the assembled client | November source and manifest | November changed scope |
| --- | ---: | ---: | ---: |
| Implementation errors / warnings / infos | 1,041 / 246 / 355 | 1,268 / 270 / 374 | 352 / 46 / 121 |
| Consistency errors / warnings | 0 / 127 | 0 / 129 | 5 / 44 |
| Export findings | 10 | 10 | 10 |
| Docs and README errors / warnings | 0 / 0 | 0 / 0 | 0 / 0 |

The whole verifier still exits with findings. The ten export findings concern
the same existing private helper files. Its resource filename heuristic also
reports the same seven existing webhook management routes in both full runs.
The package exercises the routes through its Webhooks resource. No skip,
coverage exclusion or public export was added to clear a verifier finding.

Review selected 155 changed types and reported 357 errors and 46 warnings,
including five contextual entries counted again by the changed consistency
check. The schema fragments `CreateModelResponseProperties` and
`BetaCreateModelResponseProperties` compose their containing Chat and
Responses classes. The scalar components `frame_count`, `frame_duration_ms`
and `safety_identifier` are declared by their containing request, result or
event models. These five records link to actual carriers in the manifest
metadata. The matrix below records the remaining categories encountered in
changed scope.

| Diagnostic area | Disposition |
| --- | --- |
| Agent stream obfuscation | Shared event decoding preserves padding in raw event data. Variant-specific fields, copies and diagnostics avoid coupling callers to it. |
| Request enums and immutable records | Closed write enums validate supported values. Several new read/write DTOs use explicit constructors and shared codecs, so the generic verifier also reports missing convenience copies or fixed discriminator getters. |
| Composed wire shapes | Flattened Responses WebSocket requests and inherited or shared Live, Agent and Webhook codecs are exercised through their public entry points. The discounted background window is HTTP-only. |
| Aliases and context-dependent requiredness | Dart's `defaultTier` carries the Admin `default` field. Shared SVG options are optional in some contexts and checked on the generation request. |
| Existing wire differences | Previously omitted Responses fields, model `created` and `owned_by` fields, and historical function output `name` and `call_id` compatibility are outside the changed contract. The newly widened `namespace` is covered by typed creation and replay. |
| New endpoint checks | The root-wide Admin exclusion remains visible in the toolkit config. All 12 newly declared operations have explicit mock route fixtures under their owning tickets. |

The merged client and migration guide are ready for a separately approved
major release. Validation used offline fixtures. GitHub records the final
reviewed head and CI checks in the [closeout issue](https://github.com/davidmigloz/ai_clients_dart/issues/579).
