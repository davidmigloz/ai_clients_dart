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

### Generation and streaming

- Messages with typed inputs, system prompts, and multi-turn history
- Mid-conversation system messages (`InputMessage.system`), turn-scoped reminders (`clearAt`), and per-message effort (`InputMessage.systemEffort`) inside the messages array, no user turn required
- SSE streaming with cancelation and token counting
- Adaptive and extended thinking controls, with `outputTokensDetails` reasoning-token breakdown, typed `thinking`/`redacted_thinking` input blocks, `Message.toInputMessage()` for multi-turn replay, `display: updates` progress updates, and preserved-thinking block-binding controls with `inputTransformations` reporting (beta)
- Prompt-cache diagnostics on the Claude API report where the cache prefix diverged between turns
- Server-held Messages threads, context editing, threshold compaction, and signed on-demand compaction (beta)
- Server-side fallback: automatically re-run refused requests on another model via the `fallbacks` chain (or Anthropic's `FallbacksParam.defaultMode()` recommendations), or retry manually with the refusal `fallback_credit_token` — including best-effort redemption mode and per-response `fallback_credit` usage outcomes (beta)

### Tools and multimodal

- Custom tool calling with strict schemas and tool choice controls
- Mid-conversation tool changes: add or remove tools between turns with `tool_addition`/`tool_removal` blocks while preserving the prompt cache (beta)
- Computer-use and browser-use toolsets (`computer_toolset_20260801` / `browser_toolset_20260801` with per-member configs and `browser_state` results), web search, code execution, advisor, and MCP tool integration
- Vision and document inputs with citations, an oversized-image policy via `transformations`, plus your own cited `search_result` blocks (RAG)

### Operational APIs

- Message batches for large-scale offline processing
- Compliance Activity Feed, directory, organization settings, app content, sessions, and artifact downloads. Security Posture is beta.
- Model discovery with lifecycle filters, model lines, and thinking and server-tool capabilities
- Organization Admin API for keys, users, invites, workspaces, rate limits and compliance settings
- Files (expiration, cursor pagination) and skills (multi-file uploads, container skills)
- Managed agents with sessions, thread status filters, execution principals, tool permission evaluation, vaults, and streaming events (beta)
- Scheduled deployments: run agent sessions on a cron schedule, with deployment runs, pause/resume, and run-now (beta)
- Multiagent orchestration with dynamic workflows, subagents, and an advisor, plus per-tool configs, session budgets, and outcome evaluations (beta)
- Typed webhook event parsing and MCP-OAuth / static-bearer / environment-variable credential validation (beta)
- Memory stores for persistent agent memories with versioning and redaction (beta)
- Dreams: asynchronous memory-consolidation jobs over memory stores and session transcripts, with `create_new`/`update_existing` output behavior (beta, research preview)
- Generally available user profiles with end-customer attribution, enforcement filters, program status, and action URLs. The legacy beta profile methods remain available.

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and cancellation built into the client.
- Follows Anthropic resource naming closely, so official docs translate directly into Dart code.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

Requires Dart 3.12 or later. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

```yaml
dependencies:
  anthropic_sdk_dart: ^10.0.0
```

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
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

The client defaults to Claude API version `2026-10-21`. If your requests rely
on sampling parameters or other legacy input behavior, set
`apiVersion: AnthropicConfig.legacyApiVersion` in `AnthropicConfig`.
See the [API version migration](MIGRATION.md#claude-api-version-2026-10-21).

Set `AnthropicConfig.workspaceId` to select a workspace with a key that can
access multiple workspaces. Messages, Batches and Models also accept a
per-call `workspaceId`. Single-workspace keys can normally omit it. Claude
Platform on AWS requires workspace selection on workspace-scoped endpoints.
Workload Identity Federation tokens select their workspace at token exchange.
Use a new token exchange to change it.
[Workspace selection](https://platform.claude.com/docs/en/manage-claude/authentication#select-a-workspace)

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
        model: 'claude-sonnet-5',
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
        model: 'claude-sonnet-5',
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
        model: 'claude-sonnet-5',
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
    model: 'claude-sonnet-5',
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

Thinking is configured on the request, not through a separate client. Current-generation models (Claude Sonnet 5, Opus 5, Fable 5.1) run adaptive thinking by default and reject `thinking: enabled`/`disabled`; use `ThinkingConfig.adaptive(...)` to control display and steer depth with `effort`. `ThinkingEnabled(budgetTokens:)` is only accepted by older models.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5',
        maxTokens: 1024,
        thinking: const ThinkingAdaptive(display: ThinkingDisplayMode.summarized),
        messages: [InputMessage.user('Explain the tradeoffs of isolates in Dart.')],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

For a multi-turn conversation (e.g. tool use), replay the assistant turn with `response.toInputMessage()` instead of hand-picking blocks — thinking blocks must be passed back unmodified and in their original order, or the API returns a 400 error. On Claude Fable 5.1 they are also bound to the conversation prefix: keep the history append-only (don't edit earlier turns, `system`, or `tools`), or opt into dropping invalidated blocks with `ThinkingBlockBinding(prefixMismatchBehavior: ThinkingPrefixMismatchBehavior.dropBlock)` under the `thinking-binding-controls-2026-08-01` beta and inspect `response.inputTransformations`.

```dart
final messages = [
  userMessage,
  response.toInputMessage(), // preserves thinking blocks + order
  // One tool_result per replayed tool_use block, or the API rejects the turn.
  InputMessage.userBlocks([
    for (final toolUse in response.toolUseBlocks)
      InputContentBlock.toolResult(
        toolUseId: toolUse.id,
        content: [ToolResultContent.text(toolResult)],
      ),
  ]),
];
```

→ [Full example](example/thinking_example.dart)

</details>

### How do I keep conversation state on the server?

<details>
<summary><b>Show example</b></summary>

Message threads are in beta on the Claude API, Claude Platform on AWS, Claude Models on Google Cloud (Anthropic managed), and Microsoft Foundry. Send `MessageThreadParam.create()` with the full first request and the `message-threads-2026-08-12` beta header. Continue with `MessageThreadParam.continueFrom(previous.id)`, new messages, and the same beta set. Omit `system` and `tools` on continuation requests.

Wait for `message_stop` before using a streamed response ID. `finalMessage()` returns the completed message or throws when the stream fails or ends early. If the turn refused or a fallback model wrote the reply, start a new thread. To recover from an expired thread, keep a local copy of your conversation and replay it in a new create request. The low-level calls send one logical request and leave replay to the caller.

Threads are unavailable to organizations using HIPAA readiness or Inference
hooks. They are ineligible for zero data retention. For token counting, send
the full history including system and tools. Batches report a thread-bearing
item as an individual request error.

Use `client.messages.createThread(request)` to track the conversation and its
latest usable response ID. The handle keeps routing and beta headers and
reuses the response container. Set `replayOnThreadError: true` to replay the
full history once when the API identifies an unusable continuation ID.
Replay resends earlier messages. The default surfaces the error to the caller.
After a stream ends early, call `send()` with no new messages to retry that turn.

[Runnable thread example](example/message_threads_example.dart) · [Runnable thread helper](example/message_thread_helper_example.dart) · [Claude message threads guide](https://platform.claude.com/docs/en/build-with-claude/message-threads)

</details>

### How do I compact a conversation?

<details>
<summary><b>Show example</b></summary>

Set `compaction: const CompactionConfig.summarize()` on a separate Messages request with the `compact-2026-09-04` beta header. Use a model with on-demand compaction capability. On success the response has `StopReason.compaction` and a signed `CompactionBlock`. Replace the summarized history with `summary.toInputMessage()` and send the same beta header when using the block. Keep the summary, signature, and tool changes together as returned. Keep the full conversation if compaction returns no valid summary.

For threshold compaction, configure `ContextManagementConfig` with a
`thresholdCompaction` edit and send `compact-2026-01-12`. Tool-result and
thinking-block clearing use `context-management-2025-06-27`. Inspect
`message.contextManagement?.appliedEdits` for edits the server applied. Beta
token counting can report the original input count. Send on-demand compaction
and context editing on separate requests. Threads only allow the context edit
that preserves all thinking blocks.

[Runnable context editing example](example/context_management_example.dart) · [Context editing guide](https://platform.claude.com/docs/en/build-with-claude/context-editing)

[Runnable compaction example](example/on_demand_compaction_example.dart) · [Claude on-demand compaction guide](https://platform.claude.com/docs/en/build-with-claude/compaction-on-demand)

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
        model: 'claude-sonnet-5',
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
          model: 'claude-sonnet-5',
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
              model: 'claude-sonnet-5',
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

Use `client.models.list()` to discover Claude models by lifecycle stage and inspect their capabilities. The default list includes active and deprecated models. Include `ModelLifecycle.retired` in the filter to list retired models.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.models.list(
      lifecycle: const [ModelLifecycle.active],
    );

    for (final model in response.data) {
      print('${model.id} — ${model.line ?? model.displayName}');
    }
  } finally {
    client.close();
  }
}
```

Use `client.models.retrieve(modelId)` to check capabilities for one model. For example, read `model.capabilities?.thinking.types.betweenTools?.supported` before using `ThinkingConfig.betweenTools()` with a compatible model. Read `model.capabilities?.serverTools` for code execution and web search availability.

Pass `betas: ['compact-2026-09-04']` to `list` or `retrieve` to request the beta on-demand compaction capability. Pass `workspaceId` to select a workspace when your credential can access several. A workspace-scoped credential can omit it or pass its own workspace ID.

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
      print('${skill.id}: ${skill.displayName}');
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

Use `client.agents`, `client.sessions`, and `client.vaults` for the Managed Agents beta API. Create an agent configuration, start sessions to interact with Claude, list session events and session thread events as the agent works, and store vault credentials securely.

Use `Multiagent20261001Params` to configure workflow workers, subagents, and the advisor. Agent and session responses expose the resolved topology. Updating a configuration within the same version preserves omitted fields, and an explicit `null` resets a field to its default.

The session event list and stream expose dynamic workflow progress as `WorkflowRunEvent`. A workflow error can arrive before the run is created, or before an existing run ends. Follow the terminal result through the workflow end event. Session and thread idle events also expose model refusals and their optional details. Retrieve the thread to inspect a `SessionInlineAgent` snapshot for an unsaved workflow worker. Use `SessionErrorEvent.errorDetails` for typed session errors and retry status. See the runnable [workflow example](example/managed_agents_workflow_example.dart).

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    // Create an agent
    final agent = await client.agents.create(
      const CreateAgentParams(
        name: 'My Agent',
        model: ModelParamsId(id: 'claude-sonnet-5'),
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

Agent execution defaults to the Anthropic-managed service account. On Claude Platform on AWS, configure `AgentExecutionIdentity.awsRole(arn)` for an IAM role. An explicit `executionIdentity: null` in `UpdateAgentParams` resets the principal.

Use `AutoPolicy()` for server-evaluated tool permissions and read the event's `evaluation` alongside `evaluatedPermission`. Web fetch can restrict which URL sources contribute candidates with `ManagedWebFetchUrlSources`. Claude applies those filters along with organization domain restrictions and the environment's network configuration.

→ [Full example](example/managed_agents_example.dart)

</details>

### How do I manage agent memory stores?

<details>
<summary><b>Show example</b></summary>

Use `client.memoryStores` to create persistent memory stores that can be mounted into agent sessions. The API supports memory CRUD, append-only versioning, and per-version redaction. This is a beta feature and the SDK sends the required `anthropic-beta` header automatically.

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    // Create a memory store and a memory inside it.
    final store = await client.memoryStores.create(
      CreateMemoryStoreParams(name: 'user-preferences'),
    );

    final memories = client.memoryStores.memories(store.id);
    final memory = await memories.create(
      const CreateMemoryParams(
        path: '/preferences/greeting.md',
        content: 'Prefer "Hi"',
      ),
    );

    // Update with an optional precondition.
    await memories.update(
      memory.id,
      UpdateMemoryParams(
        content: 'Prefer "Hello"',
        precondition: ContentSha256Precondition(
          contentSha256: memory.contentSha256,
        ),
      ),
    );

    // List versions, then archive and delete the store.
    final versions = await client.memoryStores
        .memoryVersions(store.id)
        .list(memoryId: memory.id);
    print('Versions: ${versions.data.length}');

    await client.memoryStores.archive(store.id);
    await client.memoryStores.delete(store.id);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/memory_stores_example.dart)

</details>

### How do I attribute Claude requests to a user profile?

<details>
<summary><b>Show example</b></summary>

Create a profile once for each customer in your onboarding flow and store its
ID. Reuse that ID on requests made on the customer's behalf.

```dart
final profiles = client.userProfiles.current;
final profile = await profiles.create(
  const CreateCurrentUserProfileRequest(
    externalUserDetails: UserProfileExternalUserDetails(referenceId: 'customer_123'),
  ),
);

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-5-5',
    maxTokens: 256,
    messages: [InputMessage.user('Summarize this support request.')],
  ),
  userProfileId: profile.id,
);
print(response.text);
```

The profile methods use the API key for the organization that owns the
profile. An Admin API key is unnecessary. The `userProfileId` argument
adds `anthropic-user-profile-id` to an inference request. It works with
Messages, token counting, and batch creation. On a batch it applies to all
entries.

Profile management is also available on Claude Platform on AWS with the
appropriate IAM actions. Anthropic-managed Google Cloud supports create, list,
retrieve, and update with Google Cloud credentials and its organization-level
base URL. The [Anthropic guide](https://platform.claude.com/docs/en/manage-claude/user-profiles#before-you-start)
lists cross-platform attribution requirements.

See [the user profiles example](example/current_user_profiles_example.dart)
for enforcement status and pagination. Treat an unfamiliar status as
restricted when deciding access, and preserve the wire value for diagnostics.
[Enforcement guidance](https://platform.claude.com/docs/en/manage-claude/user-profiles#check-whether-anthropic-has-restricted-or-banned-a-profile)

</details>

### How do I manage organization workspaces and access?

<details>
<summary><b>List workspaces with a scoped Admin key</b></summary>

Configure a separate client with a Claude Console Admin API key for
organization membership, invitations, API keys, workspace settings, and rate
limits. Select a workspace with the resource path or filter where applicable.

```dart
final admin = AnthropicClient.withApiKey(adminKey);
try {
  final organization = await admin.organization.retrieve();
  final workspaces = await admin.organization.workspaces.list(
    includeDefault: true,
    limit: 10,
  );
  print('${organization.name}: ${workspaces.data.length} workspaces');
} finally {
  admin.close();
}
```

[Runnable Admin example](example/organization_admin_example.dart) · [Claude Admin API](https://platform.claude.com/docs/en/manage-claude/admin-api)

</details>

### How do I use the Compliance API?

<details>
<summary><b>Read scoped Compliance activity, directory and content</b></summary>

Use a client configured with a separate Compliance Access Key. A Claude Console
Admin API key with `read:compliance_activities` can query the Activity Feed.
Use `read:compliance_org_data` for organizations, roles, groups, and effective
settings. Use `read:compliance_user_data` for organization users, member
preferences, and group members. Security Posture accepts
`read:compliance_org_data` or `read:org_audit`. Member preferences and Security
Posture are beta. Pass the organization UUID to organization-specific routes.
A key with `read:org_audit` can use the Compliance read endpoints.
Use a server or CLI when Compliance is enabled for the organization.

```dart
final client = AnthropicClient.withApiKey(complianceAccessKey);
try {
  final first = await client.compliance.listActivities(
    order: ComplianceOrder.asc,
    limit: 100,
  );
  if (first.hasMore && first.lastId != null) {
    final next = await client.compliance.listActivities(
      order: ComplianceOrder.asc,
      afterId: first.lastId,
      limit: 100,
    );
    // Process next.data in a secure destination.
  }
} finally {
  client.close();
}
```

Use one activity cursor at a time and keep its filters and order. For
incremental export, use overlapping `createdAt` windows and deduplicate by
activity ID so late-arriving records are included. Directory lists use the
opaque `nextPage` token. When listing preferences, pass the same `userIds`
and `includeUnset` values with each page, including after an empty page
that supplies a continuation token.

Use the Compliance apps resource at `client.compliance.apps` for chats, files,
projects, local and remote session transcripts, and Code Artifacts. Read access
requires a Compliance Access Key with `read:compliance_user_data` or
`read:org_audit`. Use the separate
`delete:compliance_user_data` scope for permanent deletions. Download methods
return streams of bytes and can report media type, disposition, checksum,
and request ID through `onResponse`. Code Artifact downloads accept
`allowZip: true` for multi-file content. Chat artifact version content is a
JSON object containing the version's text. Check that a binary transfer
completed before using its bytes.

[Activity Feed example](example/compliance_example.dart) · [Content example](example/compliance_content_example.dart) · [Compliance API access](https://platform.claude.com/docs/en/manage-claude/compliance-api-access) · [Directory guide](https://platform.claude.com/docs/en/manage-claude/compliance-org-data)

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
        model: 'claude-sonnet-5',
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
| [`api_version_example.dart`](example/api_version_example.dart) | Current API version and legacy opt-out |
| [`mid_conversation_system_example.dart`](example/mid_conversation_system_example.dart) | Mid-conversation, turn-scoped, and effort-only system messages |
| [`streaming_example.dart`](example/streaming_example.dart) | Streaming responses |
| [`tool_calling_example.dart`](example/tool_calling_example.dart) | Tool calling with schemas |
| [`web_search_example.dart`](example/web_search_example.dart) | Web search tool |
| [`advisor_example.dart`](example/advisor_example.dart) | Advisor tool (beta) |
| [`computer_use_example.dart`](example/computer_use_example.dart) | Computer-use toolset (`computer_toolset_20260801`) |
| [`browser_use_example.dart`](example/browser_use_example.dart) | Browser-use toolset with `browser_state` tool results |
| [`thinking_example.dart`](example/thinking_example.dart) | Adaptive thinking, progress updates, block binding, and multi-turn replay |
| [`diagnostics_example.dart`](example/diagnostics_example.dart) | Prompt-cache diagnostics on the Claude API |
| [`message_threads_example.dart`](example/message_threads_example.dart) | Create and continue a Messages thread (beta) |
| [`message_thread_helper_example.dart`](example/message_thread_helper_example.dart) | Track a thread and opt into bounded recovery (beta) |
| [`on_demand_compaction_example.dart`](example/on_demand_compaction_example.dart) | Stream a signed summary and replay it (beta) |
| [`context_management_example.dart`](example/context_management_example.dart) | Edit context and preview input token counts (beta) |
| [`fallback_example.dart`](example/fallback_example.dart) | Server-side fallback chain and refusal credit-token retry (beta) |
| [`vision_example.dart`](example/vision_example.dart) | Image and document inputs |
| [`document_example.dart`](example/document_example.dart) | Document inputs with citations |
| [`search_result_example.dart`](example/search_result_example.dart) | Supplying your own cited `search_result` blocks (RAG) |
| [`token_counting_example.dart`](example/token_counting_example.dart) | Token counting |
| [`message_batches_example.dart`](example/message_batches_example.dart) | Batch processing |
| [`files_example.dart`](example/files_example.dart) | File management |
| [`skills_example.dart`](example/skills_example.dart) | Skills management |
| [`mcp_example.dart`](example/mcp_example.dart) | MCP tool integration |
| [`managed_agents_example.dart`](example/managed_agents_example.dart) | Managed agents: agents, sessions, vaults, multiagent rosters, outcomes, webhooks, credential validation (beta) |
| [`managed_agents_workflow_example.dart`](example/managed_agents_workflow_example.dart) | Configure dynamic workflows and follow workflow run events (Managed Agents beta) |
| [`session_threads_example.dart`](example/session_threads_example.dart) | Session threads: list, retrieve, stream events, archive (beta) |
| [`deployments_example.dart`](example/deployments_example.dart) | Scheduled deployments and deployment runs: cron schedule, pause/resume, run-now (beta) |
| [`memory_stores_example.dart`](example/memory_stores_example.dart) | Managed agents memory stores, memories, and versions (beta) |
| [`dreams_example.dart`](example/dreams_example.dart) | Dreams: memory-consolidation jobs — create, poll, list, archive (beta, research preview) |
| [`current_user_profiles_example.dart`](example/current_user_profiles_example.dart) | Inspect enforcement status and paginate user profiles |
| [`user_profiles_example.dart`](example/user_profiles_example.dart) | Legacy user profiles and enrollment URLs (beta) |
| [`organization_admin_example.dart`](example/organization_admin_example.dart) | Read-only organization and workspace administration |
| [`models_example.dart`](example/models_example.dart) | Model lifecycle filters, pagination, and capabilities |
| [`compliance_example.dart`](example/compliance_example.dart) | Scoped Compliance Activity Feed |
| [`compliance_content_example.dart`](example/compliance_content_example.dart) | Scoped Compliance app content and artifact downloads |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`anthropic_sdk_dart_example.dart`](example/anthropic_sdk_dart_example.dart) | Quick-start overview |

## API Coverage

| API | Status |
|-----|--------|
| Messages | ✅ Full |
| Message Batches | ✅ Full |
| Models | ✅ Full |
| Files | ✅ Full |
| Skills | ✅ Full |
| Agents (Beta) | ✅ Full |
| Sessions (Beta) | ✅ Full |
| Vaults (Beta) | ✅ Full |
| Memory Stores (Beta) | ✅ Full |
| Dreams (Beta) | ✅ Full |
| User Profiles | ✅ GA and legacy beta |
| Webhooks (Beta) | ✅ Full |
| Compliance | Activity Feed, directory, settings, Security Posture, apps, sessions and Code Artifacts |

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
