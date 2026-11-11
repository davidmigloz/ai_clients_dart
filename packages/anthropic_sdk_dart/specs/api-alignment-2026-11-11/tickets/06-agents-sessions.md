# Align agents, sessions, events and multiagent workflows

[GitHub issue #483](https://github.com/davidmigloz/ai_clients_dart/issues/483).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `06-agents-sessions` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Update existing Managed Agents entry points for dynamic workflows, permission evaluation, session introspection and streaming.

## Dependencies

- #478
- #479

## Acceptance

- [ ] Verify agent, session, thread, event and resource paths, mandatory beta headers, and cursor/stream variants.
- [ ] Round-trip current permission, tool, networking, workflow and status unions, preserving future response variants.
- [ ] Provide a runnable multiagent example. Document organization and hosted/self-hosted server behavior.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
