# Implementation Patterns

- Extend the shared core patterns in [implementation-patterns-core.md](../../../../../../.agents/shared/api-toolkit/references/implementation-patterns-core.md).
- Keep package-specific layering consistent with `packages/anthropic_sdk_dart/lib/src/`.
- Use `describe` before adding new manifest entries or scaffolds.

## Package-Specific Patterns

### New built-in tools — three touch points

Adding a built-in tool requires changes in three files, not just the tool class:

1. **Tool class** — `lib/src/models/beta/tools/<tool>.dart` (or `lib/src/models/tools/built_in_tools.dart` for GA tools). Add as `part of` the `built_in_tools.dart` library.
2. **`BuiltInTool` sealed class** — in `lib/src/models/tools/built_in_tools.dart`:
   - Add a convenience factory (e.g., `BuiltInTool.advisor(...)`)
   - Add the `fromJson` dispatch case
3. **`ToolDefinition._isBuiltInType`** — in `lib/src/models/tools/tool_definition.dart`: add the type prefix (e.g., `type.startsWith('advisor_')`). Without this, `ToolDefinition.fromJson` routes the tool to `Tool.fromJson` which crashes on missing `input_schema`.

### Response content blocks need input block pairs

When the API returns a new content block type in assistant responses (e.g., `advisor_tool_result`), you almost always need a corresponding input block in `lib/src/models/content/input_content_block.dart` for multi-turn round-tripping. Check the spec for a matching `BetaRequest*Block` schema.

Checklist:
- Add the `InputContentBlock.fromJson` dispatch case
- Add a convenience factory on `InputContentBlock`
- Add the `*InputBlock` class (mirror the response block but add `cacheControl`)
- Check `additionalProperties` in the request schema — if `false`, only include fields defined in the spec (e.g., response blocks may have `caller` but the request counterpart may not)

### Round-trip fidelity for forward-compatible enums

When an enum has an `unknown` fallback for unrecognized values, `toJson()` must serialize the **original wire string**, not the enum member name. Otherwise unknown values round-trip as the literal `"unknown"`, corrupting multi-turn conversations.

Pattern: store the raw string as the primary field, derive the typed enum via a getter:

```dart
class MyError {
  final String rawErrorCode;  // stored, serialized
  MyErrorCode get errorCode => MyErrorCode.fromJson(rawErrorCode);  // derived

  const MyError({required this.rawErrorCode});
}
```

### Request vs response schema differences

The spec often has separate `BetaRequest*` and `BetaResponse*` schemas for the same logical type. They can differ:
- `additionalProperties: false` on request but not on response
- Fields present in response but absent in request (e.g., `caller`)
- Different required fields

Always check both schemas when implementing a content block pair.
