# Implementation Patterns

- Extend the shared core patterns in [implementation-patterns-core.md](../../../../../../.agents/shared/api-toolkit/references/implementation-patterns-core.md).
- Keep package-specific layering consistent with `packages/ollama_dart/lib/src/`.
- Use `describe` before adding new manifest entries or scaffolds.

## Native API Patterns

- Keep optional response fields nullable for older-server compatibility. Chat and generate share Go metrics; update both responses and both stream events even when OpenAPI omits streaming-chat metrics.
- Thinking is a boolean or model-defined string; null uses the model default. Preserve unknown string values, existing enum factories, and `ShowResponse.thinking` metadata instead of limiting future values to an enum.
- Replay an assistant message's content, thinking, and tool calls together; preserve tool IDs, function indices, and tool result names/IDs.
- Model metadata can contain arbitrary nested JSON. Use deep equality and hashing for maps/lists; keep tensor shape values as integer lists.
- Preserve legacy fields that old Ollama servers accepted, documenting current deprecations rather than removing public APIs during a refresh.

## Binary and Hosted Requests

- Blob uploads use `http.Request.bodyBytes` with `application/octet-stream`; never read/reassign `.body` while cloning binary requests in authentication, logging, or retry layers. Preserve headers and transport settings.
- Blob HEAD 404 means `false`; other failures propagate. Upload 200 (already present) and 201 (created) both succeed without decoding JSON.
- Hosted web resources use the configured base URL and existing auth/retry/error pipeline. Require explicit cloud configuration in examples; do not silently reroute credentials from a local host.
- Web fetch accepts scheme-less URL strings advertised in upstream examples. Omit an unset `max_results` to preserve the service default.

## System One

- Use typed string/object/array content, named question maps, sealed choice/noul/score variants, and typed answers. Objects and arrays are JSON content, not chat messages or image input.
- Preserve question/criterion insertion order: tied choices select the first candidate. Validate JSON field shapes, leaving blank text, question/candidate counts, request size, and context limits to the server. Do not invent probabilities or normalize scores.
- A `noul` is a probability of true; a score is a weighted average of zero-based criterion indices. Confidence is distribution concentration, not calibrated correctness.
- System One returns one JSON response and reuses the normal transport pipeline; it does not have a streaming variant.
