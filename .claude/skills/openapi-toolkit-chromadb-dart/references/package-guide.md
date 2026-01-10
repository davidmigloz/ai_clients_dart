# chromadb Package Guide

## Package Configuration

| Setting | Value |
|---------|-------|
| Package Name | `chromadb` |
| API | ChromaDB Vector Database |
| API Version | v2 |
| Base URL | `http://localhost:8000` (default) |
| Auth Header | `x-chroma-token` |
| Barrel File | `lib/chromadb.dart` |
| Specs Directory | `specs/` |

## Directory Structure

```
lib/src/
├── auth/               # Authentication providers
├── client/             # Client configuration
├── embeddings/         # Embedding function interface
├── errors/             # Exception hierarchy
├── interceptors/       # Request interceptors
├── loaders/            # Data loader interface
├── models/
│   ├── auth/           # Auth identity
│   ├── collections/    # Collection models
│   ├── databases/      # Database models
│   ├── metadata/       # Health, version, errors
│   ├── records/        # Add/get/query/delete
│   └── tenants/        # Tenant models
├── resources/          # API resources
├── utils/              # Utilities
└── wrappers/           # High-level wrappers
```

## File Path Patterns

| Type | Pattern |
|------|---------|
| Models | `lib/src/models/{category}/{name}.dart` |
| Resources | `lib/src/resources/{name}_resource.dart` |
| Unit Tests | `test/unit/models/{category}/{name}_test.dart` |
| Integration Tests | `test/integration/{name}_test.dart` |
| Examples | `example/{name}_example.dart` |

## API Hierarchy

ChromaDB v2 uses a hierarchical tenant → database → collection structure:

```
/api/v2/tenants/{tenant}/databases/{database}/collections/{collection_id}/...
```

The client uses default tenant (`default_tenant`) and database (`default_database`) for simple DX.
