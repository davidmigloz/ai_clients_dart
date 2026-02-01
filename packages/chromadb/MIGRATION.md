# Migration Guide

This guide helps you migrate from the old `chromadb` client (v0.x) to the new **v1.0.0** (complete rewrite with resource-based organization and comprehensive API coverage).

## Overview of Changes

The new client features a **resource-based API** with improved architecture:

* `client.health` — Server health, version, and status checks
* `client.collections` — Collection management (low-level)
* `client.records(collectionId)` — Record CRUD operations (low-level)
* `client.databases` — Database management for multi-tenant setups
* `client.tenants` — Tenant management for multi-tenant setups
* `client.auth` — Authentication and identity
* `client.functions(collectionId)` — Serverless function management

**Key improvements:**
* Built-in authentication providers
* Comprehensive exception hierarchy
* Automatic retry with exponential backoff
* Request tracing with correlation IDs
* New features: Advanced Search, Functions, Collection Forking

## Quick Reference Table

| Operation             | Old API (v0.x)                                      | New API (v1.0.0)                                                     |
| --------------------- | --------------------------------------------------- | -------------------------------------------------------------------- |
| **Initialize Client** | `ChromaClient(baseUrl: '...')`                      | `ChromaClient(config: ChromaConfig(...))`                            |
| **Local Instance**    | `ChromaClient()`                                    | `ChromaClient()` or `ChromaClient.local()`                           |
| **With API Key**      | `ChromaClient(headers: {'x-chroma-token': 'key'})` | `ChromaClient.withApiKey('key')`                                     |
| **Create Collection** | `client.createCollection(name: 'x')`                | `client.createCollection(name: 'x')` *(unchanged)*                   |
| **Get or Create**     | `client.getOrCreateCollection(name: 'x')`           | `client.getOrCreateCollection(name: 'x')` *(unchanged)*              |
| **List Collections**  | `client.listCollections()` → `List<CollectionType>` | `client.listCollections()` → `List<Collection>` *(with pagination)*  |
| **Delete Collection** | `client.deleteCollection(name: 'x')`                | `client.deleteCollection(name: 'x')` *(unchanged)*                   |
| **Count Collections** | ❌ Not available                                     | `client.countCollections()`                                          |
| **Heartbeat**         | `client.heartbeat()` → `int`                        | `client.health.heartbeat()` → `HeartbeatResponse`                    |
| **Version**           | `client.version()` → `String`                       | `client.health.version()` → `VersionResponse`                        |
| **Reset**             | `client.reset()`                                    | `client.health.reset()`                                              |
| **Collection Class**  | `Collection`                                        | `ChromaCollection` *(wrapper with `.metadata` property)*             |
| **Collection Metadata**| `collection.metadata` → `Map<String, dynamic>?`    | `collection.metadata.metadata` → `Map<String, dynamic>?`             |
| **Modify Collection** | `collection.modify(name: ..., metadata: ...)`       | `collection.modify(newName: ..., newMetadata: ...)` → `Collection`   |
| **Add Records**       | `collection.add(...)`                               | `collection.add(...)` *(unchanged)*                                  |
| **Get Records**       | `collection.get(...)`                               | `collection.get(...)` *(default includes changed)*                   |
| **Peek Records**      | `collection.peek(...)`                              | `collection.peek(...)` *(default includes changed)*                  |
| **Query Records**     | `collection.query(...)`                             | `collection.query(...)` *(default includes changed)*                 |
| **Advanced Search**   | ❌ Not available                                     | `collection.search(...)`                                             |
| **Include Enum**      | `Include` (5 values)                                | `Include` (6 values, +`uris`, +static defaults)                      |
| **Exception Type**    | `ChromaApiClientException`                          | `ChromaException` hierarchy                                          |

## 1) Client Initialization

