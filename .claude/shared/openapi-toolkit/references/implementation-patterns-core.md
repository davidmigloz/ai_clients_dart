# Implementation Patterns (Core)

Generic patterns for Dart API client implementation. See your package's `references/implementation-patterns.md` for package-specific patterns.

## Model Conventions

### Basic Structure

```dart
import '../copy_with_sentinel.dart';

/// Description from OpenAPI spec.
class ModelName {
  /// Field documentation.
  final String? fieldName;

  /// Creates a [ModelName].
  const ModelName({
    this.fieldName,
  });

  /// Creates a [ModelName] from JSON.
  factory ModelName.fromJson(Map<String, dynamic> json) => ModelName(
        fieldName: json['fieldName'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        if (fieldName != null) 'fieldName': fieldName,
      };

  /// Creates a copy with replaced values.
  ModelName copyWith({
    Object? fieldName = unsetCopyWithValue,
  }) {
    return ModelName(
      fieldName:
          fieldName == unsetCopyWithValue
              ? this.fieldName
              : fieldName as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelName &&
          runtimeType == other.runtimeType &&
          fieldName == other.fieldName;

  @override
  int get hashCode => fieldName.hashCode;

  @override
  String toString() => 'ModelName(fieldName: $fieldName)';
}
```

### Type Mappings

| OpenAPI Type | Dart Type |
|--------------|-----------|
| `string` | `String` |
| `integer` | `int` |
| `number` | `double` |
| `boolean` | `bool` |
| `array` | `List<T>` |
| `object` | `Map<String, dynamic>` or custom class |
| `$ref` | Referenced class name |

### Nested Object Handling

```dart
// In fromJson
nestedObject: json['nestedObject'] != null
    ? NestedClass.fromJson(json['nestedObject'] as Map<String, dynamic>)
    : null,

// In toJson
if (nestedObject != null) 'nestedObject': nestedObject!.toJson(),
```

### List Handling

```dart
// Simple list
items: (json['items'] as List?)?.cast<String>(),

// List of objects
items: (json['items'] as List?)
    ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
    .toList(),

// In toJson
if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
```

### Number Handling

```dart
// Always convert num to double for decimal fields
value: (json['value'] as num?)?.toDouble(),
```

---

## Enum Conventions

### Basic Structure

```dart
/// Description from OpenAPI spec.
enum EnumName {
  /// Unspecified value.
  unspecified,

  /// Value description.
  valueName,
}

/// Converts string to [EnumName] enum.
EnumName enumNameFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'ENUM_NAME_VALUE_NAME' => EnumName.valueName,
    _ => EnumName.unspecified,
  };
}

/// Converts [EnumName] enum to string.
String enumNameToString(EnumName value) {
  return switch (value) {
    EnumName.valueName => 'ENUM_NAME_VALUE_NAME',
    EnumName.unspecified => 'ENUM_NAME_UNSPECIFIED',
  };
}
```

### Naming Conventions

- Enum name: `PascalCase` (e.g., `HarmCategory`)
- Enum values: `camelCase` (e.g., `hateSpeech`)
- Wire format: `SCREAMING_SNAKE_CASE` (e.g., `HARM_CATEGORY_HATE_SPEECH`)
- Converter functions: `enumNameFromString`, `enumNameToString`

### Always Include Default

Always include an `unspecified` or `unknown` value for forward compatibility:

```dart
_ => EnumName.unspecified,  // Catch-all for unknown values
```

---

## JSON Serialization

### Required Fields

```dart
// In fromJson - throw or use default if truly required
requiredField: json['requiredField'] as String,

// In toJson - always include
'requiredField': requiredField,
```

### Optional Fields

```dart
// In fromJson - allow null
optionalField: json['optionalField'] as String?,

// In toJson - conditionally include
if (optionalField != null) 'optionalField': optionalField,
```

### Preserve Unknown Fields

When the API might return fields not yet in the schema:

```dart
final Map<String, dynamic>? additionalProperties;

// In fromJson
final knownKeys = {'name', 'displayName'};
additionalProperties: Map.fromEntries(
  json.entries.where((e) => !knownKeys.contains(e.key)),
),

// In toJson
...?additionalProperties,
```

---

## Test Patterns

### Standard Test Groups

```dart
void main() {
  group('ClassName', () {
    group('fromJson', () {
      test('creates instance with all fields', () { ... });
      test('handles null values', () { ... });
      test('handles partial data', () { ... });
    });

    group('toJson', () {
      test('converts all fields to JSON', () { ... });
      test('omits null values', () { ... });
    });

    test('round-trip preserves data', () { ... });

    group('copyWith', () {
      test('creates copy with changed field', () { ... });
      test('can set field to null', () { ... });
    });

    group('equality', () {
      test('equal instances are equal', () { ... });
      test('different instances are not equal', () { ... });
    });

    test('toString includes all fields', () { ... });
  });
}
```

