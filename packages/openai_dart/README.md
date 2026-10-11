# OpenAI Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![openai_dart](https://img.shields.io/pub/v/openai_dart.svg)](https://pub.dev/packages/openai_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart and Flutter client for the **[OpenAI API](https://platform.openai.com/docs/api-reference)**. Generate text with the Responses API, stream output, call tools, and work with images, audio, and embeddings.

> [!TIP]
> Coding agents: start with [llms.txt](./llms.txt) for documentation and examples.

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Why choose this client?](#why-choose-this-client)
- [Quickstart](#quickstart)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Responses API](#responses-api)
  - [Other model APIs](#other-model-apis)
  - [Images, audio, and video](#images-audio-and-video)
  - [Files, batches, and model evaluation](#files-batches-and-model-evaluation)
  - [Webhooks and safety](#webhooks-and-safety)
  - [Advanced Responses workflows](#advanced-responses-workflows)
  - [Live and Realtime](#live-and-realtime)
  - [Agents and Vaults](#agents-and-vaults)
- [Error Handling](#error-handling)
- [Examples](#examples)
- [API Coverage](#api-coverage)
- [Official Documentation](#official-documentation)
- [Sponsor](#sponsor)
- [License](#license)

</details>

## Features

- Responses API: text generation, streaming, conversations, structured output, vision, and tool calling.
- Chat Completions, Decisions, embeddings, and image, audio, and video generation.
- Built-in web search, file search, Code Interpreter, computer use, and custom tools.
- Files, batches, fine-tuning, evals, signed webhooks, and safety resources.
- Realtime and Live sessions, persistent Responses WebSockets, Agents, and Vaults.
- Pure Dart support for Dart and Flutter on mobile, desktop, web, and servers.

## Why choose this client?

- Use typed Dart requests and responses with a resource API similar to the official SDKs.
- Use the same client in Dart backends and Flutter apps, without a Flutter dependency.
- Get streaming helpers, configurable retries, interceptors, and typed exceptions.
- Rely on strict [semver](https://semver.org/) and [migration guides](MIGRATION.md) when upgrading.

## Quickstart

Requires Dart 3.12 or later and works with Dart and Flutter. Set `OPENAI_API_KEY` in your environment before running this native Dart example. For upgrades, see the [Migration Guide](MIGRATION.md).

```yaml
dependencies:
  openai_dart: ^11.0.0
```

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('What is the capital of France?'),
      ),
    );
    print(response.outputText);
  } finally {
    client.close();
  }
}
```

Keep API keys on trusted infrastructure. For a distributed Flutter or web app, route requests through your backend.

## Configuration

<details>
<summary><b>API keys, environment variables, and client lifetime</b></summary>

`OpenAIClient.fromEnvironment()` reads `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `OPENAI_ORG_ID`, and `OPENAI_PROJECT_ID`. It also reads optional `OPENAI_WEBHOOK_SECRET` for local verification. Environment loading is for native Dart; use explicit configuration when environment variables are unavailable.

`OpenAIClient.withApiKey('YOUR_API_KEY')` creates a client from a supplied key. Reuse a client for multiple requests and call `close()` when finished; an injected HTTP client remains caller-owned.

</details>

<details>
<summary><b>Timeouts, retries, and custom endpoints</b></summary>

Use `OpenAIConfig` for a proxy, timeout, retry policy, or organization/project selection.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient(
    config: OpenAIConfig(
      authProvider: ApiKeyProvider('YOUR_API_KEY'),
      baseUrl: 'https://api.openai.com/v1',
      timeout: const Duration(minutes: 10),
      connectTimeout: const Duration(seconds: 30),
      retryPolicy: const RetryPolicy(maxRetries: 3),
      // organization: 'org-...',
      // project: 'proj-...',
    ),
  );

  try {
    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('Hello!'),
      ),
    );
    print(response.outputText);
  } finally {
    client.close();
  }
}
```

For Azure, set the deployment URL and use `AzureApiKeyProvider`. See [Error Handling](#error-handling) for retry boundaries.

</details>

<details>
<summary><b>Imports for Realtime and deprecated Assistants APIs</b></summary>

The main import is `package:openai_dart/openai_dart.dart`. Realtime uses `package:openai_dart/openai_dart_realtime.dart`; deprecated Assistants resources use `package:openai_dart/openai_dart_assistants.dart`.

</details>

## Usage

Start with the Responses API for a model call and its output. Expand a topic for a short example or a link to a complete workflow.

### Responses API

<a id="how-do-i-create-a-response"></a>
<details>
<summary><b>How do I create a response?</b></summary>

Call `client.responses.create` with a model and input. Read the generated text with `response.outputText` and token usage with `response.usage`.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('What is the capital of France?'),
      ),
    );
    print(response.outputText);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/responses_example.dart)

</details>

<a id="how-do-i-stream-responses"></a>
<details>
<summary><b>How do I stream responses?</b></summary>

Use `client.responses.createStream` and `textDeltas()` to display text as it arrives. Use the typed events or `accumulate()` when you also need tool calls and response metadata; `collectText()` consumes the stream into one string.

```dart
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final stream = client.responses.createStream(
      const CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('Tell me a short story.'),
      ),
    );
    await for (final text in stream.textDeltas()) {
      stdout.write(text);
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/responses_example.dart)

</details>

<a id="how-do-i-continue-a-conversation"></a>
<details>
<summary><b>How do I continue a conversation?</b></summary>

Pass the previous response ID with the next input. For separately managed conversation history, use `client.conversations`.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final first = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('My name is Alice.'),
      ),
    );
    final next = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-5.5',
        previousResponseId: first.id,
        input: const ResponseInput.text('What is my name?'),
      ),
    );
    print(next.outputText);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/responses_example.dart) · [Conversations example](example/conversations_example.dart)

</details>

<a id="how-do-i-get-structured-json-output"></a>
<details>
<summary><b>How do I get structured JSON output?</b></summary>

Set `TextConfig.format` to `JsonSchemaFormat` to request output matching your schema. Check for refusals and incomplete responses before decoding the text.

```dart
import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('Extract the name from: Alice is a doctor.'),
        text: TextConfig(
          format: JsonSchemaFormat(
            name: 'person',
            strict: true,
            schema: {
              'type': 'object',
              'properties': {
                'name': {'type': 'string'},
              },
              'required': ['name'],
              'additionalProperties': false,
            },
          ),
        ),
      ),
    );
    if (response.status == ResponseStatus.completed &&
        response.outputText.isNotEmpty) {
      print(jsonDecode(response.outputText));
    }
  } finally {
    client.close();
  }
}
```

→ [Responses example](example/responses_example.dart)

</details>

<a id="how-do-i-use-tool-calling"></a>
<details>
<summary><b>How do I use tool calling?</b></summary>

Define a function with JSON Schema parameters. Your application executes the requested function and returns its result with the original `callId`; the client does not execute tools for you.

```dart
import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-5.5',
        input: const ResponseInput.text(
          'Use the add tool to calculate 123 + 456.',
        ),
        tools: [
          ResponseTool.function(
            name: 'add',
            description: 'Add two numbers',
            parameters: {
              'type': 'object',
              'properties': {
                'a': {'type': 'number'},
                'b': {'type': 'number'},
              },
              'required': ['a', 'b'],
              'additionalProperties': false,
            },
          ),
        ],
      ),
    );
    final results = <Item>[];
    for (final call in response.functionCalls) {
      if (call.name != 'add') throw StateError('Unknown tool: ${call.name}');
      final args = jsonDecode(call.arguments) as Map<String, dynamic>;
      final sum = (args['a'] as num) + (args['b'] as num);
      results.add(
        FunctionCallOutputItem.string(
          callId: call.callId,
          output: sum.toString(),
        ),
      );
    }
    if (results.isNotEmpty) {
      final finalResponse = await client.responses.create(
        CreateResponseRequest(
          model: 'gpt-5.5',
          previousResponseId: response.id,
          input: ResponseInput.items(results),
        ),
      );
      print(finalResponse.outputText);
    } else {
      print(response.outputText);
    }
  } finally {
    client.close();
  }
}
```

→ [Responses example](example/responses_example.dart) · [Async tool results](example/async_tools_example.dart)

</details>

<a id="how-do-i-analyze-images"></a>
<details>
<summary><b>How do I analyze images?</b></summary>

Include text and image content in a Responses input message. Images can be supplied as a public URL, a data URL, or an uploaded file ID.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.items([
          MessageItem(
            role: MessageRole.user,
            content: [
              InputContent.text('What is in this image?'),
              InputContent.imageUrl('https://example.com/image.jpg'),
            ],
          ),
        ]),
      ),
    );
    print(response.outputText);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/responses_example.dart) · [Chat vision example](example/vision_example.dart)

