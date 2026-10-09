# Optional idle-session run observation

Status: planned; implementation acceptance pending.
GitHub: [#394](https://github.com/davidmigloz/ai_clients_dart/issues/394).
Primary requirements: `AGENTS-HELPER-01`, `AGENTS-HELPER-02`, `AGENTS-HELPER-03`, `AGENTS-HELPER-04`.
Native GitHub blockers: [#386](https://github.com/davidmigloz/ai_clients_dart/issues/386).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Agents and Vaults](../agents-vaults.md), AGENTS-HELPER-01–04.
Dependency: [ticket 34](34-durable-sessions.md).
Shared reference: input-key portion of AGENTS-HELPER-08, primarily owned by [ticket 43](43-local-dispatch.md).

## User capability and scope

A caller can deliberately start one follow-up on an idle durable session and
consume a single-use handle until the selected root turn has terminated and the
session is idle. This optional local helper owns **zero new HTTP operations**.
Raw session input remains able to steer active work; the helper's idle and
single-input-writer requirements are local workflow rules, not server guarantees.

The proposed Dart helper captures immutable input/options and starts lazily.
Retrieve idle state, await the SSE subscription's readiness, then POST normalized
input. Keep raw persistent observation, guide samples stopping at a terminal
event, and this terminal-then-idle helper as distinct consumption modes.

## Acceptance criteria

- [ ] The public handle performs zero HTTP requests before deliberate start/iteration, permits one consumption, snapshots mutable inputs/options and rejects repeated consumption locally.
- [ ] Public controlled fixtures prove retrieve idle → subscribe ready → input POST. Non-idle sessions reject before subscription/input; submission failure releases the observation. Raw active-session input still works.
- [ ] A nonempty string normalizes to one user input_text message. Empty-input rejection is a helper rule; valid raw API shapes remain unchanged. The submission's stable input key follows the shared case-insensitive precedence policy without taking ownership of dispatcher result retries.
- [ ] The first turn.created with subagent_id null selects the coordinator turn. Initial idle, child terminal events and unrelated turn terminals cannot complete the handle.
- [ ] Original events remain available in order, with bounded recent event-ID deduplication matching the pinned SDK bound of 1024; overflow/eviction is deterministic and does not retain unbounded history.
- [ ] Selected completed/failed/cancelled turn → session.idle, or session.failed, ends observation. Unexpected EOF before that boundary is a local observation error, never an invented backend outcome.
- [ ] Close/break/abort during retrieve, subscribe, input or later observation releases local HTTP/SSE/buffers and preserves the exposed abort cause. No implicit cancel event, session delete or replay/resume request occurs.
- [ ] Documentation makes concurrent input-writer limitations explicit. Local cancellation cannot undo completed side effects or forcibly cancel arbitrary application Futures; later dispatch integration uses cooperative cancellation.
- [ ] A public offline idle-run example and README/llms demonstrate the boundary and manual backend cancellation. VM, actual Chrome JavaScript and Wasm fixtures, appropriate package checks, independent requirements/engineering reviews and exact final-head CI pass before user-authorized merge.

## Evidence and validation plan

Helper behavior comes from pinned [Python streams](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/streaming/agents/_streams.py)
and [Node session streams](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/agents/agent-session-stream.ts),
cross-checked against the [session guide](https://developers.openai.com/api/docs/guides/agents-api/sessions).
Deep input capture is an explicit Dart design choice; do not claim both SDKs
deep-copy user input arrays. Canonical wire contracts remain owned by ticket 34.

Use controlled streams, public mocks and deterministic ordering assertions:
**no API key, live call or cost**. Planning evidence satisfies no checkbox.
Tool callbacks, result collection and parsing belong to tickets 43–44.
