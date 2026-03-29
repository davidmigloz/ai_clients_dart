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
- [ ] **`==`/`hashCode` contract**: Every `@immutable` class that overrides `==` must compare the same fields used in `hashCode`. Never do runtimeType-only `==` with field-based `hashCode`. Never pair content-based `==` helpers (`listsEqual`/`mapsEqual`) with identity-based `hashCode` (`list.hashCode`/`map.hashCode`) — both sides must use content-based helpers.
- [ ] **Collection equality**: For list/map fields, use content-based equality helpers (`listsEqual`/`listHash`, `mapsEqual`/`mapHash`) — never bare `list.hashCode` or `map.hashCode` (identity-based). Most packages provide these in `models/common/equality_helpers.dart`; if the package doesn't have them yet, check whether an existing package's helpers can be copied in.
- [ ] **New field discipline**: When adding a field to a model, update all four: `==`, `hashCode`, `toString`, `copyWith`.
- [ ] **Nullable field serialization**: Optional-nullable fields use `if (field != null) 'key': field` (scalars) or `if (field != null) 'key': field!.toJson()` (nested models) to omit nulls. Required-nullable fields always emit the key. Distinguish required vs optional from the OpenAPI spec — see [implementation-patterns-core.md](implementation-patterns-core.md#nullable-field-serialization) for the full decision table.
- [ ] **Model-variant nullability**: Fields only returned by a subset of API models must be nullable so all model variants parse without throwing. In streaming APIs, all non-discriminator fields on content/delta types must also be nullable since partial events may only include the `type` field.
- [ ] **Spec type fidelity**: Verify field types match the OpenAPI spec exactly — array fields use `List<T>`, string parameters use `String` even for numeric-looking values. Never model a spec `type: array` field as a single object; check the spec for `items` to determine the list element type.

### Sealed Classes
- [ ] **Doc comment subtypes**: Sealed class doc comments must enumerate all subtypes. Update the parent's doc comment when adding a variant.
- [ ] **Unknown fallback variant**: Sealed class `fromJson` must include an unknown/fallback variant preserving raw JSON — never throw on unrecognized discriminator values.
- [ ] **Const factory constructors**: Sealed union types should use `const factory` redirecting constructors, not static methods, so consumers can use `const` contexts. Be consistent across all sealed unions.
- [ ] **Enum forward compatibility**: Enum `fromString`/`fromJson` must return a forward-compatible fallback (e.g., `unknown`/`null`) for unrecognized values — never silently default to a meaningful enum member like `mp3` or `high`.

### API Design
- [ ] **Name conflicts**: Avoid class names that conflict with Flutter/`dart:ui` types (`Image`, `Text`, `Color`, `Container`). Prefer domain-prefixed names. When renaming, add `@Deprecated` typedef for the old name.
- [ ] **Convenience factory defaults**: Factories that set default values (e.g., `role: 'user'`) must document those defaults and not be used in contexts where the defaults are invalid (e.g., system instructions where roles are forbidden).
- [ ] **Factory parameter optionality**: Convenience factory required/optional parameters should match the spec's field requiredness — don't make optional spec fields required in factories.
- [ ] **Resource parameter types**: Verify resource parameters use types from the correct API surface (e.g., Responses API resources should use Responses API types, not Chat Completions types).
- [ ] **Const preservation**: When modifying constructors or factories, verify `const` is preserved if the target constructor supports it. String interpolation with constructor parameters is valid in `const` initializer lists.

### fromJson / toJson
- [ ] **Discriminator validation**: Sealed subtype `fromJson` must validate the discriminator field matches the expected value.
- [ ] **Constructor validation parity**: Validation constraints in constructors (asserts, mutual exclusivity) must also be enforced in `fromJson`.
- [ ] **JSON encoding**: Always use `jsonEncode()` for serialization — never `.toString()` on maps/objects.
- [ ] **Parameter placement**: Query parameters per spec → URL query string; body parameters per spec → request body. Don't mix them.

### Documentation
- [ ] **Method/path name accuracy**: After renaming methods, files, or config paths, search all docs, error messages, and examples for references to the old names/paths and update them.
- [ ] **Capability claims**: Doc comments must not claim capabilities that aren't implemented or hardcode server-side defaults.
- [ ] **Field list freshness**: Update doc comments enumerating fields (factory methods, copy methods, sealed summaries) after adding/renaming fields.
- [ ] **Stale defaults/thresholds**: After changing default values, thresholds, or behavior, search for all doc comments and README references to the old values and update them (e.g., "25% jitter" → "10% jitter").
- [ ] **README version placeholders**: Installation snippets must use the actual package version from `pubspec.yaml` — never `^x.y.z` or other non-functional placeholders.
- [ ] **Example compile validity**: Verify README/doc code examples compile after API changes — watch for `const` expressions using non-const factory constructors.
- [ ] **Migration guide accuracy**: Migration guide snippets must be self-consistent (matching version numbers, correct method names, valid imports) and compile correctly as shown.

### Testing
- [ ] **Sealed/enum coverage**: New sealed classes need tests for all variants, `fromJson`/`toJson` round-trip, error cases, equality/hashCode.
- [ ] **Fixture freshness**: When changing a JSON key, update all test fixtures and add assertions for the renamed field.
- [ ] **Async assertions**: Use `await expectLater(asyncFn(), throwsA(...))` for async throws — not `expect`.
- [ ] **Field assertions**: When adding a field to test fixtures, add corresponding parse/serialize assertions.
- [ ] **Test placement**: Tests with local `HttpServer`/`MockClient` belong in `test/unit/`, not `test/integration/`.
- [ ] **httpClient lifecycle spy**: Tests verifying "does not close custom httpClient" must inject a spy/fake that tracks `close()` calls and asserts it was not invoked.
- [ ] **Empty env var guards**: Integration test API key guards must treat empty env vars as missing — use `env['KEY']?.isNotEmpty == true`, not `containsKey('KEY')`.

### Streaming / SSE
- [ ] **Streaming examples**: Ensure streaming examples process events before closing — no `listen()` + immediate `close()`.
- [ ] **SSE parser boundaries**: Blank lines must unconditionally reset ALL event state (type, data buffer, metadata). Multi-`data:` lines for the same event must be joined with `\n` per the SSE spec. `data: [DONE]` must flush any buffered event and terminate.
- [ ] **SSE error events**: Synthetic error maps must include a `type` field for consumer dispatch. `withoutEventType()` must preserve `_rawData` for error event consumers.
- [ ] **Error consistency**: Streaming and non-streaming paths must map the same HTTP status codes to the same exception types.

### Cross-Cutting
- [ ] **Cross-package patterns**: When fixing a bug, `grep -r '<pattern>' packages/` for the same issue in sibling packages that share API types.
- [ ] **Integration tests for binary data**: Run integration tests for any new factory that handles base64/binary data before merging — spec descriptions can be misleading about expected formats.

### Cleanup
- [ ] **Dead code**: Run `dart analyze --fatal-infos` after refactoring to catch unused imports, variables, and classes.
- [ ] **Shared helpers**: After implementing the same logic in multiple resource classes (error mapping, header building, stream parsing), extract to a shared helper/mixin to prevent divergence.
- [ ] **Hardcoded versions**: User-Agent headers and pubspec descriptions must not hardcode specific model/API versions that will become stale — use a centralized version constant or generic descriptions.

### Security
- [ ] **Credential redaction**: Redact credential-bearing query parameters (`key`, `access_token`, `api_key`) before logging URLs. Also redact authentication tokens in `toString()` output — never expose full credentials via logging or exceptions.