</details>

<a id="how-do-i-search-the-web"></a>
<details>
<summary><b>How do I search the web?</b></summary>

Add `ResponseTool.webSearch()` to let the model search for current information. The full examples also show location hints, domain filters, sources, and image results.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-5.5',
        input: const ResponseInput.text(
          'What are the latest developments in AI?',
        ),
        tools: [ResponseTool.webSearch()],
      ),
    );
    print(response.outputText);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/web_search_example.dart) · [Search controls](example/web_search_controls_example.dart)

</details>

<a id="how-do-i-count-input-tokens"></a>
<details>
<summary><b>How do I count input tokens?</b></summary>

Use `client.responses.inputTokens.count` to estimate input size before generating a response.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final count = await client.responses.inputTokens.count(
      model: 'gpt-5.5',
      input: const ResponseInput.text('Hello, how are you?'),
    );
    print(count.inputTokens);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/input_tokens_example.dart)

</details>

### Other model APIs

<a id="how-do-i-use-chat-completions"></a>
<details>
<summary><b>How do I use chat completions?</b></summary>

Use `client.chat.completions.create` for applications built around Chat messages. Read the first choice with `response.text`; new applications can start with the Responses examples above.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-5.5',
        messages: [
          ChatMessage.system('You are a helpful assistant.'),
          ChatMessage.user('What is the capital of France?'),
        ],
      ),
    );
    print(response.text);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/chat_example.dart)

