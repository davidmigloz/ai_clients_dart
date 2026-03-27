# OpenResponses Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![open_responses](https://img.shields.io/pub/v/open_responses.svg)](https://pub.dev/packages/open_responses)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[OpenResponses specification](https://www.openresponses.org/)** with streaming, tool calling, structured output, and multi-turn responses across multiple providers. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

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

### Core response workflows

- Single typed responses endpoint for text, multimodal input, and reasoning models
- SSE streaming with incremental text and event handling
- Tool calling, MCP tools, and structured outputs with JSON schema
- Multi-turn conversations through `previousResponseId`

### Provider portability

- Works with OpenAI-compatible services, local runtimes, and custom gateways
- Pure Dart client surface for backends, CLIs, and Flutter apps
- Interceptors, retries, and typed metadata across providers

### Supported providers

`open_responses` works with any service that implements the OpenResponses or OpenAI-compatible response shape.

| Provider | Base URL | Auth | Typical use case |
| --- | --- | --- | --- |
| OpenAI | `https://api.openai.com/v1` | Bearer token | Hosted production models |
| Ollama | `http://localhost:11434/v1` | None by default | Local models and offline development |
| Hugging Face Spaces | Custom Space URL | Bearer token | Hosted open models |
| OpenRouter | `https://openrouter.ai/api/v1` | Bearer token | Multi-provider routing |
| [Vercel AI Gateway](https://vercel.com/docs/ai-gateway/sdks-and-apis/openresponses) | `https://ai-gateway.vercel.sh/v1` | Bearer token | Edge-deployed AI gateway |
| [Databricks](https://docs.databricks.com/aws/en/machine-learning/model-serving/score-model-serving-endpoints) | `https://<host>.databricks.com/serving-endpoints` | Bearer token | Enterprise model serving |
| [vLLM](https://docs.vllm.ai/en/latest/examples/online_serving/openai_responses_client/) | `http://localhost:8000/v1` | None by default | High-throughput local inference |
| LM Studio | `http://localhost:1234/v1` | None by default | Desktop local inference |

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- One request format works across providers, reducing migration cost and vendor lock-in.

## Quickstart

```yaml
dependencies:
  open_responses: ^0.1.5
```

```dart
import 'package:open_responses/open_responses.dart';

Future<void> main() async {
  final client = OpenResponsesClient(
    config: OpenResponsesConfig(
      baseUrl: 'https://api.openai.com/v1',
      authProvider: BearerTokenProvider('YOUR_API_KEY'),
    ),
  );

  try {
    final response = await client.responses.create(
      CreateResponseRequest.text(
        model: 'gpt-4o',
        input: 'What is the capital of France?',
      ),
    );

    print(response.outputText);
  } finally {
    client.close();
  }
}
```

## Configuration

<details>
<summary><b>Configure provider URLs, auth, and retries</b></summary>

Use `OpenResponsesClient.fromEnvironment()` for OpenAI-style defaults, or provide `OpenResponsesConfig` directly when you target another provider. This keeps provider switching explicit and easy to test.

```dart
import 'package:open_responses/open_responses.dart';

Future<void> main() async {
  final client = OpenResponsesClient(
    config: OpenResponsesConfig(
      baseUrl: 'http://localhost:11434/v1',
      timeout: const Duration(minutes: 5),
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

- `OPENAI_API_KEY`
- `OPENAI_BASE_URL`

Use explicit configuration on web builds where runtime environment variables are not available.

</details>

## Usage

### How do I create a response?

<details>
<summary><b>Show example</b></summary>

The `CreateResponseRequest.text(...)` helper keeps simple requests short, while the full request type remains available for advanced configurations. `response.outputText` is the fastest path for text-first integrations.

```dart
import 'package:open_responses/open_responses.dart';

Future<void> main() async {
  final client = OpenResponsesClient(
    config: OpenResponsesConfig(
      baseUrl: 'https://api.openai.com/v1',
      authProvider: BearerTokenProvider('YOUR_API_KEY'),
    ),
  );

  try {
    final response = await client.responses.create(
      CreateResponseRequest.text(
        model: 'gpt-4o',
        input: 'Summarize why provider portability matters.',
      ),
    );

    print(response.outputText);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/create_response_example.dart)

</details>

### How do I stream events?

<details>
<summary><b>Show example</b></summary>

Streaming works through a runner helper or manual event iteration. That makes it easy to bind partial text updates to a CLI, server-sent event bridge, or Flutter state notifier.

```dart
import 'dart:io';

import 'package:open_responses/open_responses.dart';

Future<void> main() async {
  final client = OpenResponsesClient.fromEnvironment();

  try {
    final runner = client.responses.stream(
      CreateResponseRequest.text(
        model: 'gpt-4o',
        input: 'Write a short note about Flutter desktop.',
      ),
    )..onTextDelta(stdout.write);

    await runner.finalResponse;
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

Tool calling is declared in the request, which keeps the provider-neutral contract intact. This is useful when you want one agent loop that can run against hosted or local providers.

```dart
import 'package:open_responses/open_responses.dart';

Future<void> main() async {
  final client = OpenResponsesClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o',
        input: const ResponseTextInput('What is the weather in Berlin?'),
        tools: [
          FunctionTool(
            name: 'get_weather',
            description: 'Get the current weather',
            parameters: const {
              'type': 'object',
              'properties': {
                'location': {'type': 'string'},
              },
              'required': ['location'],
            },
          ),
        ],
      ),
    );

    print(response.functionCalls.length);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/tool_calling_example.dart)

</details>

### How do I keep a multi-turn conversation?

<details>
<summary><b>Show example</b></summary>

OpenResponses keeps follow-up turns provider-neutral through `previousResponseId`. That is the main portability feature when you need stateful assistants without rewriting request history handling for each backend.

```dart
import 'package:open_responses/open_responses.dart';

Future<void> main() async {
  final client = OpenResponsesClient.fromEnvironment();

  try {
    final first = await client.responses.create(
      CreateResponseRequest.text(
        model: 'gpt-4o',
        input: 'My name is Alice.',
      ),
    );

    final second = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o',
        input: const ResponseTextInput('What is my name?'),
        previousResponseId: first.id,
      ),
    );

    print(second.outputText);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/multi_turn_example.dart)

</details>

### How do I request structured output?

<details>
<summary><b>Show example</b></summary>

Structured output uses the same response surface and adds a JSON schema under `text.format`. That keeps extraction workflows consistent even when you swap providers behind the same Dart code.

```dart
import 'package:open_responses/open_responses.dart';

Future<void> main() async {
  final client = OpenResponsesClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o',
        input: const ResponseTextInput('List three fruits and their colors.'),
        text: TextConfig(
          format: JsonSchemaFormat(
            name: 'fruits',
            schema: const {
              'type': 'object',
              'properties': {
                'fruits': {
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'name': {'type': 'string'},
                      'color': {'type': 'string'},
                    },
                    'required': ['name', 'color'],
                  },
                },
              },
              'required': ['fruits'],
            },
          ),
        ),
      ),
    );

    print(response.outputText);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/structured_output_example.dart)

