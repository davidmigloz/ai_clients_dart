# Optional local Agent function dispatch (#395)

Status: implementation and early engineering review complete; final-head review and CI remain merge gates. Reactivated under #413; #317 remains completed. Zero HTTP operations or wire schemas are added.

## Authority and distinct local metadata

Frozen authority remains OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`, SHA-256 `73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc`, Python 3.42.0 `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`, Node 7.47.0 `c717857c3151bde92e07e4d396301a9c67163e68`. The [scoped handoff](43-local-dispatch-manifest.json) records six unchanged real DTO bindings and exact source hashes. Global source/manifest promotion remains #427-owned.

Both frozen SDK dispatchers use `agent.session.turn.item.added` plus `function_call`, not item.done. Reuse existing canonical `AgentSessionFunctionCallItemResource`, input/output unions and raw session create/events operations; no callback-shaped wire DTO exists. Local `AgentToolHandler`, `AgentToolErrorObserver`, stage enum and private error context never enter request JSON or mutate stored tool definitions.

`sessions.stream(...,toolHandlers:...)` adds dispatch to the existing follow-up handle. `sessions.createRun(request,toolHandlers:...)` captures a canonical streamed request and returns the same lazy cursor. Omitted/true stream means SSE; explicit false rejects before authentication/HTTP. This explicit Dart helper choice differs from Node's callback property requiring stream:true in the raw creation body; raw Dart create/createStream remain manual. No saved Agent, hosted environment, credentials, browser responses or executor are created automatically.

Creation identity comes only from canonical session.created. Its ID must pass the raw resource's opaque-segment/path admission before identity is exposed or callbacks execute. A registered call before identity, a foreign session, or a conflicting nonnullable outer turn fails locally. Nullable outer turn remains valid, and call.turn_id is the captured result routing identity.

## One checkpoint and one logical submission

The original event is queued in arrival order with a detached routing/argument/handler checkpoint before caller delivery. Advancing the same cursor executes that pending checkpoint once, sequentially. Stream cancellation immediately after delivery does not run it. Arguments are decoded/detached as a JSON object; primitive/array/null arguments remain valid raw wire shapes but do not invoke local object handlers.

Registered calls deduplicate `(turn_id,call_id)` for the full invocation, including child turns and beyond the 1,024-event recent-ID window. Distinct registered calls have a configurable default 1,024-call local budget; overflow fails without evicting identities or rerunning side effects. Unknown function names remain manual. Wire tools, callback registration and execution are separate responsibilities.

JSON object outputs become JSON text. Text, canonical supported input content/typed output and null use the existing tool-result union. Argument, execution and serialization errors submit exactly `Tool handler failed.` and success:false. An optional asynchronous observer receives the real cause/stack/stage and captured identifiers privately; it is awaited, and observer failure cannot replace or suppress the generic result. HTTP failures do not notify that observer or become tool failures.

Every result captures its body and a generated result-prefixed key distinct from the input key, stripping all input-key casing from result options. Generic transport retries are disabled only for these result requests. The narrow registration race permits four total attempts with waits of 100/300/600 ms only for status400, code invalid_request_error, and the exact captured call-ID message. Handler/body/key never change across those attempts. Other400s,429,503 and uncertain transport failures propagate immediately; this intentionally does not inherit the SDKs' broader ordinary retry policy. Raw events.create defaults remain unchanged and authentication submissions can never enable retries.

A public mixed-case defaults/rotating-provider fixture exposed creation SSE header precedence: a case-sensitive map can retain an updated caller key before a later differently cased provider key. A narrow internal `openPrivateByteStream.idempotencyKey` value is forced after header construction, supplied only from explicitly captured Agent request headers. Other private stream media/retry behavior is unchanged. Existing AuthInterceptor filtering and raw events.create's final caller-key correction already preserve follow-up/results; both create/follow-up probes verify stable distinct logical keys through the exact race loop.

## Lifetime, privacy and validation

Abort wins while callback, observer, retry timer or HTTP work is pending: stop waiting, cancel owned timers/observation, and submit no false generic tool failure or late output. Completed operation races unregister removable stop listeners rather than permanently attaching Future.any continuations to a lifetime Future. Three deterministic internal fixtures assert zero registrations after 100 large successful payloads while the lifetime remains open, plus error/stop/late completion cleanup. Arbitrary callback Futures require application cooperative cancellation; completed side effects are not undone. Source-only failures after a validated boundary do not poison completion, while real callback/result-HTTP failures remain distinct. Private default diagnostics retain explicit readable causes without logging payloads or identifiers.

- 47 new deterministic public helper/resource tests and 3 internal removable-stop lifecycle tests passed on VM, actual Chrome JavaScript and Chrome Wasm; all 39 idle-run regressions also passed on VM.
- Fixtures cover output/argument unions and invalid/cyclic/nonfinite values, observer failure/awaiting/privacy, full-run dedup/window eviction/child turns, sequential callbacks, cancellation before resumption/during callbacks/observer/race wait, explicit call budget, exact retry/exhaustion and wrong-code/message/status errors, lazy streamed creation, identity/path admission and mixed-case provider/default keys.
- Offline example passes follow-up and `--create` modes using only synthetic HTTP/SSE and separate canonical definitions/local callbacks.
- Scoped formatting/fixes, read-only package analysis and toolkit documentation/README checks passed, with 65 collapsible usage topics. Final exact-head independent review and CI remain merge gates.

Result collection/output parsing (#396), files/artifacts (#397), release/version/changelog and global source promotion are outside this slice.
