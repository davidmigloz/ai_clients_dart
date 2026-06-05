# Core Implementation Patterns

**Contents:** [Manifest Kinds](#manifest-kind-values) · [Type Safety](#type-safety-patterns) · [toString](#tostring-convention) · [Equality & Hashing](#equality-and-hashing) · [copyWith Clearing](#copywith-nullable-clear-semantics) · [Immutability](#immutability-enforcement) · [fromJson Patterns](#fromjson-defensive-patterns) · [Const & Closed Values](#constant-and-closed-value-spec-fields) · [readOnly Fields](#readonly-output-only-fields) · [Nullable Serialization](#nullable-field-serialization) · [Tri-State Nullable](#tri-state-nullable-serialization) · [Open Objects](#open-object-schemas) · [HTTP Client](#http-client-patterns) · [DateTime](#datetime-handling) · [Security](#security) · [Opaque Redaction](#opaque-payload-redaction) · [JSON](#json-serialization) · [SSE Parsing](#sse-parser-correctness) · [async\* Guard](#eager-ensurenotclosed-wrapping-for-async) · [Stream Lifecycle](#stream-connection-lifecycle) · [API Design](#api-design)

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

For **nullable** collections, do not write `${list?.length} items` — when the
field is `null` that renders the misleading literal `"null items"`. Print `null`
when the field is absent and the count only when present, e.g. via a small helper:

```dart
String _summarize(List<Object?>? list) =>
    list == null ? 'null' : '${list.length} items';

// usage
String toString() => 'UsageMetadata(cacheTokensDetails: ${_summarize(cacheTokensDetails)})';
// absent  → cacheTokensDetails: null
// empty   → cacheTokensDetails: 0 items
// present → cacheTokensDetails: 2 items
```

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

For fields whose values may contain nested maps or lists (e.g., `Map<String, dynamic>`
holding arbitrary JSON, unknown-variant `rawJson`, or `List<Map>` whose maps can be
nested), use the deep variants — shallow helpers compare nested collections by
identity and break equality for any non-trivial JSON payload:

| Field type | `==` helper | `hashCode` helper |
|-----------|-------------|-------------------|
| `Map<String, dynamic>` (nested) | `mapsDeepEqual(a, b)` | `mapDeepHashCode(map)` |
| `List<Map<String, dynamic>>` (nested) | `listOfMapsDeepEqual(a, b)` | `listOfMapsHashCode(list)` |

### Unknown-Variant Fallbacks Reuse the Shared Deep Helpers

Unknown/fallback sealed variants store arbitrary server JSON, so their `==`/`hashCode`
must use the **deep** helpers above. Don't roll a bespoke per-class shallow
comparator — a hand-written `_mapsEqual`/`_jsonsEqual` paired with
`Object.hashAllUnordered(json.entries)` compares nested maps/lists by identity,
so two unknown payloads with equal nested content compare unequal, diverging
from every other `Unknown*` type in the SDK:

```dart
// WRONG — bespoke shallow helper, nested values compared by identity
bool operator ==(Object other) =>
    other is UnknownEvent && _mapsEqual(json, other.json);
int get hashCode => Object.hashAllUnordered(json.entries);

// CORRECT — shared deep helpers
bool operator ==(Object other) =>
    other is UnknownEvent && mapsDeepEqual(json, other.json);
int get hashCode => mapDeepHashCode(json);
```

### New Field Checklist

When adding a field to a model class, update **all four**:
1. `operator ==` — compare the field
2. `hashCode` — include the field
3. `toString` — print the field
4. `copyWith` — expose the field

## `copyWith` Nullable Clear Semantics

The common `param ?? this.param` pattern silently conflates "caller didn't
provide this field" with "caller explicitly passed `null`", so consumers cannot
clear a previously-set nullable field via `copyWith`. When other models in the
package use the `unsetCopyWithValue` sentinel (typically declared in
`models/common/copy_with_sentinel.dart`), nullable `copyWith` parameters should
follow the same pattern for consistency:

```dart
// WRONG — cannot distinguish "not provided" from "set to null"
OcrPage copyWith({
  String? header,
  String? footer,
  OcrPageDimensions? dimensions,
}) => OcrPage(
  header: header ?? this.header,   // passing null keeps the old value
  footer: footer ?? this.footer,
  dimensions: dimensions ?? this.dimensions,
);

// CORRECT — sentinel differentiates "omitted" from "explicit null"
OcrPage copyWith({
  Object? header = unsetCopyWithValue,
  Object? footer = unsetCopyWithValue,
  Object? dimensions = unsetCopyWithValue,
}) => OcrPage(
  header: identical(header, unsetCopyWithValue) ? this.header : header as String?,
  footer: identical(footer, unsetCopyWithValue) ? this.footer : footer as String?,
  dimensions: identical(dimensions, unsetCopyWithValue)
      ? this.dimensions
      : dimensions as OcrPageDimensions?,
);
```

For non-nullable fields the simple `param ?? this.param` pattern is still
correct — there's no "clear" case to distinguish.

## Immutability Enforcement

Classes annotated `@immutable` must store unmodifiable copies of mutable
collections. Accepting a raw `Map` or `List` constructor parameter and storing
it directly allows callers to mutate the object after construction:

```dart
// WRONG — stores mutable reference
@immutable
class SchemaFormat {
  const SchemaFormat({required this.properties});
  final Map<String, dynamic> properties; // caller can modify after construction
}

// CORRECT — store unmodifiable copy
@immutable
class SchemaFormat {
  SchemaFormat({required Map<String, dynamic> properties})
      : properties = Map.unmodifiable(properties);
  final Map<String, dynamic> properties;
}
```

For deeply nested structures (`Map<String, List<String>>`), use recursive
unmodifiable wrappers or document that inner collections must not be mutated.

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

### Unknown Variant toJson Fidelity

Unknown/fallback sealed variants store the original `rawJson` for forward
compatibility. Their `toJson()` must spread `rawJson` first and let typed
fields win on collision — otherwise either unknown keys are dropped, or
`copyWith`-updated typed fields are silently overwritten by stale `rawJson`
values:

```dart
// WRONG — ignores rawJson, drops forward-compat keys
Map<String, dynamic> toJson() => {
  'type': type,
  'retry_status': retryStatus.toJson(),
};

// WRONG — rawJson's retry_status overwrites the typed field,
//         so copyWith(retryStatus: newStatus) is lost
Map<String, dynamic> toJson() => {
  'type': type,
  'retry_status': retryStatus.toJson(),
  ...rawJson, // spread last — overwrites the typed retry_status above
};

// CORRECT — rawJson provides the base, typed fields win on collision
Map<String, dynamic> toJson() => {
  ...rawJson,
  'type': type,
  'retry_status': retryStatus.toJson(), // copyWith changes preserved
};
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

## Constant and Closed-Value Spec Fields

When the spec pins a field to a single value, don't model it as a freely-settable
field — that lets callers build invalid requests and contradicts the doc comment.
Two shapes recur:

### Required `const` discriminator → constant getter

When the spec defines the field as a required `const` (e.g. `EnvironmentConfig.type`
is const `"remote"`, `RankService.ranking_config` is const `"rank_service"`), make it
a fixed getter — remove it from the constructor and `copyWith` — and reject any other
value in `fromJson`. Invalid configs become unrepresentable:

```dart
// WRONG — settable field accepts arbitrary values and serializes them verbatim
class EnvironmentConfig {
  const EnvironmentConfig({this.type = 'remote', ...});
  final String type;
  Map<String, dynamic> toJson() => {'type': type, ...}; // can emit "type": "bogus"
}

// CORRECT — constant getter; fromJson validates the wire value
class EnvironmentConfig {
  const EnvironmentConfig({...});           // no `type` parameter
  String get type => 'remote';              // always serializes the constant
  factory EnvironmentConfig.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'remote') {
      throw FormatException('EnvironmentConfig: expected type "remote", got "$type"');
    }
    return EnvironmentConfig(...);
  }
  Map<String, dynamic> toJson() => {'type': type, ...};
}
```

Exclude the const discriminator from manifest verification (it has no settable
field to compare), the same way the URL-path `model` is excluded on
`GenerateContentRequest`/`EmbedContentRequest`.

### Closed enum / const-default input field → validate, don't silently accept

For a string member the spec restricts to a closed set (e.g. `["disabled"]`), or a
const-*default* field that may still appear in input (e.g. a `developer`-only
`role`), parse leniently on omission but validate when present — throw on a value
outside the closed set instead of mapping any string to the variant or silently
re-normalizing it on output:

```dart
// WRONG — any string maps to the disabled variant; bad input round-trips silently
factory EnvironmentNetworkEgressAllowlist.fromJson(dynamic json) =>
    json is String ? EnvironmentNetworkDisabled() : ...;

