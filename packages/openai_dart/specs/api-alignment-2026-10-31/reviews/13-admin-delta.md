# Bounded organization Admin APIs

Issue #426; parent #413. The October 31, 2026 contract is frozen at OpenAPI
`2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`, Python 3.42.0
`0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`, and Node 7.47.0
`c717857c3151bde92e07e4d396301a9c67163e68`. The adjacent manifest records the
source hashes, twelve operations, all 33 named dependency components, three
contextual inline models, and the conditional historical-usage disposition.

## Deliberate boundary and authentication

Seven new operations cover five external-key operations, project API-key update,
and Decisions usage. The five external-storage operations are explicit ticket
prerequisites for OCI and current storage statuses. Other historical Admin APIs
remain excluded from this implementation's scope, without new toolkit exclusions.

Python and Node expose `client.admin.organization` through their shared root
client and Admin-key security mechanism. Dart deliberately uses a standalone
`OpenAIAdminClient` requiring `OpenAIAdminConfig`: `admin.organization` has no
inference methods and never inherits an ordinary client's credentials, project,
default headers or mutable configuration. The environment constructor reads
`OPENAI_ADMIN_KEY` only, with no `OPENAI_API_KEY` fallback. It optionally reads
`OPENAI_BASE_URL` and `OPENAI_ORG_ID` for its own configuration.

Custom Admin providers supply one nonempty Bearer Authorization header. Other
provider headers are not consumed; organization/routing headers belong in the
explicit Admin config. Per-call authorization cannot override the selected Admin
provider. There is no local token-prefix heuristic: the service determines key
permissions. Config headers and per-call headers are snapshotted before awaits.

The client uses the existing HTTP retry, abort, timeout, logging and status error
policies in its own interceptor chain. Redirects are disabled before credential
attachment and before transport dispatch. Borrowed transports stay caller-owned;
closing the logical client prevents new requests. Provider/send/body-stream
errors are guarded at their external origin even when callbacks throw a typed
OpenAIException containing private text. Original causes remain explicitly
readable while automatic diagnostics hide key/provider metadata, identifiers,
usage filters and response/error bodies. Actual sent request context is retained
when injected transports omit or mislabel it. The shared logger gains only the
precise twelve-route Admin privacy predicate.

## Exact wire contracts

- Every successful operation expects HTTP 200 JSON. External-key deletion returns
  `ExternalKey`, while external-storage deletion returns `DeletedExternalStorage`.
  Both validation POSTs have no body or Content-Type. No Agents beta header is
  synthesized.
- External-key requests have separate AWS/Azure/GCP variants with fixed tags,
  canonical required fields, patterns and bounds. Purpose is omitted when absent,
  rather than eagerly set to EKM. Azure/GCP PSP decryption requires a version;
  EKM forbids it. The received flat key envelope is distinct from request unions,
  and its object/type strings remain open where canonical declares strings.
- External-storage request and resolved-response provider unions differ. AWS,
  Azure and GCP resolved providers retain their extra native fields; OCI carries
  tenancy OCID, region and bucket. Known statuses are pending, validated, degraded
  and unhealthy; future received status strings/provider variants remain readable.
  Validation does not synthesize a local state transition. Deletion removes config,
  not cloud data; the service owns default-retention restoration and interrupted
  deletion completion.
- Project API-key update requires scopes and/or relative expiry, with no null
  request values. Empty scopes means All permissions within owner effective
  access; scope strings remain open. Expiry is 1–31,536,000 seconds per request,
  subject to service policy. Ordinary transient-429 retries can reapply it; the
  existing client policy does not retry POST 5xx/connection/timeouts. No absolute
  expiry conversion, idempotency key generation or exactly-once claim is added.
  This route includes service-account-owned project keys, without conflating it
  with separate service-account management endpoints. The inline received owner
  object has optional type/user/service_account members; no required tag is
  invented. Last-used time is required nullable; expiry is optional nullable.
- Decisions usage preserves inclusive start/exclusive end windows, 1m/1h/1d
  buckets, source-specific bucket limits, open model/service-tier strings,
  source grouping, explicit page cursors and every canonical counter. The
  30-minute and 12-hour cache-write counters remain distinct. Optional nullable
  counters/group fields preserve omission versus explicit null. `unlabeled`
  does not establish direct API origin.
- Query arrays use bare repeated keys, following canonical form/explode and
  Python. Node's bracket-key serialization is a recorded SDK dialect difference.
  Empty/null filters are omitted; caller order is retained. Key-list limit zero
  is valid, unlike storage-list minimum one. Pagination returns one page without
  hidden requests. Opaque path IDs are encoded exactly once; lone-surrogate URI
  values fail privately before authentication, while valid Unicode is preserved.

Canonical Admin objects generally permit extra properties. Finite future JSON is
owned deeply; typed members remain authoritative. Required/null/type parsing is
strict. Copies, full effective-JSON equality/hash and private string output cover
all fields. Unknown received providers remain opaque; unknown writable provider
variants reject before dispatch rather than receiving writable authority.

`UsageCompletionsResult` is one of the twelve assigned schema changes, but its
30-minute counter requirement is explicitly conditional on an existing supported
response model. There is no organization completions-usage resource/model in this
package. The condition is therefore not applicable: this issue adds no historical
endpoint and does not graft Admin aggregates onto Chat `CompletionUsage`.
`DecisionsUsageResult.inputCacheWrite30mTokens` is independently implemented.

## Validation and review

- Package format/fix/analyze: clean.
- Focused synthetic model/public HTTP fixtures: 76 tests pass on VM and Chrome.
- Local VM transport tests: two pass (real redirect isolation and environment
  project-key fallback rejection). These are unit fixtures, not live API tests.
- Offline example: five MockClient requests complete; no real credentials,
  cloud registration, billing access, version bump or publication.
- DTD discovery found no running debug app; the library example runs in a fresh
  CLI process, with no app to hot reload.
- Required GitHub CI and independent engineering/requirements review gate merge.
  A complete integrated local unit run is coordinated by the parent after all
  isolated lanes land, avoiding concurrent heavy HTTP/2 fixtures.

## Toolkit handoff

Frozen fetch/review, describe and scaffold dry run use the isolated scratch
package `/tmp/openai-issue426-contract`. The reviewed candidate is promoted only
inside that scratch package. The adjacent 33 bindings are overlaid; canonical
repository schema/global manifest promotion remains #427. The documentation
resource/example map is updated without adding API exclusions or suppressions.

Overlay verification: implementation 1,023 errors/147 warnings/292 infos,
consistency zero errors/114 warnings, nine export findings, and zero docs/README
findings (62 collapsible topics). The seven new implementation findings require
literal Dart enum declarations; these intentional value classes preserve exact
future received strings. The additional export finding is the internal
`admin_json.dart` helper, not a missing public API model. Existing global gaps
remain recorded for #427/#246. This receipt does not claim globally green parity.
