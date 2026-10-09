# Bounded optional HTTP/2 transport evaluation

Status: planned; no benchmark, adoption or runtime compatibility claim yet.
GitHub: [#399](https://github.com/davidmigloz/ai_clients_dart/issues/399).
Tracking: [parent #317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Ticket: [46 — HTTP/2 evaluation](tickets/46-http2-evaluation.md).

The user approved exactly one additional evaluation after accepting the seven-core-
ticket finish line. The milestone now ends with seven accepted Agents/Vaults core
implementations plus this accepted evaluation report. No migration, upstream patch,
production transport/default change or follow-on ticket is required to complete it.
A justified **defer** decision is a successful evaluation outcome.

## Purpose and source baseline

Determine whether optional HTTP/2 transport offers a useful, compatible path for
native `openai_dart` workloads. `http2` 3.1.0 introduces a pooled, multiplexed
`Http2Client` implementing `http.Client`, so the existing client injection seam is
sufficient for investigation. Potential connection/handshake savings under concurrency
are an inference to measure, not an established end-to-end OpenAI speed improvement.
Existing `http.Client` already reuses connections; the baseline must reuse it too.

The assessment pins [http2 3.1.0](https://pub.dev/packages/http2/versions/3.1.0),
its [published archive](https://pub.dev/api/archives/http2-3.1.0.tar.gz) and
[tagged adapter source](https://github.com/dart-lang/http/blob/http2-v3.1.0/pkgs/http2/lib/src/http2_client.dart).
Published archive SHA256:
`480bf904908b4e4ec4fac8117f69f5ff54cf48c12b1761f0a192e1e10196ee7b`.
Adapter SHA256, identical in archive and tag:
`6b1698059e602fa6cf429d7c8a242ad672e8e481033de0117d119afdfccb12d8`.
These sources were inspected, not benchmarked. The OpenAPI/Python/Node core pins
remain unchanged; this evaluation does not add canonical operations or schemas.

Confirmed adapter properties, to exercise rather than conceal in the report:

- The class is experimental, imports `dart:io`, accepts HTTPS only and requires
  ALPN `h2`; it has no HTTP/1 fallback. Web entrypoints must retain their existing
  browser transport and must not acquire an unconditional IO import.
- `send()` does not handle `AbortableRequest.abortTrigger`. `close()` rejects new
  requests and drains ongoing response bodies; canceling a response subscription
  resets its individual HTTP/2 stream. Our generic SSE abort path currently closes
  a dedicated client expecting prompt termination. That mismatch is a known blocker
  to treating interface compatibility as complete transport support.
- Requests are fully buffered via `finalize().toBytes()`, including multipart and
  streamed uploads. Response pause/resume forwarding, redirect/decompression behavior,
  connection policy and proxy support need explicit compatibility classification.
- A new client per SSE request loses shared multiplexing. Reusing a borrowed pooled
  client must preserve caller ownership and isolation between concurrent requests.

## Requirements and finite work

- **HTTP2-EVAL-01 — Baseline and boundaries:** verify the fixed version/source
  receipts and existing injection/lifetime seams. Keep the production dependency,
  default transport, public API and seven core tickets unchanged. Any test/benchmark-
  only dependency or fixture needed during evaluation is explicitly documented.
  No dependency on unimplemented Agents/Vaults methods; existing Responses SSE,
  JSON, multipart and binary paths provide representative public-client fixtures.
- **HTTP2-EVAL-02 — Compatibility evidence:** use a real loopback TLS peer negotiating
  `h2`, not only a MockClient. Exercise abort before/after headers, SSE abort versus
  subscription cancellation, borrowed/owned cleanup and shared-stream isolation;
  bounded upload memory and slow-consumer behavior; graceful shutdown, server stream
  limits/GOAWAY; and HTTPS/h2 versus rejected HTTP1/plain HTTP endpoints. Classify
  redirect/compression/proxy differences for the tested scope. Record expected
  failures honestly; fixing upstream or implementing a production adapter is not
  an acceptance prerequisite. Synthetic credentials only, no logged private payloads.
- **HTTP2-EVAL-03 — Reproducible local measurements:** compare reusable HTTP1 and
  HTTP2 clients using matched TLS, fixed payloads and concurrency levels. Separate
  cold/warm connections, sequential/parallel JSON and long-lived synthetic SSE.
  Record connection count, total/first-byte latency, throughput and bounded memory
  observations with platform/SDK/package versions and reproducible commands.
  Bound fixture sizes, concurrency and timeouts so runs cannot hang or grow without
  limit. Disclose sample counts/variability and measurement limits. Synthetic results
  establish transport behavior, not faster model inference or higher API rate limits.
- **HTTP2-EVAL-04 — One decision and closure:** publish an evidence-backed adopt/defer
  recommendation identifying gains, failed compatibility cases and limitations.
  Document an optional injection recipe only if the demonstrated use case is safe,
  with explicit ownership/platform/cancellation limits. Otherwise record defer and
  its reasons. A production migration or remediation would need separate explicit
  user authorization; do not create follow-on issues automatically.

## Acceptance and execution policy

The ticket closes when its reproducible local evidence and final recommendation are
reviewed and accepted, even if the recommendation is defer. An assessment of source
alone is the starting point, not completed benchmark/runtime evidence. Local TLS
servers are unit fixtures under `test/unit/`; benchmarks may live in a dedicated
benchmark directory. Preserve the existing unit/integration placement rules.

No OpenAI key, paid API request, hosted environment or full integration suite is
needed. Default evaluation cost is $0. Production runtime changes, HTTP3, WebSocket
or media-transport redesign, platform transport comparison projects, issue #316,
package publication and new work streams remain outside this ticket.
