# Native MCP output review

PR #443; reviewed November 4, 2026. This contributor correction is output-only.
It does not expand typed request Item or conversation-resource MCP support.

## Sources and contract decisions

- [Frozen OpenAPI](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json).
- [Python 3.42.0 output declarations](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/types/responses/response_output_item.py).
- [Node 7.47.0 Responses declarations](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/responses/responses.ts).
- [PR-referenced Node declarations](https://github.com/openai/openai-node/blob/9854bd60f7e2a5840baa61d86d9a288d2127ae8f/src/resources/responses/responses.ts).

Known fields agree with the official SDKs: native MCP calls have no call_id;
arguments, name and server_label are required. Five native call statuses and
three structured error variants are represented. Discovery and approval output
variants retain producing-agent metadata on the beta surface.

The pinned OpenAPI tool descriptor describes object-shaped input_schema and
annotations, while Python uses object and Node uses unknown. Receive models
follow that broader SDK tolerance with immutable finite JSON snapshots. The
approval response resource's required list contains an undeclared request_id;
both SDKs omit it. The output mapping follows their actual declared fields and
does not fabricate a request_id property. Writable approval input is a different
schema and is not claimed by this change.

## Review findings and fixes

Two deterministic probes reproduced forward-compatibility failures in original
head af9d7a3: a future status and a future error discriminator each rejected the
entire Response. Status parsing now uses the existing enum fallback convention;
it does not claim to retain the original unknown string. UnknownMcpCallError
retains an immutable raw JSON snapshot and redacts diagnostics. Known malformed
errors still fail, and the unknown constructor rejects known discriminators.
Copies snapshot replacements and typed discriminator overrides win raw metadata.

The review checked full-field equality/hash, nullable clearing, parsed collection
ownership, subtype behavior, public exports and redacted diagnostics. Existing
const constructors explicitly retain caller-owned collections; this convention is
not a claim that constructor arguments become immutable. Repository migration
guidance now documents the removed callId and changed native field/error/status
contracts. No changelog or release version is edited.

## Validation and handoff

The contribution's original MCP/Responses selection passes 347 tests and package
analysis. Independent mock-only probes verify all four output variants through
SSE, WebSocket envelopes and the merged #442 final-output collector, including
out-of-order finalized items, structured errors and omitted terminal output.
The two fallback fixes have focused malformed/unknown/immutability/copy/redaction
regressions: all **27 MCP tests pass**, including 18 new fallback cases through
HTTP/SSE/WebSocket paths. The full unit suite passes **25,332 tests with 2 skips**.
Full-package analysis with fatal infos, formatting and quick-fix checks pass; the
migration example compiles. Both previously failing compatibility probes now
accept the future values. CI for the updated head is recorded in PR #443. No live
API execution or provider acceptance is claimed.

Toolkit describe was consulted for the existing contextual MCP mappings before
adding the [21 scoped bindings](pr443-mcp-output-manifest.json). Direct pinned
schema inspection establishes the resource output schema absent from the older
manifest. Existing Live bindings remain separate. These handoff mappings cover
the native output models and the local unknown extension; they do not modify
canonical spec, global manifest or source metadata. Their final promotion and
cross-ticket reconciliation remain assigned to #427. No global passing toolkit
gate is claimed by this focused contributor fix.