```dart
import 'package:chromadb/chromadb.dart';

// OLD
final old = ChromaClient(
  baseUrl: 'http://localhost:8000',
  tenant: 'default_tenant',
  database: 'default_database',
);

// NEW
final client = ChromaClient(
  config: ChromaConfig(
    baseUrl: 'http://localhost:8000',
    tenant: 'default_tenant',
    database: 'default_database',
  ),
);
```

### Convenience Constructors

```dart
// Local instance (equivalent to defaults)
final local = ChromaClient.local(port: 8000);

// With API key authentication
final cloud = ChromaClient.withApiKey(
  'your-api-key',
  baseUrl: 'https://api.trychroma.com',
  tenant: 'my-tenant',
  database: 'my-database',
);
```

### Don't Forget to Close

```dart
// NEW: Always close the client when done
client.close();
```

## 2) Authentication

### API Key Authentication

```dart
// OLD - Manual headers
final old = ChromaClient(
  baseUrl: 'https://api.trychroma.com',
  headers: {'x-chroma-token': 'your-api-key'},
);

// NEW - API key provider
final client = ChromaClient(
  config: ChromaConfig(
    baseUrl: 'https://api.trychroma.com',
    authProvider: ApiKeyProvider('your-api-key'),
  ),
);

// NEW - Convenience constructor
final cloud = ChromaClient.withApiKey('your-api-key',
  baseUrl: 'https://api.trychroma.com',
);
```

### Bearer Token Authentication (New)

```dart
// OAuth/JWT token authentication
final client = ChromaClient(
  config: ChromaConfig(
    baseUrl: 'https://your-chroma-instance.com',
    authProvider: BearerTokenProvider('your-jwt-token'),
  ),
);
```

### Custom Authentication Provider (New)

```dart
class MyAuthProvider implements AuthProvider {
  @override
  Future<AuthCredentials> getCredentials() async {
    // Fetch fresh token (e.g., from OAuth flow)
    final token = await refreshToken();
    return BearerTokenCredentials(token: token);
  }
}

final client = ChromaClient(
  config: ChromaConfig(
    authProvider: MyAuthProvider(),
  ),
);
```

## 3) Collection Management

```dart
// Create collection
// OLD
final old = await client.createCollection(
  name: 'my-collection',
  metadata: {'description': 'My documents'},
  embeddingFunction: myEmbedder,
);

// NEW - Same signature, different return type
final collection = await client.createCollection(
  name: 'my-collection',
  metadata: {'description': 'My documents'},
  embeddingFunction: myEmbedder,
);
// Note: Returns ChromaCollection instead of Collection
```

### Accessing Collection Properties

```dart
// OLD - Collection class had direct properties
final old = await client.getCollection(name: 'my-docs');
print(old.name);      // String
print(old.id);        // String
print(old.metadata);  // Map<String, dynamic>? - The collection's custom metadata

// NEW - ChromaCollection wraps Collection with convenience accessors
final collection = await client.getCollection(name: 'my-docs');
print(collection.name);  // String (convenience accessor)
print(collection.id);    // String (convenience accessor)

// To access custom metadata, use the nested path:
print(collection.metadata.metadata);  // Map<String, dynamic>? - Custom metadata

// Full Collection object available via .metadata:
print(collection.metadata.name);           // String
print(collection.metadata.id);             // String
print(collection.metadata.metadata);       // Map<String, dynamic>? - Custom metadata
print(collection.metadata.dimension);      // int? (NEW)
print(collection.metadata.configurationJson); // CollectionConfiguration? (NEW)
print(collection.metadata.schema);         // CollectionSchema? (NEW)
print(collection.metadata.logPosition);    // int? (NEW)
print(collection.metadata.version);        // int? (NEW)
```

```dart
// Get or create collection (unchanged)
final collection = await client.getOrCreateCollection(
  name: 'my-collection',
  embeddingFunction: myEmbedder,
);
```