// CORRECT — only the closed literal is accepted
factory EnvironmentNetworkEgressAllowlist.fromJson(dynamic json) {
  if (json is String) {
    if (json != 'disabled') {
      throw ArgumentError('EnvironmentNetworkEgressAllowlist: expected "disabled", got "$json"');
    }
    return EnvironmentNetworkDisabled();
  }
  ...
}
```

## readOnly (Output-Only) Fields

A field the spec marks `readOnly: true` is output-only: the server populates it on
responses, and sending it in a request is out-of-spec and redundant. Keep it on the
response model, but remove it from request DTOs entirely — both the serialized body
and any method parameter that fed it:

```dart
// WRONG — readOnly field serialized in a create request
class CreateModelInteractionParams {
  const CreateModelInteractionParams({this.environmentId, ...});
  final String? environmentId; // readOnly in the spec — must not be sent
  Map<String, dynamic> toJson() => {
    if (environmentId != null) 'environment_id': environmentId, // out-of-spec
    ...
  };
}

// CORRECT — environment_id removed from the request DTO; reference via the writable sibling
class CreateModelInteractionParams {
  const CreateModelInteractionParams({this.environment, ...});
  final EnvironmentConfigOrId? environment; // writable; use .id('...') to reference an existing one
  Map<String, dynamic> toJson() => {
    if (environment != null) 'environment': environment!.toJson(),
    ...
  };
}
```

`environment_id` is still parsed on the `Interaction` *response* model — only the
request side drops it. When removing it, also drop the resource-method parameter
(`environmentId`) that used to populate it, across every create variant.

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

### Tri-State Nullable Serialization

The decision table above has only two outcomes for an optional field: omit the
key (`null`) or emit it. Some specs need a **third** state. When a field is
*optional and nullable* and the API treats explicit JSON `null` as "turn this
feature off" — common in `session.update`-style partial-update payloads where a
field is `anyOf: {object, null}` — plain optional-omit can't express it: omitting
the key means "leave unchanged", so callers have no way to send `"x": null`.

Model the third state with an additive `clearX` flag (defaulting to `false`, so
existing call sites keep compiling) and have `fromJson` distinguish "key absent"
from "key present with null" via `containsKey`:

```dart
@immutable
class AudioConfigInput {
  const AudioConfigInput({
    this.noiseReduction,
    this.clearNoiseReduction = false,
  });

