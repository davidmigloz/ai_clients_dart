# #425 Vertex Responses and OpenAI regional endpoint routing

Frozen contract: October 31, 2026. This slice follows #316's immutable resource
configuration generations. No global OpenAPI promotion, release metadata, cloud
credentials, ADC discovery or paid calls belong to it.

## Primary receipts and scope

- [Python 3.42.0 Vertex provider](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/providers/vertex.py).
- [Python named residency resolution](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/_data_residency.py).
- [Node 7.47.0 Vertex provider](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/providers/vertex.ts).
- [Node cancellation gate](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/internal/vertex.ts).
- [Node named residency resolution](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/internal/data-residency.ts).
- [Official regional processing/storage guide](https://developers.openai.com/api/docs/guides/your-data), frozen local guide receipt under `/tmp/openai-oct31-audit/docs/guides-your-data.md`.

Runtime provider behavior reuses existing Responses DTOs and resource paths.
The inventory also assigns canonical `PublicProjectResidency` to this slice. Its
15 uppercase project-setting values are `GLOBAL`, `US_STORAGE_PROCESSING`,
`EU_STORAGE_PROCESSING`, `JP_STORAGE`, `JP_STORAGE_PROCESSING`, `KR_STORAGE`,
`CA_STORAGE`, `SG_STORAGE`, `IN_STORAGE`, `IN_STORAGE_PROCESSING`, `AU_STORAGE`,
`AU_STORAGE_PROCESSING`, `GB_STORAGE`, `AE_STORAGE`, `AE_STORAGE_PROCESSING`.
There is no existing project CRUD model/field in this package to bind it to.
Project administration remains intentionally deferred; adding an unused settings
DTO or project CRUD would expand this issue. This is a named, audited exclusion.
`OpenAIDataResidency` is the separate four-choice official SDK runtime URL
selector, **not** a Dart binding or alias for that 15-value canonical project
setting enum. No manifest mapping claims otherwise. The final source promotion
and inventory disposition accounting remain #427.

Both official providers use the global `aiplatform.googleapis.com` host or a
`{location}-aiplatform.googleapis.com` regional host, the complete
`/v1/projects/{project}/locations/{location}/publishers/openai/v1` root, and a
complete explicit base URL overriding project/location. Legacy domain-scoped
project IDs retain dots/colon; invalid path identifiers fail without echoing input.
Custom roots are HTTP(S), without userinfo/query/fragment; Google domains require
HTTPS. Tokens are nonempty printable ASCII without whitespace. Conflicting auth,
OpenAI organization/project headers and wrong origins fail before token resolution.
Redirect following is disabled on every attempt. Credential failures do not retain
the original credential-library exception as a cause.

Intentional Dart boundaries are explicit: the portable provider requires an injected
`FutureOr<String>` callback; optional native ADC loading is separate. A native
`fromEnvironment` convenience reads only Google project/location. The factory does
not inherit OpenAI environment credentials. Additional known credential header
aliases (`x-api-key`, `openai-api-key`) are also rejected. This slice permits only
Responses create/retrieve/cancel/delete/input-items/compact and HTTP SSE, rather
than implying every API resource works on Vertex. Listing, input-token counting,
other resources and all WebSocket paths fail locally. These are documented scope
choices, not claims that the upstream providers enforce the same route allowlist.

The SDK named OpenAI mapping is exactly global/us/eu/ae. The official guide also
lists other regional storage endpoints; they remain available through explicit
ordinary base URLs. US/EU eligible processing and UAE restricted model/service
processing are distinguished from storage-only regions. A matching endpoint,
project key or Google location does not configure or guarantee residency.

## Runtime and ownership review

`VertexProvider` is immutable routing plus callback identity. `OpenAIConfig.vertex`
sets provider-owned routing/auth defaults; installing a conflicting configuration
fails atomically. `copyWith`/`updateConfig` preserve omission, explicitly clear the
nullable provider, and select a replacement provider's root unless the caller
supplies a root. Clearing the provider restores the ordinary global OpenAI root;
other settings remain explicit and normal snapshot validation applies.

Each client generation builds a transport adapter around its existing raw HTTP
pool. Normal requests acquire credentials below retries; SSE's interceptor bypass
still reaches the same adapter. Source request headers/body are snapshotted before
awaiting a token, and the bearer exists only on that attempt's outgoing wrapper.
No mutable client-wide last-token field exists. Retained resources, nested input
items, pending callbacks and retries keep their original provider/root/budget.
Reacquiring a resource adopts a completed config update. Custom middleware and
ordinary non-provider transport behavior remain unchanged.

Every auth/header attempt has its own timer, elapsed-time check and native abort
gate. A final event-turn checkpoint drains queued Future cancellation propagation
before committing dispatch, including linked SSE abort futures. Timed-out/aborted
callbacks are observed but discarded; they cannot open a late request. Callback
work itself cannot be forcibly cancelled, so callers bound their own refresh I/O.
Closing the client closes every retained generation/request adapter and promptly
settles unresolved auth waits without waiting for callback completion. Late
callback results cannot dispatch, and borrowed raw pools remain open.

Timeout covers auth and response headers; buffered HTTP retains its existing body
budget. SSE body lifetime has no automatic whole-stream deadline. Explicit abort
and subscription cancellation retain request-scoped native cancellation and
backpressure. The response-body forwarding controller has immediate cancellation,
without awaiting an idle peer. Raw shared pools are closed only by their original
owner. Dedicated factory clients close normally; a factory returning the injected
shared pool is wrapped as borrowed and cannot close that pool.

Provider callback/transport/body exceptions use sanitized diagnostic errors,
without retaining credential-bearing causes. Origin/header/route checks happen
before callback execution. Unsupported resource getters, Responses WS and direct
Live/Realtime socket paths reject before any connection/token request.

## Requirements evidence and validation

- 21 portable provider unit fixtures passed on VM: exact roots/identifiers,
  residency mapping, copy/value/provider identity, atomic config conflict checks,
  all six lifecycle method+URL/query shapes, concurrent out-of-order tokens,
  retry rotation, immutable original headers, opaque response ID handling, wrong origins/routes/encoded path
  traversal/auth headers, unsupported resources/WS/listing, timeout/abort/close
  late results, blocking callback elapsed time, safe errors, retained-generation
  updates, SSE auth and dedicated/borrowed ownership.
- Three real loopback HTTP/SSE fixtures passed: cross-origin redirects never
  reach the second peer with credentials, header timeout cancels an actual
  transport, and cancelling an idle SSE subscription leaves a borrowed pool
  usable for the next request. The idle peer explicitly disables HttpServer
  output buffering so it emits a complete event before holding its response open.
- Actual Chrome JavaScript and Wasm each passed 42 tests serially: the 21
  portable provider fixtures plus 21 existing runtime/config tests. The final
  opaque-ID fixture refinement also passed the portable VM21 selection.
- `example/vertex_responses_example.dart` passed with six synthetic lifecycle
  requests and six independently acquired tokens, zero external calls.
- The relevant serial ordinary client, auth/URL/snapshot, timeout/abort/SSE and
  Responses/Realtime/Live socket regression selection passed 203 tests.
- A broader client selection was stopped after 315 passes/two environment skips
  when unrelated environment subprocess tests timed out while browser compilation
  overlapped. Their source/timeouts were not changed; this run is not reported as
  passing. Final integrated suite ownership belongs to the parent workflow/CI.
- Package format (802 files), fix and fatal-info analysis completed cleanly.
- Toolkit docs verification passed (45 discovered/29 verified resources, zero
  issues/exclusion changes); README verification passed (20 headings/61
  collapsible usage topics, zero issues).
- Independent auth architecture peer review found no blocker. The root reviewer
  requested prompt close of unresolved provider work and an empty-segment guard;
  both are implemented and covered by the final 24 provider tests. Final whole-PR
  review and exact-head GitHub CI remain pending at PR preparation.
