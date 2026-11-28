# Google AI & Vertex AI Gemini API Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![googleai_dart](https://img.shields.io/pub/v/googleai_dart.svg)](https://pub.dev/packages/googleai_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[Google AI Gemini Developer API](https://ai.google.dev/gemini-api/docs)** and **[Vertex AI Gemini API](https://cloud.google.com/vertex-ai/generative-ai/docs/overview)** with text generation, image generation, tool calling, grounding tools, Live API WebSocket sessions, service tier routing, and embeddings. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

> [!NOTE]
> Google's [Vertex AI name changes](https://docs.cloud.google.com/gemini-enterprise-agent-platform/vertex-ai-name-changes) place several Vertex AI products and features — such as the **Vertex AI Platform** and **Generative AI on Vertex AI** — under the new **Gemini Enterprise Agent Platform** brand. The underlying API and SDKs still use the **Vertex AI** name, so this client keeps it: `GoogleAIConfig.vertexAI(...)`, `ApiMode.vertexAI`, and the `aiplatform.googleapis.com` endpoint match Google's REST API and official SDKs.

> [!NOTE]
> The official [`google_generative_ai`](https://pub.dev/packages/google_generative_ai) Dart package has been deprecated in favor of [`firebase_ai`](https://pub.dev/packages/firebase_ai). However, since [`firebase_ai`](https://pub.dev/packages/firebase_ai) is a **Flutter package** rather than a **pure Dart package**, this **unofficial client** bridges the gap by providing a **pure Dart, fully type-safe** API client for both Google AI and Vertex AI.

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

### Core Gemini APIs

- Text generation, image generation, streaming, token counting, and multimodal prompts
- Embeddings, model discovery, and context caching
- Tool calling plus structured outputs through typed schemas
- Service tier selection (`standard`, `flex`, `priority`) per request
- Long-running operations, pagination helpers, and retries

### Grounding and retrieval tools

- Google Search, URL Context, Google Maps, and File Search tools
- Files, cached contents, corpora, file search stores, and batch operations
- Interactions and Live API WebSocket flows with code execution and MCP server integration

### Google AI and Vertex AI support

- Google AI API key workflows for hosted Gemini access
- Vertex AI project and location routing with OAuth auth providers
- Auth tokens and tuned models for ephemeral auth and tuned model workflows
- One Dart client surface for server apps, CLIs, and Flutter codebases

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- One package supports both Google AI and Vertex AI without duplicated abstractions.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

Requires Dart 3.12 or later. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

```yaml
dependencies:
  googleai_dart: ^13.1.0
```

Set `GOOGLE_GENAI_API_KEY` and create a Gemini Developer API interaction on
the stable `v1` endpoint.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment(
    interactionsApiVersion: ApiVersion.v1,
  );

  try {
    final interaction = await client.interactions.create(
      model: 'gemini-4-hydrogen',
      input: const InteractionInput.text('Explain why Dart works well for APIs.'),
    );

    print(interaction.outputText);
  } finally {
    client.close();
  }
}
```

[Runnable quickstart](example/example.dart) ·
[GenerateContent example](example/generate_content.dart) ·
[Vertex AI example](example/vertex_ai_example.dart)

## Configuration

<details>
<summary><b>Configure Google AI, Vertex AI, auth providers, and retries</b></summary>

Use `GoogleAIClient.fromEnvironment()` for the default `GOOGLE_GENAI_API_KEY` workflow. Switch to `GoogleAIConfig.googleAI(...)` or `GoogleAIConfig.vertexAI(...)` when you need alternate auth placement, custom headers, or Vertex-specific project routing.

`apiVersion` selects the client-wide API version. Pass
`interactionsApiVersion: ApiVersion.v1` to opt into stable Interactions on
the Gemini Developer API while using the existing client-wide configuration
for other resources. Managed agents and Live require Developer API `v1beta`.
[Gemini API version matrix](https://aistudio.google.com/api-reference/api-versions)

For Vertex AI, `location` selects the endpoint:

| Location | Endpoint |
| --- | --- |
| `global` | `https://aiplatform.googleapis.com` |
| `us`, `eu` | `https://aiplatform.{location}.rep.googleapis.com` |
| A region such as `us-central1` | `https://{location}-aiplatform.googleapis.com` |

The location is also kept in the request path. Model and feature availability depends on the selected location; see Google's [endpoint documentation](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/learn/locations#multi-region-endpoints). Use `copyWith(baseUrl: ...)` to override the REST endpoint.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final googleClient = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      authProvider: ApiKeyProvider('YOUR_API_KEY'),
      timeout: const Duration(minutes: 2),
      retryPolicy: RetryPolicy.defaultPolicy,
    ),
  );

  final vertexClient = GoogleAIClient(
    config: GoogleAIConfig.vertexAI(
      projectId: 'your-project-id',
      location: 'us-central1',
      authProvider: BearerTokenProvider('YOUR_ACCESS_TOKEN'),
    ),
  );

  googleClient.close();
  vertexClient.close();
}
```

Environment variable:

- `GOOGLE_GENAI_API_KEY`

Use explicit configuration on web builds where runtime environment variables are not available.

**API Versions:**

Google AI supports both stable and beta API versions, and `googleai_dart` exposes them through the same config object.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final stableClient = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      apiVersion: ApiVersion.v1,
      authProvider: ApiKeyProvider('YOUR_API_KEY'),
    ),
  );

  final betaClient = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      apiVersion: ApiVersion.v1beta,
      authProvider: ApiKeyProvider('YOUR_API_KEY'),
    ),
  );

  stableClient.close();
  betaClient.close();
}
```

- `v1` is the stable choice for production rollouts.
- `v1beta` exposes preview features earlier and is the default for Google AI.
- `v1beta1` exposes Vertex AI preview features such as GenerateContent long decode. Select it with `GoogleAIConfig.vertexAI(apiVersion: ApiVersion.v1beta1, ...)`.

**Vertex AI:**

Use Vertex AI when you need OAuth-based auth, GCP project scoping, or enterprise controls such as regional routing and broader Google Cloud integration.

```dart
import 'package:googleai_dart/googleai_dart.dart';

class MyOAuthProvider implements AuthProvider {
  @override
  Future<AuthCredentials> getCredentials() async {
    return BearerTokenCredentials('YOUR_ACCESS_TOKEN');
  }
}

Future<void> main() async {
  final client = GoogleAIClient(
    config: GoogleAIConfig.vertexAI(
      projectId: 'your-project-id',
      location: 'us-central1',
      authProvider: MyOAuthProvider(),
    ),
  );

  client.close();
}
```

