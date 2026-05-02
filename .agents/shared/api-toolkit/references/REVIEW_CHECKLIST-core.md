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
- [ ] **Collection equality**: For list/map fields, use content-based equality helpers — never bare `list.hashCode` or `map.hashCode` (identity-based). Use **shallow** helpers (`mapsEqual`/`mapHash`, `listsEqual`/`listHash`) when values are primitives or already-equatable objects. Use **deep** helpers (`mapsDeepEqual`/`mapDeepHashCode`, `listOfMapsDeepEqual`/`listOfMapsHashCode`) when values may contain nested maps/lists — e.g., `Map<String, dynamic>` storing arbitrary JSON, `rawJson` on unknown-variant fallbacks, or `List<Map>` where maps can be nested. Most packages provide these in `models/common/equality_helpers.dart`.
- [ ] **New field discipline**: When adding a field to a model, update all four: `==`, `hashCode`, `toString`, `copyWith`.
- [ ] **`copyWith` nullable-clear semantics**: Nullable `copyWith` params using `param ?? this.param` cannot clear a set value back to `null`. When the package provides an `unsetCopyWithValue` sentinel (typically in `models/common/copy_with_sentinel.dart`), use `Object? param = unsetCopyWithValue` so callers can distinguish "not provided" from "explicitly null". See [implementation-patterns-core.md](implementation-patterns-core.md#copywith-nullable-clear-semantics).
- [ ] **Non-nullable spec fields reject explicit null**: If the OpenAPI spec marks a field non-nullable, reject explicit `null` reliably — prefer a non-nullable Dart parameter type where possible, or an explicit runtime check that throws `ArgumentError`/`StateError` (a bare `assert` is stripped in release/AOT builds and won't enforce at runtime; keep it only as a debug-time supplement). Document the real "clear a key" mechanism (e.g., empty-string sentinel) in the dartdoc so callers don't pass `null` and get rejected server-side.
- [ ] **Bidirectional field coverage**: When adding a request field that instructs the API to return extra structured data (e.g., `documentAnnotationFormat` → response `documentAnnotation`), add the matching response field. Missing response fields silently drop API payload data.
- [ ] **Nested equality completeness**: When asserting `==` on a container type in round-trip tests, the nested element type's `==`/`hashCode` must include all user-visible fields — shallow comparison (e.g., `data.length`) silently passes tests even when serialization of nested fields regresses. Upgrade the nested `==`/`hashCode` rather than weakening the assertion.
- [ ] **Nullable field serialization**: Optional-nullable fields use `if (field != null) 'key': field` (scalars) or `if (field != null) 'key': field!.toJson()` (nested models) to omit nulls. Required-nullable fields always emit the key. Distinguish required vs optional from the OpenAPI spec — see [implementation-patterns-core.md](implementation-patterns-core.md#nullable-field-serialization) for the full decision table.
- [ ] **Model-variant nullability**: Fields only returned by a subset of API models must be nullable so all model variants parse without throwing. In streaming APIs, all non-discriminator fields on content/delta types must also be nullable since partial events may only include the `type` field.
- [ ] **Spec type fidelity**: Verify field types match the OpenAPI spec exactly — array fields use `List<T>`, string parameters use `String` even for numeric-looking values. Never model a spec `type: array` field as a single object; check the spec for `items` to determine the list element type.
- [ ] **Open object handling**: Schemas with `additionalProperties: true` must have an overflow field (e.g., `Map<String, dynamic>? extra`) that preserves and round-trips unknown keys via `fromJson`/`toJson`. The toolkit verifier flags missing overflow fields as errors (blocking).

### Sealed Classes
- [ ] **Doc comment subtypes**: Sealed class doc comments must enumerate all subtypes. Update the parent's doc comment when adding a variant.
- [ ] **Unknown fallback variant**: Sealed class `fromJson` must include an unknown/fallback variant preserving raw JSON — never throw on unrecognized discriminator values.
- [ ] **Const factory constructors**: Sealed union types should use `const factory` redirecting constructors, not static methods, so consumers can use `const` contexts. Be consistent across all sealed unions.
- [ ] **Enum forward compatibility**: Enum `fromString`/`fromJson` must return a forward-compatible fallback (e.g., `unknown`/`null`) for unrecognized values — never silently default to a meaningful enum member like `mp3` or `high`.
- [ ] **Enum `fromString` force-unwrap**: Never use `!` on the result of an enum `fromString()` documented to return `null` for unrecognized values. Throw `FormatException('Unknown <EnumName>: "$value"')` on null instead — a bare `Null check operator used on a null value` gives no context for diagnosing forward-compatibility failures.
- [ ] **Enum unknown doc accuracy**: If an enum `fromJson` maps unrecognized values to a static `unknown` constant (losing the raw string), the doc comment must not claim "preserves the raw value." Either update the doc to match the implementation, or store the raw string so the claim is true.

### API Design
- [ ] **Name conflicts**: Avoid class names that conflict with Flutter/`dart:ui` types (`Image`, `Text`, `Color`, `Container`). Prefer domain-prefixed names. When renaming, add `@Deprecated` typedef for the old name.
- [ ] **Convenience factory defaults**: Factories that set default values (e.g., `role: 'user'`) must document those defaults and not be used in contexts where the defaults are invalid (e.g., system instructions where roles are forbidden).
- [ ] **Factory parameter optionality**: Convenience factory required/optional parameters should match the spec's field requiredness — don't make optional spec fields required in factories.
- [ ] **Resource parameter types**: Verify resource parameters use types from the correct API surface (e.g., Responses API resources should use Responses API types, not Chat Completions types).
- [ ] **Const preservation**: When modifying constructors or factories, verify `const` is preserved if the target constructor supports it. String interpolation with constructor parameters is valid in `const` initializer lists.
- [ ] **Barrel file exports**: All public types referenced by exported API fields (sealed hierarchies, enums, error types, retry-status hierarchies) must themselves be exported via the package's barrel file. Hidden types make fields unusable downstream — verify by consuming the package externally, not just by `dart analyze` within the package.
- [ ] **Wired parameters**: Every parameter a resource method accepts (`abortTrigger`, `streamClientFactory`, etc.) must flow through to the HTTP layer. Accepted-but-unused parameters are undetectable bugs. For streaming resources, follow the established pattern: forward `super.streamClientFactory`, route through `StreamingResource.sendStream` so `abortTrigger` and SSE headers are handled uniformly.
- [ ] **Factory tear-off compatibility**: Adding a named parameter to a `factory` constructor changes its function type and breaks consumers using it as a tear-off. For public sealed-variant factories, prefer a differently-named factory (or an optional-positional parameter) unless the change is intentionally breaking.
- [ ] **Deprecated vs new-field precedence**: When a spec deprecates flat fields in favor of a new config object but the Dart model still serializes both, document which wins server-side (typically the new field) in the class-level dartdoc so callers can reason about mixed configurations.

### fromJson / toJson
- [ ] **Discriminator validation**: Sealed subtype `fromJson` must validate the discriminator field matches the expected value.
- [ ] **Constructor validation parity**: Validation constraints in constructors (asserts, mutual exclusivity) must also be enforced in `fromJson`.
- [ ] **Required fields fail fast**: When the spec marks a field as required, `fromJson` must throw `FormatException` on missing/null — never silently default to empty collections or synthetic values. Deferred failures mask malformed responses and resurface as confusing errors downstream (e.g., `first` on an empty list).
- [ ] **Unknown variant toJson fidelity**: Unknown/fallback sealed variants storing `rawJson` must spread `rawJson` first, then overwrite with typed fields, so `toJson()` preserves both unknown keys and `copyWith`-updated fields. Ignoring `rawJson` drops unknown keys; letting `rawJson` overwrite typed fields silently loses `copyWith` changes.
- [ ] **JSON encoding**: Always use `jsonEncode()` for serialization — never `.toString()` on maps/objects.
- [ ] **Parameter placement**: Query parameters per spec → URL query string; body parameters per spec → request body. Don't mix them.
- [ ] **Endpoint URL path**: Resource methods that construct URLs manually (especially upload endpoints bypassing `requestBuilder.buildUrl`) must match the OpenAPI spec path exactly — including action suffixes (e.g., `:uploadToFileSearchStore`, not `:upload`). The toolkit `verify --checks implementation` flags missing action suffixes.

### Documentation
- [ ] **Method/path name accuracy**: After renaming methods, files, or config paths, search all docs, error messages, and examples for references to the old names/paths and update them.
- [ ] **Capability claims**: Doc comments must not claim capabilities that aren't implemented or hardcode server-side defaults.
- [ ] **Doc nullability accuracy**: Doc comments on nullable fields (`String?`, `int?`, etc.) must accurately reflect the type — say "May be `null` when ..." rather than promising a synthetic value like "empty string when the value is missing." Doc/type mismatches mislead callers into wrong defensive-coding patterns. If you want a non-nullable contract, change the type and normalize in `fromJson`; otherwise update the doc to acknowledge `null`.
- [ ] **Field list freshness**: Update doc comments enumerating fields (factory methods, copy methods, sealed summaries) after adding/renaming fields.
- [ ] **Stale defaults/thresholds**: After changing default values, thresholds, or behavior, search for all doc comments and README references to the old values and update them (e.g., "25% jitter" → "10% jitter").
- [ ] **README version placeholders**: Installation snippets must use the actual package version from `pubspec.yaml` — never `^x.y.z` or other non-functional placeholders.
- [ ] **Example compile validity**: Verify README/doc code examples compile AND are semantically correct — method names, property names, and parameter names must match the actual Dart API (e.g., `embeddings.create()` not `embeddings.generate()`, `input` not `inputs`). Watch for `const` expressions on classes whose constructors are not const — including factory constructors and generative constructors whose initializer list calls non-const operations like `Map.unmodifiable()` or `List.unmodifiable()`. The full example file may already omit `const` correctly while the README snippet drifts.
- [ ] **Migration guide accuracy**: Migration guide snippets must be self-consistent (matching version numbers, correct method names, valid imports) and compile correctly as shown.
- [ ] **Dartdoc symbol link scope**: Dartdoc `[Symbol]` links only resolve when the symbol is importable in the current library. For cross-layer references (models → resources, where importing would create an unwanted dependency), use backticks or plain text instead of square-bracket links.
- [ ] **Base64 decoding in examples**: Doc-comment and README examples referencing base64 string fields (`b64Json`, `data`) must decode with `base64Decode()` before treating the value as bytes. A variable named `bytes` assigned directly from a base64 string is almost always wrong and won't work if users copy the snippet.

### Testing
- [ ] **Sealed/enum coverage**: New sealed classes need tests for all variants, `fromJson`/`toJson` round-trip, error cases, equality/hashCode.
- [ ] **Fixture freshness**: When changing a JSON key, update all test fixtures and add assertions for the renamed field.
- [ ] **Async assertions**: Use `await expectLater(asyncFn(), throwsA(...))` for async throws — not `expect`.
- [ ] **Field assertions**: When adding a field to a model, add unit tests covering all four model contracts: (1) `fromJson`/`toJson` round-trip including the new field, (2) optional-omit behavior when the field is absent from JSON, (3) `copyWith` exposes and updates it (with null-clear coverage for nullable fields), (4) `toString` includes the field. Round-tripping JSON alone leaves typos in `copyWith`/`toString` undetected.
- [ ] **Test placement**: Tests with local `HttpServer`/`MockClient` belong in `test/unit/`, not `test/integration/`.
- [ ] **httpClient lifecycle spy**: Tests verifying "does not close custom httpClient" must inject a spy/fake that tracks `close()` calls and asserts it was not invoked.
- [ ] **Empty env var guards**: Integration test API key guards must treat empty env vars as missing — use `env['KEY']?.isNotEmpty == true`, not `containsKey('KEY')`.
- [ ] **Resource method coverage**: Every new resource method (CRUD operation, streaming endpoint) must have a unit test verifying the request path, HTTP method, required headers, and response parsing. When the resource gates on a beta/feature header (e.g., `anthropic-beta`), every endpoint test in the resource must assert that header — not just the first one — since a missing header silently degrades to a different API surface.
- [ ] **No orphaned computations**: Every computed value in a test (exit codes, parsed fields, error results) must be asserted. Unasserted values silently hide regressions.
- [ ] **No top-level test initializers**: Test resources (sample directories, fixture files, shared configs) must be resolved inside `main()`/`setUpAll()`, not as top-level initializers — top-level resolution runs at import/test-discovery time and can break unrelated test files when the directory is unexpected.
- [ ] **Multipart field value scoping**: Multipart-body assertions must scope values to their field name — bare `contains('\r\nhigh\r\n')` can accidentally match an unrelated field's value. Use a helper that matches `name="{field}"\r\n\r\n{value}\r\n` end-to-end.
- [ ] **Multipart header case**: `http.MultipartRequest.finalize()` stores the boundary header under the lowercase key `content-type`. Tests asserting the multipart Content-Type must use the lowercase key (or a case-insensitive lookup) — `headers['Content-Type']` will silently return `null`.
- [ ] **Fixture completeness**: Response-JSON test fixtures must include every field the spec marks as required. Incomplete fixtures diverge from real payloads and mask parser regressions for the missing required fields.

### Streaming / SSE
- [ ] **Streaming examples**: Ensure streaming examples process events before closing — no `listen()` + immediate `close()`.
- [ ] **SSE parser boundaries**: Blank lines must unconditionally reset ALL event state (type, data buffer, metadata). Multi-`data:` lines for the same event must be joined with `\n` per the SSE spec. `data: [DONE]` must flush any buffered event and terminate.
- [ ] **SSE error events**: Synthetic error maps must include a `type` field for consumer dispatch. `withoutEventType()` must preserve `_rawData` for error event consumers.
- [ ] **Error consistency**: Streaming and non-streaming paths must map the same HTTP status codes to the same exception types.
- [ ] **Closed-client guard**: Streaming resource methods must call `ensureNotClosed()` before opening a subscription, matching the guard pattern used by sibling methods in the same resource class. Missing guards let callers start streams after `close()`.
- [ ] **Eager `ensureNotClosed` for `async*`**: `async*` method bodies are lazy — nothing runs until the stream is listened to, so an `ensureNotClosed()` call inside an `async*` body fails late. Wrap it: the public method is a non-`async*` wrapper that calls the guard synchronously, then returns a private `async*` helper stream. See [implementation-patterns-core.md](implementation-patterns-core.md#eager-ensurenotclosed-wrapping-for-async).
- [ ] **Non-streaming methods reject `stream=true`**: When a request body supports a `stream` flag, the non-streaming resource methods (`generate()`, `edit()`, `create()`) must throw `ArgumentError` on `request.stream == true`, pointing at the streaming variant. Otherwise SSE responses silently fail opaque JSON parsing.

### Cross-Cutting
- [ ] **Cross-package patterns**: When fixing a bug, `grep -r '<pattern>' packages/` for the same issue in sibling packages that share API types.
- [ ] **Integration tests for binary data**: Run integration tests for any new factory that handles base64/binary data before merging — spec descriptions can be misleading about expected formats.

### Cleanup
- [ ] **Dead code**: Run `dart analyze --fatal-infos` after refactoring to catch unused imports, variables, and classes.
- [ ] **Shared helpers**: After implementing the same logic in multiple resource classes (error mapping, header building, stream parsing), extract to a shared helper/mixin to prevent divergence.
- [ ] **Hardcoded versions**: User-Agent headers and pubspec descriptions must not hardcode specific model/API versions that will become stale — use a centralized version constant or generic descriptions.
- [ ] **Manifest coverage for new Dart models**: When introducing a new Dart model class for a spec schema, add a matching `manifest.json` entry (`kind: object` / `sealed_parent` / `sealed_variant` as appropriate). Missing entries let future regeneration emit duplicate/conflicting types and hide coverage regressions from the verifier.

### Security
- [ ] **Credential redaction**: Redact credential-bearing query parameters (`key`, `access_token`, `api_key`) before logging URLs. Also redact authentication tokens in `toString()` output — never expose full credentials via logging or exceptions.
- [ ] **Opaque payload redaction**: Redact opaque/encrypted payload fields (e.g., `encryptedContent` on Anthropic compaction blocks, server-provided signatures) in `toString()` as `[N chars]`, matching the existing `RedactedThinkingBlock` / `AdvisorRedactedResult` pattern. These fields can leak via logs or exceptions and are often large enough to bloat output. See [implementation-patterns-core.md](implementation-patterns-core.md#opaque-payload-redaction).