</details>

<a id="how-do-i-stream-chat-completions"></a>
<details>
<summary><b>How do I stream chat completions?</b></summary>

Use `client.chat.completions.createStream` with `textDeltas()` or `ChatStreamAccumulator`. Set `StreamOptions(includeUsage: true)` for final usage; the usage-only chunk can have no choices.

→ [Full example](example/streaming_example.dart)

</details>

<a id="how-do-i-classify-or-score-shared-input"></a>
<details>
<summary><b>How do I classify or score shared input?</b></summary>

Use `client.decisions.create` for typed predicate, choice, and score questions. Answers can include refusals; input supports text and HTTP(S) or data URL images.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final decision = await client.decisions.create(
      DecisionRequest(
        model: 'gpt-6-luna',
        input: DecisionInput.text('The screen arrived broken.'),
        questions: [
          DecisionQuestion.predicate(
            name: 'damaged',
            instructions: 'Does the customer report a damaged item?',
          ),
        ],
      ),
    );
    for (final answer in decision.answers) {
      if (answer case PredicateDecisionAnswer(:final probability)) {
        print('Damage probability: $probability');
      } else if (answer is RefusalDecisionAnswer) {
        print('The question was refused.');
      }
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/decisions_example.dart) · [Image input example](example/decision_image_urls_example.dart)

</details>

<a id="how-do-i-create-embeddings"></a>
<details>
<summary><b>How do I create embeddings?</b></summary>

Use `client.embeddings.create` to generate text vectors. Set `dimensions` when you need a smaller vector.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.embeddings.create(
      EmbeddingRequest(
        model: 'text-embedding-3-small',
        input: EmbeddingInput.text('Hello, world!'),
        dimensions: 256,
      ),
    );
    print(response.firstEmbedding);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/embeddings_example.dart)

</details>

### Images, audio, and video

<a id="how-do-i-generate-and-edit-images-with-gpt-image-25"></a>
<details>
<summary><b>How do I generate and edit images with GPT Image 2.5?</b></summary>

Use `client.images.generate` or `edit` with an explicit model. Use `editJson` for URL, data URL, or file-ID inputs; generation and editing also have streaming variants.

```dart
import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.images.generate(
      const ImageGenerationRequest(
        model: ImageModels.gptImage25Flare,
        prompt: 'A cute robot holding a flower',
        size: ImageSize.size1024x1024,
      ),
    );
    final image = response.data.first.b64Json;
    if (image != null) {
      await File('robot.png').writeAsBytes(base64Decode(image));
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/images_example.dart) · [Model selection](example/image_model_selection_example.dart)

</details>

<a id="how-do-i-use-audio"></a>
<details>
<summary><b>How do I use audio?</b></summary>

Use `client.audio.speech.create` for speech bytes, `createByteStream` for audio chunks, and `createStream` for typed speech events. Transcription and translation are available through `client.audio.transcriptions` and `client.audio.translations`.

```dart
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final bytes = await client.audio.speech.create(
      const SpeechRequest(
        model: 'gpt-4o-mini-tts',
        input: 'Hello! How are you today?',
        voice: SpeechVoice.marin,
        responseFormat: SpeechResponseFormat.mp3,
      ),
    );
    await File('speech.mp3').writeAsBytes(bytes);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/audio_example.dart) · [Streaming speech](example/speech_streaming_example.dart) · [Transcription and translation](example/existing_audio_example.dart)

</details>

<a id="how-do-i-generate-videos"></a>
<details>
<summary><b>How do I generate videos?</b></summary>

Use `client.videos.create` to start a video job, poll `retrieve` until completion, then download with `retrieveContent`. The example also covers editing and extension.

→ [Full example](example/videos_example.dart)

</details>

<a id="how-do-i-generate-replay-and-stream-chat-audio"></a>
<details>
<summary><b>How do I generate, replay, and stream Chat audio?</b></summary>

Request Chat audio through `client.chat.completions` and choose a built-in or custom voice. Replay the returned audio ID in later messages; accumulate streamed audio before decoding it.

→ [Full example](example/chat_audio_example.dart)

</details>

<a id="how-do-i-manage-voice-consent-recordings"></a>
<details>
<summary><b>How do I manage voice consent recordings?</b></summary>

Use `client.audio.voiceConsents` to upload and manage consent recordings before creating custom voices.

→ [Full example](example/voice_consents_example.dart)

</details>

<a id="how-do-i-create-a-custom-voice"></a>
<details>
<summary><b>How do I create a custom voice?</b></summary>

Use `client.audio.voices` with a consent ID and an audio sample. Pass the returned voice ID to speech requests as a custom voice reference.

→ [Full example](example/voices_example.dart)

</details>

### Files, batches, and model evaluation

<a id="how-do-i-manage-files"></a>
<details>
<summary><b>How do I manage files?</b></summary>

Use `client.files` to upload, list, retrieve, and delete files. Use `client.uploads` for large multipart uploads.

