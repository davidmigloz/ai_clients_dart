# ChromaDB Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![chromadb](https://img.shields.io/pub/v/chromadb.svg)](https://pub.dev/packages/chromadb)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for **[ChromaDB](https://www.trychroma.com/)** with collections, vector search, multi-tenant storage, embeddings, and RAG pipelines. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

> [!TIP]
> Coding agents: start with [llms.txt](./llms.txt). It links to the package docs, examples, and optional references in a compact format.

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Why choose this client?](#why-choose-this-client)
- [Quickstart](#quickstart)
- [Configuration](#configuration)
- [Usage](#usage)
- [Error Handling](#error-handling)
- [Examples](#examples)
- [API Coverage](#api-coverage)
- [Official Documentation](#official-documentation)
- [Sponsor](#sponsor)
- [License](#license)

</details>

## Features

### Collection and record management

- Create, list, update, fork, and delete collections
- Add, update, upsert, get, count, and delete records
- Attach documents, embeddings, metadata, and record filters

### Search and operational tooling

- Similarity queries with `where` and `whereDocument` filtering
- High-level `ChromaCollection` wrapper with auto-embedding
- Embedding functions, tenant, database, auth, and health resources for managed deployments

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Retries, interceptors, and error handling built into the client.
- Includes both low-level resources and a high-level `ChromaCollection` wrapper for auto-embedding workflows.

## Quickstart

```yaml
dependencies:
  chromadb: ^1.1.0
```

```dart
import 'package:chromadb/chromadb.dart';

Future<void> main() async {
  final client = ChromaClient();

  try {
    final collection = await client.getOrCreateCollection(name: 'my-documents');

    await collection.add(
      ids: ['doc-1'],
      embeddings: [
        [0.1, 0.2, 0.3],
      ],
      documents: ['Hello from ChromaDB'],
    );

    final results = await collection.query(
      queryEmbeddings: [
        [0.1, 0.2, 0.3],
      ],
      nResults: 1,
    );

    print(results.ids);
  } finally {
    client.close();
  }
}
```

## Configuration

<details>
<summary><b>Configure hosts, tenants, databases, and auth</b></summary>

Use the default constructor for local development, or pass a `ChromaConfig` when you need Chroma Cloud credentials, custom tenants, or non-default databases.

```dart
import 'package:chromadb/chromadb.dart';

Future<void> main() async {
  final client = ChromaClient(
    config: ChromaConfig(
      baseUrl: 'http://localhost:8000',
      tenant: 'default_tenant',
      database: 'default_database',
      retryPolicy: RetryPolicy(
        maxRetries: 3,
        initialDelay: Duration(seconds: 1),
      ),
    ),
  );

  client.close();
}
```

Use `ApiKeyProvider` or `BasicAuthProvider` for secured or hosted deployments.

</details>

## Usage

### How do I manage collections?

<details>
<summary><b>Show example</b></summary>

Collections are the main organizational unit in ChromaDB. The client provides direct helpers for create, get, list, count, and delete operations without dropping down to raw HTTP calls.

```dart
import 'package:chromadb/chromadb.dart';

Future<void> main() async {
  final client = ChromaClient();

  try {
    final collection = await client.createCollection(
      name: 'my-docs',
      metadata: {'source': 'docs'},
    );

    print(collection.name);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/collections_example.dart)

</details>

### How do I add records?

<details>
<summary><b>Show example</b></summary>

Use `add`, `update`, or `upsert` depending on whether you want strict inserts or idempotent writes. Typed parameters make it clear which vectors, documents, and metadata travel together.

```dart
import 'package:chromadb/chromadb.dart';

Future<void> main() async {
  final client = ChromaClient();

  try {
    final collection = await client.getOrCreateCollection(name: 'docs');

    await collection.add(
      ids: ['id-1', 'id-2'],
      embeddings: [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
      ],
      documents: ['Doc 1', 'Doc 2'],
      metadatas: [
        {'source': 'web'},
        {'source': 'pdf'},
      ],
    );
  } finally {
    client.close();
  }
}
```

→ [Full example](example/records_example.dart)

</details>

### How do I auto-embed data?

<details>
<summary><b>Show example</b></summary>

The high-level `ChromaCollection` wrapper can call an embedding function automatically, which removes a manual vectorization step from your Dart RAG pipeline.

```dart
import 'package:chromadb/chromadb.dart';

Future<void> main() async {
  final client = ChromaClient();

  try {
    final collection = await client.getOrCreateCollection(
      name: 'auto-embedded',
      embeddingFunction: MyEmbeddingFunction(),
    );

    await collection.add(
      ids: ['doc-1'],
      documents: ['Dart works well for CLIs and servers.'],
    );
  } finally {
    client.close();
  }
}

class MyEmbeddingFunction implements EmbeddingFunction {
  @override
  Future<List<List<double>>> generate(List<Embeddable> inputs) async {
    return List.generate(inputs.length, (_) => [0.1, 0.2, 0.3]);
  }
}
```

→ [Full example](example/embedding_function_example.dart)

</details>

### How do I query similar records?

<details>
<summary><b>Show example</b></summary>

Queries accept vector inputs, result counts, and include flags, which makes semantic search straightforward from Dart. This is the main building block for retrieval and RAG layers.

```dart
import 'package:chromadb/chromadb.dart';

Future<void> main() async {
  final client = ChromaClient();

  try {
    final collection = await client.getOrCreateCollection(name: 'docs');
    final results = await collection.query(
      queryEmbeddings: [
        [0.1, 0.2, 0.3],
      ],
      nResults: 3,
    );

    print(results.ids);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/query_example.dart)

</details>

### How do I filter by metadata?

<details>
<summary><b>Show example</b></summary>

Metadata filtering is part of the search request, which keeps retrieval logic on the server side instead of post-processing in the app. This is useful for tenant scoping, document classes, and content freshness filters.

```dart
import 'package:chromadb/chromadb.dart';

Future<void> main() async {
  final client = ChromaClient();

  try {
    final collection = await client.getOrCreateCollection(name: 'docs');
    final results = await collection.query(
      queryEmbeddings: [
        [0.1, 0.2, 0.3],
      ],
      nResults: 5,
      where: {'source': 'web'},
    );

    print(results.ids);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/metadata_filtering_example.dart)

</details>

### How do I work with tenants and databases?

<details>
<summary><b>Show example</b></summary>

Multi-tenant operations are exposed directly on the client, which is useful for SaaS control planes and managed ChromaDB installations. You do not need separate admin bindings for these workflows.

```dart
import 'package:chromadb/chromadb.dart';

Future<void> main() async {
  final client = ChromaClient();

  try {
    final tenant = await client.tenants.getByName(name: 'default_tenant');
    print(tenant.name);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/multi_tenant_example.dart)

</details>

### How do I check server health?

<details>
<summary><b>Show example</b></summary>

Health endpoints are useful for deployment checks and CI smoke tests. Keeping them in the same client helps when you bundle ChromaDB into local tooling or managed dashboards.

```dart
import 'package:chromadb/chromadb.dart';

Future<void> main() async {
  final client = ChromaClient();

  try {
    final heartbeat = await client.health.heartbeat();
    print(heartbeat.nanosecondHeartbeat);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/health_example.dart)

</details>

## Error Handling

<details>
<summary><b>Handle API failures, validation issues, and connection problems</b></summary>

`chromadb` throws typed exceptions so retrieval code can distinguish between auth errors, server errors, validation problems, and timeouts. Catch `ApiException` first for HTTP failures, then fall back to `ChromaException` for other client-side errors.

```dart
import 'dart:io';

import 'package:chromadb/chromadb.dart';

Future<void> main() async {
  final client = ChromaClient();

  try {
    await client.health.version();
  } on ApiException catch (error) {
    stderr.writeln('ChromaDB API error ${error.statusCode}: ${error.message}');
  } on ChromaException catch (error) {
    stderr.writeln('ChromaDB client error: $error');
  } finally {
    client.close();
  }
}
```

→ [Full example](example/error_handling_example.dart)

</details>

## Examples

See the [example/](example/) directory for complete examples:

| Example | Description |
|---------|-------------|
| [`collections_example.dart`](example/collections_example.dart) | Collection management |
| [`records_example.dart`](example/records_example.dart) | Record operations |
| [`query_example.dart`](example/query_example.dart) | Similarity queries |
| [`metadata_filtering_example.dart`](example/metadata_filtering_example.dart) | Metadata filtering |
| [`embedding_function_example.dart`](example/embedding_function_example.dart) | Auto-embedding workflows |
| [`functions_example.dart`](example/functions_example.dart) | Embedding functions |
| [`multi_tenant_example.dart`](example/multi_tenant_example.dart) | Multi-tenant deployments |
| [`databases_example.dart`](example/databases_example.dart) | Database management |
| [`auth_example.dart`](example/auth_example.dart) | Authentication |
| [`health_example.dart`](example/health_example.dart) | Server health checks |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`chromadb_example.dart`](example/chromadb_example.dart) | Quick-start overview |
| [`tenants_example.dart`](example/tenants_example.dart) | Tenant management |

## API Coverage

| API | Status |
|-----|--------|
| Collections | ✅ Full |
| Records | ✅ Full |
| Functions | ✅ Full |
| Databases | ✅ Full |
| Tenants | ✅ Full |
| Auth | ✅ Full |
| Health | ✅ Full |

## Official Documentation

- [API reference](https://pub.dev/documentation/chromadb/latest/)
- [ChromaDB docs](https://docs.trychroma.com/)
- [ChromaDB Python SDK](https://github.com/chroma-core/chroma)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by Chroma.
