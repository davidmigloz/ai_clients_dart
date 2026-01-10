# ChromaDB Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![chromadb](https://img.shields.io/pub/v/chromadb.svg)](https://pub.dev/packages/chromadb)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[ChromaDB](https://www.trychroma.com/)** vector database API - the open-source embedding database for AI applications.

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Why choose this client?](#why-choose-this-client)
- [Quickstart](#quickstart)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Examples](#examples)
- [Migration Guide](#migration-guide)
- [API Coverage](#api-coverage)
- [Development](#development)
- [License](#license)

</details>

## Features

### Collections

- ✅ Create, get, list, update, delete collections
- ✅ Collection metadata management
- ✅ Collection count and fork operations

### Records

- ✅ Add records with embeddings, documents, metadata
- ✅ Get records by ID or with filters
- ✅ Update and upsert records
- ✅ Delete records by ID or with filters
- ✅ Count records in collection

### Vector Search

- ✅ Query by embedding similarity
- ✅ Metadata filtering (`where` clauses)
- ✅ Document filtering (`whereDocument` clauses)
- ✅ Configurable result count and includes
- ✅ Advanced hybrid search with grouping and ranking

### Embedding Functions

- ✅ Custom embedding function interface
- ✅ Auto-embedding on add/update/upsert/query
- ✅ Multimodal support (documents and images)
- ✅ Data loader for URI-based content

### Multi-Tenant

- ✅ Tenant management (create, get, update)
- ✅ Database management (list, create, get, delete)
- ✅ Default tenant/database configuration

### Serverless Functions

- ✅ Attach functions to process records
- ✅ Get attached function details
- ✅ Detach functions with output cleanup

### Health & Status

- ✅ Heartbeat, version, pre-flight checks
- ✅ Health check and reset endpoints
- ✅ User identity/authentication info

## Why choose this client?

- ✅ Type-safe with sealed classes
- ✅ Minimal dependencies (http, logging only)
- ✅ Works on all compilation targets (native, web, WASM)
- ✅ Interceptor-driven architecture
- ✅ Comprehensive error handling
- ✅ Automatic retry with exponential backoff
- ✅ High-level wrapper with auto-embedding

## Quickstart

```dart
import 'package:chromadb/chromadb.dart';

void main() async {
  final client = ChromaClient();

  // Create or get a collection
  final collection = await client.getOrCreateCollection(
    name: 'my-documents',
  );

  // Add documents with embeddings
  await collection.add(
    ids: ['doc1', 'doc2'],
    embeddings: [
      [0.1, 0.2, 0.3],
      [0.4, 0.5, 0.6],
    ],
    documents: ['Hello world', 'Goodbye world'],
  );

  // Query by embedding similarity
  final results = await collection.query(
    queryEmbeddings: [[0.1, 0.2, 0.3]],
    nResults: 5,
  );

  print(results.ids);
  print(results.documents);

  client.close();
}
```

## Installation

```yaml
dependencies:
  chromadb: ^0.1.0
```

## Configuration

<details>
<summary><b>Configuration Options</b></summary>

```dart
import 'package:chromadb/chromadb.dart';

final client = ChromaClient(
  config: ChromaConfig(
    baseUrl: 'http://localhost:8000',  // Default ChromaDB server
    tenant: 'default_tenant',
    database: 'default_database',
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration(seconds: 1),
    ),
  ),
);
```

**Authentication (for ChromaDB Cloud or secured instances):**

```dart
final client = ChromaClient(
  config: ChromaConfig(
    baseUrl: 'https://api.trychroma.com',
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
  ),
);

// Or use the convenience constructor
final client = ChromaClient.withApiKey(
  'YOUR_API_KEY',
  baseUrl: 'https://api.trychroma.com',
  tenant: 'YOUR_TENANT',
  database: 'YOUR_DATABASE',
);
```

</details>

## Usage

### Collections

<details>
<summary><b>Collection Management</b></summary>

```dart
import 'package:chromadb/chromadb.dart';

final client = ChromaClient();

// Create a new collection
final collection = await client.createCollection(
  name: 'my-docs',
  metadata: {'description': 'My document collection'},
);

// Get an existing collection
final existing = await client.getCollection(name: 'my-docs');

// Get or create (idempotent)
final col = await client.getOrCreateCollection(name: 'my-docs');

// List all collections
final collections = await client.listCollections();
for (final c in collections) {
  print('${c.name}: ${c.id}');
}

// Count collections
final count = await client.countCollections();

// Delete a collection
await client.deleteCollection(name: 'my-docs');

client.close();
```

</details>

### Adding Records

<details>
<summary><b>Adding Records Example</b></summary>

```dart
import 'package:chromadb/chromadb.dart';

final client = ChromaClient();
final collection = await client.getOrCreateCollection(name: 'docs');

// Add with embeddings
await collection.add(
  ids: ['id1', 'id2', 'id3'],
  embeddings: [
    [1.0, 2.0, 3.0],
    [4.0, 5.0, 6.0],
    [7.0, 8.0, 9.0],
  ],
  documents: ['Doc 1', 'Doc 2', 'Doc 3'],
  metadatas: [
    {'source': 'web'},
    {'source': 'pdf'},
    {'source': 'api'},
  ],
);

// Upsert (insert or update)
await collection.upsert(
  ids: ['id1', 'id4'],
  embeddings: [
    [1.1, 2.1, 3.1],
    [10.0, 11.0, 12.0],
  ],
  documents: ['Updated Doc 1', 'New Doc 4'],
);

client.close();
```

</details>

### Auto-Embedding

<details>
<summary><b>Auto-Embedding with Custom Function</b></summary>

```dart
import 'package:chromadb/chromadb.dart';

// Implement your embedding function
class MyEmbeddingFunction implements EmbeddingFunction {
  @override
  Future<List<List<double>>> generate(List<Embeddable> inputs) async {
    // Call your embedding API (OpenAI, Cohere, local model, etc.)
    return inputs.map((input) {
      return switch (input) {
        EmbeddableDocument(:final document) => _embedText(document),
        EmbeddableImage(:final image) => _embedImage(image),
      };
    }).toList();
  }

  List<double> _embedText(String text) {
    // Your embedding logic here
    return [0.1, 0.2, 0.3];
  }

  List<double> _embedImage(String base64) {
    // Your image embedding logic here
    return [0.4, 0.5, 0.6];
  }
}

void main() async {
  final client = ChromaClient();

  // Create collection with embedding function
  final collection = await client.getOrCreateCollection(
    name: 'auto-embed',
    embeddingFunction: MyEmbeddingFunction(),
  );

  // Add documents - embeddings generated automatically!
  await collection.add(
    ids: ['id1', 'id2'],
    documents: ['Hello world', 'Goodbye world'],
  );

  // Query by text - embedding generated automatically!
  final results = await collection.query(
    queryTexts: ['greeting'],
    nResults: 5,
  );

  client.close();
}
```

</details>

### Querying

<details>
<summary><b>Vector Search Example</b></summary>

```dart
import 'package:chromadb/chromadb.dart';

final client = ChromaClient();
final collection = await client.getOrCreateCollection(name: 'docs');

// Basic query
final results = await collection.query(
  queryEmbeddings: [[1.0, 2.0, 3.0]],
  nResults: 10,
);

print('IDs: ${results.ids}');
print('Documents: ${results.documents}');
print('Distances: ${results.distances}');

// Query with metadata filter
final filtered = await collection.query(
  queryEmbeddings: [[1.0, 2.0, 3.0]],
  nResults: 5,
  where: {
    'source': {r'$eq': 'web'},
  },
);

// Query with document filter
final docFiltered = await collection.query(
  queryEmbeddings: [[1.0, 2.0, 3.0]],
  nResults: 5,
  whereDocument: {
    r'$contains': 'important',
  },
);

// Control what's included in response
final withEmbeddings = await collection.query(
  queryEmbeddings: [[1.0, 2.0, 3.0]],
  nResults: 5,
  include: [
    Include.documents,
    Include.metadatas,
    Include.embeddings,
    Include.distances,
  ],
);

client.close();
```

</details>

### Metadata Filtering

<details>
<summary><b>Metadata Filtering Examples</b></summary>

```dart
import 'package:chromadb/chromadb.dart';

final client = ChromaClient();
final collection = await client.getOrCreateCollection(name: 'docs');

// Equality filter
final results = await collection.get(
  where: {'category': {r'$eq': 'tech'}},
);

// Comparison filters
final recent = await collection.get(
  where: {'year': {r'$gte': 2020}},
);

// In filter
final selected = await collection.get(
  where: {'status': {r'$in': ['active', 'pending']}},
);

// Logical AND
final combined = await collection.get(
  where: {
    r'$and': [
      {'category': {r'$eq': 'tech'}},
      {'year': {r'$gte': 2020}},
    ],
  },
);

// Logical OR
final either = await collection.get(
  where: {
    r'$or': [
      {'priority': {r'$eq': 'high'}},
      {'urgent': {r'$eq': true}},
    ],
  },
);

// Document content filter
final containing = await collection.get(
  whereDocument: {r'$contains': 'machine learning'},
);

client.close();
```

</details>

### Getting and Deleting Records

<details>
<summary><b>Get and Delete Examples</b></summary>

```dart
import 'package:chromadb/chromadb.dart';

final client = ChromaClient();
final collection = await client.getOrCreateCollection(name: 'docs');

// Get all records
final all = await collection.get();

// Get by IDs
final specific = await collection.get(
  ids: ['id1', 'id2'],
);

// Get with filter
final filtered = await collection.get(
  where: {'source': {r'$eq': 'web'}},
  limit: 10,
  offset: 0,
);

// Peek at first N records
final peek = await collection.peek(limit: 5);

// Count records
final count = await collection.count();

// Delete by IDs
await collection.delete(ids: ['id1', 'id2']);

// Delete by filter
await collection.delete(
  where: {'status': {r'$eq': 'archived'}},
);

client.close();
```

</details>

### Multi-Tenant

<details>
<summary><b>Multi-Tenant Example</b></summary>

```dart
import 'package:chromadb/chromadb.dart';

final client = ChromaClient(
  config: ChromaConfig(
    tenant: 'my-tenant',
    database: 'my-database',
  ),
);

// Create a tenant
await client.tenants.create(name: 'new-tenant');

// Get tenant info
final tenant = await client.tenants.getByName(name: 'new-tenant');
print('Tenant: ${tenant.name}');

// Create a database in tenant
await client.databases.create(
  name: 'new-database',
  tenant: 'new-tenant',
);

// List databases
final databases = await client.databases.list(tenant: 'new-tenant');
for (final db in databases) {
  print('Database: ${db.name}');
}

// Work with collections in specific tenant/database
final collection = await client.getOrCreateCollection(
  name: 'my-collection',
  tenant: 'new-tenant',
  database: 'new-database',
);

client.close();
```

</details>

### Health & Status

<details>
<summary><b>Health Check Example</b></summary>

```dart
import 'package:chromadb/chromadb.dart';

final client = ChromaClient();

// Heartbeat
final heartbeat = await client.health.heartbeat();
print('Server time: ${heartbeat.nanosecondHeartbeat}');

// Version
final version = await client.health.version();
print('Version: ${version.version}');

// Health check
final health = await client.health.healthcheck();
print('Status: $health');

// Pre-flight checks
final preflight = await client.health.preFlightChecks();
print('Pre-flight: $preflight');

// Get user identity (if authenticated)
final identity = await client.auth.identity();
print('User: ${identity.userId}');

client.close();
```

</details>

## Examples

See the [`example/`](example/) directory for comprehensive examples:

1. **[chromadb_example.dart](example/chromadb_example.dart)** - Basic usage
2. **[collections_example.dart](example/collections_example.dart)** - Collection management
3. **[records_example.dart](example/records_example.dart)** - Add, get, update, delete records
4. **[query_example.dart](example/query_example.dart)** - Similarity search
5. **[metadata_filtering_example.dart](example/metadata_filtering_example.dart)** - Where/whereDocument filters
6. **[embedding_function_example.dart](example/embedding_function_example.dart)** - Custom embedding function
7. **[multi_tenant_example.dart](example/multi_tenant_example.dart)** - Tenant and database management
8. **[error_handling_example.dart](example/error_handling_example.dart)** - Exception handling patterns
9. **[functions_example.dart](example/functions_example.dart)** - Serverless function operations
10. **[auth_example.dart](example/auth_example.dart)** - Authentication providers
11. **[health_example.dart](example/health_example.dart)** - Health and status checks
12. **[tenants_example.dart](example/tenants_example.dart)** - Tenant management
13. **[databases_example.dart](example/databases_example.dart)** - Database management

## Migration Guide

If you're migrating from the old `chromadb` client (v0.x), see the [Migration Guide](MIGRATION.md) for detailed instructions on:

- Client initialization changes
- Collection metadata access patterns
- Include enum updates
- Exception handling improvements
- New features like Search API, Functions, and multi-tenant management

## API Coverage

This client implements the **ChromaDB v2 REST API**:

### Health Resource (`client.health`)

- **heartbeat** - Server heartbeat (`GET /api/v2/heartbeat`)
- **version** - Server version (`GET /api/v2/version`)
- **preFlightChecks** - Pre-flight checks (`GET /api/v2/pre-flight-checks`)
- **healthcheck** - Health check (`GET /api/v2/healthcheck`)
- **reset** - Reset database (`POST /api/v2/reset`)

### Auth Resource (`client.auth`)

- **identity** - Get user identity (`GET /api/v2/auth/identity`)

### Tenants Resource (`client.tenants`)

- **create** - Create tenant (`POST /api/v2/tenants`)
- **getByName** - Get tenant (`GET /api/v2/tenants/{name}`)
- **update** - Update tenant (`PATCH /api/v2/tenants/{name}`)

### Databases Resource (`client.databases`)

- **list** - List databases (`GET /api/v2/tenants/{tenant}/databases`)
- **create** - Create database (`POST /api/v2/tenants/{tenant}/databases`)
- **getByName** - Get database (`GET /api/v2/tenants/{tenant}/databases/{name}`)
- **deleteByName** - Delete database (`DELETE /api/v2/tenants/{tenant}/databases/{name}`)

### Collections Resource (`client.collections`)

- **list** - List collections (`GET /api/v2/.../collections`)
- **create** - Create collection (`POST /api/v2/.../collections`)
- **getByName** - Get collection by name (`GET /api/v2/.../collections/{name}`)
- **getByCrn** - Get by CRN (`GET /api/v2/collections/{crn}`)
- **update** - Update collection (`PUT /api/v2/.../collections/{id}`)
- **deleteByName** - Delete collection by name (`DELETE /api/v2/.../collections/{name}`)
- **count** - Count collections (`GET /api/v2/.../collections_count`)
- **fork** - Fork collection (`POST /api/v2/.../collections/{id}/fork`)

### Records Resource (`client.records`)

- **add** - Add records (`POST /api/v2/.../collections/{id}/add`)
- **update** - Update records (`POST /api/v2/.../collections/{id}/update`)
- **upsert** - Upsert records (`POST /api/v2/.../collections/{id}/upsert`)
- **getRecords** - Get records (`POST /api/v2/.../collections/{id}/get`)
- **query** - Query by similarity (`POST /api/v2/.../collections/{id}/query`)
- **search** - Hybrid search with filters/grouping (`POST /api/v2/.../collections/{id}/search`)
- **deleteRecords** - Delete records (`POST /api/v2/.../collections/{id}/delete`)
- **count** - Count records (`GET /api/v2/.../collections/{id}/count`)

### Functions Resource (`client.functions`)

- **attach** - Attach function (`POST /api/v2/.../collections/{id}/functions/attach`)
- **getFunction** - Get attached function (`GET /api/v2/.../collections/{id}/functions/{name}`)
- **detach** - Detach function (`POST /api/v2/.../collections/{id}/attached_functions/{name}/detach`)

### High-Level Wrapper (`ChromaCollection`)

- Automatic embedding generation from documents/images/URIs
- Convenient query methods accepting text instead of embeddings
- Hybrid search with filtering, grouping, and pagination
- Input validation and error handling

## Development

This package is part of the [ai_clients_dart](https://github.com/davidmigloz/ai_clients_dart) monorepo.

```bash
# Install dependencies
melos bootstrap

# Run tests
melos run test

# Format code
dart format .

# Analyze code
dart analyze
```

## License

`chromadb` is licensed under the [MIT License](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE).
