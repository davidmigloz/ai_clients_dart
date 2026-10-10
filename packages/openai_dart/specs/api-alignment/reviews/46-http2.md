# HTTP/2 transport evaluation: defer adoption

Status: local evaluation complete; final independent published-head review, CI and user-authorized merge remain gates for [#399](https://github.com/davidmigloz/ai_clients_dart/issues/399). This report completes the one approved evaluation when those gates pass. It does not create a migration or follow-on ticket.

**Recommendation: defer `http2` 3.1.0 adoption.** Keep the current production `http.Client` transport and injection API. Multiplexing reduces connection count in the local concurrent workload, but cancellation compatibility, response buffering and repeated SSE interoperability are blockers. This experiment does not demonstrate faster model inference or higher API rate limits. No opt-in recipe is recommended from these results.

## Sources and scope

The [published 3.1.0 archive](https://pub.dev/api/archives/http2-3.1.0.tar.gz) SHA256 is `480bf904908b4e4ec4fac8117f69f5ff54cf48c12b1761f0a192e1e10196ee7b`. Its adapter and [tagged source](https://github.com/dart-lang/http/blob/286037b57bcd0cb353ed98be8a508e753221e661/pkgs/http2/lib/src/http2_client.dart) both hash to `6b1698059e602fa6cf429d7c8a242ad672e8e481033de0117d119afdfccb12d8`; the tag resolves to commit `286037b57bcd0cb353ed98be8a508e753221e661`. The development dependency is exactly `http2: 3.1.0`. Production dependencies, library source, default client, public API, OpenAPI/official-client pins and package version are unchanged.

Existing seams are sufficient to evaluate: JSON requests borrow `OpenAIClient(httpClient: ...)`; ordinary Responses SSE without an abort trigger also uses that borrowed client. Generic Responses SSE with an abort trigger creates an owned client from `streamClientFactory` and closes it to abort. That factory is an owned-client factory, not permission to return and close a shared borrowed pool. Newer private binary/Agents transports use different cancellation handling; this report does not claim every resource has the generic Responses SSE behavior.

The real loopback peer uses Node's standard HTTP/2/TLS library with HTTP/1.1 allowed on the same endpoint, the same generated certificate, request work and payloads. Certificate keys exist only in temporary directories and are deleted. Trust is limited to the exact generated certificate; no blanket certificate acceptance is used. Synthetic auth is `fixture-only`; the peer records counters and modes, not authorization headers or payload contents. Test-only Node/OpenSSL prerequisites are documented below. API requests and cost: **0 / $0**.

## Observed compatibility

| Case | Observation and consequence |
| --- | --- |
| Public JSON and ownership | Valid Responses views negotiate `h2`; closing OpenAIClient leaves the injected pool usable. Sequential JSON reuses one connection. |
| Native JSON abort | An already-completed trigger is ignored. In-flight abortion before headers and after actual client header arrival leaves the request active; releasing the peer produces a successful response. Reusable IOClient aborts the equivalent pending requests. |
| Responses SSE abort | Both before and after headers, closing the dedicated candidate drains the active request instead of stopping it. Data can still arrive after the requested abortion. The peer must end/reset the response to complete shutdown. |
| Subscription cancellation | Public Responses SSE subscription cancellation and raw body cancellation reset the individual stream, observed before peer release; an unrelated request can use the same shared connection. Cancellation is distinct from graceful client close. |
| Graceful shutdown | `close()` rejects new requests but waits for existing bodies; an open SSE keeps `closed` pending until completion/cancellation. |
| GOAWAY and capacity | A server GOAWAY permits the accepted SSE to finish and a later JSON call reconnects. Five held requests open three connections under a configured two-stream cap and under a server-advertised two-stream cap with the client's cap at 100. This is not a general GOAWAY/retry or zero-limit stress study. |
| Multipart and streamed upload | Public 1 MiB multipart upload succeeds. A directly streamed adapter request sends no partial upload to the peer until the producer closes; requests are fully buffered by `finalize().toBytes()`. Public byte-based uploads already hold caller bytes, so the latter is an adapter probe, not a new public streaming-upload feature. |
| Paused response | In the bounded 4 MiB probe, Node enqueues/completes the full candidate response while its Dart consumer is paused. The IO baseline stops enqueueing earlier. The adapter listens to incoming messages without forwarding downstream pause/resume; this is evidence of weak backpressure, not an exact Dart buffer-size measurement. |
| Repeated SSE | The local reusable public SSE workload has candidate failures on subsequent requests; recorded errors include `ClientException` and peer `ERR_HTTP2_ERROR`. All matched IO requests succeed. Node's reference client completes eight sequential SSE requests (80 events) on one connection. The adapter/client/Node interaction is demonstrated; its precise cause and other peers/versions are not established. No failed timing is counted as a speed improvement. |
| Redirects and gzip | The adapter returns the 302 and raw gzip bytes. The reusable IO baseline follows the same redirect and decompresses the same gzip response. Configuration and application handling would need separate assessment before a drop-in recipe. |
| Proxy | IOClient supports the tested explicit `HttpClient.findProxy` hook; the candidate dials directly and exposes no equivalent proxy hook. Environment/system proxy behavior is not claimed to have been exhaustively tested. |
| HTTP/1/plain HTTP | Plain HTTP is rejected; HTTPS without negotiated `h2` fails instead of falling back. |
| Browser | The IO-only adapter compiles through Dart's browser stubs, but the real Chrome JavaScript dial rejects with Unsupported operation. An exploratory Wasm dial did not settle and its runner had to be stopped; no candidate Wasm support is claimed. The committed negative browser fixture targets JavaScript; existing Responses regression fixtures pass JavaScript and Wasm. The package's browser transport remains unchanged. |

## Matched measurements

Batch total milliseconds: median [minimum–maximum]. Only fully successful cells with successful warm-up are comparable.

| Workload | HTTP/1.1 | HTTP/2 | New connections H1 / H2 |
| --- | --- | --- | --- |
| JSON cold, concurrency 1 | 65.7 [63.9–128.2] | 65.8 [64.6–93.9] | 1–1 / 1–1 |
| JSON cold, concurrency 8 | 22.1 [19.1–25.9] | 16.9 [14.0–23.2] | 8–8 / 1–1 |
| JSON warm, concurrency 1 | 54.6 [53.7–56.4] | 56.5 [54.1–57.9] | 0–0 / 0–0 |
| JSON warm, concurrency 8 | 8.9 [8.1–11.0] | 9.2 [8.8–10.3] | 0–0 / 0–0 |
| SSE cold, concurrency 1 | 843.6 [817.2–943.9] | **failed 20/40** (warm-up failures 0) | 1–1 / 4–4 |
| SSE cold, concurrency 8 | 114.8 [110.7–126.0] | 110.5 [108.4–121.2] | 8–8 / 1–1 |
| SSE warm, concurrency 1 | 821.5 [779.7–897.5] | **failed 20/40** (warm-up failures 20) | 0–0 / 4–4 |
| SSE warm, concurrency 8 | 105.6 [103.2–108.7] | **failed 40/40** (warm-up failures 0) | 0–0 / 0–0 |

Recorded platform: macos (Version 26.6.2 (Build 25G83)); Dart `3.12.2 (stable) (Tue Jun 9 01:11:39 2026 -0700) on "macos_arm64"`, Node `v26.3.1`, OpenSSL `OpenSSL 3.6.4 25 Aug 2026 (Library: OpenSSL 3.6.4 25 Aug 2026)`, `http` 1.6.0 and `http2` 3.1.0. [Source receipts](../http2/source-receipts.json) bind the archive, adapter, runtime and fixture bytes.

Each cell has five paired samples of eight requests with concurrency 1 or 8. Protocol order alternates within samples. The client is reused throughout each batch; **cold** means its pool starts empty, not eight fresh clients. Warm cells prime eight requests at the same concurrency before measurement. A warm-up failure makes a cell ineligible for warm performance claims. Connections are actual new peer TCP/TLS connections during the measured batch; warm zero means reuse, not absence of connections.

JSON Responses use the same ~4 KiB body and 5 ms service delay. Synthetic SSE uses ten ~4 KiB events at 10 ms intervals. Header arrival, first nonempty body byte, first parsed SSE event and total completion are separately recorded. For JSON, the `first_event_ms` field is full public Response completion, not first byte. Raw per-request measurements and failures are retained in [measurements.json](../http2/measurements.json); [summary.json](../http2/summary.json) records median, minimum and maximum for each cell and every captured timing distribution. Throughput counts successful completed requests only.

The bounds are eight requests per batch, concurrency at most eight, stream/HTTP1 connection cap 100, three-second per-request deadline, four-minute whole-run deadline, 256 peer requests and fixed 4 MiB memory probes. Peer holds self-release after five seconds; fixture observation and startup/command waits are bounded. A deadlining experiment is a failure, not successful completion or proof of transport release.

## Memory observations and limits

| Bounded probe | Sampled RSS increase | Producer/peer observation |
| --- | --- | --- |
| H1 public_multipart_4MiB | 4.14 MiB | wire 4,194,703 bytes |
| H1 paused_raw_response_4MiB | 0.88 MiB | peer enqueued 851,968 bytes while paused; payload finished false |
| H2 public_multipart_4MiB | 12.34 MiB | wire 4,194,703 bytes |
| H2 paused_raw_response_4MiB | 0.61 MiB | peer enqueued 4,194,304 bytes while paused; payload finished true |

RSS is sampled every 5 ms in the Dart process; the Node process is excluded. Input upload bytes are allocated before the upload baseline. These are observed deltas in a shared JIT/GC process, not allocation counts, isolated transport overhead, instantaneous peaks or memory guarantees. There is no forced GC or heap-profiler attribution, and zero/small deltas cannot establish zero buffering. Wire counters establish producer/peer behavior independently of RSS.

Loopback timings omit WAN round-trip cost, proxies, production server policy, long-run connection aging and model execution. Certificates and peer startup are outside measured batches; cold request TLS handshakes are inside. Variability, JIT, scheduling and GC affect these small samples. Fewer connections plausibly help other workloads, but these results do not establish a real OpenAI latency benefit.

## Reproduce and validation

From `packages/openai_dart`, after workspace `dart pub get`, with Node >=18 and OpenSSL supporting `req -addext`:

```sh
dart test --reporter=failures-only test/unit/resources/http2_evaluation_test.dart
dart test --platform chrome --reporter=failures-only test/unit/resources/http2_browser_evaluation_test.dart test/unit/resources/responses_compact_test.dart
dart test --platform chrome --compiler dart2wasm --reporter=failures-only test/unit/resources/responses_compact_test.dart
dart run benchmark/http2/transport_benchmark.dart 5 > measurements.json
```

The benchmark writes progress to stderr and JSON evidence to stdout. It accepts 3–10 samples. It requires no API key and constructs loopback URLs only. Fixtures are under `test/unit/` because they call local servers, not live APIs. There is no benchmark claim from a MockClient.

Local validation passed: 23 native compatibility fixtures, also run successfully from the monorepo root using package-resolved peer paths; four Chrome JavaScript checks (the candidate negative fixture plus three existing Responses checks); three existing Chrome Wasm regression checks; and the complete VM unit suite, **25,233 passed with two existing environment-dependent skips**. Formatting covered 719 files with zero changes, `dart fix --apply` found nothing to fix and `dart analyze .` was clean. Node syntax validation and `git diff --check` passed. API toolkit diagnostic identities are unchanged: 984 existing implementation errors, 126 warnings and 278 infos, plus 115 consistency warnings; exports/docs/README have no errors. All 389 tracked production library/spec/config files are byte-identical to the merged base, and the only pubspec change is the exact development dependency. The final benchmark runs separately from tests and compiler jobs.

Independent review corrected five material draft evidence gaps: public reset telemetry, server-advertised capacity, actual after-header abortion, bounded SSE/RSS cleanup, and first-body-byte timing. Peer reset telemetry also distinguishes Node compatibility response finish from explicit payload completion. Earlier incomplete runs and exploratory failures are retained in `/tmp/openai-alignment-audit/46-http2`; only the committed final measurements support the numerical report. Published-file and exact-head CI approvals remain later gates, separate from this local result.

## Decision and finish line

**Defer.** Multiplexing is demonstrated, but ignoring native abort signals, graceful-close SSE mismatch, fully buffered requests, weak response backpressure and this peer's repeated SSE failures outweigh the demonstrated connection savings. HTTPS+h2-only, IO-only and redirect/compression/proxy differences also prevent a general drop-in recommendation. No migration, upstream patch, opt-in recipe, release or new ticket follows automatically.

All seven bounded core Agents/Vaults tickets are already merged through #406. Acceptance of this one reviewed evaluation closes #399 and the bounded parent #317 after its user-authorized merge; deferred helpers, Admin/legacy and later parity remain deferred inventory. Completion does not claim complete API/SDK parity.