```dart
// Get existing collection (unchanged)
final collection = await client.getCollection(
  name: 'my-collection',
  embeddingFunction: myEmbedder,
);
```

```dart
// List collections
// OLD
final collections = await client.listCollections();

// NEW - Now supports pagination
final collections = await client.listCollections(
  limit: 10,
  offset: 0,
);
```

```dart
// Delete collection (unchanged)
await client.deleteCollection(name: 'my-collection');
```

```dart
// NEW: Count collections
final count = await client.countCollections();
```

## 4) Working with Records

Record operations remain largely unchanged on the collection wrapper.

### Adding Records

```dart
// UNCHANGED
await collection.add(
  ids: ['id1', 'id2'],
  embeddings: [[0.1, 0.2, 0.3], [0.4, 0.5, 0.6]],  // OR
  documents: ['Hello world', 'Goodbye world'],     // auto-embedded
  metadatas: [{'source': 'web'}, {'source': 'api'}],
);
```

### Updating Records

```dart
// UNCHANGED
await collection.update(
  ids: ['id1'],
  documents: ['Updated text'],
  metadatas: [{'updated': true}],
);
```

### Upserting Records

```dart
// UNCHANGED
await collection.upsert(
  ids: ['id1', 'id3'],
  documents: ['Updated text', 'New text'],
);
```

### Getting Records

```dart
// CHANGED: Default includes no longer include embeddings
// OLD default: [Include.embeddings, Include.metadatas, Include.documents]
// NEW default: [Include.documents, Include.metadatas]

final items = await collection.get(
  ids: ['id1', 'id2'],
  where: {'source': 'web'},
  whereDocument: {r'$contains': 'hello'},
  limit: 10,
  offset: 0,
  include: [Include.documents, Include.metadatas, Include.embeddings],
);
```

### Querying Records

```dart
// CHANGED: Default includes no longer include embeddings
// OLD default: [Include.embeddings, Include.metadatas, Include.documents, Include.distances]
// NEW default: [Include.documents, Include.metadatas, Include.distances]

final results = await collection.query(
  queryTexts: ['search query'],      // OR
  queryEmbeddings: [[0.1, 0.2, 0.3]], // pre-computed
  nResults: 5,
  where: {'source': 'web'},
  whereDocument: {r'$contains': 'hello'},
  include: [Include.documents, Include.metadatas, Include.distances],
);

// To include embeddings in query results:
final resultsWithEmbeddings = await collection.query(
  queryTexts: ['search query'],
  include: [Include.documents, Include.metadatas, Include.distances, Include.embeddings],
);
```

### Advanced Search (New)

```dart
// NEW: Hybrid search with filtering, grouping, and ranking
final searchResults = await collection.search(
  searches: [
    SearchPayload(
      filter: SearchFilter(
        queryIds: ['id1', 'id2'],
        whereClause: {'status': 'active'},
      ),
      groupBy: SearchGroupBy(keys: ['category']),
      limit: SearchLimit(limit: 10, offset: 0),
      select: SearchSelect(keys: ['Document', 'Metadata']),
    ),
  ],
);
```

### Deleting Records

```dart
// UNCHANGED
final deletedIds = await collection.delete(
  ids: ['id1'],
  where: {'archived': true},
  whereDocument: {r'$contains': 'deprecated'},
);
```

### Counting and Peeking

```dart
// count() - UNCHANGED
final count = await collection.count();

// peek() - Default includes CHANGED
// OLD default: [Include.embeddings, Include.metadatas, Include.documents]
// NEW default: [Include.documents, Include.metadatas]
final preview = await collection.peek(limit: 5);

// To get embeddings, explicitly include them:
final previewWithEmbeddings = await collection.peek(
  limit: 5,
  include: [Include.documents, Include.metadatas, Include.embeddings],
);
```

### Modifying Collection