  final NoiseReduction? noiseReduction;
  /// When true, `toJson` emits `"noise_reduction": null` to disable the feature.
  final bool clearNoiseReduction;

  factory AudioConfigInput.fromJson(Map<String, dynamic> json) =>
      AudioConfigInput(
        noiseReduction: json['noise_reduction'] == null
            ? null
            : NoiseReduction.fromJson(
                json['noise_reduction'] as Map<String, dynamic>),
        // key present with null → caller asked to disable
        clearNoiseReduction:
            json.containsKey('noise_reduction') && json['noise_reduction'] == null,
      );

  Map<String, dynamic> toJson() => {
        if (noiseReduction != null)
          'noise_reduction': noiseReduction!.toJson()
        else if (clearNoiseReduction)
          'noise_reduction': null, // explicit disable
        // otherwise omit → "no change"
      };
}
```

This is the request-payload sibling of [copyWith nullable clear
semantics](#copywith-nullable-clear-semantics): both distinguish "not provided"
from "explicitly null".

## Open Object Schemas

When an OpenAPI schema has `"additionalProperties": true`, the object is *open* —
it can carry arbitrary keys beyond the declared `properties`. This is common for
JSON Schema pass-through types (e.g., tool input schemas) where the user defines
the shape.

### Dart Implementation

Add a `Map<String, dynamic>? extra` field to capture undeclared keys:

```dart
@immutable
class InputSchema {
  final String type;
  final Map<String, dynamic>? properties;
  final List<String>? required;
  final Map<String, dynamic>? extra;

