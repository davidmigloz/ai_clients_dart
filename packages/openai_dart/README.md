# OpenAI Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![openai_dart](https://img.shields.io/pub/v/openai_dart.svg)](https://pub.dev/packages/openai_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[OpenAI API](https://platform.openai.com/docs/api-reference)** with Responses API, Decisions API, Chat Completions, images, videos, audio, custom tools, embeddings, evals, realtime, and more. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

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

- Responses API with streaming, multi-turn conversations, structured output, background mode, cache prewarming, and typed cache diagnostics
- Decisions API for typed predicate, choice, and score answers from text or inline images
- Chat Completions with tool calling, vision, structured output, detailed usage, audio completion/streaming, and obfuscation controls
- Images, videos, audio (TTS, transcription, translation), and embeddings
- Realtime API via WebSocket and WebRTC with audio streaming
- Input token counting via `inputTokens` for cost estimation

### Tools

- Web search, file search, code interpreter, computer use, and custom tools
- Async function/custom tools with faithful call replay and conversation metadata

### Operational APIs

- Files, uploads, batches, fine-tuning, moderations, evals, and model management
- Conversations, containers, content provenance checks, ChatKit, and skills
- Assistants and vector stores (deprecated — use Responses API instead)

See [API Coverage](#api-coverage) for the full coverage table.

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- Supports OpenAI generation, media, operational, and Realtime APIs; see the coverage table for remaining gaps.
- Resource-based API design matching official SDKs.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

Requires Dart 3.12 or later. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

```yaml
dependencies:
  openai_dart: ^10.0.1
```

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      CreateResponseRequest(
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

### Import structure

The package provides multiple entry points for different APIs:

```dart
// Main entry point (recommended) — includes Chat Completions, Responses API,
// Embeddings, Images, Videos, Audio, Files, Batches, Fine-tuning, and more.
import 'package:openai_dart/openai_dart.dart';

// Assistants API (deprecated — use Responses API instead)
import 'package:openai_dart/openai_dart_assistants.dart' as assistants;

// Realtime API — WebSocket and WebRTC sessions
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;
```

## Configuration

<details>
<summary><b>Configure auth, retries, and custom endpoints</b></summary>

Use `OpenAIClient.fromEnvironment()` for the default `OPENAI_API_KEY` workflow. Switch to `OpenAIConfig` when you need a proxy, custom timeout, or a non-default retry policy.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient(
  config: OpenAIConfig(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
    baseUrl: 'https://api.openai.com/v1', // Default
    timeout: Duration(minutes: 10),
    connectTimeout: Duration(seconds: 30),
    retryPolicy: RetryPolicy(maxRetries: 3),
    organization: 'org-xxx', // Optional
    project: 'proj-xxx', // Optional
  ),
);
```

**From environment variables:**

```dart
final client = OpenAIClient.fromEnvironment();
// Reads OPENAI_API_KEY, OPENAI_BASE_URL, OPENAI_ORG_ID, OPENAI_PROJECT_ID
```

**With API key directly:**

```dart
final client = OpenAIClient.withApiKey('sk-...');
```

**Custom base URL (for proxies or Azure):**

```dart
final client = OpenAIClient(
  config: OpenAIConfig(
    baseUrl: 'https://my-resource.openai.azure.com/openai/deployments/my-deployment',
    authProvider: AzureApiKeyProvider('YOUR_AZURE_KEY'),
  ),
);
```

</details>

## Usage

### How do I classify or score shared input?

The [Decisions API](https://developers.openai.com/api/docs/guides/decisions) returns ordered typed answers to predicate, choice, and score questions. It currently supports `gpt-6-luna` and accepts text or inline images.

```dart
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
  } else if (answer case RefusalDecisionAnswer()) {
    print('The question was refused.');
  }
}
```

Use `DecisionInput.messages` with `DecisionContent.parts` for mixed text/image input. `DecisionInputPart.image(imageUrl: ...)` accepts a data URL; `DecisionInputPart.imageBytes(bytes, mediaType: 'image/png')` builds the MIME/base64 data URL. Files, external image URLs, other roles, tools, and audio are unsupported. Unset image detail defaults to `auto` on the server.

Requests support 1–200 questions, 2–255 choices per choice question, 2–10 levels per score question, and up to 128 images across all messages. An optional `safetyIdentifier` is limited to 128 characters. Choice values preserve strings and booleans as distinct types; score answers can be fractional. Refusals can occur alongside successful answers. There is no model-event streaming mode.

→ [Full example](example/decisions_example.dart)

### How do I configure an execution container?

Create a standalone container with a memory tier and network policy, then pass its ID to Code Interpreter:

```dart
final container = await client.containers.create(
  CreateContainerRequest(
    name: 'my-container',
    memoryLimit: ContainerMemoryLimit.gb1,
    networkPolicy: ContainerNetworkPolicy.disabled,
  ),
);

final tool = ResponseTool.codeInterpreter(
  container: CodeInterpreterContainer.id(container.id),
);
// Use tool in a Responses request, then delete the container when finished.
await client.containers.delete(container.id);
```

The current memory tiers are `gb1`, `gb4`, `gb16`, and `gb64`, which emit `1g`, `4g`, `16g`, and `64g`. Automatic containers accept the same configuration through `CodeInterpreterContainer.auto(...)`. An allowlist uses `ContainerNetworkPolicy.allowlist(['api.example.com'], domainSecrets: [...])`, with typed `ContainerNetworkPolicyDomainSecret` entries. Secret values are redacted in model diagnostics.

Standalone creation also supports `ContainerSkill.reference(skillId: ..., version: 'latest')` and inline skills whose `ContainerSkillSource.base64(data: ...)` contains an already encoded ZIP bundle. Returned memory/network settings and expiration members can be absent; check them before use. Filter listing with `client.containers.list(name: 'my-container')`.

See the [migration guide](MIGRATION.md#upcoming-container-configuration-corrections) for changes to integer memory values, `allowedHosts`, required names, response expiration, and const construction.

→ [Full example](example/containers_example.dart)

### How do I create a response?

<details>
<summary><b>Show example</b></summary>

The Responses API is the recommended way to generate text. Pass a model and input, and access the result via `response.outputText`.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient.fromEnvironment();

final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-5.5',
    input: ResponseInput.text('What is the capital of France?'),
  ),
);

print('Response: ${response.outputText}');
print('Usage: ${response.usage}');

client.close();
```

→ [Full example](example/responses_example.dart)

</details>

### How do I use persistent Responses WebSockets?

<details>
<summary><b>Show example</b></summary>

On native Dart/Flutter, open an authenticated connection through the existing
client configuration and read its lane-aware envelopes:

```dart
final connection = await client.responses.connect();
final latest = <String, String>{};
final bothLaneCompletions = Completer<void>();
final subscription = connection.events.listen(
  (message) {
    if (message case ResponsesStreamEvent(
      streamId: final lane?,
      event: ResponseCompletedEvent(:final response),
    )) {
      latest[lane] = response.id;
      if (latest.containsKey('planner') &&
          latest.containsKey('research') &&
          !bothLaneCompletions.isCompleted) {
        bothLaneCompletions.complete();
      }
    } else if (message is ResponsesErrorEvent) {
      // Inspect message.error.code and message.status to choose lane recovery.
      if (!bothLaneCompletions.isCompleted) {
        bothLaneCompletions.completeError(
          StateError('A lane request failed.'),
        );
      }
    }
  },
  onError: (Object error) {
    // Protocol/transport failures are identifiable, payload-redacted exceptions.
    if (!bothLaneCompletions.isCompleted) {
      bothLaneCompletions.completeError(error);
    }
  },
  onDone: () {
    if (!bothLaneCompletions.isCompleted) {
      bothLaneCompletions.completeError(
        StateError('Connection closed before both lanes completed.'),
      );
    }
  },
);
try {
  await Future.wait<void>([
    Future<void>.sync(
      () => connection
        ..create(
          const CreateResponseRequest(
            model: 'gpt-6-sol',
            input: ResponseInput.text('Draft a plan.'),
          ),
          streamId: 'planner',
        )
        ..create(
          const CreateResponseRequest(
            model: 'gpt-6-sol',
            input: ResponseInput.text('Research the risks.'),
          ),
          streamId: 'research',
        ),
    ),
    bothLaneCompletions.future,
  ], eagerError: true);
} finally {
  try {
    await connection.close();
    await connection.done;
  } finally {
    await subscription.cancel();
  }
}
```

`streamId` routes events and orders requests within a lane; `previousResponseId`
selects ancestry. Continue with the actual returned ID and only new input. A lane
reused without a parent starts a new response. `generate: false` warms state and
returns an ID for subsequent chaining. These are WebSocket-only fields;
`ResponsesCreateEvent` composes the normal request, omits `stream`/false
`background`, rejects `background: true`, and retains `streamOptions`.

Response completion and request-scoped server errors leave the connection open.
`ResponsesErrorEvent` retains full error metadata and absent-versus-null
`code`/`param`. Shared events use `ResponsesStreamEvent.event`; future events
retain raw JSON. One socket reader emits interleaved envelopes. The first listener
receives buffered early events, including events before an early close; the default
opening capacity is 1,024 and overflow fails explicitly. After the first listener,
only active subscribers receive broadcasts. Cancelling a listener removes that
listener; explicitly await connection cleanup. `done` completes independently of
event draining. Close code/reason expose observed transport facts.

Browser WebSockets cannot send custom headers. Any configured auth/default/org/
project/version headers reject before dialing with proxy guidance. Use an explicit
headerless client configuration and an authenticated backend WebSocket proxy.
`additionalHeaders` and configured header precedence apply on native platforms;
`beta: true` forces the multi-agent opt-in header. `connector` is an injectable
seam, and `connectionTimeout` defaults to the configured connect timeout.