```dart
// OLD
await collection.modify(
  name: 'new-name',           // Note: parameter was 'name'
  metadata: {'updated': true}, // Note: parameter was 'metadata'
);
// Returns: void

// NEW
final updated = await collection.modify(
  newName: 'new-name',          // Changed: 'name' → 'newName'
  newMetadata: {'updated': true}, // Changed: 'metadata' → 'newMetadata'
);
// Returns: Collection (the updated collection data)

// Note: collection.metadata is NOT auto-updated
// Get a fresh reference to see updated values if needed
```

## 5) Include Enum Changes

The `Include` enum has been enhanced with a new value and static defaults:

```dart
// OLD
enum Include {
  documents,
  embeddings,
  metadatas,
  distances,
  data,
}

// Default for get(): [Include.embeddings, Include.metadatas, Include.documents]
// Default for query(): [Include.embeddings, Include.metadatas, Include.documents, Include.distances]

// NEW
enum Include {
  documents,
  embeddings,
  metadatas,
  distances,
  uris,      // NEW: Include URIs in response
  data,
}

// Static defaults available:
Include.defaultGet;    // [Include.documents, Include.metadatas]
Include.defaultQuery;  // [Include.documents, Include.metadatas, Include.distances]
```

**Important:** Default includes have changed for both `get()` and `query()`:

| Method    | Old Default                                       | New Default                              |
| --------- | ------------------------------------------------- | ---------------------------------------- |
| `get()`   | `[embeddings, metadatas, documents]`              | `[documents, metadatas]`                 |
| `peek()`  | `[embeddings, metadatas, documents]`              | `[documents, metadatas]`                 |
| `query()` | `[embeddings, metadatas, documents, distances]`   | `[documents, metadatas, distances]`      |

**Key change:** Embeddings are **NOT included by default** in any operation.

If you need embeddings in responses, explicitly include them:

```dart
final items = await collection.get(
  ids: ['id1'],
  include: [Include.documents, Include.metadatas, Include.embeddings],
);
```

## 6) Embedding Functions

The embedding function interface remains unchanged.

```dart
class CustomEmbedder implements EmbeddingFunction {
  @override
  Future<List<List<double>>> generate(List<Embeddable> inputs) async {
    // Generate embeddings using your service
    return inputs.map((input) {
      switch (input) {
        case EmbeddableDocument(:final text):
          return _embedText(text);
        case EmbeddableImage(:final base64):
          return _embedImage(base64);
      }
    }).toList();
  }
}

final collection = await client.getOrCreateCollection(
  name: 'docs',
  embeddingFunction: CustomEmbedder(),
);

// Embeddings generated automatically from documents
await collection.add(
  ids: ['id1'],
  documents: ['Hello world'],
);
```

## 7) Data Loaders

The data loader interface remains unchanged.

```dart
class ImageLoader implements DataLoader<Loadable> {
  @override
  Future<Loadable> call(List<String> uris) async {
    // Load images from URIs and return as base64
    return await Future.wait(uris.map(_loadAndEncode));
  }
}

final collection = await client.getOrCreateCollection(
  name: 'images',
  embeddingFunction: myEmbedder,
  dataLoader: ImageLoader(),
);

// Data loaded from URIs before embedding
await collection.add(
  ids: ['img1'],
  uris: ['https://example.com/image.jpg'],
);
```

## 8) Health & Server Operations

```dart
// OLD
final heartbeat = await client.heartbeat();  // Returns int
final version = await client.version();      // Returns String
final reset = await client.reset();          // Returns bool

// NEW - Methods moved to health resource
final heartbeat = await client.health.heartbeat();  // Returns HeartbeatResponse
print(heartbeat.nanosecondHeartbeat);

final version = await client.health.version();      // Returns VersionResponse
print(version.version);

final reset = await client.health.reset();          // Returns bool

// NEW: Additional health checks
final checks = await client.health.preFlightChecks();
final status = await client.health.healthcheck();
```

## 9) Multi-Tenant Operations (New)

