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
