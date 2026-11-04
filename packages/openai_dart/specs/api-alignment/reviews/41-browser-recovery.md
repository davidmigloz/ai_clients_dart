# Browser actions and current-state recovery (#393)

Status at PR preparation: implementation and independent engineering/requirements review complete; final browser refinement check and exact-head CI remain merge gates. Reactivated under #413; #317 remains completed.

## Bounded scope and sources

This adds zero HTTP operations and zero schemas. Canonical authority is OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce` (SHA-256 `73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc`). Python 3.42.0 (`0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`) and Node 7.47.0 (`c717857c3151bde92e07e4d396301a9c67163e68`) retain the same three origin decisions and separate private authentication submit/cancel contracts. Exact SDK file hashes and nine unchanged model bindings are in [the scoped handoff](41-browser-recovery-manifest.json). Global promotion remains #427-owned.

Existing raw DTOs already enforce field/request bounds, six active fields, the 120 KiB submission budget, immutable ownership and private diagnostics. Dedicated authentication submission already disables physical retries, including custom middleware retries. These behaviors are reused and regression tested without duplicate wire models. No browser executor, password manager, automatic approval or credential replay was added.

The [session events guide](https://developers.openai.com/api/docs/guides/agents-api/sessions/events#how-to-recover-a-disconnected-stream) and [computer-use guide](https://developers.openai.com/api/docs/guides/agents-api/tools/computer-use) describe the workflow. Rechecking them did not expand the frozen operation/schema scope.

## Readiness and application-owned examples

`AgentSessionEventsResource.stream` gains optional synchronous `onReady` after successful status/media header validation and before body delivery. It can complete a local signal without waiting for an initial event; setup failure/cancellation never signals readiness. Callback failure disposes the response, retains the original explicit cause and surfaces private default diagnostics even for application-thrown SDK exceptions. A post-callback guard handles reentrant subscription cancellation without retaining a late body. Callback-free raw behavior and HTTP ownership remain unchanged.

Readiness is an observation boundary, not an atomic distributed-state transaction or a guarantee of continued connection. Callers must handle stream error/EOF both while awaiting readiness and during retrieval, then close their subscription on every exit. The callback's return is ignored; it is intended only to complete a local signal.

Both examples are offline. Recovery opens and buffers first, retrieves current session and paginated root history, stores final output by ID, drops buffered updates for already-final IDs, bounds retained application state by count/bytes and history by 32 pages, deduplicates recent event IDs and resumes live updates. It refreshes current required actions after restoring output; historical/buffered forms never authorize a response. The browser example retrieves current forms before each explicit approve/deny/cancel or authentication cancel/submit, omits an invented turn_id, and waits for observed resumed work after HTTP 202 acceptance. Uncertain delivery requires a fresh explicit state read and human decision.

Origin approval does not alter network permissions or confirm every consequential action. Closing/breaking/aborting observation does not cancel backend work, delete a durable session, shut down self-hosted compute or erase published artifacts. Session, turn, observer and environment states remain distinct. The finite example view is an application rendering policy, not an SDK history/result collector.

## Local validation

- 379 targeted raw-session, streaming, private-diagnostic, shared audio-stream and authentication/source-boundary regressions passed.
- 14 final focused fixtures passed on VM and Chrome JavaScript, including generic/private typed callback errors, preserved causes, reentrant cancellation, one physical auth submission after either HTTP or transport failure, explicit refresh and FINEST body-log redaction.
- The same 14-case selection passed in actual Chrome Wasm after the production callback privacy fix. A final Wasm rerun of the later test-only FINEST logging assertions is pending the shared browser compiler slot; the PR validation checklist records its final outcome.
- Both synthetic HTTP/SSE examples passed with zero external calls. They never submit a task, execute a tool, provision an environment or register credentials.
- Scoped format/fix/analyze, toolkit docs/README and whitespace checks passed. Only the five changed Dart files are formatted/fixed, avoiding unrelated mutation. Independent engineering/requirements review passed after the callback privacy fix. Exact-head CI remains pending at PR preparation.

No release, version, changelog, global manifest or canonical-spec change belongs here.
