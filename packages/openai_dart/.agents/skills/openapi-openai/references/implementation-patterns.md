# Implementation Patterns

- Extend the shared core patterns in [implementation-patterns-core.md](../../../../../../.agents/shared/api-toolkit/references/implementation-patterns-core.md).
- Keep package-specific layering consistent with `packages/openai_dart/lib/src/`.
- Use `describe` before adding new manifest entries or scaffolds.

## OpenAI-Specific Patterns

### Base64 Fields Require Data URL Format

OpenAI API fields that accept inline binary data (e.g., `file_data`,
`image_url` with base64) require **data URL format**, not raw base64 strings.
The spec descriptions are misleading — they say "base64 encoded data" but the
API rejects raw base64 and expects `data:<mediaType>;base64,<data>`.

When adding convenience factories for binary data fields, follow the existing
`ContentPart.imageBase64()` pattern:

```dart
// WRONG — raw base64, API returns 400
static ContentPart fileData({required String data, ...}) =>
    FileContentPart(fileData: data, ...);

// CORRECT — data URL with MIME type
static ContentPart fileData({
  required String data,
  required String mediaType,
  ...
}) => FileContentPart(fileData: 'data:$mediaType;base64,$data', ...);
```

Always run an integration test when adding new binary data factories to catch
spec-vs-reality mismatches.

### Multi-Model Response Shapes

The OpenAI API has multiple model families that return different response shapes
(e.g., `text-moderation-*` vs `omni-moderation-*`). Fields only returned by
newer models **must** be nullable so responses from older models parse without
throwing.

Check the OpenAPI spec examples and the Python SDK for which fields are truly
required across all model variants vs only present in specific ones.

### Web WebSocket Authentication

Browser WebSockets cannot set request headers — there is no API to send
`Authorization` (or `OpenAI-Project`, etc.) on the handshake. Any guidance that
tells a web caller to "use the ephemeral secret as a bearer token and connect
directly" is wrong: the header is silently dropped and the connection fails with
an opaque close/401.

Two consequences for the Realtime resource:

1. **The web connector must reject all headers, not just `Authorization`.** Throw
   on *any* non-empty `headers` map, comparing case-insensitively, and surface the
   received keys plus the supported alternatives:

   ```dart
   // WRONG — only catches the exact key; lowercase `authorization`,
   //         `OpenAI-Project`, etc. silently fail
   if (headers.containsKey('Authorization')) {
     throw const ConnectionException('Browser WebSockets cannot set Authorization.');
   }

   // CORRECT — any header is unsupported on web
   if (headers.isNotEmpty) {
     throw ConnectionException(
       'Browser WebSockets cannot set headers (got: ${headers.keys.join(', ')}). '
       'Use WebRTC (realtimeSessions.calls.create(...)) or a server-side '
       'WebSocket proxy that can set the Authorization header.',
     );
   }
   ```

2. **Docs/examples must point at the real web flows.** Replace any "connect
   directly from the browser with a bearer token" framing with WebRTC
   (`realtimeSessions.calls.create(...)`) or a backend/proxy that opens the
   authenticated socket. The ephemeral client secret is still useful on web — for
   the WebRTC SDP exchange and for server-side scope-narrowing — just not as a
   WebSocket bearer token. Keep `connect()`'s Platform Notes and the
   `ConnectionException` message consistent with this.