### Tenant Management

```dart
// Create tenant
final tenant = await client.tenants.create(name: 'my-tenant');

// Get tenant
final retrieved = await client.tenants.getByName(name: 'my-tenant');

// Update tenant
final updated = await client.tenants.update(
  name: 'my-tenant',
  newName: 'renamed-tenant',
);
```

### Database Management

```dart
// List databases
final databases = await client.databases.list(tenant: 'my-tenant');

// Create database
final db = await client.databases.create(
  name: 'my-database',
  tenant: 'my-tenant',
);

// Get database
final retrieved = await client.databases.getByName(
  name: 'my-database',
  tenant: 'my-tenant',
);

// Delete database
await client.databases.deleteByName(
  name: 'my-database',
  tenant: 'my-tenant',
);
```

## 10) Exception Handling

```dart
// OLD - Single exception type
try {
  await collection.add(ids: ['id1'], documents: ['text']);
} on ChromaApiClientException catch (e) {
  print('Error ${e.code}: ${e.message}');
  print('URI: ${e.uri}');
  print('Method: ${e.method}');
}

// NEW - Specific exception types
try {
  await collection.add(ids: ['id1'], documents: ['text']);
} on RateLimitException catch (e) {
  // 429 - Rate limited
  final waitTime = e.retryAfter ?? Duration(seconds: 5);
  print('Rate limited, retry after: $waitTime');
  await Future.delayed(waitTime);
} on AuthenticationException catch (e) {
  // 401/403 - Check credentials
  print('Authentication failed: ${e.message}');
} on NotFoundException catch (e) {
  // 404 - Resource not found
  print('Not found: ${e.message}');
} on ConflictException catch (e) {
  // 409 - Resource already exists
  print('Conflict: ${e.message}');
} on ValidationException catch (e) {
  // 400/422 - Invalid input
  print('Validation error: ${e.message}');
} on ServerException catch (e) {
  // 5xx - Server error
  print('Server error: ${e.message}');
} on TimeoutException catch (e) {
  // Request timed out
  print('Timeout: ${e.message}');
} on AbortedException catch (e) {
  // Request cancelled
  print('Aborted: ${e.message}');
} on ApiException catch (e) {
  // Catch-all for other API errors
  print('API error: ${e.message}');
  print('Request: ${e.request?.method} ${e.request?.url}');
  print('Response: ${e.response?.statusCode}');
}
```

### Automatic Retry

The new client automatically retries on:
* HTTP 429 (Rate Limit) — respects `Retry-After` header
* HTTP 5xx (Server Errors)
* Network/connection errors

Non-retryable errors (4xx except 429) fail immediately.

## 11) Advanced Configuration

```dart
import 'package:logging/logging.dart';

final client = ChromaClient(
  config: ChromaConfig(
    baseUrl: 'https://api.trychroma.com',
    tenant: 'my-tenant',
    database: 'my-database',
    authProvider: ApiKeyProvider('your-api-key'),
    timeout: Duration(minutes: 2),
    retryPolicy: RetryPolicy(
      maxRetries: 5,
      initialDelay: Duration(seconds: 1),
      maxDelay: Duration(minutes: 1),
      backoffMultiplier: 2.0,
      jitterFactor: 0.2,
    ),
    logLevel: Level.FINE,
  ),
);
```

### Disable Retries

```dart
final client = ChromaClient(
  config: ChromaConfig(
    retryPolicy: RetryPolicy.none,
  ),
);
```

## 12) New Features in v1.0.0

### Serverless Functions

```dart
// Attach a function to a collection
final response = await collection.attachFunction(
  name: 'processor',
  functionId: 'embed_processor',
  outputCollection: 'processed-data',
  params: {'key': 'value'},
);
print('Created: ${response.justCreated}');

// Get attached function details
final func = await collection.getFunction(name: 'processor');
print('Function: ${func.attachedFunction.name}');

// Detach function
await collection.detachFunction(
  name: 'processor',
  deleteOutput: false,
);
```