```dart
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final file = await client.files.upload(
      bytes: await File('training.jsonl').readAsBytes(),
      filename: 'training.jsonl',
      purpose: FilePurpose.fineTune,
    );
    print(file.id);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/files_example.dart) · [Large uploads](example/uploads_example.dart)

</details>

<a id="how-do-i-use-batch-processing"></a>
<details>
<summary><b>How do I use batch processing?</b></summary>

Use `client.batches.create` to submit a JSONL input file for asynchronous processing. Retrieve the batch status and output file when it completes.

→ [Full example](example/batches_example.dart)

</details>

<a id="how-do-i-fine-tune-a-model"></a>
<details>
<summary><b>How do I fine-tune a model?</b></summary>

Create a job through `client.fineTuning.jobs` with a training file ID, then retrieve its status and resulting model name.

→ [Full example](example/fine_tuning_example.dart)

</details>

<a id="how-do-i-evaluate-models"></a>
<details>
<summary><b>How do I evaluate models?</b></summary>

Use `client.evals` to define grading criteria and run evaluations against test data.

→ [Full example](example/evals_example.dart)

</details>

### Webhooks and safety

<a id="how-do-i-receive-signed-webhooks"></a>
<details>
<summary><b>How do I receive signed webhooks?</b></summary>

Verify the original request bytes and headers with `WebhookVerifier.unwrapBytes` before reading an event. `WebhookVerifier.fromEnvironment()` reads `OPENAI_WEBHOOK_SECRET` without an API key; handle invalid signatures, acknowledge receipt, and deduplicate deliveries in your receiver.

→ [Full example](example/webhooks_example.dart)

</details>

<a id="how-do-i-manage-webhook-endpoints"></a>
<details>
<summary><b>How do I manage webhook endpoints?</b></summary>

Use `client.webhooks` to create, list, update, delete, rotate, and test project endpoints, and `client.webhooks.eventTypes.list()` to discover webhook event types. Save signing secrets returned by creation or rotation securely; `test` sends a real delivery.

→ [Full example](example/webhook_endpoints_example.dart)

</details>

<a id="how-do-i-moderate-content"></a>
<details>
<summary><b>How do I moderate content?</b></summary>

Use `client.moderations.create` to check text against content policies.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final result = await client.moderations.create(
      ModerationRequest(input: ModerationInput.text('Check this text')),
    );
    print(result.results.first.flagged);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/moderation_example.dart)

</details>

<a id="how-do-i-investigate-verified-safety-notifications"></a>
<details>
<summary><b>How do I investigate verified safety notifications?</b></summary>

Use `client.safety.alerts` for project alerts and `client.safety.cases` for organization cases. Retrieve IDs from verified notices using credentials for the correct scope.

→ [Full example](example/safety_example.dart) · [Full example](example/safety_explanations_example.dart)

</details>

<a id="how-do-i-inspect-monitoring-failures"></a>
<details>
<summary><b>How do I inspect monitoring failures?</b></summary>

Inspect typed monitoring details on HTTP exceptions, failed Responses, and WebSocket errors. These details describe the failure; they do not automatically resume work or execute suggested actions.

→ [Full example](example/monitoring_errors_example.dart)

</details>

<a id="how-do-i-check-content-provenance"></a>
<details>
<summary><b>How do I check content provenance?</b></summary>

Use `client.contentProvenanceChecks.create` to inspect an image or audio file for C2PA and SynthID signals. Dispatch on the returned result type.

→ [Full example](example/content_provenance_checks_example.dart)

</details>

### Advanced Responses workflows

<a id="how-do-i-use-persistent-responses-websockets"></a>
<details>
<summary><b>How do I use persistent Responses WebSockets?</b></summary>

Use `client.responses.connect()` for a persistent connection with named response lanes. Continue with returned response IDs and await connection cleanup; browser connections require an authenticated backend proxy because WebSockets cannot send API-key headers.

```dart
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final connection = await client.responses.connect();
    try {
      connection.create(
        const CreateResponseRequest(
          model: 'gpt-5.5',
          input: ResponseInput.text('Tell me a short joke.'),
        ),
      );
      await for (final message in connection.events) {
        if (message case ResponsesStreamEvent(
          event: OutputTextDeltaEvent(:final delta),
        )) {
          stdout.write(delta);
        } else if (message case ResponsesStreamEvent(
          event: ResponseCompletedEvent(),
        )) {
          break;
        } else if (message case ResponsesStreamEvent(
          event: ResponseFailedEvent() || ResponseIncompleteEvent(),
        )) {
          throw StateError('The response did not complete.');
        } else if (message is ResponsesErrorEvent) {
          throw StateError('Response failed: ${message.error.code}');
        }
      }
    } finally {
      await connection.close();
      await connection.done;
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/responses_websocket_example.dart)

</details>

<a id="how-do-i-steer-a-running-responses-request"></a>
<details>
<summary><b>How do I steer a running Responses request?</b></summary>

Use the steering controls to submit input during an active response. Respect pending continuation state so accepted input and completed tool results are not sent twice.

→ [Full example](example/responses_steering_example.dart)

</details>

<a id="how-do-i-recover-a-responses-websocket"></a>
<details>
<summary><b>How do I recover a Responses WebSocket?</b></summary>

