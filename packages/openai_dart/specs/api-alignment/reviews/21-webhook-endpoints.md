# Project webhook endpoint management acceptance

Status: merged after independent review, runtime verification and green CI.
Implementation [PR #363](https://github.com/davidmigloz/ai_clients_dart/pull/363) merged October 8, 2026 at `b5159171218e8feb9f720c5db7d1d82ea3cf1a80` after all 14 final-head CI contexts completed (13 successful, one standard skip), closing #358.
Tracking: [#358](https://github.com/davidmigloz/ai_clients_dart/issues/358),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [WH-ENDPOINT-01–04](../webhooks-safety.md#project-endpoint-management).
Receiver [PR #362](https://github.com/davidmigloz/ai_clients_dart/pull/362) merged
October 8, 2026 at `eea142bf9b100448f5216572e4db2d50a7ad0f5b`, closing #357.
Final head `99df2a4ead5f5c0b53240dbbbb44fd5d02ee1d91` passed all 14 contexts
(13 successes and standard Test(all) skip), including the public golden-fixture
alert follow-up. [Alert #1](https://github.com/davidmigloz/ai_clients_dart/security/secret-scanning/1)
is resolved as used_in_tests with exact public SDK provenance; no deployment
credential was implicated. No rotation or history rewrite was performed.

## Sources and canonical proof

Rechecked October 8 against
[OpenAPI 506aff0a](https://github.com/openai/openai-openapi/blob/506aff0a8099581b50e119b87f8f2692cdad043f/openapi.json),
[Python 3.26.1 / 9301e319](https://github.com/openai/openai-python/tree/9301e319ea33ef28fba380f39a289dedc14652c1),
[Node 7.30.1 / bc6c0bfb](https://github.com/openai/openai-node/tree/bc6c0bfb70f253d5caa3f335699e9713ea9067b5)
and [Webhooks reference](https://developers.openai.com/api/reference/resources/webhooks).
Twenty relevant official files fetched successfully. SDK endpoint contracts match
the planning sources; fresh canonical JSON equals the repository snapshot. Toolkit
fetch/review confirms no change. The canonical snapshot stays pinned at 506aff0a;
metadata retains the actual refreshed fetch time with unchanged source/history,
not an invented spec version or replacement. Wider inventory remains tracked.

Eleven real management components were described and scaffolded (22 receipts).
They map to the exact public models; no invented schema or exclusion is added.
The closed ProjectEventTypeEnum maps to WebhookEventType with exactly 23 writable
choices; returned/discovery strings stay open. Ten object components cover four
requests and six response shapes. Actual public serializers validate against
exact canonical JSONSchema in 125 cases, including all 23 enum values, Unicode
boundary requests, required-nullable/omitted fields, rotation and future response
strings. Independent 92 canonical and 18 metadata probes run through the public
barrel, covering malformed/fixed/required/null/copy/ownership/secret boundaries.

## Authenticated operations and received contracts

client.webhooks now provides list/create/retrieve/update/delete/rotateSecret/test,
with eventTypes.list discovery. All eight use ResourceBase/RequestBuilder and
existing auth, abort, HTTP errors/request IDs, conservative retries and closed
checks. Update is POST. No beta header, administrative routing, duplicate auth
stack or implicit local verifier update is introduced. Existing local verification
continues to work after client closure without HTTP/auth/lifetime checks.

Path IDs encode once and preserve base queries, percent/slash/query/fragment/
Unicode identity. Dart URI normalization cannot faithfully route empty or dot
segments; those three unsendable ID values fail safely before auth/network, with
no provider prefix allowlist. Manual list pagination uses only optional limit
1–100 and after; null after is omitted and server default 20 is documented. Returned
nullable firstId/lastId keys are required; cursors are never inferred from data.

Create name constraints count Unicode runes, 1–256; URLs require only the exact
case-sensitive HTTPS prefix and at most 2,048 characters. Event lists are nonempty
with canonical writable enum values. Constraints run at construction, parsing
and serialization without assert-only enforcement. Update permits any nonnull
subset including {}, with supplied eventTypes replacing the complete set.
Rotation supports omitted body and explicit {}, retaining omitted/false/true.
Default false invalidates the prior key immediately; true gives a 24-hour overlap.
Callers coordinate stored keys/receiver changes explicitly. Test event_type is
required; success:true means the request completed, while statusCode reports the
receiver response and can be 4xx/5xx. No live test delivery is sent by acceptance.

Returned DTOs follow response constraints independently of writable requests.
Endpoint signingSecretHint and list firstId/lastId must be present but may be null;
updatedAt is optional nonnull and can be cleared by copy. With-secret create/rotate
returns required signingSecret without imposing a prefix, nonempty or format rule.
Deletion accepts either canonical boolean value; test success is fixed true and
its statusCode is any canonical integer. All fixed object envelopes validate.

Models implement complete contextual parsing/serialization, copy/clear/replacement,
effective-wire equality/hash, fresh serialization and finite immutable raw/list
ownership. Received DTOs preserve canonically permitted finite future metadata; request
serialization emits the modeled canonical fields. Nested child
replacement uses the new child's effective JSON, without old metadata resurrection.
New constructors are nonconst to freeze collections immediately. Diagnostics
redact opaque fields, signing keys and raw metadata; getter/toJson retain values.

## Signing secret diagnostics

Built-in enabled response logging structurally redacts signing_secret before
truncation, including nested/escaped keys and short, empty or raw-looking values.
Exact known secret echoes in diagnostic strings are masked. Malformed secret-
bearing create/rotate responses are omitted from logs; successful malformed JSON
or models fail with safe contextual FormatException, without source/cause/body.
Original HTTP response identity/body, model getters/toJson and raw exception body
remain available unchanged to the caller. Custom raw logging remains caller-owned.

ErrorInterceptor uses safe diagnostic fallback instead of leaking raw secret JSON.
ApiException rendering redacts secret-bearing message/metadata while public
error type/code/param fields remain intact. Structured quota classification and
retry behavior use original values; an underscore signing key fixture proves no
permanent-quota retry is introduced. Existing ordinary response formatting and
nonsecret error behavior remain unchanged. Direct caller-created exception bodies
may be cyclic or shared: independent review caught recursion in the new diagnostic
scan, now fixed with identity-visited Map/List handling and a public regression.

All 22 logging/privacy cases pass on VM, real Chrome JavaScript and Wasm. Tests
configure and restore the existing logging hierarchy requirement; no global client
logging rewrite is introduced. open_responses has no corresponding webhook/key
API and its logger does not log full response bodies, so no sibling implementation
change is warranted. Generic unrelated raw error paths remain outside this slice.

## Documentation, example and validation

README, llms, API coverage and example mappings describe all eight methods,
closed writable versus open returned choices, exact pagination/nullable constraints,
rotation/storage, client lifetime, safe diagnostics and receiver status. The
literal README function compiles with fatal-info analysis and runs three mocked
operations, storing created/rotated keys explicitly and observing receiver status 500.
The offline lifecycle example runs ten mocked requests across all eight operations,
two cursor pages and two rotation modes. It verifies no configured secret mutation,
separates success:true from receiver status 500/acknowledged:false, deletes its synthetic
endpoint and closes client/custom transport. No external test receiver is contacted.

Format → fix → fatal-info analysis passes. Full package unit suite:
**13,026 passed with two existing environment skips**, versus receiver baseline
12,604 (239 model + 161 public resource + 22 privacy fixtures). All **533 Dart
files** are formatted. These **422 focused cases** pass separately on VM, real
Chrome JavaScript and Chrome Wasm. 125 canonical serializers and 110 independent probes,
literal README and runnable example pass. No live integration suite, account/API-key
use, paid action, publishing or package version bump: **$0**.

Full toolkit --checks all --scope all has exports/docs/README clear. Implementation
remains diagnostic at **271 errors / 74 warnings / 213 infos**, versus baseline
261 / 74 / 213; consistency stays **35 warnings**. Identity comparison adds ten
inherited _EndpointValue.toJson scanner misses and one generic fallback requirement
that conflicts with the exact closed writable enum, while resolving the old
missing webhook_event_types resource error: net +10. Runtime/schema fixtures and
independent reviews confirm these classifications. No permissive enum, duplicate
method, fake component, exclusion or toolkit change masks these or unrelated gaps.

Independent requirements and cross-author engineering reviews approve models,
resource/abort/retry/URI fixtures, redaction/error preservation, source/schema
proof, manifest, docs and example after validated findings are fixed. Final-head CI completed before merge; #358 is closed. Next is #359 safety retrieval (receiver prerequisite now merged), then
#360 monitoring details; later API/SDK parity phases remain inventoried.
