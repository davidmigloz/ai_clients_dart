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

## Structured output helper decisions

The pinned Python and TypeScript response parsers attempt to decode every text
block when a schema is supplied. Claude's guide describes refusals and
token-limited responses whose text may fall outside the schema. Dart decodes
completed text on a natural turn end or requested stop sequence. For other
stop reasons it returns the original message for recovery or inspection.
Decoder errors on completed text retain the original message and block index.
[Pinned Python response parser](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/lib/_parse/_response.py) · [Pinned TypeScript response parser](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/lib/parser.ts) · [Claude structured outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs)

Persisted request JSON accepts a single deprecated top-level `output_format`
and emits `output_config.format`. Dart rejects both format values together,
matching the pinned beta Messages request transforms. Python GA `messages.parse`
merges its typed format over an existing format. TypeScript beta batch creation
passes stored request items through. Dart applies one rule to persisted JSON for
Messages, token counts, and batches. The Dart helper takes a JSON Schema and
caller decoder, preserving effort and task-budget settings.

Completed Messages stream helpers require `message_stop`, a matching stop for
each started content block, and `message_delta`. The structured helper also
requires a non-null terminal stop reason before decoding. Ordinary stream
completion still preserves explicit null updates for compatibility. Snapshots
can be read during the stream. [Claude streaming event order](https://platform.claude.com/docs/en/build-with-claude/streaming) · [Streaming stop reasons](https://platform.claude.com/docs/en/build-with-claude/handling-stop-reasons)
[Pinned Python conflict check](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/lib/_parse/_transform.py) · [Pinned TypeScript request transform](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/lib/internal/beta-messages-request.ts)
