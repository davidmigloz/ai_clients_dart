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

## Signed compaction in tool runs

The runner can request one signed summary between completed tool turns and
outside its assistant iteration budget. It uses full stateless replay. Claude
rejects signed compaction together with server-held Messages threads or
threshold compaction. Task budgets keep their total and omit `remaining`.
The summary request omits context editing, stop sequences, forced tool choices
and structured output formats, including fallback formats. Assistant requests
keep those settings.

The inline-tools beta records tool changes in the signed block. Dart compares
the ordered changes for local, server and MCP tools with the existing replay.
It keeps the original history when the returned list differs, including when
the API drops changes or returns a list whose equivalence is uncertain. A
failed threshold summary with null content leaves tool availability unchanged.
Signed blocks are reused unchanged and unusable summaries remain inspectable.

[Claude on-demand compaction](https://platform.claude.com/docs/en/build-with-claude/compaction-on-demand) · [Messages thread limits](https://platform.claude.com/docs/en/build-with-claude/message-threads#compaction) · [Signed replay and tool changes](https://platform.claude.com/docs/en/build-with-claude/compaction-thinking-blocks#change-the-system-prompt-or-tools) · [Pinned Python runner](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/lib/tools/_beta_runner.py) · [Pinned TypeScript runner](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/lib/tools/BetaToolRunner.ts)

## Successful Messages diagnostics

The pinned Python and TypeScript SDKs attach provider request and workspace
IDs to decoded objects. TypeScript also exposes the HTTP response through
`withResponse()`. Dart exposes a separate `MessageResponse` through
`client.messages.createWithResponse()`, with the same decoded `Message` plus
HTTP status and the two provider identifiers. Read identifiers from the
successful response headers. The request's correlation ID and workspace
selection describe outgoing routing and stay separate.

The buffered transport captures effective credentials at dispatch, including
credentials applied by provider adapters and across retries. Diagnostic
identifiers that echo those values are dropped even if the borrowed transport
omits request metadata. The opt-in wrapper uses the ordinary Messages decoder
and retains safe AWS and Azure request IDs independently, with a platform ID
fallback when Claude's ID is unavailable.
[AWS request IDs](https://platform.claude.com/docs/en/build-with-claude/claude-platform-on-aws#request-ids) · [Pinned AWS header aliases](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/packages/bedrock-sdk/src/AWS_restJson1.ts#L286-L288) · [Foundry correlation request IDs](https://platform.claude.com/docs/en/build-with-claude/claude-in-microsoft-foundry#correlation-request-ids)
[Python response model fields](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/_models.py#L193-L217) · [TypeScript metadata attachment](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/internal/parse.ts#L73-L93) · [TypeScript APIPromise](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/core/api-promise.ts#L73-L99)