Vertex AI setup requirements:

- A GCP project with Vertex AI enabled
- OAuth 2.0 credentials or a service account flow
- A valid project ID and location such as `us-central1` or `global` (the `global` location uses `aiplatform.googleapis.com` instead of a regional endpoint)

</details>

## Usage

### How do I continue or stream a Gemini interaction?

<details>
<summary><b>Show example</b></summary>

Pass the earlier interaction ID as `previousInteractionId` to continue a
conversation the server has stored. Use `store: false` for a stateless request.
`createStream(...)` yields typed server-sent events and accepts an
`abortTrigger`. To replay a stored stream, call `resumeStream(...)` with the
interaction ID and the last event ID you processed.

```dart
final first = await client.interactions.create(
  model: 'gemini-4-hydrogen',
  input: const InteractionInput.text('My favorite language is Dart.'),
);

final next = await client.interactions.create(
  model: 'gemini-4-hydrogen',
  input: const InteractionInput.text('What is my favorite language?'),
  previousInteractionId: first.id,
);
print(next.outputText);
```

Gemini 4 foreground long decode may return
`InteractionStatus.requiresContinuation`. For a stored interaction, send the
latest `continuationToken` and set `previousInteractionId` to the ID of the hop
that issued it. Omit `input` and keep the same model, generation settings,
tools, and system instruction.
For a stateless interaction, keep `store: false` and resend the original `input`
with the latest token.

