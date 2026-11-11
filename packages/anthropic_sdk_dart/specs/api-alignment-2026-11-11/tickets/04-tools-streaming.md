# Align tool replay, streaming and typed errors

[GitHub issue #481](https://github.com/davidmigloz/ai_clients_dart/issues/481).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `04-tools-streaming` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Close tool addition/removal, MCP listing and browser/computer toolset gaps. Audit structured output, tool-runner helpers and errors.

## Dependencies

- #478
- #480

## Acceptance

- [ ] Verify inline tool definitions and MCP listing replay; keep version and beta gates explicit.
- [ ] Verify browser/computer tool-call decoding, unknown tool cases, tools and output usage accounting, and the supported SDK helper workflows.
- [ ] Preserve status and request IDs, structured errors, cancellation and error termination across HTTP and SSE. Verify no partial stream appears as a successful final message.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.
