# Completed-result collection and local structured parsing

Status: deferred outside the bounded milestone; not implemented.
GitHub: [#396](https://github.com/davidmigloz/ai_clients_dart/issues/396).
Primary requirements: `AGENTS-HELPER-09`, `AGENTS-HELPER-10`, `AGENTS-HELPER-11`, `AGENTS-HELPER-12`.
Native GitHub blockers: [#394](https://github.com/davidmigloz/ai_clients_dart/issues/394), [#395](https://github.com/davidmigloz/ai_clients_dart/issues/395).
Original tracker: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317); removed from its active child list.
Specification: [Agents and Vaults](../agents-vaults.md), AGENTS-HELPER-09–12.
Dependencies: [ticket 42](42-idle-run-helper.md) and [ticket 43](43-local-dispatch.md).

Deferred backlog: retained for future explicit prioritization; this ticket does not block completion of #317. Its acceptance remains unchecked, and implementation will not start automatically.

## User capability and scope

A caller can opt into completed coordinator-message collection before consuming
a run, retrieve a detached raw result from that same observation, and optionally
parse all final text blocks using a supplied schema and local validator. This
owns **zero new HTTP operations**: there is no final-result route. Integration
must work both with manual required actions and enabled local dispatch.

## Acceptance criteria

- [ ] Collection is opt-in before progress consumption or final-result retrieval starts an unused handle. Default consumption retains no collector messages; late enable rejects. Partial manual consumption and getter draining use the same iterator/dispatcher rather than create another observation or input.
- [ ] Repeated successful result retrieval reuses the detached successful result, without HTTP, handler or parser re-execution; collector buffers are released. Failed-result caching is explicitly specified as a Dart choice because Node caches a rejected promise while Python may retry a failed parser.
- [ ] Collect only completed assistant item.done snapshots for the selected root turn. Exclude partial/commentary/child output, accept completed legacy null-phase, deduplicate item IDs and order by output_index.
- [ ] Full source-supported snapshots are detached, with legitimate received extras following the established parser policy. Current canonical OutputTextResource has no annotations field: add no invented typed field or claim unknown extras satisfy the canonical schema.
- [ ] A pure all-message text projection joins text in content order and stays distinct from final-answer selection. A completed raw result with no text remains valid; mutation, duplicate and out-of-order fixtures verify ownership/equality/hash.
- [ ] Success requires the selected completed turn and idle boundary. Failed/cancelled turns, unhandled function/browser/environment actions and incomplete observation produce typed local errors retaining detached partial turn/messages/actions and the exposed cause. Unhandled actions fail promptly rather than hang.
- [ ] Transport/observation failure never claims backend failure. Generic printable errors protect private values while explicit partial-result properties remain useful; an established completed boundary is not poisoned by unrelated later transport failure.
- [ ] Typed output uses caller-supplied JSON schema plus a local parser/validator. Streamed creation binds the canonical schema; existing-session follow-up uses only the local parser and sends no session update or inferred schema change. Conflicting bindings reject before HTTP.
- [ ] Validate every final output_text block, retaining the first successfully parsed value as the typed result only after all blocks validate. No text or any later parsing failure yields a generic parse error preserving the completed raw result; callbacks/parsers never enter wire JSON.
- [ ] Public offline raw/typed examples, README/llms and exports demonstrate collection timing, partial outcomes and manual/dispatch integration. VM, actual Chrome JavaScript and Wasm fixtures, appropriate package checks, independent reviews and exact final-head CI pass before user-authorized merge.

## Evidence and validation plan

Sources are pinned [Python result collection](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/beta/agents/_result.py),
[Node collector](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/agent-turn-result-collector.ts),
[Node collection lifecycle](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/result-collection.ts)
and [Node parsing](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/parse-result.ts).
Dart adapters do not import Pydantic or Zod runtimes. Canonical DTOs remain owned
by the raw tickets and the [planning ledger](../agents-vaults-plan.json).

Use controlled streams, synthetic parser failures and public mocks: **no API key,
live call or cost**. Planning evidence satisfies no checkbox; no release is included.
