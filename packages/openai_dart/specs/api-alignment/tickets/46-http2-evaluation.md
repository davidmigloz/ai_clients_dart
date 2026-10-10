# Evaluate optional HTTP/2 transport support

Status: local evaluation complete; **defer** recommended. Final published-head review/CI and user-authorized merge pending.
GitHub: [#399](https://github.com/davidmigloz/ai_clients_dart/issues/399).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [HTTP/2 evaluation](../http2-evaluation.md).
Primary requirements: `HTTP2-EVAL-01`, `HTTP2-EVAL-02`, `HTTP2-EVAL-03`, `HTTP2-EVAL-04`.
Dependency: none; use existing public client/Responses HTTP and SSE paths.
Canonical operation ownership: none. This is one evaluation, not another API slice.

The user approved this one additional ticket. Evaluate `http2` 3.1.0 as an optional
native transport while preserving the existing production dependency/default/API.
Local multiplexing saves concurrent connections; cancellation, buffering and repeated SSE compatibility block adoption.
A documented **defer** outcome can close the ticket. No migration, upstream fix or
follow-on issue is required or automatically authorized.

## Acceptance criteria

- [ ] Fixed published/tagged source receipts and current client injection/ownership seams are verified; no unsupported runtime or measured-performance claim is made from source inspection alone.
- [ ] Public-client fixtures against a real local TLS HTTP2 peer classify abort before/after headers, SSE abort/subscription cancel, shared-stream isolation, borrowed ownership and graceful shutdown/GOAWAY. Known failures are recorded; they need not be repaired to conclude defer.
- [ ] Bounded multipart/streamed-upload and slow-consumer fixtures record buffering/backpressure behavior; HTTP1/plain HTTP rejection, browser portability and redirect/compression/proxy differences are explicitly documented for the evaluated scope.
- [ ] Reusable HTTP1/HTTP2 clients have matched local cold/warm, sequential/concurrent JSON and synthetic-SSE measurements, including connection counts, total/first-byte latency, throughput and bounded memory observations. Versions, limits, sample variability and reproduction commands are recorded; no inference-speed or API-limit claim follows from synthetic results.
- [ ] One reviewed adopt/defer report explains measured gains, blockers and limitations. An opt-in recipe is published only for a demonstrated safe use case with ownership/platform/cancellation limits; otherwise defer closes the evaluation. Production transport/default changes and automatically created follow-on work remain outside scope.
- [ ] Appropriate local checks and independent review accept the evidence and decision; any committed fixtures/report have green final-head CI. Tests hitting only local servers remain unit tests; no API key, paid API or full live suite is used.

Wire/source facts and the finite evaluation boundary are in the linked specification.
The source assessment already identifies experimental/IO-only HTTPS+h2 behavior,
missing Abortable trigger handling, graceful close and whole-body upload buffering.
The report now exercises these source findings with runtime evidence. Final published-head review and CI remain acceptance gates. Default cost $0;
no release/version bump or new Agents/Vaults dependency.

## Evaluation record

[Evidence and decision](../reviews/46-http2.md) records local TLS fixtures, matched five-sample measurements, failures and limits. A defer decision completes this evaluation after final review/CI and user-authorized merge; it creates no migration or follow-on issue.
