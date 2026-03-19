# Core Review Checklist

## Toolkit Verification

Run these after implementation, before creating a PR:

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir <config-dir>
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir <config-dir>
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir <config-dir> --checks all --scope all
```

After toolkit verification, run the package-level Dart quality steps documented in the package skill.

## Implementation Review

Use this checklist during code review and before finalizing changes. For detailed code examples and rationale behind each item, see [implementation-patterns-core.md](implementation-patterns-core.md).

### Model Classes
- [ ] **`==`/`hashCode` contract**: Every `@immutable` class that overrides `==` must compare the same fields used in `hashCode`. Never do runtimeType-only `==` with field-based `hashCode`.
- [ ] **Collection equality**: For list/map fields, use content-based equality helpers (`listsEqual`/`listHash`, `mapsEqual`/`mapHash`) — never bare `list.hashCode` or `map.hashCode` (identity-based). Most packages provide these in `models/common/equality_helpers.dart`; if the package doesn't have them yet, check whether an existing package's helpers can be copied in.
- [ ] **New field discipline**: When adding a field to a model, update all four: `==`, `hashCode`, `toString`, `copyWith`.
- [ ] **Nullable field serialization**: Optional-nullable fields use `if (field != null) 'key': field` (scalars) or `if (field != null) 'key': field!.toJson()` (nested models) to omit nulls. Required-nullable fields always emit the key. Distinguish required vs optional from the OpenAPI spec — see [implementation-patterns-core.md](implementation-patterns-core.md#nullable-field-serialization) for the full decision table.
- [ ] **Model-variant nullability**: Fields only returned by a subset of API models must be nullable so all model variants parse without throwing. In streaming APIs, all non-discriminator fields on content/delta types must also be nullable since partial events may only include the `type` field.
- [ ] **Spec type fidelity**: Verify field types match the OpenAPI spec exactly — array fields use `List<T>`, string parameters use `String` even for numeric-looking values.

### Sealed Classes
- [ ] **Doc comment subtypes**: Sealed class doc comments must enumerate all subtypes. Update the parent's doc comment when adding a variant.
- [ ] **Unknown fallback variant**: Sealed class `fromJson` must include an unknown/fallback variant preserving raw JSON — never throw on unrecognized discriminator values.
- [ ] **Const factory constructors**: Sealed union types should use `const factory` redirecting constructors, not static methods, so consumers can use `const` contexts. Be consistent across all sealed unions.

### API Design
- [ ] **Name conflicts**: Avoid class names that conflict with Flutter/`dart:ui` types (`Image`, `Text`, `Color`, `Container`). Prefer domain-prefixed names. When renaming, add `@Deprecated` typedef for the old name.
- [ ] **Convenience factory defaults**: Factories that set default values (e.g., `role: 'user'`) must document those defaults and not be used in contexts where the defaults are invalid (e.g., system instructions where roles are forbidden).

### fromJson / toJson
- [ ] **Discriminator validation**: Sealed subtype `fromJson` must validate the discriminator field matches the expected value.
- [ ] **Constructor validation parity**: Validation constraints in constructors (asserts, mutual exclusivity) must also be enforced in `fromJson`.
- [ ] **JSON encoding**: Always use `jsonEncode()` for serialization — never `.toString()` on maps/objects.
- [ ] **Parameter placement**: Query parameters per spec → URL query string; body parameters per spec → request body. Don't mix them.

### Documentation
- [ ] **Method name accuracy**: Verify README/doc comment method names match actual implementation after renames.
- [ ] **Capability claims**: Doc comments must not claim capabilities that aren't implemented or hardcode server-side defaults.
- [ ] **Field list freshness**: Update doc comments enumerating fields (factory methods, copy methods, sealed summaries) after adding/renaming fields.

### Testing
- [ ] **Sealed/enum coverage**: New sealed classes need tests for all variants, `fromJson`/`toJson` round-trip, error cases, equality/hashCode.
- [ ] **Fixture freshness**: When changing a JSON key, update all test fixtures and add assertions for the renamed field.
- [ ] **Async assertions**: Use `await expectLater(asyncFn(), throwsA(...))` for async throws — not `expect`.
- [ ] **Field assertions**: When adding a field to test fixtures, add corresponding parse/serialize assertions.
- [ ] **Test placement**: Tests with local `HttpServer`/`MockClient` belong in `test/unit/`, not `test/integration/`.

### Streaming / SSE
- [ ] **Streaming examples**: Ensure streaming examples process events before closing — no `listen()` + immediate `close()`.
- [ ] **SSE parser boundaries**: Blank lines must unconditionally reset ALL event state (type, data buffer, metadata). Multi-`data:` lines for the same event must be joined with `\n` per the SSE spec.
- [ ] **Error consistency**: Streaming and non-streaming paths must map the same HTTP status codes to the same exception types.

### Cleanup
- [ ] **Dead code**: Run `dart analyze --fatal-infos` after refactoring to catch unused imports, variables, and classes.
