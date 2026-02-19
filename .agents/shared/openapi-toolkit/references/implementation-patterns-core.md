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

### Security: URL Redaction

When logging URLs in streaming methods, ensure credential query parameters are redacted.
Use the `Redactor` utility to mask sensitive values before logging:

```dart
final redactor = Redactor(redactionList: const ['key', 'access_token']);
final safeUrl = redactor.redactString(request.url.toString());
logger.info('REQUEST $safeUrl');
```

---

## Multipart Upload Patterns

### Why Multipart Bypasses Interceptors

Like streaming, multipart form uploads use `httpClient.send()` directly with `MultipartRequest`, which bypasses the interceptor chain. Resources with multipart uploads must:

1. Apply authentication manually to the `MultipartRequest`
2. Send via `httpClient.send()` to get `StreamedResponse`
3. Check status and map errors before consuming response

### Authentication Helper Pattern

Every resource that uses `httpClient.send()` directly (streaming or multipart) needs this helper:

> **Note**: Streaming resources use the `StreamingResource` mixin because multiple resources need streaming (messages, batches, completions). For multipart uploads, which are typically isolated to a single resource (e.g., FilesResource), a private helper method is sufficient and avoids over-abstraction.

```dart
/// Applies authentication to a request that bypasses the interceptor chain.
Future<void> _applyAuthentication(http.BaseRequest request) async {
  final provider = requestBuilder.config.authProvider;
  if (provider == null) return;

  final credentials = await provider.getCredentials();
  switch (credentials) {
    case ApiKeyCredentials(:final apiKey):
      if (!request.headers.containsKey('x-api-key')) {
        request.headers['x-api-key'] = apiKey;
      }
    case BearerTokenCredentials(:final token):
      if (!request.headers.containsKey('authorization')) {
        request.headers['authorization'] = 'Bearer $token';
      }
    case NoAuthCredentials():
      break;
  }
}
```

### Multipart Upload Example

```dart
Future<FileMetadata> upload({
  required Uint8List bytes,
  required String fileName,
}) async {
  final uri = requestBuilder.buildUrl('/v1/files');
  final headers = requestBuilder.buildHeaders()
    ..remove('content-type'); // Multipart sets its own

  final request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers)
    ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

  // CRITICAL: Apply authentication manually
  await _applyAuthentication(request);

  final streamedResponse = await httpClient.send(request);
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode >= 400) {
    _throwError(response);
  }

  return FileMetadata.fromJson(jsonDecode(response.body));
}
```

### Common Mistake

**Wrong**: Forgetting to apply auth to multipart requests
```dart
// BROKEN - Missing authentication!
final request = http.MultipartRequest('POST', uri)..headers.addAll(headers);
final response = await httpClient.send(request); // 401 Unauthorized
```

**Right**: Always apply authentication before sending
```dart
final request = http.MultipartRequest('POST', uri)..headers.addAll(headers);
await _applyAuthentication(request);  // <-- Don't forget!
final response = await httpClient.send(request);
```

---

---

## Integration Test Patterns

### Using Real Data

For integration tests that require real data (images, files, etc.), don't use inline placeholders:

**Wrong**: Invalid inline data that API rejects
```dart
// BROKEN - API rejects this tiny invalid image
const base64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAAB...';
```

**Right**: Fetch real data from a reliable source
```dart
test('analyzes image from base64', () async {
  // Fetch a real image and convert to base64
  final imageUrl = Uri.parse('https://example.com/real-image.jpg');
  final imageResponse = await http.get(imageUrl);

  // Gracefully skip if external resource unavailable
  if (imageResponse.statusCode != 200) {
    markTestSkipped('Could not fetch test image');
    return;
  }

  final imageBase64 = base64Encode(imageResponse.bodyBytes);
  // Now test with valid base64 data
});
```

### Graceful Skip Pattern

Integration tests should handle external dependencies gracefully:

```dart
test('uploads file', () async {
  // Skip if API key not available
  if (apiKey == null) {
    markTestSkipped('API key not available');
    return;
  }

  // Skip if test file not available
  final testFile = File('test/fixtures/sample.pdf');
  if (!testFile.existsSync()) {
    markTestSkipped('Test file not found');
    return;
  }

  // Proceed with test...
});
```

### Test Fixture Guidelines

1. **Don't inline large binary data** - Use files or fetch from URLs
2. **Handle rate limits** - External services may rate limit test fetches
3. **Use stable URLs** - Prefer stable CDN URLs over dynamic sources
4. **Skip gracefully** - Use `markTestSkipped()` for unavailable dependencies

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