### Collection Forking (Low-Level)

```dart
// Fork an existing collection
final forked = await client.collections.fork(
  collectionId: 'original-collection-id',
  newName: 'forked-collection',
);
```

### CRN Support (Low-Level)

```dart
// Get collection by Chroma Resource Name
final collection = await client.collections.getByCrn(
  crn: 'crn:chroma:...',
);
```

### User Identity

```dart
// Get authenticated user identity
final identity = await client.auth.identity();
print('User: ${identity.userId}');
print('Tenant: ${identity.tenant}');
print('Databases: ${identity.databases}');
```

## Common Pitfalls & Notes

### Breaking Changes

* **Collection class renamed**: `Collection` → `ChromaCollection` (high-level wrapper)
* **Collection metadata access**: `collection.metadata` → `collection.metadata.metadata` (nested access for custom metadata)
* **Modify parameters renamed**: `name` → `newName`, `metadata` → `newMetadata`
* **Modify return type**: Now returns `Collection` instead of `void`
* **Health methods moved**: `client.heartbeat()` → `client.health.heartbeat()`
* **Health return types**: `heartbeat()` returns `HeartbeatResponse`, `version()` returns `VersionResponse` instead of primitives
* **List return type**: `listCollections()` returns `List<Collection>` instead of `List<CollectionType>`
* **Default includes changed**: `get()`, `peek()`, and `query()` no longer include embeddings by default

### New Requirements

* **Close the client**: Always call `client.close()` when done to release HTTP resources
* **Exception handling**: Replace `ChromaApiClientException` catches with specific exception types

### Behavior Changes

* **Retry is automatic**: 429 and 5xx errors are automatically retried with exponential backoff
* **Include.uris**: New enum value available for including URIs in responses

### Migration Checklist

1. ☐ Update client initialization to use `ChromaConfig`
2. ☐ Replace header-based auth with `ApiKeyProvider` or `BearerTokenProvider`
3. ☐ Update collection metadata access patterns (`collection.metadata.metadata`)
4. ☐ Update `modify()` calls to use `newName`/`newMetadata` parameters
5. ☐ Update `heartbeat()`/`version()` calls to use `client.health.*`
6. ☐ Update `reset()` calls to use `client.health.reset()`
7. ☐ Add explicit `Include.embeddings` if embeddings are needed in:
   - `get()` calls
   - `peek()` calls
   - `query()` calls
8. ☐ Update exception handling to use typed exceptions
9. ☐ Add `client.close()` calls in cleanup code

## FAQ

### How do I set custom HTTP headers?

Use the `defaultHeaders` parameter in `ChromaConfig`:

```dart
final client = ChromaClient(
  config: ChromaConfig(
    baseUrl: 'https://your-chroma-instance.com',
    defaultHeaders: {
      'X-Custom-Header': 'value',
      'X-Correlation-ID': 'request-123',
    },
    authProvider: ApiKeyProvider('your-api-key'),
  ),
);
```

Custom headers are merged with authentication headers and included in every request.

### Can I use both custom headers and authentication?

Yes, authentication headers from `authProvider` are combined with `defaultHeaders`:

```dart
final client = ChromaClient(
  config: ChromaConfig(
    baseUrl: 'https://api.trychroma.com',
    authProvider: ApiKeyProvider('your-api-key'), // Adds x-chroma-token header
    defaultHeaders: {
      'X-Request-Source': 'my-app', // Additional custom header
    },
  ),
);
```

## Getting Help

* Browse the [examples](example/)
* Check the [API docs](https://pub.dev/documentation/chromadb/latest/)
* Open an issue: [https://github.com/davidmigloz/ai_clients_dart/issues](https://github.com/davidmigloz/ai_clients_dart/issues)

---

For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).
