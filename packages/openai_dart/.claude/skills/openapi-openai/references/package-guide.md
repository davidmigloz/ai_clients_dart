# openai_dart Package Guide

## Package Configuration

| Setting | Value |
|---------|-------|
| Package Name | `openai_dart` |
| API | OpenAI API |
| API Key Env Var | `OPENAI_API_KEY` |
| Barrel File | `lib/openai_dart.dart` |
| Specs Directory | `specs/` |

## Directory Structure

```
lib/src/
├── client/                  # Client configuration and core
│   ├── openai_client.dart   # Main client class
│   ├── config.dart          # Configuration options
│   └── request_builder.dart # HTTP request building
├── auth/                    # Authentication
│   └── auth_provider.dart   # API key and org auth
├── interceptors/            # Request/response pipeline
│   ├── interceptor.dart     # Base interceptor
│   ├── auth_interceptor.dart
│   ├── error_interceptor.dart
│   └── logging_interceptor.dart
├── errors/                  # Exception handling
│   └── exceptions.dart      # Custom exceptions
├── resources/               # API resources
│   ├── base_resource.dart
│   ├── chat_resource.dart
│   ├── embeddings_resource.dart
│   ├── audio_resource.dart
│   ├── images_resource.dart
│   ├── files_resource.dart
│   ├── uploads_resource.dart
│   ├── batches_resource.dart
│   ├── models_resource.dart
│   ├── moderations_resource.dart
│   ├── assistants_resource.dart
│   ├── threads_resource.dart
│   ├── messages_resource.dart
│   ├── runs_resource.dart
│   ├── run_steps_resource.dart
│   ├── vector_stores_resource.dart
│   ├── fine_tuning_resource.dart
│   └── realtime_resource.dart
├── models/                  # Domain models
│   ├── chat/
│   ├── completions/
│   ├── embeddings/
│   ├── audio/
│   ├── images/
│   ├── files/
│   ├── uploads/
│   ├── batches/
│   ├── models/
│   ├── moderations/
│   ├── assistants/
│   ├── threads/
│   ├── messages/
│   ├── runs/
│   ├── run_steps/
│   ├── vector_stores/
│   ├── fine_tuning/
│   ├── realtime/
│   ├── streaming/
│   ├── tools/
│   └── common/
├── extensions/              # Helper extensions
├── realtime/                # Real-time API implementation
│   ├── realtime_client.dart
│   ├── realtime_api.dart
│   └── event_handler.dart
└── utils/                   # Utilities
    ├── streaming_parser.dart
    └── json_helpers.dart
```

## File Path Patterns

| Type | Pattern |
|------|---------|
| Models | `lib/src/models/{category}/{name}.dart` |
| Resources | `lib/src/resources/{name}_resource.dart` |
| Unit Tests | `test/unit/models/{category}/{name}_test.dart` |
| Integration Tests | `test/integration/{name}_integration_test.dart` |
| Examples | `example/{name}_example.dart` |

## Naming Conventions

| Entity | Convention | Example |
|--------|------------|---------|
| Request models | `{Operation}Request` | `ChatCompletionCreateRequest` |
| Response models | `{Entity}` or `{Entity}Response` | `ChatCompletion`, `ImagesResponse` |
| List responses | `{Entity}ListResponse` | `AssistantListResponse` |
| Delete responses | `{Entity}DeleteResponse` | `FileDeleteResponse` |
| Enums | PascalCase | `FinishReason`, `MessageRole` |
| Resources | `{Entity}Resource` | `ChatResource`, `FilesResource` |

## Resource Hierarchy

```dart
client
├── chat
│   └── completions
│       ├── create()
│       └── createStream()
├── completions
│   ├── create()
│   └── createStream()
├── embeddings
│   └── create()
├── audio
│   ├── speech()
│   ├── transcriptions()
│   └── translations()
├── images
│   ├── generate()
│   ├── edit()
│   └── createVariation()
├── files
│   ├── list()
│   ├── create()
│   ├── retrieve()
│   ├── delete()
│   └── content()
├── uploads
│   ├── create()
│   ├── addPart()
│   ├── complete()
│   └── cancel()
├── batches
│   ├── list()
│   ├── create()
│   ├── retrieve()
│   ├── cancel()
│   └── results()
├── models
│   ├── list()
│   ├── retrieve()
│   └── delete()
├── moderations
│   └── create()
├── fineTuning
│   └── jobs
│       ├── list()
│       ├── create()
│       ├── retrieve()
│       ├── cancel()
│       ├── listEvents()
│       └── checkpoints
│           └── list()
├── beta
│   ├── assistants
│   │   ├── list()
│   │   ├── create()
│   │   ├── retrieve()
│   │   ├── update()
│   │   └── delete()
│   ├── threads
│   │   ├── create()
│   │   ├── retrieve()
│   │   ├── update()
│   │   ├── delete()
│   │   ├── createAndRun()
│   │   ├── createAndRunStream()
│   │   ├── messages
│   │   │   ├── list()
│   │   │   ├── create()
│   │   │   ├── retrieve()
│   │   │   ├── update()
│   │   │   └── delete()
│   │   └── runs
│   │       ├── list()
│   │       ├── create()
│   │       ├── createStream()
│   │       ├── retrieve()
│   │       ├── update()
│   │       ├── cancel()
│   │       ├── submitToolOutputs()
│   │       ├── submitToolOutputsStream()
│   │       └── steps
│   │           ├── list()
│   │           └── retrieve()
│   └── vectorStores
│       ├── list()
│       ├── create()
│       ├── retrieve()
│       ├── update()
│       ├── delete()
│       ├── files
│       │   ├── list()
│       │   ├── create()
│       │   ├── retrieve()
│       │   └── delete()
│       └── fileBatches
│           ├── create()
│           ├── retrieve()
│           ├── cancel()
│           └── listFiles()
└── realtime
    └── connect()
```
