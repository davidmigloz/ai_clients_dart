# Environment lifecycle webhooks and subscriptions

Status: deferred outside the bounded milestone; not implemented.
GitHub: [#392](https://github.com/davidmigloz/ai_clients_dart/issues/392).
Primary requirements: `AGENTS-WEBHOOK-01`.
Native GitHub blockers: [#389](https://github.com/davidmigloz/ai_clients_dart/issues/389), [#357](https://github.com/davidmigloz/ai_clients_dart/issues/357), [#358](https://github.com/davidmigloz/ai_clients_dart/issues/358).
Original tracker: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317); removed from its active child list.
Specification: [Agents and Vaults](../agents-vaults.md), AGENTS-WEBHOOK-01.
Dependencies: [ticket 37](37-environments-templates.md); merged [#357](https://github.com/davidmigloz/ai_clients_dart/issues/357) and [#358](https://github.com/davidmigloz/ai_clients_dart/issues/358).

Deferred backlog: retained for future explicit prioritization; this ticket does not block completion of #317. Its acceptance remains unchecked, and implementation will not start automatically.

## User capability and scope

A caller can subscribe through the existing webhook-endpoint resource, verify a
signed delivery, inspect its typed environment notification, and retrieve the
environment using its ID. This adds **zero HTTP operations** to the 47-operation
Agents/Vaults partition. It extends existing endpoint subscriptions and typed
received webhooks rather than introducing an environment action endpoint.

Own `agent.environment.ready`, `agent.environment.failed`,
`agent.environment.suspended` and `agent.environment.expired`. Map the four
`WebhookAgentEnvironment*` schemas plus their actual
`WebhookAgentSessionEnvelope`/`AgentEnvironmentEvent` dependencies to implemented
types. These envelopes have `id`, `object`, `created_at`, `type` and `data`; they
are distinct from session SSE events. Ready/failed describe prewarm setup;
suspended allows later resumption, whereas expired cannot resume from a snapshot.

## Acceptance criteria

- [ ] All four signed notification variants are publicly decoded and accessible, with constructor/parser/copy, round-trip, immutable ownership and equality/hash fixtures for their real required fields.
- [ ] The endpoint subscription enum supports all four names; actual public mock create/update/list/retrieve flows preserve them with explicit project selection and existing auth/header behavior.
- [ ] Known malformed notification fields fail validation; existing finite unknown-event handling remains available without claiming unknown shapes satisfy the canonical discriminator schema.
- [ ] Verification uses the original request bytes and existing signature/timestamp policy; bad signatures, mutated bodies and replay-window failures reject before caller handling.
- [ ] Required envelope fields remain present and environment data is detached. Printable diagnostics never expose signing secrets or confidential payload values.
- [ ] Existing five agent.session notifications and unrelated webhook variants retain their behavior; notification receipt does not imply exactly-once delivery, automatic execution, provision entitlement or a lifecycle-control endpoint.
- [ ] An offline example configures subscriptions, verifies synthetic deliveries, handles repeated IDs in application-owned state and retrieves the selected environment without a live provisioning call.
- [ ] README/llms, exports and real manifest mappings describe the implemented capability; VM, actual Chrome JavaScript and Wasm fixtures, appropriate package checks, independent requirements/engineering review and exact final-head CI pass before user-authorized merge.

## Evidence and validation plan

Wire authority is immutable [OpenAPI `0ef225c4`](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json).
Workflow context comes from the [webhook guide](https://developers.openai.com/api/docs/guides/agents-api/sessions/webhooks)
and [environment lifecycle guide](https://developers.openai.com/api/docs/guides/agents-api/environments/lifecycle).
The specification and [planning ledger](../agents-vaults-plan.json) retain source
pins and distinguish these additional webhook schemas from the HTTP closure.

Default validation is deterministic offline signed fixtures and public mock HTTP:
**no API key, live call or cost**. Planning evidence does not satisfy any checkbox.
No release/version bump or Phase 7/8 implementation belongs to this ticket.
