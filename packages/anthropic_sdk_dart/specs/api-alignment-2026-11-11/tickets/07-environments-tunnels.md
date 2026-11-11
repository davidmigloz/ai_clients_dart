# Add Managed Agents environments and tunnels

[GitHub issue #484](https://github.com/davidmigloz/ai_clients_dart/issues/484).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `07-environments-tunnels` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Add environment lifecycle, self-hosted work endpoints and publicly documented tunnel and certificate flows.

## Dependencies

- #483

## Acceptance

- [ ] Cover every current generated environment and tunnel method, with path, verb, headers, body and documented pagination.
- [ ] Verify ticketing/heartbeat and binary or certificate contracts where applicable, and document access requirements.
- [ ] Account separately for historical organization-prefixed tunnel aliases and surface any genuine access/contract blocker.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.

## Wire decisions

- The six environment operations and eight self-hosted work operations use `managed-agents-2026-04-01`. Management uses the configured credential and workspace. An explicitly scoped worker bearer excludes the configured API key and is only available on documented bearer-capable work operations. The official direct Claude API workers poll and acknowledge with the environment key, then use the sessions credential for renewal and stop. The SDK preserves the heartbeat string verbatim so it can be echoed for optimistic concurrency. [Pinned Python work resource](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/resources/beta/environments/work.py) · [Pinned TypeScript work resource](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/resources/beta/environments/work.ts)
- The frozen HTTP snapshot and Python output type describe session work. TypeScript also exposes the `healthcheck` work arm with an optional discriminator. Dart decodes both and retains raw future work arms. The official worker loop performs sandbox execution, tool routing and lease renewal over the public operations. Dart exposes those operations and the scoped credential and lease models. The worker runtime and provider credential parity remain part of closeout. [Pinned TypeScript work models](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/resources/beta/environments/work.ts#L405) · [Environment platform differences](https://platform.claude.com/docs/en/managed-agents/choosing-an-environment)