The current [WebSocket guide](https://developers.openai.com/api/docs/guides/websocket-mode)
describes 16 in-flight responses, 32 named lanes plus default, and a 60-minute
connection limit. On disconnection, recover manually using a stored response ID
or replay full context with no parent. A `store: false` fork should reach
`response.in_progress` before the source lane advances. Standalone compaction
starts a new chain using the complete returned compacted window. Mid-turn steering
is described below. Automatic recovery and multi-agent tool-result injection
remain planned follow-ups.

→ [Runnable offline example](example/responses_websocket_example.dart), with
warm-up, two lanes, incremental continuation and awaited cleanup for $0.

The shared annotation-added event accepts its required nullable annotation value.
See the [migration guide](MIGRATION.md#upcoming-nullable-streaming-annotations)
before dereferencing `OutputTextAnnotationAddedEvent.annotation`.

</details>

### How do I steer a running Responses request?

<details>
<summary><b>Show example</b></summary>

Send user input after the original `response.created`, then keep reading until
the successor completes:

```dart
final connection = await client.responses.connect();
final reader = StreamIterator(connection.events);
String? originalId;
String? successorId;
var completed = false;
try {
  connection.create(
    const CreateResponseRequest(
      model: 'gpt-6-sol',
      input: ResponseInput.text('Draft a project plan.'),
    ),
  );
  while (await reader.moveNext()) {
    final message = reader.current;
    if (message case ResponsesStreamEvent(
      event: ResponseCreatedEvent(:final response),
    )) {
      if (originalId == null) {
        originalId = response.id;
        connection.steer(
          previousResponseId: originalId,
          input: const ResponsesSteerInput.text('Keep the scope small.'),
        );
      } else {
        successorId = response.id; // The queued input is now committed.
      }
    } else if (message is ResponsesSteerAcceptedEvent) {
      // Save message.steer.id. Acceptance queues input; keep reading.
    } else if (message is ResponsesSteerPendingEvent) {
      // This minimal example has no tool runner. Return saved results through
      // one explicit create per parent on message.streamId; see the full example.
      throw StateError('The continuation needs saved tool results or approval.');
    } else if (message is ResponsesSteerFailedEvent ||
        message is ResponsesErrorEvent) {
      throw StateError('The request or steering failed.');
    } else if (message case ResponsesStreamEvent(event: ResponseFailedEvent())) {
      throw StateError('A response failed before the continuation completed.');
    } else if (message case ResponsesStreamEvent(
      event: ResponseIncompleteEvent(:final response),
    )) {
      if (response.id != originalId ||
          response.incompleteDetails?.reason != 'steered') {
        throw StateError('A response ended incomplete without successful steering.');
      }
    } else if (message case ResponsesStreamEvent(
      event: ResponseCompletedEvent(:final response),
    )) {
      if (successorId != null && response.id == successorId) {
        completed = true;
        break;
      }
    }
  }
  if (!completed) {
    throw StateError('Connection closed with an unknown steering outcome.');
  }
} finally {
  try {
    await connection.close();
    await connection.done;
  } finally {
    await reader.cancel();
  }
}
```

Steering supports the GPT-6 family in supported single-agent modes, without a
conversation binding or automatic compaction. Unsupported modes surface server
failures; the client does not maintain a model allowlist. `ResponsesSteerEvent`
contains only `type`, `previous_response_id` and `input`. `ResponsesSteerInput`
accepts text or a nonempty list of user messages containing text/image/file parts.
It excludes create settings, lane fields, message IDs/status and tool results.
`sendSteer` accepts an already-built event; `steer` is the convenience method.

`response.steer.accepted` queues the update; successor `response.created` commits
it. The original can end as incomplete with reason `steered` or complete normally
before that successor arrives. Steering does not rewrite emitted output, undo
actions or cancel tools already running.

For `waiting_for_required_input`, inspect `ResponsesSteerPendingEvent.requiredInput`.
Its seven typed stub kinds identify function, custom, computer, shell, apply-patch,
tool-search results or MCP approval; they are not complete result items. Use saved
results in one explicit `create` per parent on the original lane. That request uses
its own settings; the server prepends accepted steering. Several pending
submissions can share the same stubs, and a matching create can arrive before a
pending notification. Do not rerun tools or resend accepted input.

Pending reasons and failure codes remain open strings. A failure preserves the
original rejected raw input, optional allocated ID and lane, including future
metadata. A failure after acceptance retains the same steering ID. Correct invalid
input before deciding whether to submit it again. A missing acknowledgment or
disconnect leaves the outcome unknown; no frame is automatically replayed.

→ [Runnable offline steering example](example/responses_steering_example.dart)
demonstrates automatic continuation and two pending submissions sharing one saved
tool result, with exactly one continuation create and awaited cleanup for $0.
See [migration guidance](MIGRATION.md#upcoming-typed-steering-events) for exhaustive
WebSocket event switches and the [official steering guide](https://developers.openai.com/api/docs/guides/steering).

</details>

### How do I return client-discovered tools?

<details>
<summary><b>Show example</b></summary>

Configure client-side tool search, then return the complete definitions with the
original search call ID:

```dart
final first = await client.responses.create(
  const CreateResponseRequest(
    model: 'gpt-6-sol',
    input: ResponseInput.text('Find the inventory tools.'),
    tools: [
      ToolSearchTool(
        execution: ToolSearchExecutionType.client,
        description: 'Search a local tool catalog.',
        parameters: {
          'type': 'object',
          'properties': {'goal': {'type': 'string'}},
          'required': ['goal'],
          'additionalProperties': false,
        },
      ),
    ],
    parallelToolCalls: false,
  ),
);
final call = first.output.whereType<ToolSearchCallOutputItem>().single;
final callId = call.callId;
if (call.execution != ToolSearchExecutionType.client || callId == null) {
  throw StateError('Expected a client search call with an ID.');
}
// Resolve call.arguments against your catalog; check its JSON type first.
final next = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-sol',
    previousResponseId: first.id,
    input: ResponseInput.items([
      ToolSearchOutputItemParam(
        callId: callId,
        execution: ToolSearchExecutionType.client,
        tools: const [
          NamespaceTool(
            name: 'inventory',
            description: 'Inventory tools from the local catalog.',
            tools: [
              FunctionTool(name: 'get.status'),
              CustomTool(name: 'describe', format: {'type': 'text'}),
            ],
          ),
        ],
        status: ItemStatus.completed,
      ),
    ]),
  ),
);
```

Search outputs preserve complete function/custom definitions, including parameter
and output schemas, formats, allowed callers, deferred loading and async flags.
Nested discovered functions support dotted names and may contain only `type` and
`name`. Top-level discovered functions always serialize the required nullable
`parameters` and `strict` keys. For standalone discovered-definition JSON, use
`ResponseTool.fromToolSearchOutputJson` and `toToolSearchOutputJson`; ordinary
`NamespaceTool.fromJson` uses the narrower request naming rules.

Writable `ToolSearchCallItemParam.arguments` requires a JSON object. Returned
calls use `Object?` because their arguments may be any JSON value, including null
or a list. Check the type before indexing. Returned calls/results preserve null
hosted call IDs and require their execution, status and payload fields. Search
records from `responses.inputItems.list` use `ToolSearchCallResourceItem` and
`ToolSearchOutputResourceItem`; their explicit conversion methods create writable
items, and call conversion rejects non-object arguments. To retain raw output
history, `ResponseInput.fromOutputItems` accepts raw JSON maps.

The [tool-search guide](https://developers.openai.com/api/docs/guides/tools-tool-search)
documents hosted search and client continuation. The canonical writable discovered
namespace schema allows dotted function names, while the returned schema references
ordinary namespaces with narrower names. Search-result parsing deliberately uses
the discovered context to retain loaded definitions; this is a compatibility
interpretation of those sources. The canonical top-level function schema also
requires nullable keys that some guide examples omit.

→ [Runnable offline example](example/tool_search_example.dart), demonstrating two
local requests, the original call ID and complete discovered definitions without
an API key or tool execution. See the [migration guide](MIGRATION.md#upcoming-tool-search-fidelity)
for required constructor arguments and new `Item` variants.

</details>

### How do I select and inspect an access program?

<details>
<summary><b>Show example</b></summary>

Use `AccessProgramsParam` to select a cyber access program and inspect the effective
returned selection through `AccessProgramsBody`:

```dart
const request = CreateResponseRequest(
  model: 'gpt-6-sol',
  input: ResponseInput.text('Explain how to validate a patch in a test setup.'),
  accessPrograms: AccessProgramsParam(cyber: CyberAccessProgram.daybreakBlue),
);
final response = await client.responses.create(request);
print(response.accessPrograms?.cyber.toJson() ?? 'Not reported or implicit Standard');
```

`CyberAccessProgram` supports `standard`, `daybreakBlue` and `daybreakRed` with
their exact wire values. Omit `accessPrograms` or use `const AccessProgramsParam()`
to leave selection to the server. No default is inserted by the client. An implicit
Standard selection is reported as null by the server; explicit Standard retains
its returned object. Older responses that omit this metadata remain accepted.

Request JSON rejects supplied null, unsupported keys inside the selection object,
and invalid cyber values. Returned objects require a nonnull known `cyber` value;
extra returned fields remain tolerated. Clearing a Dart selection with
`copyWith(accessPrograms: null)` omits the request key. Ordinary, retrieved,
cancelled and streamed lifecycle responses retain the effective program, including
through `ResponseStreamAccumulator.response`.

Explicit selection requires compatible model and organization/project access; it
does not grant approval. Match the program to the model rather than the approval
level. Follow the current [Daybreak guide](https://developers.openai.com/api/docs/guides/daybreak)
for model eligibility, project setup, omission defaults and 400/403 errors. Usage
tiers such as Build, Launch and Grow are separate from access-program selection.

→ [Runnable offline example](example/access_programs_example.dart), demonstrating
omission, an empty selection and all three explicit values without an API key,
Daybreak provisioning or API charges.

</details>

### How do I observe compaction progress?

<details>
<summary><b>Show example</b></summary>

Enable inline compaction with context management and watch for the typed progress
event while continuing to consume the stream:

```dart
const request = CreateResponseRequest(
  model: 'gpt-6-astra',
  input: ResponseInput.text('Continue the current task.'),
  contextManagement: [
    ContextManagement.compaction(compactThreshold: 200000),
  ],
);
await for (final event in client.responses.createStream(request)) {
  switch (event) {
    case ResponseCompactionCompactingEvent(:final itemId, :final outputIndex):
      print('Compacting $itemId at output index $outputIndex.');
    case ResponseCompletedEvent():
      print('Response completed.');
    default:
      break;
  }
}
```

`ResponseCompactionCompactingEvent` carries required `sequenceNumber`,
`outputIndex` and `itemId`, plus optional beta `agent` metadata. It is nonterminal
and contains no summary or encrypted content. `ResponseStreamAccumulator` exposes
it through `latestEvent` while preserving response, text, reasoning and status.
The final response retains the opaque `CompactionOutputItem`.

The [compaction guide](https://developers.openai.com/api/docs/guides/compaction)
describes automatic threshold-based compaction and standalone `responses.compact`.
For standalone compaction, replay the complete returned output window with
`compacted.toInput()`. Existing context management,
explicit triggers and encrypted replay remain available; future event types still
use `UnknownEvent`.

→ [Runnable offline example](example/compaction_progress_example.dart), with no API
key or large context. See the [migration guide](MIGRATION.md#upcoming-compaction-progress)
when updating exhaustive switches or manual unknown-event handlers.

</details>

### How do I configure hosted shell and return local results?

<details>
<summary><b>Show example</b></summary>

Configure a hosted container, local runtime, or existing container on the shell
tool. Hosted configuration reuses container memory, network and skill models:

```dart
final hostedTool = ResponseTool.shell(
  environment: ShellToolEnvironment.containerAuto(
    memoryLimit: ContainerMemoryLimit.gb4,
    networkPolicy: ContainerNetworkPolicy.disabled,
    skills: const [ContainerSkill.reference(skillId: 'skill_uploaded')],
  ),
);
final localTool = ResponseTool.shell(
  environment: ShellToolEnvironment.local(
    skills: const [
      ShellLocalSkill(
        name: 'csv-summary',
        description: 'Summarize a local CSV dataset.',
        path: '/workspace/skills/csv-summary',
      ),
    ],
  ),
);
final request = CreateResponseRequest(
  model: 'gpt-6-astra',
  input: const ResponseInput.text('Summarize the dataset.'),
  tools: [hostedTool],
  toolChoice: ResponseToolChoice.shell(),
);
```

For a locally executed call, inspect the commands and apply your application's
execution policy. Return captured output on the original call ID and retain the
model's output limit. This snippet supplies synthetic output:

```dart
final continuation = CreateResponseRequest(
  model: 'gpt-6-astra',
  previousResponseId: response.id,
  input: ResponseInput.items([
    ShellCallOutputInputItem(
      callId: call.callId,
      maxOutputLength: call.action.maxOutputLength,
      output: const [
        ShellCallOutputContentInput(
          stdout: 'Synthetic summary: 12 rows.',
          stderr: '',
          outcome: ShellCallExitOutcome(exitCode: 0),
        ),
      ],
    ),
  ]),
);
```

Typed command added/delta/done and output-content delta/done events expose
`commandIndex`, `outputIndex`, sequence and optional agent metadata. Output
fragments carry independent stdout/stderr fields; empty fragments and obfuscation
stay intact. Completed lifecycle responses retain full results. There is no
automatic command runner or generalized shell-output accumulator.

The [shell guide](https://developers.openai.com/api/docs/guides/tools-shell) and
[skills guide](https://developers.openai.com/api/docs/guides/tools-skills) describe
hosted bundles versus local name/description/path skills. Hosted network access
requires organization configuration and an explicit request policy. Server limits
are 50 uploaded file IDs and 200 skills per environment; the SDK documents these
limits and leaves enforcement to the service. `container_auto` belongs on a
definition; direct call history allows only local/reference environments. Returned
local environments have no skills. `toShellCallInputItem()` and
`toShellCallOutputInputItem()` bridge output, input listings and conversation
items while omitting returned-only creator metadata.

→ [Runnable offline example](example/shell_tools_example.dart), with hosted
configuration, local continuation and typed stream events. It requires no API key,
creates no containers and executes no proposed commands. See
[migration guidance](MIGRATION.md#upcoming-shell-alignment) for corrected required
nullable returned keys and distinct writable DTOs.

</details>

### How do I filter web search and inspect image results?

<details>
<summary><b>Show example</b></summary>

`ResponseTool.webSearch()` and `WebSearchTool()` now default to GA `web_search`.
Use domain filters and image settings, then request results and source metadata:

```dart
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-astra',
    reasoning: const ReasoningConfig(effort: ReasoningEffort.low),
    input: const ResponseInput.text('Find images of the Golden Gate Bridge.'),
    tools: [
      ResponseTool.webSearch(
        filters: WebSearchFilters(
          allowedDomains: const ['nps.gov', 'wikimedia.org'],
          blockedDomains: const ['spam.example'],
        ),
        searchContentTypes: const [SearchContentType.image, SearchContentType.text],
        imageSettings: WebSearchImageSettings(maxResults: 3, caption: true),
      ),
    ],
    toolChoice: ResponseToolChoice.webSearch(),
    include: const [Include.webSearchResults, Include.webSearchActionSources],
  ),
);
for (final call in response.output.whereType<WebSearchCallOutputItem>()) {
  for (final result in call.results ?? <WebSearchResult>[]) {
    if (result case WebSearchImageResult(:final imageUrl, :final sourceWebsiteUrl)) {
      print('$imageUrl from $sourceWebsiteUrl');
    }
  }
}
```

Calls expose `WebSearchCallStatus`, typed search/open-page/find actions, and
`WebSearchActionSearch.sources`. Image results are separate from assistant text
and citations. Future action/result objects retain recursively immutable JSON;
no text-result shape is assumed. Optional null image metadata normalizes to
absence. Input listings and conversation items retain the same metadata, and
`toWebSearchCallItem()` supports typed history replay.

The [official guide](https://developers.openai.com/api/docs/guides/tools-web-search)
documents scheme-free domains (up to 100 in each allow/block list), positive
image counts, and `returnTokenBudget` for GPT-5+ reasoning web search. Use
`WebSearchReturnTokenBudget.unlimited` selectively; it can increase latency and
cost. Omission leaves the server's usual budget unchanged. `externalWebAccess:
false` selects cached content on the real service.

Explicit preview types remain available with `type: 'web_search_preview'` or
`'web_search_preview_2025_03_11'`; GA also accepts `'web_search_2025_08_26'`.
GA-only controls are rejected on preview tools. Block lists, return budgets,
GA image controls/results, and forced GA choice follow the guide ahead of the
canonical schema; these differences stay visible in verification evidence.

→ [Runnable local REST/SSE example](example/web_search_controls_example.dart),
without an API key or charges. See [migration guidance](MIGRATION.md#upcoming-ga-web-search-alignment)
for the GA default and status type changes.

</details>

### How do I use async function and custom tools?

<details>
<summary><b>Show example</b></summary>

Set `async: true` on a Responses function or custom tool to let the model continue
while your application runs that tool. Both tool definitions and returned calls
preserve omitted, false and true flags; `copyWith(async: null)` removes the flag.
The client provides typed contracts; your application owns tool execution and
returning the result.

```dart
final tool = ResponseTool.function(
  name: 'get_weather',
  async: true,
  strict: true,
  parameters: const {
    'type': 'object',
    'properties': {'city': {'type': 'string'}},
    'required': ['city'],
    'additionalProperties': false,
  },
);
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-astra',
    input: const ResponseInput.text('Look up the weather in Paris.'),
    tools: [tool],
  ),
);
final call = response.output.whereType<FunctionCallOutputItemResponse>().single;
// Run your application tool and keep call.callId associated with its result.
// If other turns happen, replace this with the latest response's ID.
final latestResponseId = response.id;
await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-astra',
    previousResponseId: latestResponseId,
    tools: [tool],
    input: ResponseInput.items([
      FunctionCallOutputItem.string(
        callId: call.callId,
        output: '{"city":"Paris","celsius":24}',
      ),
    ]),
  ),
);
```

`ResponseTool.custom(async: true, ...)` uses the same execution flag.
`CustomToolCallItem.toCustomToolCallInputItem()` supplies typed custom-call replay;
function replay preserves agent, namespace, caller, status and async metadata.
Custom replay omits output-only status/creator fields. Ordinary output/result
items do not gain an async flag.

The [official async guide](https://developers.openai.com/api/docs/guides/async-tool-calling)
documents support for GPT-6 Astra and later models. Use direct application tools,
not hosted tools or programmatic calls; in Multi-agent mode, do not combine async
with parallel tool calls. There is no dedicated async streaming event: existing
item-added/done and response lifecycle events carry the calls.

→ [Runnable function/custom example](example/async_tools_example.dart), using a
local transport with an intervening turn, no API key and no charges.

</details>

### How do I change reasoning effort during a conversation?

<details>
<summary><b>Show example</b></summary>

Append a `ConfigurationUpdateItem` before the next user message to change effort
for subsequent responses. Keep the request-level `ReasoningConfig` and stable
instructions unchanged so the original prompt prefix remains reusable for caching.

```dart
const baseline = ReasoningConfig(effort: ReasoningEffort.low);
final first = await client.responses.create(
  const CreateResponseRequest(
    model: 'gpt-6-astra',
    reasoning: baseline,
    input: ResponseInput.text('Draft a database migration plan.'),
  ),
);
final next = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-astra',
    reasoning: baseline,
    previousResponseId: first.id,
    input: ResponseInput.items([
      const ConfigurationUpdateItem(
        reasoning: ConfigurationUpdateReasoning(effort: ReasoningEffort.high),
      ),
      MessageItem.userText('Analyze failure modes and rollback steps.'),
    ]),
  ),
);
print(next.outputText);
```

The server keeps the selected effort until another update replaces it. Continue
with `previousResponseId`, or preserve updates in their original positions when
replaying history. `response.reasoning.effort` still reports request-level effort.

`ConfigurationUpdateReasoning` exposes only `effort`. Omitted reasoning and `{}`
remain distinct. Nullable input IDs and effort values accept null and serialize
as omission; supplied null reasoning is invalid. Responses input listings return
`ConfigurationUpdateItemResponse`; conversation items return
`ConversationConfigurationUpdateItem`. Both require an ID and provide
`toConfigurationUpdateItem()` for typed replay.

The [official reasoning guide](https://developers.openai.com/api/docs/guides/reasoning#change-reasoning-mid-conversation)
documents GPT-6 support in standard, single-agent mode. Avoid adjacent updates,
automatic compaction, automatic truncation, and standalone `/responses/compact`
for histories containing updates. After explicit `compaction_trigger` compaction,
insert a fresh update before the next user message. Normal caching requirements
still apply.

→ [Runnable local example](example/configuration_updates_example.dart) shows
low → high → high → low across four turns, without an API key or charges.

</details>

### How do I prewarm the prompt cache and inspect diagnostics?

<details>
<summary><b>Show example</b></summary>

On supported GPT-5.6 and later models, Responses uses
`ResponsePromptCacheOptionsParam` for mode/TTL, prewarming, and comparison IDs.
Chat and compaction use the narrower `PromptCacheOptionsParam` with mode/TTL only.
A reusable prefix must meet the model's minimum cacheable length (1,024 tokens
for GPT-5.6 and later). Supply your application's stable context as `stablePrefix`;
keep its content and cache-affecting settings stable.

```dart
final baseline = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-luna',
    input: ResponseInput.text(stablePrefix),
    promptCacheOptions: const ResponsePromptCacheOptionsParam(prewarm: true),
  ),
);
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-luna',
    input: ResponseInput.text(stablePrefix),
    promptCacheOptions: ResponsePromptCacheOptionsParam(
      ttl: PromptCacheTtl.minutes30,
      comparisonResponseId: baseline.id,
      prewarm: false,
    ),
  ),
);
if (response.promptCacheDiagnostics case PromptCacheMissDiagnostics(:final reason)) {
  print('Cache miss reason: ${reason.value}');
}
print('Cached tokens: ${response.usage?.inputTokensDetails?.cachedTokens}');
```

Use a recent completed baseline from the same organization. A comparison ID
requests diagnostics; it does not load conversation history or change caching.
Diagnostics can be absent, unavailable, or refer to an expired comparison.
A hit means no miss was detected for the comparison; usage counters measure
actual reuse and billing. Future diagnostic variants and reason strings are
preserved. During streaming, inspect `ResponseCompletedEvent.response`.

The existing retention control is deprecated and expresses a maximum policy;
modern TTL expresses a minimum lifetime. They are independent.
See the [migration guide](MIGRATION.md) for the Responses options type change and
[official diagnostics guide](https://developers.openai.com/api/docs/guides/prompt-caching/diagnostics).

→ [Runnable example with bounded output and cleanup](example/prompt_cache_example.dart)

</details>

### How do I use chat completions?

<details>
<summary><b>Show example</b></summary>

Use `client.chat.completions.create(...)` for multi-turn conversations. The `response.text` convenience getter returns the first choice's message content.

The API's existing `promptCacheRetention` setting is deprecated in favor of `prompt_cache_options.ttl`; cache-options alignment is tracked in [#322](https://github.com/davidmigloz/ai_clients_dart/issues/322). For the existing control, `PromptCacheRetention.h24` emits `24h`, while `inMemory` emits the canonical `in_memory`. GPT-5.5 and newer models support only `h24`; select `inMemory` only for models that support it. Legacy `in-memory` JSON still parses, and reserialization uses `in_memory`.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient.fromEnvironment();

final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.5',
    messages: [
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.user('What is the capital of France?'),
    ],
    maxTokens: 100,
    promptCacheRetention: PromptCacheRetention.h24,
  ),
);

// response.text is a convenience extension for the first choice's message content
print('Response: ${response.text}');
print('Finish reason: ${response.choices.first.finishReason}');
print('Usage: ${response.usage?.promptTokens} in, ${response.usage?.completionTokens} out');

// Build message lists fluently with extension methods
final messages = <ChatMessage>[]
  .withSystemMessage('You are helpful')
  .withUserMessage('Hello!');

client.close();
```

→ [Full example](example/chat_example.dart)

</details>

### How do I generate, replay, and stream Chat audio?

<details>
<summary><b>Show example</b></summary>

Use an audio-capable Chat model and request audio output. Complete output exposes
its ID, base64 data, transcript, and replay expiry; text can be null.

```dart
final completion = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-audio-1.5',
    messages: [ChatMessage.user('Say only OK.')],
    modalities: const [ChatModality.text, ChatModality.audio],
    audio: const ChatAudioConfig(
      voice: ChatAudioVoice.alloy,
      format: ChatAudioFormat.wav,
    ),
    maxCompletionTokens: 128,
    store: false,
  ),
);
if (completion.audio case final audio?) {
  final bytes = base64Decode(audio.data); // import dart:convert
  await File('reply.wav').writeAsBytes(bytes); // import dart:io
  print(audio.transcript);
  final reference = ChatMessage.assistant(
    audio: ChatAudio.reference(id: audio.id),
  );
  // Add reference to a later request before audio.expiresAt.
}
```

`ChatAudioReference` is ID-only; `ChatCompletionAudio` requires all four output
fields. You can reuse the returned assistant message directly: actual request
serialization projects its audio to `{id}` without sending data/transcript/expiry.
Local response serialization retains the complete output and provider extensions.

Stream with PCM16 output and pass events to `ChatStreamAccumulator`. Each
`ChatDelta.audio` is an independent partial update. `accumulator.audio` and each
`accumulator.choices[i].audio` expose stable `ChatAudioDelta` snapshots with
`isComplete`. Data/transcript fragments append separately; ID and expiry update
when supplied. Decode complete data once after accumulation. Usage-only events
and padding stay separate from audio.

`toChatCompletion()` retains complete audio and throws `StateError` if any choice
has incomplete audio, including after interruption; inspect partial snapshots
instead. Text-only conversion behaves as before. A pure final expiry-only update
can infer `stop` during final conversion when every audio field is present, while
raw event and snapshot finish metadata remain unchanged. Reset clears all audio.

→ [Runnable audio, replay, and streaming example](example/chat_audio_example.dart)

See the [official audio guide](https://developers.openai.com/api/docs/guides/audio-chat-completions)
and [migration guide](MIGRATION.md) for parsing and conversion boundaries.

</details>

### How do I stream responses?

<details>
<summary><b>Show example</b></summary>

Streaming returns content deltas plus metadata as they arrive. Request final usage
with `includeUsage`; its additional chunk has an empty `choices` list. Use
`event.textDelta` to safely handle content and usage-only events.

```dart
final accumulator = ChatStreamAccumulator();
final stream = client.chat.completions.createStream(
  ChatCompletionCreateRequest(
    model: 'gpt-6-luna',
    reasoningEffort: ReasoningEffort.none,
    messages: [ChatMessage.user('Tell me a short story')],
    maxCompletionTokens: 64,
    store: false,
    streamOptions: const StreamOptions(
      includeUsage: true,
      includeObfuscation: true,
    ),
  ),
);
await for (final event in stream) {
  accumulator.add(event);
  stdout.write(event.textDelta ?? '');
}
final completion = accumulator.toChatCompletion();
print(completion.usage?.promptTokensDetails?.cacheWriteTokens);
print(completion.usage?.promptTokensDetails?.textTokens);
print(completion.usage?.promptTokensDetails?.imageTokens);
print(completion.usage?.completionTokensDetails?.textTokens);
```

Prompt details preserve audio, cached, unadjusted cache-write, image, and text
counts. Completion details preserve audio, reasoning, prediction, and text counts.
These details also work on ordinary completions; missing counters remain absent,
and zero remains zero. Interrupted streams can end before final usage arrives.

`includeObfuscation` controls server padding that normalizes streamed payload
sizes. Omit it to keep the server default (enabled), or set it to false to reduce
bandwidth when you trust the network links. `ChatStreamEvent.obfuscation` exposes
padding as metadata, including an empty string. It never becomes accumulated
text, refusal, reasoning, or tool arguments; `textDeltas()` and `collectText()`
also yield content only. The shared options model supports the flag on Responses
requests too; `includeUsage` is Chat-specific. See the
[official streaming reference](https://developers.openai.com/api/reference/resources/chat/subresources/completions/streaming-events)
for the wire contract.

→ [Full example](example/streaming_example.dart)

</details>

### How do I use tool calling?

<details>
<summary><b>Show example</b></summary>

Define tools with JSON Schema parameters and pass them in the request. The response indicates when the model wants to call a tool, and you can inspect the function name and arguments.

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.5',
    messages: [
      ChatMessage.user("What's the weather in Tokyo?"),
    ],
    tools: [
      Tool.function(
        name: 'get_weather',
        description: 'Get the current weather for a location',
        parameters: {
          'type': 'object',
          'properties': {
            'location': {'type': 'string', 'description': 'City name'},
          },
          'required': ['location'],
        },
      ),
    ],
  ),
);

if (response.hasToolCalls) {
  for (final toolCall in response.allToolCalls) {
    print('Function: ${toolCall.function.name}');
    print('Arguments: ${toolCall.function.arguments}');
  }
}
```

→ [Full example](example/tool_calling_example.dart)

</details>

### How do I analyze images?

<details>
<summary><b>Show example</b></summary>

Pass image URLs or base64-encoded images as content parts alongside text in a user message.

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.5',
    messages: [
      ChatMessage.user([
        ContentPart.text('What is in this image?'),
        ContentPart.imageUrl('https://example.com/image.jpg'),
      ]),
    ],
  ),
);

print(response.text);
```

→ [Full example](example/vision_example.dart)

</details>

### How do I create embeddings?

<details>
<summary><b>Show example</b></summary>

Use `client.embeddings.create(...)` to generate vector representations of text. You can optionally reduce dimensions for smaller storage.

```dart
final response = await client.embeddings.create(
  EmbeddingRequest(
    model: 'text-embedding-3-small',
    input: EmbeddingInput.text('Hello, world!'),
    dimensions: 256, // Optional: reduce dimensions
  ),
);

final vector = response.firstEmbedding;
print('Embedding dimensions: ${vector.length}');
```

→ [Full example](example/embeddings_example.dart)

</details>

### How do I generate and edit images with GPT Image 2.5?

<details>
<summary><b>Show example</b></summary>

Use `ImageModels.gptImage25Flare` for fast generation and editing, or
`ImageModels.gptImage25Sunburst` for precise edits and detailed creative work.
Both models support `low`, `medium`, `high`, `xhigh`, `max`, and `auto` quality,
custom sizes, and transparent backgrounds with PNG or WebP output.

```dart
import 'dart:convert';
import 'dart:io';

final response = await client.images.generate(
  const ImageGenerationRequest(
    model: ImageModels.gptImage25Flare,
    prompt: 'A cute robot holding a flower',
    size: ImageSize.custom('1536x864'),
    quality: ImageQuality.xhigh,
    background: ImageBackground.transparent,
    outputFormat: ImageOutputFormat.webp,
  ),
);

// GPT image models return base64 image data.
final b64 = response.data.first.b64Json;
if (b64 != null) {
  File('robot.webp').writeAsBytesSync(base64Decode(b64));
}

final edited = await client.images.editJson(
  const ImageEditJsonRequest(
    model: ImageModels.gptImage25Sunburst,
    images: [ImageReference.url('https://example.com/source.png')],
    prompt: 'Change only the flower to a sunflower',
    quality: ImageQuality.max,
    size: ImageSize.custom('1536x864'),
  ),
);
```

`ImageGenerationRequest` and multipart `ImageEditRequest` require an explicit
nonnull `model`, including for `generateStream` and `editStream`. String IDs are
forwarded unchanged; constants are conveniences rather than an allowlist.
`ImageEditJsonRequest` has a distinct optional/nullable model: omission keeps the
server's `gpt-image-2.5-sunburst` default, and an explicit ID overrides it.

Use `client.images.edit(...)` to upload image bytes, or `editJson(...)` for
up to 16 image references (URLs, data URLs, or uploaded file IDs). The streaming
variants are `generateStream`, `editStream`, and `editJsonStream`.
Snapshot constants are also available: `gptImage25Sunburst20260908` and
`gptImage25Flare20260908`.

→ [Full image example](example/images_example.dart) and
[local model-selection example](example/image_model_selection_example.dart)

See the [generation reference](https://developers.openai.com/api/reference/resources/images/methods/generate),
[editing reference](https://developers.openai.com/api/reference/resources/images/methods/edit),
and [migration guide](MIGRATION.md).

</details>

### How do I use audio?

<details>
<summary><b>Show example</b></summary>

The audio API supports both text-to-speech and speech-to-text. Use `client.audio.speech.create(...)` for TTS and `client.audio.transcriptions.create(...)` for transcription.

**Text-to-Speech:**

```dart
final audioBytes = await client.audio.speech.create(
  SpeechRequest(
    model: 'tts-1',
    input: 'Hello! How are you today?',
    voice: SpeechVoice.nova,
  ),
);

File('output.mp3').writeAsBytesSync(audioBytes);
```

**Speech-to-Text:**

```dart
final response = await client.audio.transcriptions.create(
  TranscriptionRequest(
    file: File('audio.mp3').readAsBytesSync(),
    filename: 'audio.mp3',
    model: 'whisper-1',
  ),
);

print('Transcription: ${response.text}');
```

→ [Full example](example/audio_example.dart)

</details>

### How do I use the Realtime API?

<details>
<summary><b>Show example</b></summary>

The Realtime API supports two transports: WebSocket for persistent bidirectional streaming, and WebRTC for browser-friendly audio sessions.

**WebSocket:**

```dart
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

final client = OpenAIClient.fromEnvironment();

// Connect to a realtime session via WebSocket
final session = await client.realtime.connect(
  model: 'gpt-realtime-2',
  config: const realtime.RealtimeSessionCreateRequest(
    model: 'gpt-realtime-2',
    audio: realtime.RealtimeAudioConfig(
      output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
    ),
    instructions: 'You are a helpful assistant.',
  ),
);

// Send a user text message and process events until the response is complete.
// (Use `session.appendAudioBytes(rawPcmBytes)` to stream raw audio instead.)
session.sendUserMessage('Say hello and nothing else.');

await for (final event in session.events) {
  switch (event) {
    case realtime.SessionCreatedEvent(:final session):
      print('Session created: ${session.id}');
    case realtime.ResponseTextDeltaEvent(:final delta):
      stdout.write(delta);
    case realtime.ResponseDoneEvent():
      await session.close();
    case realtime.ErrorEvent(:final error):
      print('Error: ${error.message}');
      await session.close();
    default:
      break;
  }
}

client.close();
```

**WebRTC:**

> **Note:** For WebRTC peer connections in Flutter, use the
> [`flutter_webrtc`](https://pub.dev/packages/flutter_webrtc) package.

```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

final client = OpenAIClient.fromEnvironment();

// 1. Create a peer connection and generate an SDP offer
final pc = await createPeerConnection({'iceServers': []});
final offer = await pc.createOffer();
await pc.setLocalDescription(offer);

// 2. Send the SDP offer to OpenAI and get the SDP answer
final sdpAnswer = await client.realtimeSessions.calls.create(
  realtime.RealtimeCallCreateRequest(
    sdp: offer.sdp!,
    session: const realtime.RealtimeSessionCreateRequest(
      model: 'gpt-realtime-2',
      audio: realtime.RealtimeAudioConfig(
        output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
      ),
    ),
  ),
);

// 3. Set the SDP answer to complete the WebRTC handshake
await pc.setRemoteDescription(RTCSessionDescription(sdpAnswer, 'answer'));

// Call management operations (callId is obtained from your SIP/telephony layer)
const callId = 'call_xxx';

// Accept the call (optionally override the session configuration on accept).
await client.realtimeSessions.calls.accept(
  callId,
  request: const realtime.RealtimeSessionCreateRequest(
    model: 'gpt-realtime-2',
    audio: realtime.RealtimeAudioConfig(
      output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
    ),
    instructions: 'Greet the caller in English.',
  ),
);
await client.realtimeSessions.calls.hangup(callId);
await client.realtimeSessions.calls.refer(
  callId,
  realtime.RealtimeCallReferRequest(targetUri: 'tel:+14155550123'),
);
await client.realtimeSessions.calls.reject(
  callId,
  request: realtime.RealtimeCallRejectRequest(statusCode: 486),
);

client.close();
```

→ [Full example](example/realtime_example.dart)

</details>

### How do I generate videos?

<details>
<summary><b>Show example</b></summary>

Use `client.videos.create(...)` to generate videos from text prompts with Sora. Poll with `retrieve` until the video is complete, then download the content.

```dart
final video = await client.videos.create(
  CreateVideoRequest(
    prompt: 'A cat playing piano in a jazz club',
    model: 'sora-2',
    size: VideoSize.size1280x720,
    seconds: VideoSeconds.s8,
  ),
);

final status = await client.videos.retrieve(video.id);
if (status.isCompleted) {
  final content = await client.videos.retrieveContent(video.id);
}
```

→ [Full example](example/videos_example.dart)

</details>

### How do I manage files?

<details>
<summary><b>Show example</b></summary>

Use the files API to upload, list, and retrieve file content. Files are used for fine-tuning, batches, and other workflows.

```dart
final file = await client.files.upload(
  bytes: fileBytes,
  filename: 'training.jsonl',
  purpose: FilePurpose.fineTune,
);

final files = await client.files.list();
final content = await client.files.retrieveContent(file.id);
```

→ [Full example](example/files_example.dart)

</details>

### How do I fine-tune a model?

<details>
<summary><b>Show example</b></summary>

Create a fine-tuning job by specifying a base model and a training file. Poll the job status to monitor progress and retrieve the fine-tuned model name when complete.

```dart
final job = await client.fineTuning.jobs.create(
  CreateFineTuningJobRequest(
    model: 'gpt-4o-mini-2024-07-18',
    trainingFile: 'file-abc123',
  ),
);

final status = await client.fineTuning.jobs.retrieve(job.id);
print('Fine-tuned model: ${status.fineTunedModel}');
```

→ [Full example](example/fine_tuning_example.dart)

</details>

### How do I use batch processing?

<details>
<summary><b>Show example</b></summary>

Batches let you queue many requests for asynchronous processing at lower cost. Create a batch from an input file and poll for completion.

```dart
final batch = await client.batches.create(
  CreateBatchRequest(
    inputFileId: 'file-abc123',
    endpoint: BatchEndpoint.chatCompletions,
    completionWindow: CompletionWindow.hours24,
  ),
);

final status = await client.batches.retrieve(batch.id);
print('Status: ${status.status}');
```

→ [Full example](example/batches_example.dart)

</details>

### How do I evaluate models?

<details>
<summary><b>Show example</b></summary>

Use the evals API to create evaluation definitions with grading criteria, then run them against test data to measure model performance.

```dart
final eval = await client.evals.create(
  CreateEvalRequest(
    name: 'My Evaluation',
    dataSourceConfig: EvalDataSourceConfig.custom(
      itemSchema: {
        'type': 'object',
        'properties': {
          'prompt': {'type': 'string'},
          'expected': {'type': 'string'},
        },
      },
    ),
    testingCriteria: [
      EvalGrader.stringCheck(
        name: 'matches_expected',
        input: '{{sample.output_text}}',
        operation: StringCheckOperation.ilike,
        reference: '%{{item.expected}}%',
      ),
    ],
  ),
);

final run = await client.evals.runs.create(
  eval.id,
  CreateEvalRunRequest(
    dataSource: EvalRunDataSource.jsonlContent([
      {'prompt': 'Say hello', 'expected': 'hello'},
    ]),
  ),
);
```

→ [Full example](example/evals_example.dart)

</details>

### How do I moderate content?

<details>
<summary><b>Show example</b></summary>

Use the moderations API to check whether text violates content policies. The result indicates whether the input was flagged.

```dart
final result = await client.moderations.create(
  ModerationRequest(
    input: ModerationInput.text('Check this text'),
  ),
);
print('Flagged: ${result.results.first.flagged}');
```

→ [Full example](example/moderation_example.dart)

</details>

### How do I check content provenance?

<details>
<summary><b>Show example</b></summary>

Use the content provenance checks API to detect OpenAI C2PA/SynthID signals in an uploaded image or audio file. Results are a sealed union — dispatch on the concrete type to read the fields specific to each signal.

```dart
final check = await client.contentProvenanceChecks.create(
  bytes: File('image.png').readAsBytesSync(),
  filename: 'image.png',
);

for (final result in check.results) {
  switch (result) {
    case C2PAProvenanceResult():
      print('C2PA: ${result.outcome}, trust: ${result.validationState}');
    case SynthIDProvenanceResult():
      print('SynthID: ${result.outcome}');
    case UnknownProvenanceResult():
      print('Unrecognized signal: ${result.type}');
  }
}
```

→ [Full example](example/content_provenance_checks_example.dart)

</details>

## Error Handling

<details>
<summary><b>Handle retries, validation failures, and request aborts</b></summary>

`openai_dart` throws typed exceptions so retry logic and validation handling stay explicit. Catch `ApiException` and its subclasses first, then fall back to `OpenAIException` for other transport or parsing failures.

```dart
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('Ping'),
      ),
    );
  } on RateLimitException catch (error) {
    stderr.writeln('Rate/quota error ${error.code ?? error.type}: ${error.message}');
    stderr.writeln('Server retry hint: ${error.retryAfter}');
    // Billing/spend/quota errors require action before resending.
  } on InternalServerException catch (error) {
    stderr.writeln('Server error ${error.statusCode}; hint: ${error.retryAfter}');
  } on ApiException catch (error) {
    stderr.writeln('OpenAI API error ${error.statusCode}: ${error.message}');
  } on OpenAIException catch (error) {
    stderr.writeln('OpenAI client error: $error');
  } finally {
    client.close();
  }
}
```

Regular cloneable requests retry transient 429 responses and retry
5xx/timeouts/connections only for idempotent methods. Structured billing/spend/quota
429 codes and `insufficient_quota` type require action and stop automatic retries.
Unknown provider 429 bodies retain the existing fallback. POST 5xx, multipart
requests, and streams are not automatically replayed.

`retry-after-ms` takes precedence when valid; otherwise `Retry-After` accepts
seconds or HTTP dates. Fractional hints remain precise, scheduled waits round
up, and past dates mean zero. A valid hint above twice `RetryPolicy.maxDelay`
returns the original error immediately with its full `retryAfter`; shorter
automatic replay would violate the server minimum. This hint is exposed on
both `RateLimitException` and `InternalServerException`, including before a
stream starts. `maxRetries: 0` disables automatic retries for application-owned
retry loops. Cancellation can interrupt permitted waits.

→ [Error-handling example](example/error_handling_example.dart) and
[local retry/quota example](example/retry_guidance_example.dart)

See the [official retry guidance](https://developers.openai.com/api/docs/guides/rate-limits)
and [migration guide](MIGRATION.md) for exact boundaries.

</details>

## Examples

See the [example/](example/) directory for complete examples:

| Example | Description |
|---------|-------------|
| [`chat_example.dart`](example/chat_example.dart) | Chat completions, multi-turn conversations, and legacy cache retention |
| [`streaming_example.dart`](example/streaming_example.dart) | Content streaming, detailed final usage, and obfuscation controls |
| [`tool_calling_example.dart`](example/tool_calling_example.dart) | Function calling with tool definitions |
| [`vision_example.dart`](example/vision_example.dart) | Image analysis with vision models |
| [`responses_example.dart`](example/responses_example.dart) | Responses API with built-in tools |
| [`async_tools_example.dart`](example/async_tools_example.dart) | Local async function/custom jobs, original call IDs and latest-response continuation |
| [`prompt_cache_example.dart`](example/prompt_cache_example.dart) | Responses prewarming, comparison diagnostics, and narrow Chat cache options |
| [`decisions_example.dart`](example/decisions_example.dart) | Typed Decisions questions, refusals, usage, and inline images |
| [`embeddings_example.dart`](example/embeddings_example.dart) | Text embeddings with dimension control |
| [`image_model_selection_example.dart`](example/image_model_selection_example.dart) | Local generation/multipart/JSON-edit model contracts without API calls |
| [`images_example.dart`](example/images_example.dart) | GPT Image generation |
| [`videos_example.dart`](example/videos_example.dart) | Sora video generation, editing, and extension |
| [`audio_example.dart`](example/audio_example.dart) | Text-to-speech and transcription |
| [`chat_audio_example.dart`](example/chat_audio_example.dart) | Chat audio output, ID-only replay, and partial stream accumulation |
| [`files_example.dart`](example/files_example.dart) | File upload and management |
| [`conversations_example.dart`](example/conversations_example.dart) | Conversations API for state management |
| [`containers_example.dart`](example/containers_example.dart) | Container memory/network configuration, Code Interpreter IDs, and files |
| [`chatkit_example.dart`](example/chatkit_example.dart) | ChatKit sessions and threads |
| [`assistants_example.dart`](example/assistants_example.dart) | Assistants API (deprecated) |
| [`evals_example.dart`](example/evals_example.dart) | Model evaluation and testing |
| [`retry_guidance_example.dart`](example/retry_guidance_example.dart) | Local transient, permanent-quota, and long-hint scenarios without API calls |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`models_example.dart`](example/models_example.dart) | Model listing and retrieval |
| [`batches_example.dart`](example/batches_example.dart) | Batch processing for async jobs |
| [`moderation_example.dart`](example/moderation_example.dart) | Content moderation |
| [`content_provenance_checks_example.dart`](example/content_provenance_checks_example.dart) | Content provenance (C2PA/SynthID) detection |
| [`web_search_example.dart`](example/web_search_example.dart) | Web search with Responses API |
| [`web_search_controls_example.dart`](example/web_search_controls_example.dart) | Local GA filters, image results, sources, and REST/SSE parsing without API calls |
| [`shell_tools_example.dart`](example/shell_tools_example.dart) | Offline hosted configuration, synthetic local continuation, and typed shell stream events |
| [`compaction_progress_example.dart`](example/compaction_progress_example.dart) | Offline nonterminal compaction progress and opaque final output preservation |
| [`access_programs_example.dart`](example/access_programs_example.dart) | Offline access-program selection, server defaults and effective returned metadata |
| [`tool_search_example.dart`](example/tool_search_example.dart) | Offline client tool-search continuation with the original call ID and complete discovered definitions |
| [`responses_websocket_example.dart`](example/responses_websocket_example.dart) | Offline warm-up, two persistent lanes and incremental continuation with awaited cleanup |
| [`realtime_example.dart`](example/realtime_example.dart) | Realtime API (WebSocket and WebRTC) |
| [`fine_tuning_example.dart`](example/fine_tuning_example.dart) | Fine-tuning job management |
| [`completions_example.dart`](example/completions_example.dart) | Legacy completions API |
| [`uploads_example.dart`](example/uploads_example.dart) | Large file multipart uploads |
| [`skills_example.dart`](example/skills_example.dart) | Skills management |
| [`input_tokens_example.dart`](example/input_tokens_example.dart) | Input token counting |
| [`openai_dart_example.dart`](example/openai_dart_example.dart) | Quick-start overview |

## API Coverage

| API | Status |
|-----|--------|
| Chat Completions | Supported; stored-completion management pending |
| Responses API | Supported with persistent WebSockets and mid-turn steering; automatic recovery, tool-result injection and additional tool/configuration details pending |
| Decisions API | ✅ Full |
| Embeddings | ✅ Full |
| Images | ✅ Full |
| Videos (Sora) | ✅ Full |
| Audio (Speech, Transcription, Translation) | Supported; custom voices and some speech options pending |
| Files | ✅ Full |
| Uploads | ✅ Full |
| Batches | ✅ Full |
| Models | ✅ Full |
| Moderations | ✅ Full |
| Fine-tuning | Supported; some job/grader/checkpoint operations pending |
| Evals | ✅ Full |
| Conversations | ✅ Full |
| Containers | Supported with memory, network policies/domain secrets, and skill configuration |
| Content Provenance Checks | ✅ Full |
| ChatKit Beta | ✅ Full |
| Realtime | ✅ Full (separate import) |
| Assistants (Deprecated) | ✅ Full (separate import) |
| Threads (Deprecated) | ✅ Full (separate import) |
| Messages (Deprecated) | ✅ Full (separate import) |
| Runs (Deprecated) | ✅ Full (separate import) |
| Vector Stores (Deprecated) | ✅ Full (separate import) |
| Completions (Legacy) | ✅ Full |

Agents, Live, safety retrieval, webhook management, vaults, and Administration remain part of the [API alignment roadmap](specs/api-alignment/README.md).

## Official Documentation

- [API reference](https://pub.dev/documentation/openai_dart/latest/)
- [OpenAI API docs](https://platform.openai.com/docs/api-reference)
- [OpenAI Python SDK](https://github.com/openai/openai-python)
- [OpenAI Node.js SDK](https://github.com/openai/openai-node)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by OpenAI.
