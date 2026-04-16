# Anthropic Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![anthropic_sdk_dart](https://img.shields.io/pub/v/anthropic_sdk_dart.svg)](https://pub.dev/packages/anthropic_sdk_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[Anthropic API](https://docs.anthropic.com/en/api)** to build with Claude — messages, streaming, tool calling, extended thinking, multimodal prompts, files, skills, and batches. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

> [!TIP]
> Coding agents: start with [llms.txt](./llms.txt). It links to the package docs, examples, and optional references in a compact format.

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Quickstart](#quickstart)
- [Why choose this client?](#why-choose-this-client)
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

### Generation and streaming

- Messages with typed inputs, system prompts, and multi-turn history
- SSE streaming with cancelation and token counting
- Extended thinking and adaptive thinking controls

### Tools and multimodal

- Custom tool calling with strict schemas and tool choice controls
- Computer use, web search, code execution, advisor, and MCP tool integration
- Vision and document inputs with citations

### Operational APIs

- Message batches for large-scale offline processing
- Model discovery, files (beta), and skills (beta)
- Managed agents with sessions, vaults, and streaming events (beta)
- User profiles with trust-grant tracking and enrollment URLs (beta)

## Quickstart

```yaml
dependencies:
  anthropic_sdk_dart: ^2.0.0
```

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 1024,
        messages: [InputMessage.user('What is the capital of France?')],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and cancellation built into the client.
- Follows Anthropic resource naming closely, so official docs translate directly into Dart code.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Configuration

<details>
<summary><b>Configure auth, retries, and custom Anthropic endpoints</b></summary>

Use `AnthropicClient.fromEnvironment()` when `ANTHROPIC_API_KEY` is available. Switch to `AnthropicConfig` when you need a proxy, custom timeout, or a non-default retry policy.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient(
    config: AnthropicConfig(
      authProvider: ApiKeyProvider('YOUR_API_KEY'),
      baseUrl: 'https://api.anthropic.com',
      timeout: const Duration(minutes: 10),
      retryPolicy: RetryPolicy(
        maxRetries: 3,
        initialDelay: Duration(seconds: 1),
      ),
    ),
  );

  client.close();
}
```

Environment variables:

- `ANTHROPIC_API_KEY`
- `ANTHROPIC_BASE_URL`

Use explicit configuration on web builds where runtime environment variables are not available.

</details>

## Usage

### How do I send a Claude message?

<details>
<summary><b>Show example</b></summary>

`client.messages.create(...)` is the main Anthropic entry point. The response already exposes `response.text`, so you can skip manual content block traversal for common text outputs.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 512,
        messages: [InputMessage.user('Summarize why Flutter is useful.')],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/messages_example.dart)

</details>

### How do I stream Claude responses?

<details>
<summary><b>Show example</b></summary>

Streaming uses SSE and returns typed events. This keeps token-by-token rendering easy in Dart terminals, servers, and Flutter UIs.

```dart
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final stream = client.messages.createStream(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 256,
        messages: [InputMessage.user('Count from 1 to 5 slowly.')],
      ),
    );

    await for (final event in stream) {
      if (event is ContentBlockDeltaEvent && event.delta is TextDelta) {
        stdout.write((event.delta as TextDelta).text);
      }
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/streaming_example.dart)

</details>

### How do I use tool calling?

<details>
<summary><b>Show example</b></summary>

