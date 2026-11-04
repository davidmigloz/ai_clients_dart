# Optional completed Agent results and local parsing (#396)

Status: implementation and early engineering review complete; final-head review and CI remain merge gates. Reactivated under #413; #317 remains completed. No HTTP operation or wire schema is added.

## Source and local result boundary

Authority remains frozen OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce` SHA-256 `73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc`, Python 3.42.0 `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`, Node 7.47.0 `c717857c3151bde92e07e4d396301a9c67163e68`. The [scoped handoff](44-result-parser-manifest.json) binds existing real DTOs and hashes the inspected Python result/output helpers and Node collector/lifecycle/format types. Global source/manifest promotion remains #427-owned.

`AgentSessionRunResult` is a detached local completed-root snapshot, not a final-result route or wire DTO. Session and turn IDs derive from its actual completed root turn. Its messages reuse the canonical completed assistant message and OutputTextResource types, including received extras. Canonical OutputTextResource has no typed annotations field; none is invented here. The pure `agentSessionMessagesText` projection joins supplied content without phase selection. Result `outputText` joins collected messages; the Dart convenience `finalAnswer` chooses the last explicit final_answer message, then the last legacy null-phase message. These selections do not perform I/O.

## Single cursor and bounded collection

Collection is opt-in before progress consumption. `start()` alone may precede enabling because collection runs at the same delivery checkpoint, not a second source. A fresh `finalResult()` enables/drains that cursor; prior controlled `nextEvent()` calls can continue into it. Concurrent drivers reject without a second input/observation. Ordinary progress retains no collector history. Stream break before the boundary closes local observation and leaves a partial error; break at completed idle preserves success.

Only selected-root completed assistant item.done snapshots are collected. Exclude commentary, partial/added and child output; legacy null phase remains valid. Item.turn_id is the containing turn and is authoritative for exclusion, including a forwarded child item associated with coordinator context in outer event.turn_id. Matching root items require safe envelope/session correlation. Root creation/completion identities must agree with observed session, selected outer turn and actual turn payload. Conflicts fail typed-local identityMismatch instead of producing unsafe artifact-routing identity. No unproven server cross-field invariant is imposed on unrelated child items.

First completed item ID wins, matching Node; Python may overwrite duplicate item IDs. Output-index sorting is stable. Full source snapshots/extras are detached; immutable raw results provide matching equality/hash semantics. Default retention is 1,024 messages and 4 MiB of encoded retained turn/actions/messages combined. Limits are local Dart policy, not canonical source limits. Overflow fails explicitly without silently dropping state.

Both successful and failed result Futures are cached. This follows Node rejection caching and is an explicit Dart choice; Python can retry a failed parser. Completed temporary collector buffers are released after materializing the immutable success/partial error. No input, handler, parser or observation reruns on repeated retrieval.

## Outcomes, manual actions and privacy

Success requires an actual completed selected root turn and subsequent idle. Native failed/cancelled turns and session failure produce corresponding local result reasons. Required function/browser/environment/future actions remain explicit application responsibility; registered local handlers use the existing dispatcher. An unresolved action fails promptly instead of waiting indefinitely.

A manual HTTP202 response does not itself clear required actions. Before declaring a stored snapshot blocked, collection resumes a paused source, permits one zero-duration event-loop opportunity and drains at most the then-available queue count. This lets already-buffered canonical in-progress/completion state follow a manually submitted result. Consecutive unrelated/noisy deliveries cannot reset that bounded opportunity. No new HTTP, polling, action or replay is added. Later remote completion still requires current canonical observation.

`AgentSessionRunResultException` preserves reason, available selected turn/messages/actions and explicit cause using private default diagnostics. Observation/setup/input/result-delivery failure does not infer backend failure. Source-only late error after a validated boundary cannot poison it; real result POST failures remain errors even after completion was queued. Caller abort remains local and exposes its original reason; no false backend cancellation or tool failure is manufactured.

## Typed output

`withOutput(AgentSessionOutputBinding<T>(format: AgentJsonSchemaFormat, parse: validator))` before start returns a thin typed view of the same engine and enables collection. Streamed creation binds the canonical request.agent.text.format, preserving other settings and rejecting conflicting formats/clear flags before HTTP. Existing-session follow-up performs local validation only, sending no session update or inferred format change. Parser/callback metadata never enters JSON.

The synchronous caller parser must validate its expected schema; no Pydantic/Zod or inferred JSON-schema runtime is added. Every completed text block is validated. Return the first parsed value only after all blocks succeed. Missing text or a later error yields private `AgentSessionOutputParseException` preserving the successful completed raw result and explicit validator cause. Arbitrary T is parser/application-owned; its reference identity is cached, with no unsupported deep-copy promise.

## Verification

- 43 new public deterministic fixtures passed on VM, actual Chrome JavaScript and Chrome Wasm; all 89 prior shared-helper regressions passed alongside them on VM (132 total). Fixtures cover raw/typed cached success/failure, partial cursor continuation, completed Stream/early breaks, collection timing/concurrency, full snapshots/extras/equality/hash, output filters/order/dedup/null phase, no-text raw success, every-block parsing and later failure, creation format binding/conflicts and observed identity.
- Outcome fixtures cover native failure/cancellation, every required-action family, partial observation/abort/EOF, count/byte overflow, conflicting envelope/payload IDs, forwarded child exclusion, local dispatch and real result-delivery failure.
- Manual-action fixtures cover raw response plus buffered canonical clearing; unresolved actions with queued and ongoing unrelated noise fail promptly.
- The offline raw/typed example supports ordinary follow-up, streamed creation, raw results and local parse failure, all using synthetic HTTP/SSE only.
- Scoped formatting/fixes, read-only package analysis, toolkit documentation/README checks and whitespace checks passed. README retains 66 collapsible usage topics. Final exact-head independent review and CI remain required.

Files/artifacts (#397), release/version/changelog and global promotion (#427) remain outside this slice.
