# Implementation Patterns (chromadb)

Extends [implementation-patterns-core.md](../../../shared/openapi-toolkit/references/implementation-patterns-core.md).

## API-Specific Patterns

### Authentication

ChromaDB uses `x-chroma-token` header for API key authentication:

```dart
class ApiKeyProvider implements AuthProvider {
  final String apiKey;
  const ApiKeyProvider(this.apiKey);

  @override
  Future<AuthCredentials> getCredentials() async =>
      ApiKeyCredentials(apiKey: apiKey);
}

// Note: The `x-chroma-token` header is applied by AuthInterceptor
// when it receives ApiKeyCredentials
```

### Multi-Tenant URLs

All collection operations include tenant/database in the URL path:

```dart
final url = requestBuilder.buildUrl(
  '/api/v2/tenants/${config.tenant}/databases/${config.database}/collections',
);
```

### Embedding Functions

Per-collection embedding functions for automatic document → embedding conversion:

```dart
class ChromaCollection {
  final EmbeddingFunction? embeddingFunction;

  Future<void> add({
    required List<String> ids,
    List<String>? documents,
    List<List<double>>? embeddings,
  }) async {
    var finalEmbeddings = embeddings;
    if (finalEmbeddings == null && documents != null) {
      finalEmbeddings = await embeddingFunction!.generate(
        documents.map(Embeddable.document).toList(),
      );
    }
    // ...
  }
}
```

### Include Enum

Use the Include enum to specify which fields to return:

```dart
enum Include { documents, embeddings, metadatas, distances, uris, data }

final response = await collection.query(
  queryEmbeddings: [[1.0, 2.0, 3.0]],
  include: [Include.documents, Include.distances],
);
```

### Error Responses

ChromaDB returns errors in this format:

```json
{
  "error": "error message",
  "message": "detailed message"
}
```

Map to `ApiException` with appropriate status codes.