Anthropic tool calling supports custom schemas plus built-in tools. Keep the first request focused on the tool declaration, then feed the tool result back as another message turn.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 512,
        messages: [InputMessage.user('What is the weather in Madrid?')],
        tools: [
          ToolDefinition.custom(
            Tool(
              name: 'get_weather',
              description: 'Get the current weather for a location',
              inputSchema: const InputSchema(
                properties: {
                  'location': {'type': 'string'},
                },
                required: ['location'],
                extra: {'additionalProperties': false},
              ),
            ),
          ),
        ],
      ),
    );

    print(response.stopReason);
  } finally {
    client.close();
  }
}
```

Built-in tools like computer use, web search, code execution, and MCP are also available:

```dart
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-6',
    maxTokens: 1024,
    messages: [InputMessage.user('Find the latest Dart release notes')],
    tools: [ToolDefinition.builtIn(BuiltInTool.webSearch())],
  ),
);
```

→ [Full example](example/tool_calling_example.dart)

</details>

### How do I enable extended thinking?

<details>
<summary><b>Show example</b></summary>

Extended thinking is configured on the request, not through a separate client. That makes it easy to mix regular and higher-reasoning calls in the same Dart application.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 1024,
        thinking: const ThinkingEnabled(budgetTokens: 512),
        messages: [InputMessage.user('Explain the tradeoffs of isolates in Dart.')],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/thinking_example.dart)

</details>

### How do I send images or documents?

<details>
<summary><b>Show example</b></summary>

Anthropic accepts images and documents as typed content blocks. Use this surface when you need OCR, PDF analysis, citations, or multimodal reasoning in the same Claude request.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 512,
        messages: [
          InputMessage.userBlocks([
            InputContentBlock.text('Describe this image.'),
            InputContentBlock.image(ImageSource.url('https://example.com/image.png')),
          ]),
        ],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/vision_example.dart)

</details>

### How do I count tokens?

<details>
<summary><b>Show example</b></summary>

Use `client.messages.countTokens(...)` to estimate prompt cost and context usage before you send a full Claude request. This is useful when you need budget checks, truncation guards, or preflight validation in Dart services.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final count = await client.messages.countTokens(
      TokenCountRequest.fromMessageCreateRequest(
        MessageCreateRequest(
          model: 'claude-sonnet-4-6',
          maxTokens: 256,
          messages: [InputMessage.user('How many tokens is this message?')],
        ),
      ),
    );

    print(count.inputTokens);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/token_counting_example.dart)

</details>

### How do I run message batches?

<details>
<summary><b>Show example</b></summary>

Use `client.messages.batches` for offline or queue-driven workloads where Anthropic can process many requests asynchronously. This is the right surface for backfills, evaluations, and other large batch jobs that do not need an immediate interactive response.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final batch = await client.messages.batches.create(
      MessageBatchCreateRequest(
        requests: [
          BatchRequestItem(
            customId: 'greeting-1',
            params: MessageCreateRequest(
              model: 'claude-sonnet-4-6',
              maxTokens: 50,
              messages: [InputMessage.user('Say hello!')],
            ),
          ),
        ],
      ),
    );

    print(batch.id);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/message_batches_example.dart)

</details>

### How do I list available models?

<details>
<summary><b>Show example</b></summary>

Use `client.models.list()` to discover available Claude models and inspect their metadata.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.models.list();

    for (final model in response.data) {
      print('${model.id} — ${model.displayName}');
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/models_example.dart)

</details>

### How do I manage files?

<details>
<summary><b>Show example</b></summary>

Use `client.files` to upload, list, and delete files. This beta API lets you attach stored files to messages without re-uploading each time.

```dart
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final uploaded = await client.files.uploadBytes(
      bytes: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
      fileName: 'hello.txt',
      mimeType: 'text/plain',
    );

    print('Uploaded: ${uploaded.id}');

    final files = await client.files.list(limit: 10);
    print('Total files: ${files.data.length}');

    await client.files.deleteFile(fileId: uploaded.id);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/files_example.dart)

</details>

### How do I manage skills?

<details>
<summary><b>Show example</b></summary>

Use `client.skills` to list reusable skills. The full API also lets you create, version, and delete skills, packaging prompts and tools into versioned units that Claude can invoke.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.skills.list(limit: 10);

    for (final skill in response.data) {
      print('${skill.id}: ${skill.displayTitle ?? "untitled"}');
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/skills_example.dart)

</details>

### How do I use managed agents?

<details>
<summary><b>Show example</b></summary>

