# Core Implementation Patterns

**Contents:** [Manifest Kinds](#manifest-kind-values) · [Type Safety](#type-safety-patterns) · [toString](#tostring-convention) · [Equality & Hashing](#equality-and-hashing) · [fromJson Patterns](#fromjson-defensive-patterns) · [Nullable Serialization](#nullable-field-serialization) · [HTTP Client](#http-client-patterns) · [DateTime](#datetime-handling) · [Security](#security) · [JSON](#json-serialization) · [SSE Parsing](#sse-parser-correctness) · [API Design](#api-design)

- Keep specs checked in under package `specs/` and compare them against fetched scratch specs.
- Keep Dart serialization handwritten and deterministic.
- Prefer low-freedom workflows: fetch, review, scaffold, verify.
- Use `manifest.json` for type mapping, placement, and verification intent.

## Manifest `kind` Values

| Kind | Use for |
|------|---------|
| `object` | Standalone classes (no sealed parent) |
| `sealed_parent` | Base sealed class with discriminator |
| `sealed_variant` | Concrete subclass of a sealed parent (has `parent` field). Auto-excludes discriminator fields from all ancestor sealed parents during verification. **Always use this for sealed children — never `object`.** |
| `extension` | Dart-only subclass with no spec schema (schema is `null`) |
| `enum` | Enum types |
| `skip` | Entries excluded from verification (with `note` explaining why) |

### Skip Entry Tags

Skip entries support optional `tags` to control verification behavior:

| Tag | Effect |
|-----|--------|
| `acknowledged` | Entry is a known intentional deviation — does not trigger the partial-coverage warning |

Use `acknowledged` for structural mismatches, verifier limitations, or
intentional design choices that cannot be resolved without architectural changes.
Untagged skip entries are treated as unresolved and trigger warnings.

## Type Safety Patterns

### `oneOf` / `anyOf` Spec Fields → Sealed Dart Types

When a spec property uses `oneOf` or `anyOf` with multiple `$ref` items or
mixed types, the Dart field should use a sealed union type, not `Object?` or
`dynamic`. The toolkit `verify --checks implementation` warns when it detects
`Object` or `dynamic` for fields that reference specific schema types or unions.

### Sibling Sealed Variants Must Have Consistent Field Patterns

All variants of a sealed parent should use consistent nullability and types
for fields with the same name. The toolkit `verify --checks consistency`
warns on mismatches. For example, if most `*Delta` variants declare `id`
as `String?`, a single variant with non-nullable `id` is flagged.

### Discriminator Key Choice

When implementing `fromJson` dispatch for sealed types, prefer always-required
fields like `type` as the discriminator. Avoid optional fields like `role`
that may not be present in all variants.

### Resource Method Parameters (Future)

Resource method signatures vary across packages (typed request objects,
decomposed named params, positional args). A future toolkit enhancement
will validate resource parameters against Params/Request models once a
deterministic mapping source is established in the manifest.

## `toString` Convention

Every `@immutable` model class should include **all fields** in its `toString`
output so that the toolkit verifier can confirm completeness. To keep output
readable, truncate or summarize noisy values:

- **Lists**: show count — `tools: ${tools.length} items`
- **Maps**: show count — `metadata: ${metadata.length} entries`
- **Long strings**: first N chars — `instructions: ${instructions?.substring(0, 50)}...`
- **Nested objects**: use their own toString or show a summary field

## Equality and Hashing

### Collection Fields

Dart's `List.hashCode` and `Map.hashCode` are identity-based — two lists with
identical content produce different hash codes. Always use content-based
equality helpers (most packages keep these in `models/common/equality_helpers.dart`):

| Field type | `==` helper | `hashCode` helper |
|-----------|-------------|-------------------|
| `List<T>` | `listsEqual(a, b)` | `listHash(list)` |
| `Map<K,V>` | `mapsEqual(a, b)` | `mapHash(map)` |
| `List<Map>` | `listOfMapsEqual(a, b)` | `listOfMapsHash(list)` |

`mapHash()` uses `Object.hashAllUnordered` internally to ensure insertion-order
independence. `mapsEqual()` checks `containsKey` before comparing values to
distinguish missing keys from `null` values.

### New Field Checklist

When adding a field to a model class, update **all four**:
1. `operator ==` — compare the field
2. `hashCode` — include the field
3. `toString` — print the field
4. `copyWith` — expose the field

## fromJson Defensive Patterns

### Discriminator Validation

Sealed subtype `fromJson` must verify the discriminator value:

```dart
factory ChatVariant.fromJson(Map<String, dynamic> json) {
  final type = json['type'] as String?;
  if (type != 'chat') {
    throw FormatException('Expected type "chat", got "$type"');
  }
  // ... parse fields
}
```

### Unknown Fallback Variant

Sealed `fromJson` dispatch should never throw on unknown discriminator values.
Provide a fallback that preserves the raw JSON for forward compatibility:

```dart
factory MySealed.fromJson(Map<String, dynamic> json) {
  return switch (json['type']) {
    'variant_a' => VariantA.fromJson(json),
    'variant_b' => VariantB.fromJson(json),
    _ => MyUnknown.fromJson(json), // preserves raw JSON
  };
}
```

### Constructor Constraint Replication

If a constructor enforces constraints (`assert`, mutual exclusivity), the
`fromJson` factory must enforce them too with descriptive exceptions — it
typically bypasses constructor asserts.

### Per-Element Type Checking

Prefer explicit per-element validation over bulk `list.cast<T>()`:

```dart
// WRONG — no context on which element failed
final items = (json['items'] as List).cast<Map<String, dynamic>>();

// CORRECT — validate each element with a clear error
final rawItems = json['items'] as List? ?? [];
final items = rawItems.map((item) {
  if (item is! Map<String, dynamic>) {
    throw FormatException(
      'items: expected Map, got ${item.runtimeType}',
    );
  }
  return Item.fromJson(item);
}).toList();
```

## Nullable Field Serialization

The serialization strategy depends on two factors: whether the OpenAPI spec
marks the field as **required** or **optional**, and whether the field is a
**scalar** (`String`, `int`, `bool`, `DateTime`, etc.) or a **nested model**
(has its own `.toJson()`).

### Decision Table

| Spec | Scalar field | Nested model field |
|------|-------------|-------------------|
| Optional + nullable | `if (field != null) 'key': field` — omit key | `if (field != null) 'key': field!.toJson()` — omit key |
| Required + nullable | `'key': field` — always emit key | `'key': field?.toJson()` — always emit key |
| Required + non-nullable | `'key': field` — always emit key | `'key': field.toJson()` — always emit key |

Only call `.toJson()` on nested model objects — never on scalars (they don't
have that method and the code won't compile).

```dart
Map<String, dynamic> toJson() => {
  // Required non-nullable string — always emit, no .toJson()
  'name': name,
  // Optional nullable model — omit key when null, call .toJson()
  if (config != null) 'config': config!.toJson(),
  // Optional nullable scalar — omit key when null, no .toJson()
  if (description != null) 'description': description,
  // Required nullable model — always emit key, call .toJson()
  'content': content?.toJson(),
};
```

Confusing optional vs required, or scalars vs models, is a common source of
bugs — always check the OpenAPI spec.

## HTTP Client Patterns

### Header Merge Precedence

Protocol-critical headers (e.g., `Accept: text/event-stream` for SSE) must be
applied **last** so user-provided or default headers cannot override them.
Default headers should use `putIfAbsent` to remain overridable:

```dart
final headers = <String, String>{};
headers.addAll(defaultHeaders);            // lowest priority
headers.addAll(authHeaders);               // auth overrides defaults
headers.addAll(userHeaders);               // user overrides auth + defaults
headers['Accept'] = 'text/event-stream';   // protocol-critical — never overridable
```

### Request Object Finalization

`http.BaseRequest` objects cannot be reused after `finalize()` — each retry
attempt must construct a fresh request:

```dart
// WRONG — reuses finalized request
Future<Response> sendWithRetry(BaseRequest request) async {
  for (var i = 0; i < maxRetries; i++) {
    final response = await client.send(request); // throws on retry
  }
}

// CORRECT — factory for fresh requests
Future<Response> sendWithRetry(BaseRequest Function() requestFactory) async {
  for (var i = 0; i < maxRetries; i++) {
    final response = await client.send(requestFactory());
  }
}
```

### Retry-After Clamping

Clamp externally-provided delay values to a configurable maximum and ensure
non-negative to prevent indefinite waits or `Future.delayed` errors.

## DateTime Handling

- **Fallback values**: Use deterministic values like `DateTime.utc(1970)`, never
  `DateTime.now()` — non-deterministic fallbacks mask malformed API data and
  break test reproducibility.
- **Unix timestamps**: Always parse with `isUtc: true`:
  `DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)`.

## Security

### Credential Redaction

Always redact credential-bearing query parameters (`key`, `access_token`,
`api_key`) before logging URLs. Use a redaction utility — never log raw
`request.url` when credentials may be in the query string.

## JSON Serialization

Always use `jsonEncode()` for JSON serialization — never `.toString()` on maps
or objects. `Map.toString()` produces Dart syntax `{key: value}`, not valid JSON
`{"key": "value"}`.

## SSE Parser Correctness

### Event Boundary State Reset

Blank lines in an SSE stream mark event boundaries. On a blank line, **all**
event state must be reset unconditionally — the event type, data buffer, and any
metadata — regardless of whether data was buffered:

```dart
// WRONG — conditional reset leaks event type across boundaries
if (dataBuffer.isNotEmpty) {
  yield parseEvent(currentEvent, dataBuffer);
  dataBuffer = '';
  currentEvent = null;
}

// CORRECT — unconditional reset
if (dataBuffer.isNotEmpty) {
  yield parseEvent(currentEvent, dataBuffer);
  dataBuffer = '';
}
currentEvent = null;  // always reset on blank line
```

Multiple `data:` lines for the same event must be joined with `\n` per the SSE
specification.

### Streaming Field Nullability

In streaming APIs, content and delta types may receive partial events that only
contain the type discriminator (e.g., `{"type": "text"}`). All non-discriminator
fields on such types must be nullable to handle these partial events without
throwing.

## API Design

### Name Conflict Avoidance

Avoid class names that conflict with common Flutter or `dart:ui` types:
`Image`, `Text`, `Color`, `Container`, `Border`, `Icon`. Prefer
domain-prefixed names (e.g., `GroundingImage`). When renaming a public type,
add a `@Deprecated` typedef for the old name to avoid breaking consumers.

### Const Factory Constructors for Sealed Unions

Sealed union types should use `const factory` redirecting constructors, not
static methods, so consumers can construct instances in `const` contexts:

```dart
// WRONG — static method prevents const usage
sealed class MessageContent {
  static MessageTextContent text(String v) => MessageTextContent(v);
}

// CORRECT — const factory enables const construction
sealed class MessageContent {
  const factory MessageContent.text(String value) = MessageTextContent;
}
```

### Convenience Factory Defaults

Factories that set default values (e.g., `Content.text()` setting
`role: 'user'`) must document those defaults. Do not use such factories in
contexts where the defaults are invalid — e.g., `systemInstruction` where
roles are forbidden. Provide a base constructor or alternative factory for
those contexts.