</details>

### How do I switch providers without changing my app code?

<details>
<summary><b>Show example</b></summary>

The provider switch happens in `OpenResponsesConfig`, not in the request body. That keeps your higher-level application logic independent from the underlying deployment target.

```dart
import 'package:open_responses/open_responses.dart';

Future<void> main() async {
  final client = OpenResponsesClient(
    config: const OpenResponsesConfig(
      baseUrl: 'http://localhost:11434/v1',
    ),
  );

  try {
    final response = await client.responses.create(
      CreateResponseRequest.text(
        model: 'llama3.2',
        input: 'Explain what hot reload means.',
      ),
    );

    print(response.outputText);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/provider_switch_example.dart)

</details>

## Error Handling

<details>
<summary><b>Handle provider errors, retries, and validation failures</b></summary>

`open_responses` throws typed exceptions so provider differences do not collapse into raw HTTP status handling. Catch `ApiException` first, then fall back to `OpenResponsesException` for transport or client-side failures.

```dart
import 'dart:io';

import 'package:open_responses/open_responses.dart';

Future<void> main() async {
  final client = OpenResponsesClient.fromEnvironment();

  try {
    await client.responses.create(
      CreateResponseRequest.text(
        model: 'gpt-4o',
        input: 'Ping',
      ),
    );
  } on RateLimitException catch (error) {
    stderr.writeln('Retry after: ${error.retryAfter}');
  } on ApiException catch (error) {
    stderr.writeln('Provider API error ${error.statusCode}: ${error.message}');
  } on OpenResponsesException catch (error) {
    stderr.writeln('OpenResponses client error: $error');
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
| [`create_response_example.dart`](example/create_response_example.dart) | Basic response creation |
| [`streaming_example.dart`](example/streaming_example.dart) | Streaming events |
| [`tool_calling_example.dart`](example/tool_calling_example.dart) | Tool calling |
| [`multi_turn_example.dart`](example/multi_turn_example.dart) | Multi-turn conversations |
| [`structured_output_example.dart`](example/structured_output_example.dart) | Structured output with JSON schema |
| [`provider_switch_example.dart`](example/provider_switch_example.dart) | Switching providers |
| [`mcp_tools_example.dart`](example/mcp_tools_example.dart) | MCP tool integration |
| [`reasoning_example.dart`](example/reasoning_example.dart) | Reasoning models |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |

## API Coverage

| API | Status |
|-----|--------|
| Responses | ✅ Full |

## Official Documentation

- [API reference](https://pub.dev/documentation/open_responses/latest/)
- [OpenResponses specification](https://www.openresponses.org/)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by the OpenResponses project.