Use `client.agents`, `client.sessions`, and `client.vaults` for the Managed Agents beta API. Create an agent configuration, start sessions to interact with Claude, and use vaults to securely store credentials.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    // Create an agent
    final agent = await client.agents.create(
      const CreateAgentParams(
        name: 'My Agent',
        model: ModelParamsId(id: 'claude-sonnet-4-6'),
      ),
    );

    // Start a session and send a message
    final session = await client.sessions.create(
      CreateSessionParams(
        agent: AgentParamsId(id: agent.id),
        environmentId: 'default',
      ),
    );

    final eventsResource = client.sessions.events(session.id);
    await eventsResource.send(
      const SendSessionEventsParams(
        events: [
          UserMessageEventParams(
            content: [{'type': 'text', 'text': 'Hello, agent!'}],
          ),
        ],
      ),
    );

    final events = await eventsResource.list();
    for (final event in events.data) {
      print('Event: ${event.runtimeType}');
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/managed_agents_example.dart)

</details>

## Error Handling

<details>
<summary><b>Handle retries, validation failures, and request aborts</b></summary>

`anthropic_sdk_dart` throws typed exceptions so retry logic and validation handling stay explicit. Catch `ApiException` and its subclasses first, then fall back to `AnthropicException` for other transport or parsing failures.

```dart
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 64,
        messages: [InputMessage.user('Ping')],
      ),
    );
  } on RateLimitException catch (error) {
    stderr.writeln('Retry after: ${error.retryAfter}');
  } on ApiException catch (error) {
    stderr.writeln('Anthropic API error ${error.statusCode}: ${error.message}');
  } on AnthropicException catch (error) {
    stderr.writeln('Anthropic client error: $error');
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
| [`messages_example.dart`](example/messages_example.dart) | Basic message creation |
| [`streaming_example.dart`](example/streaming_example.dart) | Streaming responses |
| [`tool_calling_example.dart`](example/tool_calling_example.dart) | Tool calling with schemas |
| [`web_search_example.dart`](example/web_search_example.dart) | Web search tool |
| [`advisor_example.dart`](example/advisor_example.dart) | Advisor tool (beta) |
| [`computer_use_example.dart`](example/computer_use_example.dart) | Computer use tool |
| [`thinking_example.dart`](example/thinking_example.dart) | Extended thinking |
| [`vision_example.dart`](example/vision_example.dart) | Image and document inputs |
| [`document_example.dart`](example/document_example.dart) | Document inputs with citations |
| [`token_counting_example.dart`](example/token_counting_example.dart) | Token counting |
| [`message_batches_example.dart`](example/message_batches_example.dart) | Batch processing |
| [`files_example.dart`](example/files_example.dart) | File management (beta) |
| [`skills_example.dart`](example/skills_example.dart) | Skills management (beta) |
| [`mcp_example.dart`](example/mcp_example.dart) | MCP tool integration |
| [`managed_agents_example.dart`](example/managed_agents_example.dart) | Managed agents: agents, sessions, vaults (beta) |
| [`user_profiles_example.dart`](example/user_profiles_example.dart) | User profiles and enrollment URLs (beta) |
| [`models_example.dart`](example/models_example.dart) | Model listing |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`anthropic_sdk_dart_example.dart`](example/anthropic_sdk_dart_example.dart) | Quick-start overview |

## API Coverage

| API | Status |
|-----|--------|
| Messages | ✅ Full |
| Message Batches | ✅ Full |
| Models | ✅ Full |
| Files (Beta) | ✅ Full |
| Skills (Beta) | ✅ Full |
| Agents (Beta) | ✅ Full |
| Sessions (Beta) | ✅ Full |
| Vaults (Beta) | ✅ Full |
| User Profiles (Beta) | ✅ Full |

## Official Documentation

- [API reference](https://pub.dev/documentation/anthropic_sdk_dart/latest/)
- [Anthropic API docs](https://docs.anthropic.com/en/api)
- [Anthropic Python SDK](https://github.com/anthropics/anthropic-sdk-python)
- [Anthropic TypeScript SDK](https://github.com/anthropics/anthropic-sdk-typescript)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by Anthropic.
