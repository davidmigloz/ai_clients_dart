# Implementation Patterns

- Extend the shared core patterns in [implementation-patterns-core.md](../../../../../../.agents/shared/api-toolkit/references/implementation-patterns-core.md).
- Keep package-specific layering consistent with `packages/googleai_dart/lib/src/`.
- Use `describe` before adding new manifest entries or scaffolds.

## Reference Implementations

- **Python SDK** (primary): `github.com/googleapis/python-genai` — used by the toolkit audit for resource and type coverage
- **JavaScript/TypeScript SDK** (secondary): `github.com/googleapis/js-genai` (`src/types.ts`) — useful for verifying schema design decisions, especially when the spec is ambiguous

When a spec schema has no properties (e.g. `ImageSearch`, `WebSearch`), check js-genai `src/types.ts` to confirm the type is intentionally an empty marker interface before implementing as an empty Dart class. For such empty-marker schemas, keep the manifest entry as `kind: "skip"` (or otherwise exclude it) rather than mapping it as an `object`, because the toolkit verifier fails on object schemas with no properties ("No spec fields found").

## Scaffolded File Fixes

When the toolkit scaffolds new files, they require two fixes before they are valid:

1. **Replace private sentinel**: Scaffolded files contain a local `_UnsetCopyWithSentinel` class and `_unsetCopyWithValue` constant. Replace the entire block:
   ```dart
   // REMOVE these lines:
   const Object _unsetCopyWithValue = _UnsetCopyWithSentinel();
   class _UnsetCopyWithSentinel { const _UnsetCopyWithSentinel(); }
   ```
   with an import of the shared sentinel using the correct relative path for the file's directory:
   ```dart
   // e.g. for lib/src/models/common/foo.dart:
   import '../copy_with_sentinel.dart';
   // e.g. for lib/src/models/interactions/content/foo.dart:
   import '../../copy_with_sentinel.dart';
   // then use `unsetCopyWithValue` (not `_unsetCopyWithValue`) throughout the file
   ```

2. **Add missing imports**: Scaffolded files reference types without imports. Add the appropriate relative imports for each referenced type.

## Avoiding Duplicates When Scaffolding

Before accepting a scaffolded type, check whether it already exists:

- **Referenced types**: If a scaffolded file references e.g. `GoogleAiGenerativelanguageV1betaSegment`, search the codebase — it may already exist as `Segment` in `metadata/segment.dart`. Use the existing type and add the correct import rather than creating a new one.
- **New types**: If the spec introduces a schema that already has a Dart implementation (e.g. same fields, different name), prefer the existing type and note the mapping in the manifest.

## File Class Conflict

The `files/file.dart` model class is named `File`, which conflicts with `dart:io`'s `File`. When importing from `files/file.dart` in non-platform-specific code that doesn't also import `dart:io`, use it directly. In platform-specific files (`_io.dart`, `_web.dart`, `_stub.dart`) that need both, import as `file_model`:
```dart
import '../../models/files/file.dart' as file_model;
```

## Enum Serialization Pattern

Most enums use standalone functions rather than methods on the enum:
```dart
ModelStage modelStageFromString(String? value) => switch (value) { ... };
String modelStageToString(ModelStage value) => switch (value) { ... };
```
When scaffolded files incorrectly call `ModelStage.fromJson(...)` or `.toJson()`, replace with `modelStageFromString(...)` and `modelStageToString(...)`.

Some enums define `fromJson()`/`toJson()` instance methods instead (e.g. `FunctionResponseScheduling`). Check the existing codebase pattern for the specific enum before choosing an approach.
