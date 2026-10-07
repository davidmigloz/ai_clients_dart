# Existing API correctness: Phase 2 specification

Status: source audit complete; containers merged in
[PR #327](https://github.com/davidmigloz/ai_clients_dart/pull/327), closing #320.
Cache retention merged in [PR #328](https://github.com/davidmigloz/ai_clients_dart/pull/328),
closing #321; its
[acceptance evidence](reviews/03-cache-retention.md) is recorded. Cache controls/diagnostics
merged in [PR #329](https://github.com/davidmigloz/ai_clients_dart/pull/329), closing #322;
[acceptance evidence](reviews/04-cache-controls-diagnostics.md) is recorded. Chat usage/obfuscation
merged in [PR #330](https://github.com/davidmigloz/ai_clients_dart/pull/330), closing #323;
[acceptance evidence](reviews/05-chat-usage-obfuscation.md) is recorded. Parent
[#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Decisions was merged in [#319](https://github.com/davidmigloz/ai_clients_dart/pull/319)
after all CI checks passed, closing #318.

## Scope and evidence

Deliver independently usable fixes for current request/response contracts before
adding the larger missing API families. The user permits targeted breaking fixes
with migration guidance. Preserve provider compatibility where it does not send
invalid requests or lose current data. Do not release package versions here.

The current October 7 upstream candidate is semantically identical to canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
Audits cross-checked Python 3.26.0 and Node 7.30.0. Source discrepancies below are
explicit decisions rather than claims that every official SDK already agrees.

| Slice | Requirements | Observable outcome | Dependency |
| --- | --- | --- | --- |
| Container configuration | CONT-01–09, [detailed spec](containers.md) | Create/configure/inspect a container and use its ID; automatic Code Interpreter configuration emits valid memory/network fields | None; first implementation |
| Cache retention wire | CACHE-005 | Existing retention member emits canonical underscore spelling on every endpoint | None |
| Cache controls and diagnostics | CACHE-001–004, CACHE-006 | Configure Responses caching and inspect comparison/diagnostics; configure the narrower Chat cache options | Retention correction for legacy control |
| Chat usage and obfuscation | CHAT-001–002 | Preserve detailed token counters and choose stream obfuscation without treating metadata as content | None |
| Chat audio completion/streaming | CHAT-003–005 | Inspect/replay complete audio and reconstruct interleaved streamed audio | Complete/partial audio shapes before accumulation; internal steps of one feature ticket |
| Retry/error guidance | RETRY-01–06 | Stop replaying permanent quota failures and expose/honor complete server retry hints | None; preserve existing verb/cloneability policy |
| Image model selection | IMG-01–04 | Generation and multipart editing always send an explicitly selected model | None; targeted breaking API-contract correction |

Shared Responses cache-write usage is already complete in Decisions and is not a
new ticket. Hosted shell, async tools, configuration updates, web search, and
WebSockets/steering remain Phase 3. Administration and sunset work stay visible
in the parent roadmap.

## Cache contracts

- **CACHE-001:** Add distinct `ResponsePromptCacheOptionsParam`: optional nonnull
  `mode`/`ttl`, optional nullable `comparison_response_id`, optional nonnull
  `prewarm`. Empty options stay `{}`; false stays false; explicit parsed comparison
  null normalizes to absence. Use it in GA/beta create and stream requests. The
  existing `PromptCacheOptionsParam` remains the narrower Chat shape. Document
  constructor migration; do not invent a writable `generate` member.
- **CACHE-002:** `PromptCacheOptions` response echo preserves optional nullable
  comparison ID alongside required mode/TTL. It does not echo `prewarm`. Parsing,
  serialization, copy clearing, equality/hash, and diagnostics include it.
- **CACHE-003:** Add optional typed `Response.promptCacheDiagnostics`. Support
  `cache_miss` (required reason and integer missed tokens; optional reusable count),
  `cache_hit`, `comparison_response_not_found`, and `unavailable`. The nine current
  reasons are `model_changed`, `prompt_cache_key_changed`, `tools_changed`,
  `text_format_changed`, `reasoning_effort_changed`, `verbosity_changed`,
  `context_compacted`, `input_changed`, and `service_tier_changed`. Preserve future
  reason strings and unknown diagnostic objects with immutable raw JSON. Known
  malformed variants fail. Zero differs from absent. Shared GA/beta structures
  need one implementation; nested completed-event responses retain diagnostics.
- **CACHE-004:** Chat gets optional `prompt_cache_options` using only mode/TTL.
  Parse/serialize/copy-clear the nested object, including `{}`, through both
  ordinary and streamed requests. Responses-only controls do not leak into Chat.
  When adding this field, complete Chat request equality/hash over all existing
  fields as well as the new field. The CACHE-005 audit found that the current
  request compares only model/messages, including when retention differs; do not
  introduce another partial equality contract.
- **CACHE-005:** `PromptCacheRetention.inMemory` emits `in_memory`. Accept both
  underscore and legacy `in-memory` input; keep `24h` and existing unknown fallback.
  Remove stale manifest/endpoint spelling exceptions. Enum names remain stable;
  callers comparing serialized strings need migration guidance.
- **CACHE-006:** Add the canonical deprecated optional nullable retention control
  to Responses requests. Keep it absent by default and center modern examples on
  cache options. Legacy maximum retention and modern minimum TTL are independent;
  do not automatically substitute one for the other.

Acceptance uses exact public request fixtures, full Response/completed-event
fixtures, every diagnostic variant/reason, false/zero/empty/omitted/null cases,
sentinel clearing, full model contracts, and nested unknown mutation tests.

Sources: [prompt caching](https://developers.openai.com/api/docs/guides/prompt-caching),
[diagnostics](https://developers.openai.com/api/docs/guides/prompt-caching/diagnostics),
[Python request types](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/responses/response_create_params.py),
[Python response types](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/responses/response.py),
[Node Chat types](https://github.com/openai/openai-node/blob/v7.30.0/src/resources/chat/completions/completions.ts).
The current diagnostics guide documents comparison IDs: use a recent completed
response from the same organization. The ID requests diagnostics only; it does
not load history or change cache matching. Missing/expired comparison records
and inconclusive diagnostics are legitimate outcomes. Streamed diagnostics are
on the completed event. Diagnostic counts are estimates; usage measures actual
reuse and billing.

Implementation decisions: Chat/Responses creation options and returned diagnostics
are optional but reject explicit parsed null or malformed objects. Mode/TTL and
prewarm reject parsed null; comparison ID accepts it and normalizes to omission.
Compaction keeps its canonical outer-nullable narrow options. Existing returned
Response options tolerate outer null for provider compatibility. Const holder
constructors stay available; only unknown diagnostic JSON is recursively frozen.
Full Chat equality/hash includes every field. Shared nested JSON schemas and
Chat/Responses request metadata use deep value equality with consistent hashes.

## Chat usage, obfuscation, and audio

- **CHAT-001:** Add optional integer prompt details `cache_write_tokens`,
  `image_tokens`, and `text_tokens`, plus completion `text_tokens`. Preserve all
  through ordinary completions and final usage-only chunks with empty choices.
  Zero/absence and nullable copy clearing are distinct. Keep provider/embedding
  compatibility when completion counts or detail objects are absent.
- **CHAT-002:** Add optional boolean `StreamOptions.includeObfuscation` and optional
  string `ChatStreamEvent.obfuscation`. Both booleans and empty strings survive;
  absent request control preserves server defaults. Obfuscation is metadata and
  never enters accumulated text, tools, or audio.
- **CHAT-003:** Complete response audio requires id/data/transcript/expiry, while
  an outbound assistant audio reference is id-only. Preserve audio-only completions
  with nullable text and retain existing provider extensions. Actual request
  serialization must project audio references correctly; changing an unused
  `toApiJson` method alone is insufficient. Replaying audio must not send output
  data/transcript/expiry in the request.
- **CHAT-004:** Partial audio delta has independently optional id/data/transcript/
  expiry members. Id-only/data-only/transcript-only/expiry-only/empty objects work;
  expiry-only updates do not require a wire finish reason. Existing refusal/tool/
  reasoning/text deltas remain compatible. Public local-SSE fixtures establish
  the actual resource parse path.
- **CHAT-005:** Accumulate audio independently per choice, append opaque data and
  transcript fragments in order, update id/expiry, preserve old snapshots, and
  clear state on reset. Final completion retains complete audio and usage. Empty
  supplied strings differ from missing values. Match Node's finalization behavior:
  infer stop only for a pure expiry-only update when all four audio fields are
  complete; do not change raw chunk metadata or overwrite another finish reason.
  Incomplete audio has a partial snapshot API; converting it to a complete Chat
  completion fails explicitly instead of fabricating required fields. Text-only
  conversion retains existing behavior. Document this new audio boundary.

Sources: [Python usage](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/completion_usage.py),
[complete audio](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/chat/chat_completion_audio.py),
[partial chunks](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/chat/chat_completion_chunk.py),
[Node accumulator](https://github.com/openai/openai-node/blob/v7.30.0/src/lib/ChatCompletionStream.ts).
Assertions check interleaved choice isolation, fragment order, late expiry, stable
snapshots, reset, and both request/response projections without making live audio.

Implementation decisions for CHAT-001–002: new counters, request obfuscation
control, and returned padding reject explicit parsed null/wrong types because
their canonical members are nonnullable. Preserve old completion/detail-object/
provider null compatibility. Constructor/copy null clears by omission. Complete
all existing StreamOptions/Event fields and their nested Choice/ToolCallDelta/
logprob value contracts, rather than introducing partial equality for new fields.
Keep const constructors and existing caller collection ownership. Do not add
Chat audio here. Shared StreamOptions forwards the flag to existing Responses
requests, but this slice does not claim broader Responses streaming parity.

Implementation decisions for CHAT-003–005: use a structural ChatAudio union for
ID-only references versus required complete outputs, plus independent partial
ChatAudioDelta. Response parsing requires complete audio; generic assistant
parsing supports both contexts. Outer assistant audio is nullable; delta audio
and its supplied members reject null under canonical validation (Python generated
delta Optional types differ). Response projection emits required nullable content;
request projection emits audio ID only and preserves old provider reasoning.

Mirror Node's last processed nonnull delta marker, including null/absent delta
preservation and unknown/provider outer key presence. Keep finish synthesis in
final conversion only, never raw event/snapshot metadata. Preserve opaque extras
and provider-null provenance through serialization/copy/value contracts. Retain
const constructors, caller collections, stable per-choice audio snapshots, and
text-only behavior. No audio configuration/voice expansion or unrelated endpoint
work is included.

## Retry and error contracts

- **RETRY-01:** HTTP 429 permanent codes `credit_balance_exhausted`,
  `organization_spend_limit_exceeded`, `project_spend_limit_exceeded`,
  `organization_usage_limit_exceeded`, and `insufficient_quota`, or broad type
  `insufficient_quota`, are not automatically replayed. Match structured fields,
  not message substrings. Preserve typed rate-limit exception metadata.
- **RETRY-02:** Transient 429, including POST/slow_down, remains eligible. Malformed,
  absent, or unknown bodies retain existing provider fallback. Do not expand
  retries to 408/409 or non-idempotent 5xx/timeouts/connections, multipart bodies,
  or failures after streamed output.
- **RETRY-03:** Valid Retry-After is a minimum. Retain the current automatic-wait
  eligibility bound of twice `RetryPolicy.maxDelay`. Above it, return the original
  response rather than shortening the hint. Within it, never replay earlier than
  the hint. Preserve retry count, initial minimum delay, jitter, and cancellation.
- **RETRY-04:** Expose optional complete retry delay on `InternalServerException`
  and forward it through exception construction. Overload 503 remains an internal
  server exception and follows existing verb policy.
- **RETRY-05:** Share parsing across retry/error/stream boundaries. Preserve headers
  and hints on JSON and pre-stream HTTP errors, including multipart image streams.
  Numeric negatives/invalid values are ignored; past HTTP dates permit zero delay.
  Never replay errors after consuming output.
- **RETRY-06:** Align the useful SDK extension: valid `retry-after-ms` takes
  precedence, with finite fractional numeric delays supported. Invalid millisecond
  values fall back to standard seconds/date parsing. Round without scheduling an
  earlier replay; do not add a general deadline or configuration framework.

Sources: [error guide](https://developers.openai.com/api/docs/guides/error-codes),
[rate limits](https://developers.openai.com/api/docs/guides/rate-limits),
[Python retry implementation](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/_base_client.py),
[Node retry implementation](https://github.com/openai/openai-node/blob/v7.30.0/src/client.ts).
The SDKs still retry every 429 by status. Python declines hints over 120 seconds,
while Node falls back to shorter waits above 60 seconds. Follow the documented
API minimum/action-needed guidance instead of reproducing those discrepancies.

Tests script public MockClient failures/successes for each permanent code/type,
transient and unknown bodies, GET/POST 503, disabled/exhausted retries, complete
metadata, and stream boundaries. Test long-hint refusal without sleeping; use
controlled timers for permitted waits/cancellation.

## Image model requiredness

- **IMG-01:** Generation requires nonnullable model and prompt. Send the explicit
  model unchanged through JSON and streaming; keep arbitrary string identifiers.
- **IMG-02:** Multipart editing also requires a selected model in both edit paths.
- **IMG-03:** JSON editing retains its distinct optional nullable model contract
  and documented `gpt-image-2.5-sunburst` server default.
- **IMG-04:** Update construction/parsing/copy/serialization, affected fixtures,
  examples/docs, and migration guidance. Do not inject a generation default or
  apply requiredness indiscriminately to every image request shape.

This intentionally follows canonical requiredness and the
[generation reference](https://developers.openai.com/api/reference/resources/images/methods/generate)
over optional nullable model signatures still present in
[Python 3.26.0](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/image_generate_params.py)
and [Node 7.30.0](https://github.com/openai/openai-node/blob/v7.30.0/src/resources/images.ts).
The user-authorized targeted-breaking policy permits this correction. Fixtures
assert model JSON/multipart fidelity and preserved JSON-edit omission; no live
image generation is needed to test required request construction.

## Delivery and verification

Each ticket includes models, real public wiring, exports/manifest, docs/examples,
tests, and its own evidence. All new or changed model fields update copy methods,
equality/hash, diagnostics, and nullable-clear semantics; fix existing partial
contracts in the changed model rather than adding one more omitted field.

Default checks are unit-only. Local HTTP/SSE servers are unit tests. Any separately
authorized live smoke test must be bounded, avoid expensive media/large containers,
disable retries, and guarantee cleanup. Do not run the entire integration suite.
Each complete slice receives independent requirements and repository-standards
reviews before a PR. Required format/fix/analyze/unit/toolkit checks are recorded;
unrelated coverage gaps remain visible.
