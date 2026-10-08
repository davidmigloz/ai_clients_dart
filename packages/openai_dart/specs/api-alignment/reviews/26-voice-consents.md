# Voice consent management acceptance

Status: implementation verified; independent requirements and cross-author
engineering reviews approve. Runtime [PR #376](https://github.com/davidmigloz/ai_clients_dart/pull/376) merged
October 8, 2026 at 20:13:36 UTC, squash `2856c21eed697b7ec24a79e70e66800fe5ec0b79`; #368 is closed.
[#368](https://github.com/davidmigloz/ai_clients_dart/issues/368),
[ticket 26](../tickets/26-voice-consents.md), AUDIO-CONSENT-01–03 in the
[Phase 5 specification](../audio-live.md).

## Source and genuine mappings

Reviewed [OpenAPI b2751c66](https://github.com/openai/openai-openapi/blob/b2751c6625493c9c64db21b1b26a4d9300e589e3/openapi.json)
is adopted with actual fetch/source metadata and the prior 239c receipt archived.
Exactly three normalized leaf changes narrow VoiceResource.type to audio_sample,
already inventoried in pending #369. All five consent operation/component roots
are byte-semantically unchanged; each canonical response/request object is closed.
Python head [8e1fd258](https://github.com/openai/openai-python/commit/8e1fd2587deae364367e791385997ab45aa2a520)
changes only tests/test_uv_workflows.py, leaving 3.26.1 runtime code unchanged.
Node bc6c0bfb / 7.30.1 is unchanged. The official [Audio reference](https://developers.openai.com/api/reference/resources/audio)
lists the five consent operations despite their absence from the pinned SDK
resource implementations; canonical/reference governs this addition.

All five genuine roots have describe/scaffold dry-run receipts and object manifest
mappings: CreateVoiceConsentRequest, UpdateVoiceConsentRequest, VoiceConsentResource,
VoiceConsentListResource and VoiceConsentDeletedResource. The CLI cannot describe
unregistered types, so a temporary discovery config bound these actual components
before final mapping registration; it is removed. Create is explicitly a binary
multipart component without an invented JSON factory/encoding. Its JSON/binary
scanner limitations remain visible, verified by actual public multipart fixtures;
there is no new skip/tag, fake schema or checker exclusion/change.

## Requirement evidence

| Requirement | Observable acceptance |
| --- | --- |
| AUDIO-CONSENT-01 | Cached client.audio.voiceConsents exposes exact multipart POST, collection GET and item GET/POST/DELETE routes. Required-name rename stays JSON POST, not PATCH. Opaque IDs encode once; only empty/dot/dotdot unsendable segments fail. All methods support auth/abort/closed guards; explicit pagination only after/limit with documented 1–100 admission and omitted default20. Shared conservative retries apply: multipart no replay, POST transient429 only, eligible idempotent GET/DELETE retries, permanent quota/abort never replay. |
| AUDIO-CONSENT-02 | Resource/list/deleted responses enforce required fixed objects and known fields, including finite integer created_at and deleted:false. Optional nullable first_id/last_id preserve omission/null/value through serialization/copy/equality. Immutable data/rawJSON and fresh-child copies preserve finite receive-only future extras while typed fields remain authoritative. Closed rename JSON rejects unknown fields; response extras never enter writes. |
| AUDIO-CONSENT-03 | Original recording bytes/views are snapshotted and readonly; exact filename/filepart MIME plus three canonical multipart fields are verified. All eight supported bases, browser MIME parameter normalization and 10MiB−1/exact/+1 boundaries have public fixtures without transcoding/sniffing. Known extensions can infer MIME; other names require explicit supported metadata. Offline lifecycle demonstrates all five methods, two explicit pages and deletion only with an explicit --delete option (five default/six selected mock requests, $0). Docs explain current phrase, eligible project/access, same person/project and permission boundaries; no automatic recording/enrollment/live upload or invented consent_phrases DTO. |

Every model has complete field/presence/copy/clear/value/hash/ownership/contextual
malformed fixtures. Public main barrel exports all request/response/resource types.
Existing constructors/signatures/enum variants are unchanged; this addition has
no source breaking migration. Privacy is scoped to consent methods, retaining
explicit caller data while default diagnostics/logs redact recording/person
metadata, opaque IDs/cursors and echoed headers. Other API policies stay intact.

## Validated findings resolved

- Bare extension words were incorrectly accepted as filenames with inferred MIME;
  inference now requires a recognized extension, with an explicit supported MIME
  alternative for other filenames.
- Non2xx redirects reached JSON decoding. Consent dispatch now invokes the shared
  HTTP parser before decoding; its extracted implementation retains advertised
  charset, HTTP subtype/body/bytes/header/request and webhook behavior. The default
  error interceptor's >=400 policy is unchanged for other API families.
- ClientException exposed private URL/message data. After shared retries, consent
  transport wraps it with caller-readable message/url/original cause and an additive
  diagnostic-redaction flag. Socket failures retain raw cause/context too.
- AuthProvider-supplied private correlation IDs appeared in native abort diagnostics.
  A scoped abort wrapper preserves all caller fields and uses the additive redaction
  flag. Public fixtures assert the private ID actually reaches transport and remains
  available on the exception; setting only defaultHeaders would have been overwritten
  by generated tracing and would not test the claimed condition.
- Consent URLs/query cursors/request headers need privacy in addition to response
  body/header redaction. All five routes, including percent-encoded opaque IDs,
  now have public success/error/malformed FINEST fixtures.

## Validation

- Format: all 2,696 repository Dart files unchanged; package fix has nothing to
  apply and fatal-info analysis reports no issues.
- Package unit suite: 14,808 pass, two existing environment-dependent skips.
  All 326 new cases (86 model and 240 public resource cases) pass on VM, real
  Chrome JavaScript and Chrome Wasm. Existing Audio/shared HTTP regressions pass.
- Independent actual canonical corpus: four public request/response JSON rows,
  eight explicit round-trip/closed-schema assertions. Multipart creation is
  verified at its actual file/form boundary. Source closure has 12 assertions
  across five genuine closed components and two unchanged path roots.
- Exact README snippet compiles and runs with five mock requests when deletion
  is false and six when explicitly selected. Both runnable example paths report
  retention/deletion accurately, preserve original bytes and normalize browser
  MIME. Eleven consent documentation local-link occurrences resolve, with the
  new llms GitHub file link mirrored to the existing example.
- All three upstream heads remain unchanged at final publication source check.
  No live request, recording upload, dependency change or release was performed.

Full final toolkit verification reports 278 errors / 118 warnings / 216 infos,
plus 35 consistency findings. Previous baseline: 275 / 112 / 215 / 35. The exact
multiset delta has ten added identities and zero removed identities:

- Two errors identify the intentionally absent multipart-create JSON methods;
  one identifies VoiceConsent's public parser delegating to its private parser.
- Six warnings cannot see serialized-value equality/hash through toJson on the
  three response models, whose complete effective JSON contracts have public tests.
- One info compares Uint8List with the schema's string/binary convention.

All 602 previous implementation identities and all 35 consistency identities
remain visible and unchanged. Exports/docs/README checks are clean. These retained
scanner limitations are verified by real public factories and multipart fixtures;
there are no new diagnostic exclusions, fabricated schemas or checker changes.

Independent requirements, model/resource/shared-HTTP and documentation engineering
reviews approve the final combined change with no unresolved findings. Final reviewed head `cadd3f39ba82e12cb0764a87dc5808f01894e5b4` passed
[workflow 37836884914](https://github.com/davidmigloz/ai_clients_dart/actions/runs/37836884914):
14 contexts, 13 successes and the standard Test(all) skip. The actual merge receipt
above closes #368; #369 sample-derived voice creation is next.
