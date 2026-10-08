# Signed webhook receiver acceptance

Status: implemented, independently reviewed and verified; PR/merge pending.
Tracking: [#357](https://github.com/davidmigloz/ai_clients_dart/issues/357),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [WH-VERIFY-01–03 and WH-EVENT-01–03](../webhooks-safety.md).
Planning [PR #361](https://github.com/davidmigloz/ai_clients_dart/pull/361) merged
October 8, 2026 at `886659c3c11cbee89335788ba918eeecd528fce0` after all applicable
final-head checks passed (14 contexts: 13 successes and standard Test(all) skip).

## Sources and schema receipt

Rechecked October 8, 2026 against
[OpenAPI 506aff0a](https://github.com/openai/openai-openapi/blob/506aff0a8099581b50e119b87f8f2692cdad043f/openapi.json),
[Python 3.26.1 / 9301e319](https://github.com/openai/openai-python/tree/9301e319ea33ef28fba380f39a289dedc14652c1)
and [Node 7.30.1 / bc6c0bfb](https://github.com/openai/openai-node/tree/bc6c0bfb70f253d5caa3f335699e9713ea9067b5).
Fourteen relevant SDK webhook helper/resource/test/header/union/legacy files and
all 26 generated Python received-event files are byte-identical to the planning
pins. The [official Webhooks guide](https://developers.openai.com/api/docs/guides/webhooks)
confirms verify-before-parse and webhook-id delivery deduplication.

The reviewed candidate is promoted with 356 operations and 2,009 schemas. Metadata
pins the source and actual fetch timestamp, archiving the previous source and
actual timestamp. The five Agents/Vault pagination changes found independently
in planning remain recorded in Phase 6; components/webhooks are unchanged. Toolkit
review missed the parameter-only delta; this promotion does not claim Agents/Vault
implementation. All 33 real webhook components (26 events, six Agent summaries,
one Agent envelope) were described and scaffolded in dry-run. Fifty actual public
Dart serializations across all 26 canonical components validate against exact
506aff0a JSONSchema and round-trip unchanged, including 17 optional-object forms,
full Agent metadata/three actions and ordered SIP/open media values.

## Local verification and configuration

Standalone WebhookVerifier and client.webhooks expose synchronous string/bytes
verifySignature and unwrap methods. A webhook secret can come from explicit
configuration, OPENAI_WEBHOOK_SECRET or a per-call override. A null override uses
the configured secret; an empty override fails. Standalone fromEnvironment reads
only the webhook secret, while existing config/client environment factories retain
their API-key requirement. Local client wrappers work on an unconfigured or closed
client without HTTP, authentication, lifetime checks or logging. The secret is
never added to outbound headers, URL or body; copy/clear/equality/hash include it
and diagnostics redact it. Cryptography is declared directly.

Verification signs exact UTF-8 ID/original timestamp prefix and untouched original
body bytes. Prefixed secrets decode strict padded canonical standard Base64;
other keys are literal UTF-8. Required case-insensitive headers are unique and
nonempty. Timestamp ASCII decimal text permits leading zeros, retains original
spelling and stays within 0..2^53−1. Inclusive two-sided default five-minute bounds
use UTC integer seconds and overflow-safe BigInt microsecond distance. Negative
or nonfinite tolerances fail safely; zero/fractional durations remain exact.

Rotation candidates accept v1 or bare canonical Base64; unknown versions/malformed
candidates do not hide later matches. One streaming HMAC handles the body for any
candidate count. Valid-length comparisons visit all 32 bytes without prefix exit.
A 2 MiB/1,600-candidate fixture proves one HMAC, bounded body reads and 51,200
comparison-byte observations; matches after position 32 are supported. Internal
Zone-scoped clock/observation hooks are absent from public exports and cannot
replace signature computation/results or expose sensitive data.

InvalidWebhookSignatureException is additive outside sealed OpenAIException.
Signed non-JSON/non-UTF8 bytes are admissible for verify-only. Unwrap verifies
before strict UTF-8, JSON and model parsing; authenticated malformed inputs fail
with safe FormatException without source/decoder cause. Configuration failures
omit invalid secret values. Tests cover exact official SDK golden bytes, 22
independent Python hmac/hashlib receipts, Unicode/NFD/newline/BOM/raw bytes, key
identity, all header/timestamp/Base64/rotation boundaries and safe diagnostics.

## Received-event contracts and application ownership

All 26 concrete events implement the canonical discriminator/envelope/data shape.
The five Agent variants extend the real WebhookAgentSessionEnvelope. Nine Agent
and safety events require fixed object:event; seventeen others permit omission
but reject explicit null/wrong values. Source created_at integer constraints are
not confused with delivery timestamp policy. SIP name/value lists preserve
ordered duplicates; environment/media strings stay open; Agent required-action
type has exactly its three canonical values. Legacy Live event/session_id and
Realtime call_id remain distinct. Safety alert identity matches the exact lowercase
hex grammar without accepting terminal newline/CR.

Generic WebhookEvent/UnknownWebhookEvent and inline ID/alert/SIP payload helpers
are explicit schema:null SDK extensions, not invented component mappings.
Unknown/video/legacy Python-only safety events retain arbitrary finite, deeply
immutable raw shapes with only the string discriminator required. Future finite
metadata on known received events is a documented tolerant extension of the
closed canonical shape. Nested typed replacement serializes the child's complete
JSON, preventing old parent metadata resurrection. Complete copy/clear/replacement,
effective-wire equality/hash, finite/cycle validation, fresh serialization,
immutable ownership and contextual/redacted diagnostics cover all fields. New
constructors are nonconst so raw snapshots are frozen immediately; existing
constructors and sealed HTTP exception subclasses do not change.

No subscription enum, endpoint management, API lookup, call acceptance, tool
execution, persistence, replay or automatic workflow is introduced. The offline
loopback example verifies untouched bytes, rejects multi-valued required signed
headers, uses authenticated webhook-id for application-owned delivery deduplication,
returns 200 before subsequent explicit handling and returns 400 for tampering.
All HTTP/socket cleanup is awaited. The README literal receiver function compiles
and runs through the public barrel; README coverage and llms point to the example.
Public documentation also covers guide 2xx acknowledgments, retries up to 72
hours, duplicate webhook-id deliveries, redirects and the safety-specific 410
stop condition without adding delivery scheduling. Browser runtime support is
verified; documentation keeps deployment secrets on
trusted infrastructure. No existing caller migration is required.

## Validation and independent reviews

Format → fix → fatal-info analysis passes. All 525 package Dart files are formatted.
The full package unit suite passes **12,604 tests with two existing environment
skips** (baseline 11,448 + 959 models + 160 verifier + 10 public wrappers + 27
isolated environment cases). The models/verifier/public wrapper suites each pass
on VM, real Chrome JavaScript and Chrome Wasm: **1,129 focused cases per runtime**.
Twenty-seven environment cases use child processes with includeParentEnvironment:
false and synthetic values only. Existing browser environment behavior remains
UnsupportedError. The runnable example and literal README receiver both pass.
No live integration suite, API key use or paid API request was required: **$0**.

Full toolkit --checks all --scope all is recorded, with exports/docs/README clear.
Implementation reports **261 errors / 74 warnings / 213 infos**, versus the existing
229 / 74 / 213; consistency reports **35 warnings**, versus existing 32. The new
32 implementation findings are 31 inherited _WebhookValue.toJson scanner misses
(26 concrete events and five Agent object payloads) plus the generic enum fallback
requirement, which conflicts with the canonical strict three-value action summary.
Runtime/schema fixtures prove serialization and exact enum behavior. The three
new consistency warnings reflect schema-required heterogeneous data and optional
versus required object envelopes, not a new wire defect. All existing diagnostics
remain visible; no exclusion, fake component, permissive enum or duplicate method
was added to silence the checker. Endpoint/SDK gaps outside #357 remain tracked.

Independent requirements review and cross-author engineering reviews approved
models, verifier, public configuration/wrappers, isolated environment fixtures,
source/schema receipts, manifest, example and documentation. Review corrections
resolved a mistaken huge-time acceptance fixture and example HTTP duplicate-header
handling/delivery identity before final freeze. Reviewers also independently
confirmed the toolkit classifications. Final PR/CI status is recorded separately;
#357 remains open until implementation merge. Next independent slice is #358;
#359 and #360 retain their explicit dependency order.