  const InputSchema({
    this.type = 'object',
    this.properties,
    this.required,
    this.extra,
  });

  factory InputSchema.fromJson(Map<String, dynamic> json) {
    const knownKeys = {'type', 'properties', 'required'};
    final extraEntries = {
      for (final entry in json.entries)
        if (!knownKeys.contains(entry.key)) entry.key: entry.value,
    };
    return InputSchema(
      type: json['type'] as String? ?? 'object',
      properties: json['properties'] as Map<String, dynamic>?,
      required: (json['required'] as List?)?.cast<String>(),
      extra: extraEntries.isEmpty ? null : extraEntries,
    );
  }

  Map<String, dynamic> toJson() => {
    if (extra != null) ...extra!,  // spread first
    'type': type,                   // known keys win on collision
    if (properties != null) 'properties': properties,
    if (required != null) 'required': required,
  };
}
```

### Key Design Decisions

- **Spread order**: `extra` spreads first in `toJson()`, known keys overwrite after — prevents `extra` from corrupting typed fields
- **Null vs empty map**: `fromJson` returns `null` for `extra` when no unknown keys exist, matching the constructor default
- **Equality**: Use `mapsDeepEqual`/`mapDeepHashCode` since `extra` may contain nested structures
- **Const compatibility**: `const InputSchema(extra: {'additionalProperties': false})` works because `false` is a compile-time constant

### Toolkit Detection

The verifier (`verify --checks implementation`) **errors** when a schema with
`additionalProperties: true` lacks an overflow field — this is blocking, not
advisory, because a missing overflow silently drops user data (see issue #165).
The scaffold generates the `extra` field automatically for open schemas.

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

The same ordering applies to any header a resource documents as **always** set —
e.g. an `Api-Revision` opt-in. Spread caller `additionalHeaders` first, then apply
the forced header last, or the merge order silently lets callers override it and
contradicts the doc comment:

```dart
// WRONG — additionalHeaders applied last; caller can override the "always" header
final headers = {'Api-Revision': _apiRevision, ...?additionalHeaders};

// CORRECT — forced opt-in wins
final headers = {...?additionalHeaders, 'Api-Revision': _apiRevision};
```

Apply the fix to every resource that opts into the same header (e.g. both
`AgentsResource` and `InteractionsResource`).

### Binary Download Endpoints

A GET endpoint that returns binary (`application/zip`, octet-stream, image bytes)
must override `accept` and drop the default JSON `content-type` — otherwise it
advertises the wrong content negotiation. Match the established download convention
(e.g. `FilesResource.download`):

```dart
// WRONG — leaves default JSON content-type and a narrow accept on a binary GET
final headers = {'accept': 'application/binary'}; // + default content-type: application/json

// CORRECT — accept anything (or the spec's media type), no JSON content-type
final headers = {'accept': '*/*'};                // content-type omitted for the GET
```

### Upload Endpoint URLs

Google APIs use a separate `/upload/` prefix for media upload endpoints. When
constructing upload URLs manually (bypassing `requestBuilder.buildUrl`), always
verify the full path — including the action suffix — against the OpenAPI spec.
Do not assume the action name matches a shortened version:

```dart
// WRONG — shortened action name, causes 404
'${config.baseUrl}/upload/${config.apiVersion.value}/$parent:upload'