`InteractionStatusUpdateEvent` can carry a checkpoint token and usage for the
current hop. `createStream` with a token starts another decoding hop.
`resumeStream` with an event ID replays the same interaction. To total usage
across foreground hops, add the final usage from each hop. Within a hop,
use the latest cumulative usage instead of adding each checkpoint.
Set `automaticContinuation: true` on `create` or `createStream` to follow
foreground decoding tokens. Unary calls combine the output and token usage
from all hops. Streams keep each hop's created and completed events. A stream
can reconnect when a connection drops at a checkpoint. If it drops after
additional output, `InteractionContinuationInterruptedException` carries the
last token. Discard output after that checkpoint before resuming. For an
interrupted unary request, `partialInteraction` contains its completed output.
Google's Python and JavaScript SDKs enable automatic continuation by default.
[Runnable long-decode example](example/interactions_long_decode.dart) ·
[Google's long-decode guide](https://aistudio.google.com/docs/long-decode)

Select `ApiVersion.v1beta` for the managed-agent variants
`createWithAgent(...)` and `createWithAgentStream(...)`.
[Full example](example/interactions_example.dart) ·
[Interactions guide](https://aistudio.google.com/docs/interactions-overview)

</details>

### How do I load tools on demand?

<details>
<summary><b>Show example</b></summary>

Tool retrieval is in Preview on supported Gemini models on the Gemini
Developer API `v1beta`. For server-side retrieval, declare `ToolSearchTool`
and defer selected `FunctionTool` or `McpServerTool` schemas.

```dart
const tools = [
  ToolSearchTool(),
  FunctionTool(
    name: 'lookup_inventory',
    description: 'Returns available inventory for a product SKU.',
    deferLoading: true,
    parameters: {
      'type': 'object',
      'properties': {'sku': {'type': 'string'}},
      'required': ['sku'],
    },
  ),
];

final client = GoogleAIClient.fromEnvironment(
  interactionsApiVersion: ApiVersion.v1beta,
);
try {
  final interaction = await client.interactions.create(
    model: 'gemini-4-hydrogen',
    tools: tools,
    input: const InteractionInput.text('Check stock for SKU A123.'),
  );
  for (final call in interaction.functionCallSteps) {
    print('${call.name}: ${call.arguments}');
  }
} finally {
  client.close();
}
```

Send the tools array on each turn. When using `store: false`, replay the
returned steps in order and preserve their signatures. For client-side
retrieval, declare `ToolSearchExecution.client` and return the matching
function definitions in `FunctionResultSubcontentFunction` items.
[Client-side example](example/tool_retrieval_example.dart) ·
[Tool retrieval guide](https://aistudio.google.com/docs/tool-retrieval)

</details>

### How do I generate text with Gemini?

<details>
<summary><b>Show example</b></summary>

Use `client.models.generateContent(...)` for the GenerateContent API. The
`response.text` extension extracts generated text from the result.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-3.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('Explain what hot restart does in Flutter.')],
        // Optional: route to a specific service tier (standard, flex, priority)
        serviceTier: ServiceTier.flex,
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/generate_content.dart)

For long decode on supported Gemini 4 models, select the Gemini Developer API
`v1beta` or Vertex AI `v1beta1`. Set `GenerationConfig.maxOutputTokens` above
65,536 and pass `automaticContinuation: true` to `streamGenerateContent`.
Gemini 4 Neon and Hydrogen also support unary long decode through
`generateContent`. An initial direct unary request to Gemini 4 Carbon or
Argon with a limit above 32,768 can return HTTP 400.

Automatic continuation uses the same timeout and abort trigger across hops.
The unary result merges candidate output and usage. In a stream, consume text
as it arrives and use the latest reported usage across hops. If the connection
drops after emitting output beyond the latest checkpoint, the stream surfaces
the error so the application can decide how to recover.

With the default manual flow, when a candidate has `FinishReason.continuation`
and a token, start the next hop with the original request and
`copyWith(continuationToken: candidate.continuationToken)`. Keep the original
inputs and total token budget across hops. On a stream, a checkpoint token
can arrive before a finish reason. Keep output since the last checkpoint
pending so you can discard it if the stream drops and resume from that
checkpoint. To resume after `FinishReason.maxTokens` with a token, raise the
budget above the tokens already used.
[Streaming long decode example](example/generate_content_long_decode.dart) ·
[Gemini Developer API long decode](https://aistudio.google.com/docs/long-decode?generate-content=true) ·
[Vertex AI inference reference](https://docs.cloud.google.com/gemini-enterprise-agent-platform/reference/models/inference)

Use `GenerateContentRequest.labels` for request metadata on Gemini Developer
API `v1beta` and Vertex AI. On models that support speech transcription, use
`GenerationAudioTranscriptionConfig` to configure transcription output,
including SMART mode and source text where available.
[GenerateContent reference](https://aistudio.google.com/api-reference/generate-content)

</details>

### How do I select files, pages, or clips in GenerateContent?

<details>
<summary><b>Show example</b></summary>

Set metadata on the same `InlineDataPart` or `FileDataPart` that carries the
media. Document page ranges and spreadsheet sheet numbers start at 1. Audio
and video offsets use protobuf duration strings such as `1.25s`.

```dart
final excerpt = InlineDataPart(
  Blob.fromBytes('application/pdf', pdfBytes),
  documentMetadata: const DocumentMetadata(
    startPage: 2,
    endPage: 4,
    contentLayers: [DocumentContentLayer.pageText],
  ),
);
```

Use `SpreadsheetMetadata` to select a sheet, A1 cell range, and data, formulas
or images. For media returned by a function, use the same metadata on a
`FunctionResponseInlinePart` with `inlineData` or `fileData`. Video
`MediaProcessing.static` and `MediaProcessing.agentic` select how to inspect
video. The pinned Cloud SDKs reject explicit video processing modes in
function results. Supported media and selection options depend on the model
and backend.

[Full example](example/generate_content_media_slicing.dart) ·
[Document processing](https://aistudio.google.com/docs/document-processing#customize-document-processing) ·
[Function result media](https://aistudio.google.com/docs/function-calling#file-inspection-options)

</details>

### How do I register files already in Google Cloud Storage?

<details>
<summary><b>Show example</b></summary>

Use the Gemini Developer Files API with an OAuth provider. Enable the Gemini
API, then give its service agent read access to the target Cloud Storage
objects. Use a quota project if your OAuth setup requires one.

```dart
final result = await client.files.register(
  uris: ['gs://my-bucket/report.pdf'],
  authProvider: BearerTokenProvider(accessToken),
  quotaProjectId: quotaProjectId,
);
final uri = result.files?.firstOrNull?.uri;
```

Registration is available on the Developer `v1` and `v1beta` routes. Pass the
returned file URI when generating content. Vertex AI uses the Cloud Storage
URI directly. Browser requests require a compatible CORS endpoint.
[Full example](example/register_cloud_storage_files.dart) ·
[Cloud Storage registration guide](https://aistudio.google.com/docs/file-input-methods#registration)

</details>

### How do I use Vertex AI?

<details>
<summary><b>Show configuration</b></summary>

Configure your Google Cloud project, location, and OAuth credentials with
`GoogleAIConfig.vertexAI(...)`. Use `client.interactions.create(...)` for
stateful model calls and `client.interactions.list(...)` to page through
stored interaction IDs. Use `client.models.generateContent(...)` for the
GenerateContent API. Vertex Interactions documents `global`, `us`, and `eu`
availability. `us` and `eu` select dedicated multi-region endpoints.

For asynchronous model calls on the Deferred tier, use global Interactions
`v1` with `ServiceTier.deferred`, `background: true`, and `store: true`.
Start the call with `create(...)`. Poll with `get(...)` while the call is
queued. Once it reports `InteractionStatus.inProgress`, you can attach with
`resumeStream(...)`. Use `cancel(...)` to stop a queued or running call.

Cloud API keys can use `ApiKeyProvider(..., placement: AuthPlacement.header)`
with the documented project and location. The client also follows the pinned
SDK's projectless express route when both the project and location are omitted
and the Cloud base URL and API mode are configured explicitly. Listing uses
the project-scoped API.
[Vertex AI configuration](#configuration) ·
[Interactions example](example/vertex_interactions_example.dart) ·
[GenerateContent example](example/vertex_ai_example.dart) ·
[Cloud Interactions developer guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/capabilities/interactions/developer-guide) ·
[Deferred tier and supported models](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/deferred-tier)

</details>

### How do I stream Gemini output?

<details>
<summary><b>Show example</b></summary>

Streaming uses the same request type as normal generation, so you can switch between buffered and incremental output without changing the rest of your app code.

```dart
import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    await for (final chunk in client.models.streamGenerateContent(
      model: 'gemini-3.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('Write a short poem about Dart streams.')],
      ),
    )) {
      final text = chunk.text;
      if (text != null) {
        stdout.write(text);
      }
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/streaming_example.dart)

</details>

### How do I generate images?

<details>
<summary><b>Show example</b></summary>

Image generation uses `responseModalities` on the same generation endpoint, which keeps multimodal workflows inside one Gemini client. The `response.data` helper gives access to the generated image bytes.

```dart
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-2.5-flash-image',
      request: GenerateContentRequest(
        contents: [Content.text('A clean geometric poster about Flutter')],
        generationConfig: const GenerationConfig(
          responseModalities: [ResponseModality.text, ResponseModality.image],
        ),
      ),
    );

    final imageData = response.data;
    if (imageData != null) {
      print(base64Decode(imageData).length);
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/image_generation_example.dart)

</details>

### How do I generate speech?

<details>
<summary><b>Show example</b></summary>

Use Gemini Developer API `v1beta` with `generateContent`,
`ResponseModality.audio`, and a `SpeechConfig`. Gemini 3.8 TTS returns
`audio/wav` by default for unary requests. Write the decoded WAV bytes as
returned. If an older model or a streaming request returns headerless
`audio/l16`, use the reported MIME type to choose how to save or play it.

```dart
import 'dart:convert';
import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-3.8-flash-tts',
      request: GenerateContentRequest(
        contents: const [
          Content(
            role: 'user',
            parts: [
              TextPart(
                'Welcome to the show!',
                speechMetadata: SpeechMetadata(style: 'Excited and warm'),
              ),
            ],
          ),
        ],
        generationConfig: GenerationConfig(
          responseModalities: const [ResponseModality.audio],
          speechConfig: SpeechConfig.withVoice('Kore'),
        ),
      ),
    );

    final wav = response.data;
    if (wav != null) {
      await File('welcome.wav').writeAsBytes(base64Decode(wav));
    }
  } finally {
    client.close();
  }
}
```

For transcription with `gemini-3.5-transcribe`, request speaker diarization
or word timing through `GenerationAudioTranscriptionConfig`. Read the
result from `Part.audioTranscription`.

[Speech example](example/tts_example.dart) ·
[GenerateContent speech guide](https://aistudio.google.com/docs/speech-generation?generate-content=true) ·
[Audio transcription guide](https://aistudio.google.com/docs/transcribe?generate-content=true)

</details>

### How do I use tool calling?

<details>
<summary><b>Show example</b></summary>

Gemini tool calling uses typed `FunctionDeclaration` definitions inside `Tool` objects. This keeps the tool schema local to the request and easy to share across Dart services.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-3.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('What is the weather in Madrid?')],
        tools: [
          Tool(
            functionDeclarations: [
              FunctionDeclaration(
                name: 'get_weather',
                description: 'Get current weather',
                parameters: Schema(
                  type: SchemaType.object,
                  properties: {
                    'location': Schema(type: SchemaType.string),
                  },
                  required: ['location'],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/function_calling_example.dart)

</details>

### How do I ground responses with Google data?

<details>
<summary><b>Show example</b></summary>

Grounding tools let Gemini call Google Search, URL Context, Maps, or File Search without leaving the same client surface. Use these when you need fresher answers or source-aware responses in Dart and Flutter apps.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-3.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('What are the latest Dart language updates?')],
        tools: [Tool(googleSearch: GoogleSearch())],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/google_search_example.dart)

</details>

### How do I evaluate a decision with Gemini?

<details>
<summary><b>Show example</b></summary>

Gemini Decision 1 evaluates yes/no, choice, and rubric questions against
shared text or multimodal input. It returns scores or probabilities with
confidence values. Use the Gemini Developer API with `ApiVersion.v1beta`.

```dart
final response = await client.decisions.create(
  model: 'gemini-decision-1',
  input: const DecisionInput.text('My delivery arrived two days late.'),
  questions: const {
    'late_delivery': DecisionQuestion.noul(
      instructions: DecisionInstructions.text('Did the delivery arrive late?'),
    ),
  },
);

if (response.answers?['late_delivery'] case NoulAnswer(:final noul)) {
  print('Probability: $noul');
}
```

[Full example](example/decisions_example.dart) ·
[Decisions API guide](https://aistudio.google.com/docs/decisions-api)

</details>

### How do I configure speech, transcription, or video output?

<details>
<summary><b>Show options</b></summary>

Use `InteractionGenerationConfig.structuredSpeechConfig` to select speakers
and set text normalization for supported TTS models on Gemini Developer API
`v1beta`. For example:

```dart
const generation = InteractionGenerationConfig(
  structuredSpeechConfig: InteractionStructuredSpeechConfig.speakers(
    speakers: [InteractionSpeechConfig(speaker: 'Narrator', voice: 'Puck')],
    textNormalization: InteractionTextNormalization.enabled,
  ),
);
```

On the same beta surface, use `TranscriptionConfig.mode` to select SMART
editing or verbatim transcription. For generated video, set
`InteractionVideoResponseFormat.resolution` to a resolution supported by
the selected model. Sampling controls `temperature` and `topP` are
deprecated upstream and available only where the model supports them.

[Speech generation](https://aistudio.google.com/docs/speech-generation) ·
[Video output resolution](https://aistudio.google.com/docs/omni#output-resolution)

</details>

### How do I manage credentials for agents?

<details>
<summary><b>Show example</b></summary>

The Gemini Developer API `v1beta` Credentials API stores environment variables,
HTTP bearer tokens, and OAuth2 credentials for managed agents. Create or update
a credential with its secret value. Responses contain only its metadata.

```dart
final credential = await client.credentials.create(
  credential: HttpBearerConfig(id: 'deployment-token', token: token),
);
await client.credentials.update(
  credential.id,
  credential: HttpBearerUpdateConfig(token: replacementToken),
  updateMask: 'token',
);
```

Set an ID for a readable reference, or omit `id` when creating a credential to
let the server generate a UUID. The managed-agent guide documents generated IDs
even though the API reference lists `id` as required on create. Use the returned
ID to reference the credential from a managed environment.
Use `get` and `list` for metadata and `delete` to remove a stored credential.
[Full example](example/credentials_example.dart) ·
[Generated IDs for managed-agent credentials](https://aistudio.google.com/docs/agent-credentials#generated-ids)

</details>

### How do I schedule a managed agent?

<details>
<summary><b>Show example</b></summary>

Use the Gemini Developer API `v1beta` with a supported agent such as
`antigravity-preview-09-2026` or the ID returned by `client.agents.create`.
If your project requires a parent scope when creating an agent, pass
`parent: 'projects/my-project/locations/global'`.

```dart
final trigger = await client.triggers.create(
  trigger: const TriggerCreateParams(
    interaction: CreateAgentInteractionParams(
      agent: 'antigravity-preview-09-2026',
      input: InteractionInput.text('Summarize the latest project notes.'),
      environment: EnvironmentConfigOrId.id('remote'),
    ),
    schedule: '0 9 * * 1',
    timeZone: 'UTC',
  ),
);
final execution = await client.triggers.run(triggerId: trigger.id);
print(execution.interactionId);
```

Use `listExecutions(filter: ...)` to inspect matching runs. Use
`TriggerUpdate(status: TriggerStatus.paused)` with `update` to pause a
schedule. Pass `updateMask` when a gateway expects the REST update envelope.

[Agent setup example](example/agents_example.dart) ·
[Trigger example](example/triggers_example.dart) ·
[Triggers reference](https://aistudio.google.com/api-reference/triggers)

</details>

### How do I create embeddings?

<details>
<summary><b>Show example</b></summary>

Embeddings are a first-class resource and support multimodal models. This makes retrieval and semantic search pipelines straightforward to build in pure Dart.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.embedContent(
      model: 'gemini-embedding-2-preview',
      request: EmbedContentRequest(
        content: Content.text('Dart language'),
        taskType: TaskType.retrievalDocument,
      ),
    );

    print(response.embedding.values.length);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/embeddings_example.dart)

</details>

### How do I upload files for prompts?

<details>
<summary><b>Show example</b></summary>

The Google AI Files API is useful for large prompts and multimodal workflows. For Vertex AI, use Cloud Storage URIs instead of this resource.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final file = await client.files.upload(
      filePath: '/path/to/image.jpg',
      mimeType: 'image/jpeg',
      displayName: 'Sample image',
    );

    print(file.uri);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/files_example.dart)

</details>

### How do I process selected parts of a file?

<details>
<summary><b>Show example</b></summary>

Set `processing` on Interactions document, audio, or video content.
Select one-based pages or worksheet indexes, A1 cell ranges, or time
intervals. Video options can also select frames, audio, or transcripts.
The same content blocks work in typed function result subcontent.

```dart
final selection = DocumentContent(
  uri: uploadedFile.uri,
  mimeType: 'application/pdf',
  processing: const InteractionDocumentProcessing.select(
    pageOptions: InteractionPageProcessingOptions(
      startPage: 2,
      endPage: 4,
      contentLayers: [InteractionPageLayer.text],
    ),
  ),
);
```

This example uses stable Gemini Developer Interactions. Check the guide for
supported MIME types, resolution and content layers.
[Runnable example](example/interactions_media_slicing.dart) ·
[Document processing](https://aistudio.google.com/docs/document-processing#customize-document-processing) ·
[Video processing](https://aistudio.google.com/docs/video-understanding#customize-video-processing) ·
[Function result files](https://aistudio.google.com/docs/function-calling#file-inspection-options)

</details>

### How do I download a generated file?

<details>
<summary><b>Show example</b></summary>

Use `client.files.download(name: 'files/{id}')` on the Gemini Developer API
`v1` or `v1beta` for downloadable API-generated files. Find them with
`client.files.get` or `list` by checking `source` and `downloadUri`.
Uploaded and Cloud Storage-registered inputs use the Files API for prompting
and metadata. Existing Developer API gateway configurations continue to use
their configured API version.

Use `client.generatedFiles.download(name: 'generatedFiles/{id}')` for the
separate `v1beta` Generated Files collection. Both methods return bytes. The
metadata `get` methods remain available. Browser transports require an
endpoint or gateway that serves the bytes directly.

[Runnable download example](example/generated_files_example.dart) ·
[Files reference](https://aistudio.google.com/api-reference/files)

</details>

### How do I configure a managed environment?

<details>
<summary><b>Show example</b></summary>

Create managed environments with the Gemini Developer API `v1beta` preview.
Use a stored credential reference for secrets and plain values for sandbox
configuration.

```dart
final environment = await client.environments.create(
  environment: const CreateEnvironmentRequest(
    mode: EnvironmentMode.onDemand,
    env: EnvironmentVariables.map({
      'APP_MODE': EnvVar.literal('production'),
      'SERVICE_TOKEN': EnvVar(credential: 'service-token'),
    }),
    network: EnvironmentNetworkAllowlist(
      allowlist: [
        AllowlistEntry(domain: 'api.example.com', credential: 'service-egress'),
      ],
    ),
  ),
);
final reference = EnvironmentConfigOrId.id(environment.id);
```

Pass that reference to a managed-agent interaction on `v1beta`. Use
`EnvironmentConfig` when defining an inline sandbox, or
`CreateEnvironmentRequest(fromEnvironment: environment.id)` to copy an
existing sandbox. Leave sources and variables empty when copying.
Use `AllowlistEntry.credential` to attach a stored credential ID to a domain.
The egress proxy resolves the secret when it sends a matching request.
Use `EnvironmentNetworkDisabled` to block outbound traffic.

For a self-hosted sandbox, create it with `EnvironmentMode.selfHosted` and
optionally supply `customConfig` and `systemInstruction`. The create response
returns an `environmentKey` once. Store it securely for the sandbox daemon
and use only the environment ID in interactions. Metadata serialization,
get, and list omit the key. Follow Google's self-hosting guide to connect the
daemon. Sources, network settings, variables, and file snapshots apply to
Google-hosted sandboxes.
[Runnable environment configuration example](example/environment_config_example.dart) ·
[Environment guide](https://aistudio.google.com/docs/agent-environment) ·
[Credentials in the network allowlist](https://aistudio.google.com/docs/agent-credentials#network-allowlist) ·
[Self-hosted environments](https://aistudio.google.com/docs/agent-environment#self-hosted-environments)

</details>

### How do I manage environment workspace files?

<details>
<summary><b>Show example</b></summary>

Use `client.environments.files` with the Gemini Developer API `v1beta`. Pass a
workspace-relative path to inspect one file or list a directory. Omit the path
to list or download the workspace root.

```dart
final listing = await client.environments.files.list(
  environment: environmentId,
  path: 'artifacts',
  recursive: true,
);
for (final entry in listing.files ?? const <EnvironmentFile>[]) {
  print('${entry.path} (${entry.sizeBytes ?? 'unknown size'})');
}
final bytes = await client.environments.files.download(
  environment: environmentId,
  path: 'artifacts/report.pdf',
);
```

Use `nextPageToken` to continue a listing. Downloading a directory returns a
tar archive. Browser downloads require an endpoint or gateway that serves the
bytes directly. To find environments first, call `client.environments.list` with
an optional `EnvironmentMode.onDemand` or `EnvironmentMode.selfHosted` filter.

```dart
await client.environments.files.upload(
  environment: environmentId,
  path: 'inputs/report.pdf',
  bytes: pdfBytes,
  mimeType: 'application/pdf',
);
```

Set `extract: true` to unpack an archive into the destination directory, or
`overwrite: true` to replace files already there. Pass an `abortTrigger` to
cancel the local upload. The configured timeout covers authentication and
all chunks.

[Runnable environment files example](example/environment_files_example.dart) ·
[Google's environment files guide](https://aistudio.google.com/docs/agent-environment#download-files-from-the-environment)

</details>

### How do I use the Live API?

<details>
<summary><b>Show example</b></summary>

The Live API gives you bidirectional WebSocket sessions for text and audio. It supports audio input at 16kHz PCM, audio output at 24kHz PCM, session resumption with resumption tokens, and VAD (voice activity detection). Use `createLiveClient()` when you need realtime interactions beyond regular streaming responses.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();
  final liveClient = client.createLiveClient();

  try {
    final session = await liveClient.connect(
      model: 'gemini-3.8-live',
      liveConfig: LiveConfig(generationConfig: LiveGenerationConfig.audioOnly()),
    );

    session.sendText('Hello! Tell me a short joke.');
    await session.close();
  } finally {
    await liveClient.close();
    client.close();
  }
}
```

Use `ApiVersion.v1beta` for the public Gemini Developer API Live endpoint.
In browser apps, obtain a short-lived token from your server and pass it to
`connect(accessToken: token)` or `EphemeralTokenProvider(token)` with its
query placement. On native platforms, `EphemeralTokenProvider` also supports
`EphemeralTokenPlacement.header`. Vertex AI Live uses an OAuth bearer token in
native WebSocket headers. Vertex projects and locations are included in the
fully qualified model name in setup.

Read `message.responseUsageMetadata` for counts the server attaches to a Live
message. Usage may arrive in its own frame or with content. The client exposes
generated tokens as `responseTokenCount` on both backends. Use
`BidiGenerateContentServerContent.waitingForInput` to detect when the model
expects the user to continue.

`LiveConfig` accepts request labels, safety settings, and model-specific
generation settings. Use `explicitVadSignal` with supported Vertex AI models
and set `SafetySetting.method` only on Vertex AI. Use explicit affective dialog
and proactive audio controls with supported Gemini 2.5 Flash Live models.
Vertex AI Gemini 3.8 Live enables both behaviors by default. Omit
`enableAffectiveDialog` and `proactivity` for that model. Use
`ThinkingConfig.thinkingLevel` with the Developer API
`gemini-3.8-live-extended-thinking` model. Select a supported Live Translate
model when setting `LiveGenerationConfig.translationConfig`.
[Google Cloud model guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/guides/gemini-3-8-live) ·
[Developer Live thinking](https://aistudio.google.com/docs/live-api/thinking)

For a supported Vertex AI session, `sendContextUpdate()` replaces the system
instruction or tools during the session. Pass an empty tool list to clear the
tools. On models that accept client content, `sendContent(turnComplete: true)`
can finish a turn with the conversation already sent. Use client content to
seed configured initial history on Vertex AI Gemini 3.8 Live, then send
new text with `sendText()`. On the Gemini Developer API, pass
`MediaResolution(level: MediaResolutionLevel.high)` to
`BidiGenerateContentRealtimeInput.mediaResolution` for an input override.
`LiveGenerationConfig.mediaResolution` takes a `MediaResolutionLevel` for
the session default.
[Developer Live Bidi reference](https://aistudio.google.com/api-reference/live) ·
[Vertex Live model guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/guides/gemini-3-8-live)

`message.voiceActivity` exposes server-detected speech boundaries and their
audio offsets. With session resumption enabled, inspect
`session.lastResumableUpdate` for the most recent usable handle. Vertex AI
transparent resumption can also report `lastConsumedClientMessageIndex` as a
decimal string. Use it to discard acknowledged input from your buffer. The
application calls `resume()` and replays unacknowledged input as needed.
Check `session.resumable` before reconnecting to avoid reverting to an older
checkpoint with missing input.

[Full example](example/live_example.dart) ·
[Gemini Developer API ephemeral tokens](https://aistudio.google.com/docs/ephemeral-tokens) ·
[Vertex AI Live sessions](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/live-api/start-manage-session)

</details>

### How do I generate and steer live music?

<details>
<summary><b>Show example</b></summary>

Use the experimental `lyria-realtime-exp` model on the Gemini Developer API
`v1beta`. Live Music uses its own WebSocket session. Direct connections use a
Gemini API key in the query on native and web targets. Use a server-side
gateway to keep the key out of a web app. Vertex AI and Gemini Live ephemeral
tokens are unavailable for this endpoint.

```dart
final music = client.createLiveMusicClient();
try {
  final session = await music.connect(model: 'lyria-realtime-exp');
  session
    ..setWeightedPrompts(const [
      LiveMusicWeightedPrompt(text: 'Minimal piano and brushes', weight: 1),
    ])
    ..setMusicGenerationConfig(const LiveMusicGenerationConfig(bpm: 90))
    ..play();

  final first = await session.messages.firstWhere(
    (message) => message.serverContent?.audioChunks?.isNotEmpty == true,
  );
  final chunks = first.serverContent!.audioChunks!;
  // Buffer or write each chunk's decoded data for playback.
} finally {
  await music.close();
}
```

The Lyria RealTime audio specification lists 48 kHz, 16-bit stereo PCM.
Configure your player from each chunk's `mimeType` when it reports the format
or sample rate. The client decodes the bytes and delivers them in order.
Buffer and pace playback in your audio player. The runnable example writes
headerless PCM and prints the audio formats reported by the service.
Send `pause()`, `stop()`, and `resetContext()` to control generation. Send the
complete configuration when updating it and reset the context after changing
tempo or scale. Canceling the message subscription closes the session.
Slow listeners can lose unread audio when the queue fills. Queued warnings
and terminal errors remain available when reading resumes. A full queue of
control messages ends the stream with an error.

[Runnable PCM example](example/live_music_example.dart) ·
[Lyria RealTime audio specifications](https://aistudio.google.com/docs/realtime-music-generation#audio-specs) ·
[Live Music wire reference](https://aistudio.google.com/api-reference/live-music)

</details>

### How do I design or manage Gemini voices?

<details>
<summary><b>Show example</b></summary>

Use `client.voices` with the Gemini Developer API `v1beta`. A designed voice
has a reusable ID and can return preview audio. Set
`PromptedVoice.baseVoice` to remix a prebuilt or stored designed voice on a
paid project.

```dart
final created = await client.voices.create(
  store: true,
  voice: const Voice(
    type: VoiceType.prompted,
    model: 'gemini-3.8-flash-tts',
    prompted: PromptedVoice(input: 'A warm, deliberate fictional narrator.'),
  ),
);
final speech = SpeechConfig(voiceConfig: VoiceConfig(voice: created.id));
```

Use `voices.list` for catalog and stored voices, and `voices.get` or
`voices.delete` for stored custom voices. Supported synthesis models include
Gemini 3.8 Flash TTS and Gemini 3.8 Flash-Lite TTS.

Voice replication uses the same adult speaker's source and consent recordings
and requires a paid Gemini API project. Set `store` explicitly to select
stored IDs or expiring client-managed replication keys.

[Full example](example/voices_example.dart) ·
[Voice design](https://aistudio.google.com/docs/voice-design) ·
[Voice remixing](https://aistudio.google.com/docs/voice-remixing) ·
[Voice replication and consent](https://aistudio.google.com/docs/voice-replication)

</details>

### How do I transcribe live audio?

<details>
<summary><b>Set up live transcription and read interim and final text</b></summary>

Use `gemini-3.5-transcribe-live` with a text response on the Gemini Developer
API `v1beta` Live endpoint. Send 16 kHz, 16-bit mono PCM audio with
`session.sendAudio()` and listen to `session.messages` before sending audio.

```dart
final session = await liveClient.connect(
  model: 'gemini-3.5-transcribe-live',
  liveConfig: LiveConfig(
    generationConfig: LiveGenerationConfig.textOnly(),
    inputAudioTranscription: const AudioTranscriptionConfig(
      languageCodes: ['en-US'],
      customVocabulary: ['Gemini'],
    ),
    realtimeInputConfig: const RealtimeInputConfig(
      interimTranscriptTimestampEnabled: true,
    ),
  ),
);
```

Read `BidiGenerateContentServerContent.interimInputTranscription` for
provisional captions. Append each `inputTranscription.text` segment in the
default verbatim mode. With `AudioTranscriptionConfigMode.smart`, replace your
document with each finalized result and treat omitted text as an empty
document. Use `sourceText` to provide an initial document for voice editing.
Omit or pass an empty `languageCodes` list to detect the language automatically.

Automatic activity detection can flush audio with
`session.signalAudioStreamEnd()`. To control turn boundaries yourself, use
`RealtimeInputConfig.manual()` and call `signalActivityStart()` and
`signalActivityEnd()` around each audio turn.

Gemini 3.5 Transcribe Live reports utterance offsets. For word-level timing and
speaker diarization, use file transcription. Vertex AI lists the Live model in
the `global`, `us`, and `eu` locations. Connect with the Vertex OAuth
configuration and check option availability for your model and endpoint.

[Live transcription example](example/live_transcription_example.dart) ·
[Gemini Developer API Live transcription guide](https://aistudio.google.com/docs/live-api/live-transcribe) ·
[Vertex AI model availability](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-5-transcribe#regional-availability)

</details>

### How do I run a Veo video prediction?

<details>
<summary><b>Show example</b></summary>

Call `client.models.predictLongRunning` with a regional Vertex AI client and a
supported Veo model. Set `labels` to include request metadata such as an
anonymized `safety_identifier`. Pass the returned operation name to
`client.models.fetchPredictOperation` on the same regional client.
When the operation is done, read the completed media from `response.videos`.

[Runnable Veo example](example/prediction_example.dart) ·
[Veo request labels](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/abuse-monitoring#pass_an_end-user_safety_identifier_in_api_calls) ·
[Check operation status](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/video/generate-videos-from-text)

</details>

### How do I generate an interactive world with Genie 4?

<details>
<summary><b>Show example</b></summary>

Genie 4 uses a dedicated Interactions WebSocket on the paid-tier Gemini
Developer API `v1beta`. The model is generally available and Google's live
Interactions SDK surface is experimental. Create an interaction, connect, and
send one `GenieWorldSetup` with a prompt, a 16:9 reference image, or both.

```dart
final genie = client.interactions.genie;
final interaction = await genie.create();
final session = await genie.connect(interaction.id);
session.send(const GenieWorldSetup(prompt: 'A harbor at sunrise.'));
session.send(const GenieUserAction(action: GenieAction.keyClick, key: GenieKey.w));
```

Read `session.receive()` for typed events. `GenieStepEvent.mediaBytes` decodes
24 fps JPEG frames and 48 kHz signed 16-bit little-endian stereo PCM. Call
`await session.complete()` to request completion and wait for the server's
terminal event, or `await session.cancel()` to abort generation. A nonzero
completion status is available on the terminal event and causes
`complete()` to throw `GenieConnectionException`.
`detach()` closes the local socket, discards unread events, and can leave
server-side generation billing. Sessions cannot resume. Keep consuming events
during an active session to retain media. The client drops older unread media
once the backlog reaches 512 events or 16 MiB of encoded media. If control
events fill the backlog, the client drops surplus events in a batch that
contains a terminal event. Otherwise it attempts to cancel generation and
reports a stream error. Cancelling your receive subscription alone leaves the
interaction running.

For browsers, create the interaction and mint a scoped credential with
`await genie.createAuthToken(interaction.id)` on your backend. Pass the
returned `authToken` to `connect(interaction.id, authToken: ...)` in the browser.
Native clients can also authenticate with a paid-tier Gemini API key.

In a browser, use `connectWebRtc(...)` with the same scoped token and a
`BrowserGenieWebRtcPeer(mediaElement: video)` from
`package:googleai_dart/genie_web.dart`. Genie delivers video and Opus audio as
native media tracks. The `events` data channel carries typed control events,
including the terminal acknowledgement. Keep a WebRTC seed JPEG under 48 KB
so the complete JSON frame fits the 64 KiB default SCTP limit.

Compile the [browser example](example/genie_webrtc_example.dart) with
`dart compile js example/genie_webrtc_example.dart -o genie.js` and load it
with `<script defer src="genie.js"></script>` on an HTTPS or localhost page.
Use the interaction ID and scoped token supplied by your backend. The browser
may require a user gesture to play audio. On native Dart or Flutter, pass a
`GenieWebRtcPeer` backed by a host WebRTC binding, or use the package's
WebSocket transport.

[Native WebSocket example](example/genie_example.dart) ·
[Genie 4 guide](https://aistudio.google.com/docs/genie)

</details>

## Error Handling

<details>
<summary><b>Handle API failures, rate limits, canceled requests, and live session errors</b></summary>

`googleai_dart` throws typed exceptions for REST and Live API failures, which keeps retries and fallbacks explicit. Catch `ApiException` and its subclasses first, then fall back to `GoogleAIException` for other client-side failures.

```dart
import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    await client.models.generateContent(
      model: 'gemini-3.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('Ping')],
      ),
    );
  } on RateLimitException catch (error) {
    stderr.writeln('Retry after: ${error.retryAfter}');
  } on ApiException catch (error) {
    stderr.writeln('Gemini API error ${error.statusCode}: ${error.message}');
  } on GoogleAIException catch (error) {
    stderr.writeln('Google AI client error: $error');
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
| [`abort_example.dart`](example/abort_example.dart) | Request cancellation with abort triggers |
| [`agents_example.dart`](example/agents_example.dart) | Reusable agents and environments for interactions |
| [`api_versions_example.dart`](example/api_versions_example.dart) | API version selection (v1 vs v1beta) |
| [`auth_tokens_example.dart`](example/auth_tokens_example.dart) | Ephemeral token authentication |
| [`batch_example.dart`](example/batch_example.dart) | Batch operations |
| [`batches_example.dart`](example/batches_example.dart) | Batch resource management |
| [`cached_contents_example.dart`](example/cached_contents_example.dart) | Context caching |
| [`caching_example.dart`](example/caching_example.dart) | Context caching API usage |
| [`complete_api_example.dart`](example/complete_api_example.dart) | Complete API coverage demo |
| [`corpora_example.dart`](example/corpora_example.dart) | Corpus management for semantic retrieval |
| [`credentials_example.dart`](example/credentials_example.dart) | Store a managed-agent credential and inspect its metadata |
| [`decisions_example.dart`](example/decisions_example.dart) | Gemini Decision 1 question and answer types |
| [`documents_example.dart`](example/documents_example.dart) | Document management within corpora |
| [`embeddings_example.dart`](example/embeddings_example.dart) | Text embeddings |
| [`environment_files_example.dart`](example/environment_files_example.dart) | List and download managed environment workspace files |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`example.dart`](example/example.dart) | Stable Interactions quickstart |
| [`file_search_example.dart`](example/file_search_example.dart) | File search with semantic retrieval |
| [`file_search_stores_example.dart`](example/file_search_stores_example.dart) | File search store management |
| [`files_example.dart`](example/files_example.dart) | File uploads for prompts |
| [`function_calling_example.dart`](example/function_calling_example.dart) | Tool calling |
| [`generate_answer_example.dart`](example/generate_answer_example.dart) | Grounded question answering (RAG) |
| [`generate_content.dart`](example/generate_content.dart) | Basic text generation |
| [`generate_content_long_decode.dart`](example/generate_content_long_decode.dart) | Stream Gemini 4 output with automatic continuation |
| [`generate_content_media_slicing.dart`](example/generate_content_media_slicing.dart) | GenerateContent PDF page selection |
| [`generated_files_example.dart`](example/generated_files_example.dart) | Download generated Files and Generated Files media |
| [`genie_example.dart`](example/genie_example.dart) | Genie 4 world setup, JPEG frames, and WebSocket completion |
| [`genie_webrtc_example.dart`](example/genie_webrtc_example.dart) | Genie 4 browser WebRTC and native playback |
| [`google_maps_example.dart`](example/google_maps_example.dart) | Google Maps grounding |
| [`google_search_example.dart`](example/google_search_example.dart) | Grounding with Google Search |
| [`image_generation_example.dart`](example/image_generation_example.dart) | Image generation |
| [`interactions_media_slicing.dart`](example/interactions_media_slicing.dart) | Select pages and layers for Interactions media |
| [`interactions_example.dart`](example/interactions_example.dart) | Stable Interactions, streaming, state and function calls |
| [`interactions_long_decode.dart`](example/interactions_long_decode.dart) | Opt-in automatic continuation on Gemini 4 |
| [`live_example.dart`](example/live_example.dart) | Live API WebSocket sessions |
| [`live_music_example.dart`](example/live_music_example.dart) | Lyria RealTime prompts, playback controls, and PCM output |
| [`live_transcription_example.dart`](example/live_transcription_example.dart) | Stream PCM audio and read interim and finalized transcripts |
| [`models_example.dart`](example/models_example.dart) | List and inspect models |
| [`oauth_refresh_example.dart`](example/oauth_refresh_example.dart) | OAuth token refresh during retries |
| [`operations_example.dart`](example/operations_example.dart) | Long-running operations management |
| [`pagination_example.dart`](example/pagination_example.dart) | Paginated list results |
| [`permissions_example.dart`](example/permissions_example.dart) | Permission management for resources |
| [`prediction_example.dart`](example/prediction_example.dart) | Start and poll a Vertex AI Veo prediction with request labels |
| [`streaming_example.dart`](example/streaming_example.dart) | Streaming responses |
| [`tool_retrieval_example.dart`](example/tool_retrieval_example.dart) | Client-side tool retrieval on Gemini Developer API `v1beta` |
| [`triggers_example.dart`](example/triggers_example.dart) | Schedule and run managed agents on the Gemini Developer API `v1beta` |
| [`tts_example.dart`](example/tts_example.dart) | Text-to-speech with Gemini TTS models |
| [`tuned_model_generation_example.dart`](example/tuned_model_generation_example.dart) | Generate content with tuned models |
| [`tuned_models_example.dart`](example/tuned_models_example.dart) | Tuned model workflows |
| [`url_context_example.dart`](example/url_context_example.dart) | URL content fetching and analysis |
| [`vertex_ai_example.dart`](example/vertex_ai_example.dart) | Vertex AI GenerateContent |
| [`vertex_interactions_example.dart`](example/vertex_interactions_example.dart) | Vertex AI Interactions with OAuth and project routing |
| [`voices_example.dart`](example/voices_example.dart) | Create a prompted voice with Gemini Developer API |
| [`webhooks_example.dart`](example/webhooks_example.dart) | Webhook subscriptions for interaction events |

## API Coverage

| API | Status |
|-----|--------|
| Models | ✅ Full |
| Tuned Models | ✅ Full |
| Files | ✅ Full |
| Generated Files | ✅ Full |
| Voices | Gemini Developer API `v1beta` |
| Decisions | Gemini Developer API `v1beta`, `gemini-decision-1` |
| Cached Contents | ✅ Full |
| Batches | ✅ Full |
| Corpora | ✅ Full |
| File Search Stores | ✅ Full |
| Interactions | Developer REST `v1` and `v1beta`, and Vertex AI project routes. Developer managed agents require `v1beta`. |
| Credentials | Gemini Developer REST `v1beta` |
| Agents (Experimental) | ✅ Full |
| Webhooks (Experimental) | ✅ Full |
| Auth Tokens | ✅ Full |
| Live API (WebSocket) | ✅ Full |
| Genie 4 | Paid-tier Gemini Developer API `v1beta` WebSocket and WebRTC |

## Official Documentation

- [API reference](https://pub.dev/documentation/googleai_dart/latest/)
- [Google AI Gemini API docs](https://ai.google.dev/gemini-api/docs)
- [Vertex AI Gemini API docs](https://cloud.google.com/vertex-ai/generative-ai/docs/overview)
- [Google GenAI Python SDK](https://github.com/googleapis/python-genai)
- [Google GenAI JS/TS SDK](https://github.com/googleapis/js-genai)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by Google.