Opt into connection recovery and handle queued or unsent requests explicitly. Recovery reconnects the transport without automatically replaying frames already sent to the server.

→ [Full example](example/responses_recovery_example.dart)

</details>

<a id="how-do-i-use-async-function-and-custom-tools"></a>
<details>
<summary><b>How do I use async function and custom tools?</b></summary>

Declare async tools and return results with their original call IDs. Continue from the latest response ID when concurrent jobs complete.

→ [Full example](example/async_tools_example.dart)

</details>

<a id="how-do-i-return-client-discovered-tools"></a>
<details>
<summary><b>How do I return client-discovered tools?</b></summary>

Return complete discovered function or custom-tool definitions with the original tool-search call ID. The example shows discovery and continuation without executing the tools.

→ [Full example](example/tool_search_example.dart)

</details>

<a id="how-do-i-filter-web-search-and-inspect-image-results"></a>
<details>
<summary><b>How do I filter web search and inspect image results?</b></summary>

Configure domain and content-type filters on `ResponseTool.webSearch` and request sources or image results. Search output is available through both ordinary Responses and streamed events.

→ [Full example](example/web_search_controls_example.dart)

</details>

<a id="how-do-i-change-reasoning-effort-during-a-conversation"></a>
<details>
<summary><b>How do I change reasoning effort during a conversation?</b></summary>

Insert a `ConfigurationUpdateItem` before the next user input to change subsequent reasoning effort while preserving the request-level baseline. The full example covers replay and the supported compaction boundaries.

→ [Full example](example/configuration_updates_example.dart)

</details>

<a id="how-do-i-prewarm-the-prompt-cache-and-inspect-diagnostics"></a>
<details>
<summary><b>How do I prewarm the prompt cache and inspect diagnostics?</b></summary>

Use `ResponsePromptCacheOptionsParam` for Responses prewarming, TTL, and comparison diagnostics. Chat uses the narrower `PromptCacheOptionsParam`; returned usage counters report actual cached tokens.

→ [Full example](example/prompt_cache_example.dart)

</details>

<a id="how-do-i-configure-an-execution-container"></a>
<details>
<summary><b>How do I configure an execution container?</b></summary>