// CORRECT — exact spec path action
'${config.baseUrl}/upload/${config.apiVersion.value}/$parent:uploadToFileSearchStore'
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

### toString Credential Safety

Never include authentication tokens verbatim in `toString()` output. Credentials
can leak via logs, exception messages, and debug output:

```dart
// WRONG — full token exposed
@override
String toString() => 'Config(token: $authorizationToken, ...)';

// CORRECT — redacted with safe prefix length
@override
String toString() {
  final prefix = authorizationToken.length >= 4
      ? authorizationToken.substring(0, 4)
      : authorizationToken;
  return 'Config(token: $prefix***, ...)';
}
```

### Opaque Payload Redaction

The same risk applies to fields that aren't strictly credentials but that carry
opaque, server-provided payloads — for example `encryptedContent` on
Anthropic compaction blocks, verbatim signatures, or large binary blobs. They
can leak into logs via `toString()`, bloat output enormously, and aren't
meaningful to a human reader anyway. Redact them the same way existing
`RedactedThinkingBlock` / `AdvisorRedactedResult` fields are handled in the
codebase:

```dart
// WRONG — prints the full opaque payload, leaks and bloats logs
@override
String toString() => 'CompactionBlock('
    'content: $content, '
    'encryptedContent: $encryptedContent'
    ')';

// CORRECT — size-only summary, null preserved
@override
String toString() => 'CompactionBlock('
    'content: $content, '
    'encryptedContent: ${encryptedContent == null ? null : '[${encryptedContent!.length} chars]'}'
    ')';
```

Keep the null branch so `toString` still conveys "present vs absent" — callers
debugging serialization regressions often care about that distinction.

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

### `[DONE]` Termination

When the SSE stream sends `data: [DONE]`, the parser must flush any buffered
event data and terminate cleanly. Do not attempt to JSON-parse `[DONE]` as a
data payload.

### Synthetic Error Map Completeness

When constructing synthetic error event maps from HTTP error responses, always
include a `type` field so consumers dispatching on event type can handle errors:

```dart
// WRONG — no type field, consumer switch/case falls through
yield {'error': {'message': body}};

// CORRECT — includes type for dispatch
yield {'type': 'error', 'error': {'message': body}};
```

When implementing `withoutEventType()` or similar event-stripping helpers,
preserve `_rawData` so error event consumers can still access the original
payload.

### Streaming Field Nullability

In streaming APIs, content and delta types may receive partial events that only
contain the type discriminator (e.g., `{"type": "text"}`). All non-discriminator
fields on such types must be nullable to handle these partial events without
throwing.

### Eager `ensureNotClosed` Wrapping for `async*`

`async*` method bodies are lazy — none of the code inside runs until a consumer
calls `.listen()` on the returned stream. That means an `ensureNotClosed()` call
inside an `async*` body fails *late*: callers who construct a stream on a closed
client won't see the error until they try to read from it, which is often in a
different stack frame and far from the original mistake.

Wrap the `async*` body in a non-`async*` public method so the guard runs
synchronously when the stream is constructed:

```dart
// WRONG — ensureNotClosed runs only when the returned stream is listened to
Stream<ImageEditStreamEvent> editStream(ImageEditRequest request) async* {
  ensureNotClosed?.call();            // lazy — fires on .listen(), not on call
  yield* _performEdit(request);
}

// CORRECT — eager guard, async* body isolated in a private helper
Stream<ImageEditStreamEvent> editStream(ImageEditRequest request) {
  ensureNotClosed?.call();            // runs at call time
  return _editStreamImpl(request);
}

Stream<ImageEditStreamEvent> _editStreamImpl(ImageEditRequest request) async* {
  yield* _performEdit(request);
}
```

The same split is the right default for any other synchronous precondition
(argument validation, factory selection) on a streaming method.

## Stream Connection Lifecycle