### Enum Test Pattern

```dart
group('EnumName', () {
  group('enumNameFromString', () {
    test('converts known values', () { ... });
    test('converts null to unspecified', () { ... });
    test('converts invalid to unspecified', () { ... });
    test('is case insensitive', () { ... });
  });

  group('enumNameToString', () {
    test('converts all values', () { ... });
  });

  test('round-trip preserves value', () {
    for (final value in EnumName.values) {
      final str = enumNameToString(value);
      final converted = enumNameFromString(str);
      expect(converted, value);
    }
  });
});
```

---

## Export Organization

### Model Barrel Files

Each model subdirectory has a barrel file:

```dart
// lib/src/models/files/files.dart
export 'file.dart';
export 'file_search_store.dart';
```

### Main Models Export

```dart
// lib/src/models/models.dart
export 'batch/batch.dart';
export 'caching/caching.dart';
export 'content/content.dart';
// ... etc
```

### Package Export

```dart
// lib/{package_name}.dart
export 'src/models/models.dart';
export 'src/resources/resources.dart';
// ... etc
```

---

## Streaming Patterns

### Why Streaming Bypasses Interceptors

The interceptor chain operates on buffered `http.Response`. Streaming requires unbuffered `http.StreamedResponse` access. Resources with streaming must:
1. Apply auth/logging manually to the request
2. Send via `httpClient.send()` to get `StreamedResponse`
3. Check status and map errors before consuming stream

### Streaming Resource Mixin

Create a package-specific mixin that extends `ResourceBase`:

```dart
mixin StreamingResource on ResourceBase {
  /// Prepares request with auth and logging.
  Future<http.Request> prepareStreamingRequest(http.Request request) async {
    var req = request;
    if (config.authProvider != null) {
      final creds = await config.authProvider!.getCredentials();
      req = _applyAuth(req, creds);
    }
    return _applyLogging(req);
  }

  /// Sends streaming request with error handling.
  Future<http.StreamedResponse> sendStreamingRequest(http.Request request) async {
    final response = await httpClient.send(request);
    if (response.statusCode >= 400) {
      throw mapHttpError(await http.Response.fromStream(response));
    }
    return response;
  }

  // Package-specific auth helpers (_applyAuth, _applyLogging, mapHttpError)
}
```

### Using the Mixin

Resources opt-in to streaming by adding the mixin:

```dart
class ChatResource extends ResourceBase with StreamingResource {
  Stream<Event> createStream({required Request request}) async* {
    var httpRequest = http.Request('POST', url)...;

    // Use mixin methods for streaming request handling
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    // Parse stream (NDJSON or SSE depending on package)
    await for (final json in parseStream(streamedResponse.stream)) {
      yield Event.fromJson(json);
    }
  }
}
```

### Abort Monitoring (for cancellable streams)

For APIs that support abort triggers, the mixin can provide:

```dart
/// Monitors an abort trigger while streaming.
Stream<T> streamWithAbortMonitoring<T>({
  required Stream<Map<String, dynamic>> source,
  required Future<void> abortTrigger,
  required String requestId,
  required T Function(Map<String, dynamic>) fromJson,
}) {
  // StreamController that:
  // 1. Yields items from source until abortTrigger completes
  // 2. On abort: cancels source, adds AbortedException, closes
}
```

### Package-Specific Considerations

- **Auth handling**: Each package has different credential types (API key, Bearer token, ephemeral token)
- **Stream format**: Some packages use NDJSON, others use SSE
- **Error mapping**: Exception types are package-specific

---

## PR Templates

### New Model PR

**Title**: `feat({package_name}): Add {ModelName} model`

```markdown
## Summary
- Add {ModelName} model for {purpose}
- Implement fromJson/toJson serialization
- Add comprehensive unit tests

## Test plan
- [ ] Unit tests pass
- [ ] Dart analyzer passes
- [ ] Format check passes
```

### New Endpoint PR

**Title**: `feat({package_name}): Add {operation_id} endpoint`

```markdown
## Summary
- Add {METHOD} {path} endpoint
- Add required request/response models
- Implement resource method

## Test plan
- [ ] Unit tests pass
- [ ] Integration test (if applicable)
- [ ] Dart analyzer passes
```

### Breaking Change PR

**Title**: `feat({package_name})!: Remove deprecated {feature}`

```markdown
## Summary
- Remove {endpoint/model} (removed from API)
- Update exports
- Update dependent code

## Breaking Changes
- {Specific breaking changes}

## Migration
{Migration guidance if applicable}

## Test plan
- [ ] Remove related tests
- [ ] Verify no compile errors
- [ ] Dart analyzer passes
```