Use `client.containers` to create a container with a memory tier and network policy, then pass its ID to Code Interpreter. See the [migration guide](MIGRATION.md#19-container-configuration-corrections) for v11 configuration changes.

→ [Full example](example/containers_example.dart)

</details>

<a id="how-do-i-configure-hosted-shell-and-return-local-results"></a>
<details>
<summary><b>How do I configure hosted shell and return local results?</b></summary>

Configure a hosted shell through Responses tools, or execute local commands in your application and return their outputs. The client does not run local shell commands automatically.

→ [Full example](example/shell_tools_example.dart)

</details>

<a id="how-do-i-observe-compaction-progress"></a>
<details>
<summary><b>How do I observe compaction progress?</b></summary>

Watch typed compaction events in the Responses stream. Progress events are nonterminal; preserve the complete returned compacted output for continuation.

→ [Full example](example/compaction_progress_example.dart)

</details>

<a id="how-do-i-select-and-inspect-an-access-program"></a>
<details>
<summary><b>How do I select and inspect an access program?</b></summary>

Set access-program options explicitly when your account is eligible, and inspect the effective program returned by the service. Selection does not provision access or change account eligibility.

→ [Full example](example/access_programs_example.dart)

</details>

<a id="how-do-i-inject-multi-agent-tool-results"></a>
<details>
<summary><b>How do I inject multi-agent tool results?</b></summary>

Use beta multi-agent injection to return tool results to the owning agent. Track acknowledgments and uncommitted results explicitly rather than rerunning tools after uncertain delivery.

→ [Full example](example/responses_injection_example.dart)

</details>

### Live and Realtime

<a id="how-do-i-use-the-realtime-api"></a>
<details>
<summary><b>How do I use the Realtime API?</b></summary>

Import `openai_dart_realtime.dart` for Realtime WebSocket and WebRTC sessions with audio events. Use `client.realtimeSessions` for ephemeral client secrets and WebRTC calls; your application owns capture, playback, and peer-connection setup.

```dart
import 'dart:io';

import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final session = await client.realtime.connect(model: 'gpt-realtime-2');
    try {
      session.sendUserMessage('Say hello.', createResponse: false);
      session.createResponse(outputModalities: ['text']);
      await for (final event in session.events) {
        if (event is realtime.ResponseTextDeltaEvent) {
          stdout.write(event.delta);
        } else if (event is realtime.ResponseDoneEvent) {
          break;
        } else if (event is realtime.ErrorEvent) {
          throw StateError(event.error.message);
        }
      }
    } finally {
      await session.close();
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/realtime_example.dart)

</details>

<a id="how-do-i-signal-live-sessions-and-control-calls"></a>
<details>
<summary><b>How do I signal Live sessions and control calls?</b></summary>

Use `client.live` for WebRTC/SIP signaling, explicit call controls, and recordings. The full example also handles verified incoming-call notices.

→ [Full example](example/live_http_example.dart)

</details>

<a id="how-do-i-use-primary-and-sideband-live-websockets"></a>
<details>
<summary><b>How do I use primary and sideband Live WebSockets?</b></summary>

Connect primary or sideband Live WebSockets to observe typed events and control a session. Your application handles media and tool delegation, and awaits graceful finalization.

→ [Full example](example/live_websocket_example.dart)

</details>

<a id="how-do-i-fork-stored-live-sessions-and-group-captions"></a>
<details>
<summary><b>How do I fork stored Live sessions and group captions?</b></summary>

Fork a stored Live session and use transcript helpers to group captions. The example covers inherited state and caller-owned channel cleanup.

→ [Full example](example/live_workflows_example.dart)

</details>

### Agents and Vaults

<a id="how-do-i-save-and-update-an-agent-configuration"></a>
<details>
<summary><b>How do I save and update an agent configuration?</b></summary>

Use `client.agents` to save reusable model, instruction, and tool configuration. Creating an agent stores configuration without starting a session; updates replace supplied fields, while `clearX` flags reset nullable fields.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final agent = await client.agents.create(
      CreateAgentRequest(model: 'gpt-5.5', name: 'Research assistant'),
    );
    try {
      final updated = await client.agents.update(
        agent.id,
        UpdateAgentRequest(name: 'Updated research assistant'),
      );
      print(updated.name);
    } finally {
      await client.agents.delete(agent.id);
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/saved_agents_example.dart)

</details>

<a id="durable-agent-sessions"></a>
<details>
<summary><b>Durable agent sessions</b></summary>

Use `client.agents.sessions` to create sessions, observe events, and submit function results or cancellation. Cancelling a local event subscription stops observation only; cancel durable work explicitly through session inputs.

→ [Full example](example/agent_sessions_example.dart)

</details>

<a id="session-history-and-traces"></a>
<details>
<summary><b>Session history and traces</b></summary>

Read session items, turns, and published OTLP traces through `client.agents.sessions`. Trace reads require organization export settings and permissions; a page contains only traces published when it is read.

→ [Full example](example/agent_session_history_example.dart)

</details>

<a id="agent-session-subagents"></a>
<details>
<summary><b>Agent session subagents</b></summary>

Inspect child state and item/turn history through `client.agents.sessions.subagents`. These read-only methods do not create, resume, or interrupt child agents.

→ [Full example](example/agent_subagents_example.dart)

</details>

<a id="agent-environments-and-templates"></a>
<details>
<summary><b>Agent environments and templates</b></summary>

Use `client.agents.environments` and `.templates` to save hosted setup and prewarm eligible environments. Environment and session lifetimes are independent; deleting a template does not stop a session.

→ [Full example](example/agent_environments_example.dart)

</details>

<a id="agent-environment-files-and-published-artifacts"></a>
<details>
<summary><b>Agent environment files and published artifacts</b></summary>

Use `client.agents.environments.files` for live workspace files and `client.agents.sessions.artifacts` for published outputs. Download artifacts to retain them before deleting a session; use `downloadStream` for incremental bytes.

→ [Full example](example/agent_files_artifacts_example.dart)

</details>

<a id="vaults-and-write-only-credentials"></a>
<details>
<summary><b>Vaults and write-only credentials</b></summary>

Use `client.vaults` and `.credentials` to store or rotate OAuth, bearer, and hosted environment secrets. Credentials are write-only; deleting a stored credential does not revoke its provider token or cancel running work.

→ [Full example](example/vaults_example.dart)

</details>

## Error Handling

<details>
<summary><b>Handle API errors and retries</b></summary>

Catch typed exceptions such as `RateLimitException`, or `ApiException` for HTTP failures. `OpenAIException` also covers client and transport failures.

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('Hello!'),
      ),
    );
  } on RateLimitException catch (error) {
    print('Rate limit: ${error.message}; retry hint: ${error.retryAfter}');
  } on ApiException catch (error) {
    print('HTTP ${error.statusCode}: ${error.message}');
  } on OpenAIException catch (error) {
    print('Client error: ${error.message}');
  } finally {
    client.close();
  }
}
```

Cloneable requests retry transient 429 responses; 5xx, timeout, and connection retries require an idempotent method. Billing/quota errors require action, and POST 5xx, multipart requests, and streams are not automatically replayed. Server retry hints are exposed as `retryAfter`; `maxRetries: 0` disables automatic retries.

→ [Full example](example/error_handling_example.dart) · [Retry and quota example](example/retry_guidance_example.dart)

</details>

## Examples

Complete runnable workflows are in [example/](example/). Examples marked **offline** use local or mock transports; other examples can make paid API calls. Start with [responses_example.dart](example/responses_example.dart).

<details>
<summary><b>Responses, Chat, Decisions, and embeddings</b></summary>

| Example | Description |
| --- | --- |
| [responses_example.dart](example/responses_example.dart) | Responses API with built-in tools |
| [openai_dart_example.dart](example/openai_dart_example.dart) | Quick-start overview |
| [web_search_example.dart](example/web_search_example.dart) | Web search with Responses API |
| [input_tokens_example.dart](example/input_tokens_example.dart) | Input token counting |
| [conversations_example.dart](example/conversations_example.dart) | Conversations API for state management |
| [chat_example.dart](example/chat_example.dart) | Chat completions, multi-turn conversations, and legacy cache retention |
| [streaming_example.dart](example/streaming_example.dart) | Content streaming, detailed final usage, and obfuscation controls |
| [tool_calling_example.dart](example/tool_calling_example.dart) | Function calling with tool definitions |
| [vision_example.dart](example/vision_example.dart) | Image analysis with vision models |
| [decisions_example.dart](example/decisions_example.dart) | Typed Decisions questions, refusals, usage, and inline images |
| [decision_image_urls_example.dart](example/decision_image_urls_example.dart) | **Offline.** HTTP(S)/data image references, exact mixed input and one mock POST |
| [embeddings_example.dart](example/embeddings_example.dart) | Text embeddings with dimension control |

</details>

<details>
<summary><b>Images, audio, video, and live sessions</b></summary>

| Example | Description |
| --- | --- |
| [images_example.dart](example/images_example.dart) | GPT Image generation |
| [image_model_selection_example.dart](example/image_model_selection_example.dart) | Local generation/multipart/JSON-edit model contracts without API calls |
| [audio_example.dart](example/audio_example.dart) | Text-to-speech and transcription |
| [speech_streaming_example.dart](example/speech_streaming_example.dart) | **Offline.** buffered/byte/SSE speech, voice references and usage |
| [existing_audio_example.dart](example/existing_audio_example.dart) | **Offline.** modern file fields, verbose/raw translation, open/custom Chat voices and AAC |
| [chat_audio_example.dart](example/chat_audio_example.dart) | Chat audio output, ID-only replay, and partial stream accumulation |
| [videos_example.dart](example/videos_example.dart) | Sora video generation, editing, and extension |
| [realtime_example.dart](example/realtime_example.dart) | Realtime API (WebSocket and WebRTC) |
| [live_http_example.dart](example/live_http_example.dart) | **Offline.** WebRTC/SIP signaling, explicit call controls, verified incoming notice, WAV downloads and REST fork |
| [live_websocket_example.dart](example/live_websocket_example.dart) | **Offline.** primary/sideband Live, concurrent event taps, manual delegation and graceful finalization |
| [live_workflows_example.dart](example/live_workflows_example.dart) | **Offline.** stored forks, inherited state, compact Responses, caption grouping and borrowed-channel cleanup |
| [voice_consents_example.dart](example/voice_consents_example.dart) | **Offline.** upload/list/retrieve/rename/delete consent lifecycle and explicit pagination |
| [voices_example.dart](example/voices_example.dart) | **Offline.** explicit consent and sample upload, then caller-selected custom voice reference |

</details>

<details>
<summary><b>Files, batches, errors, webhooks, and safety</b></summary>

| Example | Description |
| --- | --- |
| [files_example.dart](example/files_example.dart) | File upload and management |
| [uploads_example.dart](example/uploads_example.dart) | Large file multipart uploads |
| [batches_example.dart](example/batches_example.dart) | Batch processing for async jobs |
| [fine_tuning_example.dart](example/fine_tuning_example.dart) | Fine-tuning job management |
| [evals_example.dart](example/evals_example.dart) | Model evaluation and testing |
| [models_example.dart](example/models_example.dart) | Model listing and retrieval |
| [moderation_example.dart](example/moderation_example.dart) | Content moderation |
| [content_provenance_checks_example.dart](example/content_provenance_checks_example.dart) | Content provenance (C2PA/SynthID) detection |
| [error_handling_example.dart](example/error_handling_example.dart) | Exception handling patterns |
| [retry_guidance_example.dart](example/retry_guidance_example.dart) | Local transient, permanent-quota, and long-hint scenarios without API calls |
| [webhooks_example.dart](example/webhooks_example.dart) | **Offline.** signed receiver, acknowledgment and caller-owned deduplication |
| [webhook_endpoints_example.dart](example/webhook_endpoints_example.dart) | **Offline.** project endpoint lifecycle, pagination, discovery, rotation and test status |
| [safety_example.dart](example/safety_example.dart) | **Offline.** verified notifications and separately scoped alert/case retrieval |
| [safety_explanations_example.dart](example/safety_explanations_example.dart) | **Offline.** project alert explanation presence, copy/clear and private diagnostics |
| [monitoring_errors_example.dart](example/monitoring_errors_example.dart) | **Offline.** typed HTTP/SSE monitoring failures and explicit scoped investigation |

</details>

<details>
<summary><b>Advanced Responses workflows</b></summary>

| Example | Description |
| --- | --- |
| [responses_websocket_example.dart](example/responses_websocket_example.dart) | **Offline.** warm-up, two persistent lanes and incremental continuation with awaited cleanup |
| [responses_steering_example.dart](example/responses_steering_example.dart) | **Offline.** steer a running Responses request |
| [responses_recovery_example.dart](example/responses_recovery_example.dart) | **Offline.** recover a Responses WebSocket |
| [async_tools_example.dart](example/async_tools_example.dart) | Local async function/custom jobs, original call IDs and latest-response continuation |
| [tool_search_example.dart](example/tool_search_example.dart) | **Offline.** client tool-search continuation with the original call ID and complete discovered definitions |
| [web_search_controls_example.dart](example/web_search_controls_example.dart) | Local GA filters, image results, sources, and REST/SSE parsing without API calls |
| [configuration_updates_example.dart](example/configuration_updates_example.dart) | **Offline.** change reasoning effort during a conversation |
| [prompt_cache_example.dart](example/prompt_cache_example.dart) | Responses prewarming, comparison diagnostics, and narrow Chat cache options |
| [containers_example.dart](example/containers_example.dart) | Container memory/network configuration, Code Interpreter IDs, and files |
| [shell_tools_example.dart](example/shell_tools_example.dart) | **Offline.** hosted configuration, synthetic local continuation, and typed shell stream events |
| [compaction_progress_example.dart](example/compaction_progress_example.dart) | **Offline.** nonterminal compaction progress and opaque final output preservation |
| [access_programs_example.dart](example/access_programs_example.dart) | **Offline.** access-program selection, server defaults and effective returned metadata |
| [responses_injection_example.dart](example/responses_injection_example.dart) | **Offline.** inject multi-agent tool results |

</details>

<details>
<summary><b>Agents, Vaults, and other resources</b></summary>

| Example | Description |
| --- | --- |
| [saved_agents_example.dart](example/saved_agents_example.dart) | **Offline.** saved-agent CRUD, all six persisted tools, pagination, replacement and clear/reset |
| [agent_sessions_example.dart](example/agent_sessions_example.dart) | **Offline.** durable sessions, persistent observation, manual function result and explicit cancellation |
| [agent_session_history_example.dart](example/agent_session_history_example.dart) | **Offline.** root/turn history and published OTLP trace pagination |
| [agent_subagents_example.dart](example/agent_subagents_example.dart) | **Offline.** Agent session subagents |
| [agent_environments_example.dart](example/agent_environments_example.dart) | **Offline.** template CRUD and owned hosted environment prewarming, pagination and safe inspection |
| [agent_files_artifacts_example.dart](example/agent_files_artifacts_example.dart) | **Offline.** Agent environment files and published artifacts |
| [vaults_example.dart](example/vaults_example.dart) | **Offline.** Vault CRUD and write-only credential create/rotate with safe inspection |
| [chatkit_example.dart](example/chatkit_example.dart) | ChatKit sessions and threads |
| [skills_example.dart](example/skills_example.dart) | Skills management |
| [assistants_example.dart](example/assistants_example.dart) | Assistants API (deprecated) |
| [completions_example.dart](example/completions_example.dart) | Legacy completions API |

</details>

## API Coverage

<details>
<summary><b>Supported APIs and remaining gaps</b></summary>

| API | Support |
| --- | --- |
| Responses | HTTP and SSE, persistent WebSockets, steering, opt-in recovery, and beta tool-result injection |
| Chat Completions | Generation and streaming; stored-completion management pending |
| Decisions | Predicate, choice, and score questions |
| Embeddings | Text vectors with dimension control |
| Images | Generation, editing, and streaming |
| Audio | Speech, transcription, translation, voice consents, and custom voices; consent phrase lookup remains untyped |
| Videos | Generation, editing, extension, and downloads |
| Realtime | WebSocket and WebRTC sessions through a separate import |
| Live | HTTP call controls, recordings, WebSockets, forks, and transcript helpers; some media/reconnect conveniences remain deferred |
| Files and Uploads | File management and large multipart uploads |
| Batches | Asynchronous batch processing |
| Models | Listing and retrieval |
| Moderations | Text and image moderation |
| Fine-tuning | Job management; some grader/checkpoint operations pending |
| Evals | Evaluation definitions and runs |
| Conversations | Conversation and item management |
| Containers | Memory, network policy, skills, and files |
| Content Provenance Checks | C2PA and SynthID inspection |
| Webhooks | Local signed verification and project endpoint management |
| Safety | Read-only project alerts, organization cases, and typed monitoring details |
| Agents | Saved agents, durable sessions, root/child history, published traces, hosted environments, templates, files, and artifacts |
| Vaults | Vault management and write-only credentials |
| ChatKit Beta and Skills | Sessions/threads and skills management |
| Assistants, Threads, Messages, Runs, and Vector Stores | Deprecated; separate Assistants import |
| Completions | Legacy text completions |

Some Responses tool/configuration details, Agents helper workflows, and administration APIs remain outside current coverage. See the [API alignment inventory](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/openai_dart/specs/api-alignment/README.md) for the detailed scope.

</details>

## Official Documentation

- [API reference](https://pub.dev/documentation/openai_dart/latest/)
- [OpenAI API docs](https://platform.openai.com/docs/api-reference)
- [OpenAI Python SDK](https://github.com/openai/openai-python)
- [OpenAI Node.js SDK](https://github.com/openai/openai-node)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Your support helps maintain the packages and fund API integration tests for the Dart and Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by OpenAI.