Connection wrappers (WebSocket/Realtime-style) that expose incoming frames as a
`Stream` often buffer events that arrive **before the first listener attaches**,
then drain the buffer in the controller's `onListen`. Three lifecycle hazards
recur in this shape — handle all three, and apply each fix to every parallel
connection class (e.g. realtime, translation, transcription variants):

1. **Idempotent done/close.** The done handler can fire more than once — e.g. the
   IO connector emits `CloseReceived` from inside its own `onDone`, so both the
   `CloseReceived` event branch and the subscription's `onDone` call it. Guard with
   an early return so `_eventController.close()` runs exactly once.
2. **Guard emit/drain against a closed controller.** If the socket closes before
   any listener attaches and a listener subscribes *later*, the buffered drain (or
   a straggler frame) runs after `close()` — `add`/`addError` then throw
   `StateError: Cannot add new events after calling close`. Short-circuit drain and
   emit paths when `_closed`.
3. **Bound the pre-listener buffer.** A consumer that attaches late or never makes
   `_earlyEvents` grow without limit for the life of the connection. Cap it with a
   drop policy (drop-oldest is usually right — keep the most recent frames).

```dart
final _eventController = StreamController<RealtimeEvent>(onListen: _drainBuffer);
final _earlyEvents = <Object>[];        // buffered events/errors, pre-listener
static const _maxEarlyEvents = 1024;
var _closed = false;

void _handleDone() {
  if (_closed) return;                  // (1) idempotent — close() fires once
  _closed = true;
  _eventController.close();
}

void _emitEvent(RealtimeEvent event) {
  if (_closed) return;                  // (2) never add after close
  if (!_eventController.hasListener) {
    if (_earlyEvents.length >= _maxEarlyEvents) {
      _earlyEvents.removeAt(0);         // (3) drop oldest
    }
    _earlyEvents.add(event);
    return;
  }
  _eventController.add(event);
}

void _drainBuffer() {
  if (_closed) {                        // (2) socket already closed; just clear
    _earlyEvents.clear();
    return;
  }
  for (final e in _earlyEvents) {
    if (e is RealtimeEvent) _eventController.add(e);
    // ... addError for buffered errors
  }
  _earlyEvents.clear();
}
```

`StreamController.close()` is itself idempotent, but the explicit `_closed` guard
makes the contract clear and keeps the drain/emit short-circuits correct if the
close logic later grows.

### Teardown When `close()` May Throw

When a `close()`/teardown method calls into something that can throw an
*unexpected* error — not just the expected "already closed" signal — the teardown
of owned resources (stream controllers, subscriptions) must live in a `finally`
block, or that error short-circuits cleanup and leaves listeners hanging:

```dart
// WRONG — if _socket.close() throws anything but WebSocketConnectionClosed,
//         the controller is never closed and listeners hang forever
Future<void> close() async {
  try {
    await _socket.close();
  } on WebSocketConnectionClosed {
    // already closed — fine
  }
  await _messageController.close(); // skipped when close() throws ArgumentError/WebSocketException
}

// CORRECT — controller teardown always runs; unexpected errors propagate after cleanup
Future<void> close() async {
  try {
    await _socket.close();
  } on WebSocketConnectionClosed {
    // idempotent close — swallow
  } finally {
    await _messageController.close();
  }
}
```

The expected idempotent-close signal is swallowed; any other error (e.g. an
`ArgumentError` for an invalid close code, a `WebSocketException`) propagates to the
caller *after* the controller is closed. Cover it with a test asserting the
unexpected error rethrows while the controller is still torn down.

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

Note: string interpolation with constructor parameters is valid in `const`
initializer lists. This compiles:

```dart
const MyClass.data(String data, {required String mediaType})
    : value = 'data:$mediaType;base64,$data'; // valid const
```

### Convenience Factory Defaults

Factories that set default values (e.g., `Content.text()` setting
`role: 'user'`) must document those defaults. Do not use such factories in
contexts where the defaults are invalid — e.g., `systemInstruction` where
roles are forbidden. Provide a base constructor or alternative factory for
those contexts.
