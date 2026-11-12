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

- Custom tool calling with strict schemas, tool choice controls and inline changes (beta)
- Mid-conversation tool changes: add or remove tools between turns with `tool_addition`/`tool_removal` blocks while preserving the prompt cache (beta)
- Computer-use and browser-use toolsets (`computer_toolset_20260801` / `browser_toolset_20260801` with per-member configs and `browser_state` results), web search, code execution, advisor, and the beta Messages MCP connector with tool listing and pinning
- Vision and document inputs with citations, an oversized-image policy via `transformations`, plus your own cited `search_result` blocks (RAG)

### Operational APIs

- OAuth bearer authentication and Workload Identity Federation with token refresh
- OIDC federation issuer management, signing-key sources, and polling status
- Workload Identity Federation rules and workspace bindings
- Message batches for large-scale offline processing
- Compliance Activity Feed, directory, organization settings, app content, sessions, and artifact downloads. Security Posture is beta.
- Model discovery with lifecycle filters, model lines, and thinking and server-tool capabilities
- MCP tunnel and certificate management in approved Claude API workspaces (research preview)
- Organization Admin API for keys, users, invites, workspaces, rate limits, compliance settings, RBAC and spend limits
- Service account lifecycle and workspace memberships with scoped OAuth
- Files (expiration, cursor pagination) and skills (multi-file uploads, container skills)
- Managed agents with environments, self-hosted work, sessions, thread status filters, execution principals, tool permission evaluation, vaults, and streaming events (beta)
- Scheduled deployments on the Claude API, Claude Platform on AWS, and Anthropic-managed Claude Models on Google Cloud (beta)
- Multiagent orchestration with dynamic workflows, subagents, and an advisor, plus per-tool configs, session budgets, and outcome evaluations (beta)
- Typed webhook event parsing and MCP-OAuth / static-bearer / environment-variable credential validation (beta)
- Memory stores for persistent agent memories with versioning and redaction (beta)
- Dreams: asynchronous memory-consolidation jobs over memory stores and session transcripts, with `create_new`/`update_existing` output behavior (Claude API research preview with access approval)
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

Configure `baseUrl` as the final API or proxy URL. Requests carrying an
`x-api-key` follow redirects only within the same origin on native transports.
Browsers cannot inspect redirect targets, so a redirect fails when the
request carries `x-api-key`. Native requests remove `Authorization` before
following a redirect to another origin.

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

`AnthropicConfig.timeout` defaults to ten minutes. Each buffered HTTP attempt
uses one deadline for response headers and body reads. Streams use the same
duration to wait for headers and for each subsequent gap between incoming
chunks. The first timer starts after authentication. A timeout throws
`TimeoutException`. The retry policy can retry idempotent requests sent
through the buffered client pipeline.

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

<details>
<summary><b>Authenticate with Workload Identity Federation</b></summary>

Configure an issuer, a service account, and a federation rule in Claude
Console. Supply a callback that reads a fresh identity-provider JWT for each
exchange. The client exchanges the JWT at the configured Claude API base URL
and caches the returned bearer token until refresh. For a rule that covers
multiple workspaces, pass the exchange `workspaceId` to select one.

```dart
final client = AnthropicClient.withWorkloadIdentity(
  identityTokenProvider: loadIdentityProviderJwt,
  federationRuleId: federationRuleId,
  organizationId: organizationId,
  serviceAccountId: serviceAccountId,
  workspaceId: workspaceId,
);
```

Use `AnthropicClient.withAuthToken(token)` with an existing OAuth token. The
token scope controls which Claude operations it authorizes.

[Workload Identity Federation guide](https://platform.claude.com/docs/en/manage-claude/workload-identity-federation) · [Runnable example](example/workload_identity_example.dart)

Use `client.organization.federation.issuers` with an `org:admin` OAuth
access token to manage registered identity providers. The API accepts OIDC
discovery, a fixed public JWKS endpoint, or inline public keys. Configure
the issuer URL as the exact `iss` claim from the identity provider.

```dart
final client = AnthropicClient.withAuthToken(orgAdminAccessToken);
try {
  final issuers = client.organization.federation.issuers;
  final page = await issuers.list(limit: 10);
  // Follow page.nextPage to read more issuers.
} finally {
  client.close();
}
```

[Manage WIF with the Admin API](https://platform.claude.com/docs/en/manage-claude/wif-admin-api) · [Runnable issuer example](example/federation_issuers_example.dart)

Inspect organization federation rules through `client.organization.federation.rules`
with the same `org:admin` OAuth scope. A rule binds an issuer and
service account to a scope, workspace selection, and JWT claim matches.
OAuth callers can modify `workspace:developer` and `workspace:inference`
rules. Configure rules for higher scopes in Claude Console.

```dart
final page = await client.organization.federation.rules.list(
  issuerId: federationIssuerId,
  includeArchived: false,
  limit: 20,
);
```

Use `rules.workspaces` to list, add, or remove individual workspace
bindings. Its list returns the explicit bindings and a null cursor. Inspect
the rule for legacy single-workspace and all-workspace bindings. Rules with
`appliesToAllWorkspaces` also cover future workspaces.

[Runnable federation rules example](example/federation_rules_example.dart)

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

The stream emits a terminal `ErrorEvent` for an in-band API error. Its
`requestId` and `errorCode` help diagnose the failure. The `finalMessage()`,
`collectText()`, and delta helpers raise `MessageStreamFailure` carrying the
same event. Future event types arrive as
`UnknownMessageStreamEvent` and retain their JSON payload.

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

<details>
<summary><b>Define a tool partway through a conversation</b></summary>

Add a system turn containing `InputContentBlock.toolAddition` with
`ToolChangeReference.definition`. Send `inline-tools-2026-09-15` for this beta
on the Claude API, Claude Platform on AWS, or Claude Models on Google Cloud
(Anthropic managed). For an MCP toolset declaration, also send
`mcp-client-2026-09-15` on the Claude API. Keep the MCP server URL and token
in `mcpServers`. Reference a browser or computer tool declared in `tools` by
name. To withdraw a tool, send a tool-removal block with its reference.

Keep the original `tools` array and earlier messages to reuse the cached
prefix. Retain signed compaction blocks as returned. `toolChangeBlocks`
provides typed inspection of the tool changes contained in those blocks. Keep
the original compaction and task-budget beta headers when replaying a signed
block.

[Runnable inline tool example](example/inline_tools_example.dart) · [Tool changes guide](https://platform.claude.com/docs/en/build-with-claude/mid-conversation-system-messages)

</details>

### How do I handle browser and computer toolset calls?

<details>
<summary><b>Read typed toolset actions and send results</b></summary>

Declare `BuiltInTool.browserToolset()` or `BuiltInTool.computerToolset()`.
Browser use is generally available on supported Messages models.
After a message or streamed tool input completes, inspect `toolsetAction` on
each `ToolUseBlock` to read its typed fields. A custom tool has no toolset
family. Unknown member names preserve their input for inspection.

```dart
for (final call in response.toolUseBlocks) {
  if (call.toolsetAction case BrowserNavigateAction(:final url, :final tabId)) {
    print('Browser navigation to $url on ${tabId ?? 'the active tab'}');
  }
}
```

Your application executes supported actions. Send the result with the matching
`toolUseId` and `toolsetName`. For browser actions, include `browser_state` when
reporting tabs or side effects. Successful tab management returns one
`browser_state` block, and a successful screenshot includes image content.
The runnable examples use stub executors.

[Browser example](example/browser_use_example.dart) · [Computer example](example/computer_use_example.dart) · [Claude toolset guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/browser-use-sdk)

</details>

### How do I connect a remote MCP server?

<details>
<summary><b>Declare an MCP server and toolset in a Messages request</b></summary>

Set `mcpServers` on the request and add a matching toolset under `tools`.
Pass the connector beta header with the request.

```dart
final request = MessageCreateRequest(
  model: 'claude-sonnet-5-5',
  maxTokens: 512,
  messages: [InputMessage.user('Which tools can you use?')],
  mcpServers: const [
    McpConnectorServer(name: 'remote-tools', url: 'https://mcp.example.com/mcp'),
  ],
  tools: [
    ToolDefinition.builtIn(BuiltInTool.mcpConnector(serverName: 'remote-tools')),
  ],
);
final response = await client.messages.create(
  request,
  betas: const ['mcp-client-2026-09-15'],
);
```

Use `mcp-client-2026-09-15` on the Claude API to record and pin tool lists.
Replay any `McpToolListingBlock` in the assistant turn and keep the beta header
on the follow-up. The earlier `mcp-client-2025-11-20` beta provides the
connector on supported platforms without listing or pinning. Check the provider
availability and data-handling limits before selecting a beta.

[Runnable MCP example](example/mcp_example.dart) · [Claude MCP connector guide](https://platform.claude.com/docs/en/agents-and-tools/mcp-connector)

</details>

### How do I restrict URLs Claude can fetch?

<details>
<summary><b>Choose which prior conversation sources allow a URL</b></summary>

`BuiltInTool.webFetch` accepts `WebFetchUrlSources` on every supported Messages
web fetch version. A source left out allows eligible URLs from that source.
Use `only` or `except` to select named tools in the request. Only web search
and web fetch results contribute URLs from server tools.

```dart
final tool = BuiltInTool.webFetch(
  urlSources: const WebFetchUrlSources(
    clientToolResults: WebFetchUrlToolFilter.none(),
  ),
);
```

Inspect `WebFetchToolResultBlock.errorCode` for a failed fetch. For example,
`contentTooLarge` means a fetched PDF would exceed the request's page or size
limit. `rawErrorCode` retains the original provider value.

[Runnable web fetch example](example/web_fetch_example.dart) · [Claude web fetch guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-fetch-tool)

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

Use `ImageSource.file(fileId)` for an image uploaded through the Files API.
Use `DocumentSource.content` for an unchunked string or
`DocumentSource.contentBlocks` for ordered text and image blocks. Enable
document citations to reference the text at its original block boundaries.

[Vision example](example/vision_example.dart) · [Custom document example](example/custom_content_document_example.dart) · [Claude citations guide](https://platform.claude.com/docs/en/build-with-claude/citations)

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

An errored result carries the item-level error and its provider request ID
when supplied. Unknown result types preserve their JSON for later handling.

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

Use `client.files` to upload, list, retrieve, download, and delete files.
The Files API is generally available on the Claude API and supported
first-party cloud platforms. Reference stored files in Messages to reuse them
across requests.

On Web, use `uploadBytes` for browser-selected files. Listing, metadata,
deletion, and byte downloads also work when the endpoint permits the browser's
origin and request headers through CORS. Set `AnthropicConfig.baseUrl` to a
CORS-enabled application backend that authenticates to Claude on the server
and enforces each user's file and workspace access. To expose provider request
IDs in browser errors, include `request-id` in `Access-Control-Expose-Headers`.
The Files example accepts `ANTHROPIC_PROXY_URL` at build time. Local
`upload(filePath: ...)` requires `dart:io`.

Use `client.files.list(scopeId: sessionId)` to list Managed Agents outputs. The scoped request adds the Managed Agents beta header. Only files whose metadata reports `downloadable` can be downloaded.

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

→ [Full example](example/files_example.dart) · [Files API and platform support](https://platform.claude.com/docs/en/build-with-claude/files) · [Managed Agents output files](https://platform.claude.com/docs/en/managed-agents/files)

</details>

### How do I manage skills?

<details>
<summary><b>Show example</b></summary>

Use `client.skills` to list and manage reusable skills. Use a model that supports code execution when loading skills in Messages. Upload `SKILL.md` at the root or under one enclosing directory. The ZIP download endpoint appears in the official SDK beta namespaces and requires no beta header. Deleting a skill also deletes all its versions.

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

→ [Full example](example/skills_example.dart) · [Skills API and compatibility](https://platform.claude.com/docs/en/build-with-claude/skills-guide)

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

### How do I manage agent environments?

<details>
<summary><b>Show example</b></summary>

Use `client.environments` to manage the execution environments used by Claude Managed Agents. Select a cloud configuration to set networking and packages, or a self-hosted configuration for an environment served by your own workers. Each operation sends the Managed Agents beta header. Use the key’s workspace or supply the matching `workspaceId`.

```dart
final environment = await client.environments.create(
  const CreateEnvironmentParams(
    name: 'Restricted environment',
    config: CloudEnvironmentConfigParams(
      networking: LimitedEnvironmentNetworkParams(
        allowedHosts: ['example.com'],
      ),
    ),
  ),
);
```

Pass the returned ID as `environmentId` when creating a session. To paginate the list, pass each response’s `nextPage` into the next `list(page: ...)` call until it is null.

→ [Full example](example/environments_example.dart)

</details>

### How do I poll work from a self-hosted environment?

<details>
<summary><b>Show example</b></summary>

On the Claude API, use the environment key to poll and acknowledge work. If the claim includes a scoped sessions token, use it for lease renewal and stop. Pass `EnvironmentWorkResource.noHeartbeat` when first claiming a lease and echo the server's exact `lastHeartbeat` on later calls. A conditional conflict exposes the server's lease state in `EnvironmentHeartbeatConflictException`.

```dart
final queue = client.environments.work(environmentId, bearerToken: environmentKey);
final item = await queue.poll(blockMs: 100, workerId: 'worker-1');
if (item != null) {
  await queue.ack(item.id);
  final work = client.environments.work(
    environmentId,
    bearerToken: item.credentials?.sessionsToken ?? environmentKey,
  );
  await work.heartbeat(
    item.id,
    expectedLastHeartbeat: EnvironmentWorkResource.noHeartbeat,
  );
}
```

These Dart methods expose the work API. The prebuilt worker in the official CLI and SDKs additionally runs the sandbox, tools and lease renewal loop. Claude Platform on AWS and Anthropic-managed Claude Models on Google Cloud use provider credentials for workers. Self-hosted memory stores are unavailable on those platforms. [Environment and platform differences](https://platform.claude.com/docs/en/managed-agents/choosing-an-environment)

→ [Full example](example/environment_work_example.dart)

</details>

### How do I manage MCP tunnels?

<details>
<summary><b>Show example</b></summary>

MCP tunnels require research preview access on the Claude API. Use a workload identity federation token with `workspace:manage_tunnels` for the authorized workspace. The SDK sends the tunnel beta header on tunnel and certificate calls and the OAuth beta when using a scoped bearer token. [MCP tunnels guide](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/overview)

```dart
final tunnels = client.tunnels.withToken(workspaceToken);
final tunnel = await tunnels.create(
  displayName: 'Private MCP',
  workspaceId: workspaceId,
);
final certificate = await tunnels.certificates(tunnel.id).create(
  caCertificatePem: caCertificatePem,
  workspaceId: workspaceId,
);
```

For existing Admin integrations, migrate the organization-prefixed tunnel URLs to `/v1/tunnels`, use the `mcp-tunnels-2026-06-22` header, and exchange credentials for the workspace scope. Anthropic documents the older organization routes as deprecated and available during its migration window. [Legacy Admin tunnel reference](https://platform.claude.com/docs/en/api/http/beta/organization/mcp_tunnels)

→ [Full example](example/mcp_tunnels_example.dart)

</details>

### How do I manage agent memory stores?

<details>
<summary><b>Show example</b></summary>

Use `client.memoryStores` to create persistent memory stores that can be mounted into agent sessions. The API supports memory CRUD, append-only versioning, and per-version redaction. This is a beta feature and the SDK sends the required `anthropic-beta` header automatically. For directory-style listings, use a prefix ending in `/` and `depth: 1` to group deeper paths. Memory paths start with `/`, use up to 20 nonempty segments, and must be NFC-normalized UTF-8 of at most 1,024 bytes. [Agent memory guide](https://platform.claude.com/docs/en/managed-agents/memory)

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

Use an `org:admin` OAuth token for
`client.organization.serviceAccounts`. The account's `workspaces.list`
includes its implicit Default Workspace membership. The workspace's
`serviceAccounts.list` lists active accounts with explicit memberships. A
direct lookup can return the implicit `workspace_user` membership.

Use `create` or `add` to make a Default Workspace membership explicit before
updating its role. Removing an explicit Default Workspace membership restores
the implicit membership. Supplying the admin role on creation or update
requires interactive OAuth, even when the role already matches. Archive active
federation rules before archiving their service account.

[Service account example](example/service_accounts_example.dart) · [Manage WIF with the Admin API](https://platform.claude.com/docs/en/manage-claude/wif-admin-api)

</details>

<details>
<summary><b>Inspect RBAC groups, roles and permissions</b></summary>

Use a Claude Enterprise Admin key with `read:rbac_groups` for groups and
`read:members` for roles, or `read:org_audit` for both. Group members and role
permissions have separate cursors. Group writes require `write:rbac_groups`
and can change member access. Change SCIM group membership in the identity
provider and custom role assignments in Claude Enterprise settings. The Dart
models accept legacy RBAC response aliases and serialize the current names.

```dart
final groups = await admin.organization.rbacGroups.list(limit: 10);
if (groups.data.isNotEmpty) {
  final members = await admin.organization.rbacGroups.listMembers(
    groups.data.first.id,
    limit: 10,
  );
  print('${members.data.length} members on the first page');
}
```

[Runnable RBAC example](example/organization_rbac_example.dart) · [Claude RBAC API](https://platform.claude.com/docs/en/manage-claude/user-management#groups)

</details>

<details>
<summary><b>Inspect and manage spend limits</b></summary>

Use a Claude Enterprise Admin key with `read:spend_limits` for reads and
`write:spend_limits` for changes. The configured-list endpoint uses the
spend-limit reads preview. Set or approve a cap using an integer string in
billing minor units. The Enterprise guide supports setting a per-user
override. The pinned API reference also defines organization and workspace
write scopes for Console early access. Console writes require a numeric monthly
cap. Set `amount: null` on an Enterprise per-user override to remove the numeric
cap for that period.
Approving an increase request applies the new cap and may notify the requester.
Denying the request leaves the member's cap as configured.

```dart
final limits = await admin.organization.spendLimits.listEffective(
  periods: [OrganizationSpendPeriod.monthly],
  limit: 10,
);
print('${limits.data.length} effective limits on the first page');
```

[Runnable spend example](example/organization_spend_example.dart) · [Claude spend limits API](https://platform.claude.com/docs/en/manage-claude/spend-limits-api)

</details>

<details>
<summary><b>Sign out a Claude Enterprise member</b></summary>

`admin.organization.users.signOut(userId)` revokes the member's active Claude
sessions, trusted devices, and OAuth tokens scoped to the organization while
preserving their membership. This Enterprise beta requires an Admin API key
with `write:members`. The organization primary owner cannot be signed out by
an Admin API key. Retry a temporary `503` using the configured retry policy.

[Claude Enterprise sign-out API](https://platform.claude.com/docs/en/manage-claude/user-management#sign-a-member-out-everywhere)

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
| [`federation_issuers_example.dart`](example/federation_issuers_example.dart) | List OIDC issuers with an organization OAuth token |
| [`federation_rules_example.dart`](example/federation_rules_example.dart) | List federation rules and workspace bindings |
| [`workload_identity_example.dart`](example/workload_identity_example.dart) | Exchange a workload identity JWT and call Messages |
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
| [`custom_content_document_example.dart`](example/custom_content_document_example.dart) | Cite custom document chunks by block index |
| [`web_fetch_example.dart`](example/web_fetch_example.dart) | Restrict URL sources and inspect web fetch results |
| [`search_result_example.dart`](example/search_result_example.dart) | Supplying your own cited `search_result` blocks (RAG) |
| [`token_counting_example.dart`](example/token_counting_example.dart) | Token counting |
| [`message_batches_example.dart`](example/message_batches_example.dart) | Batch processing |
| [`files_example.dart`](example/files_example.dart) | File management |
| [`skills_example.dart`](example/skills_example.dart) | Skills management |
| [`inline_tools_example.dart`](example/inline_tools_example.dart) | Define a client tool partway through a conversation (beta) |
| [`mcp_example.dart`](example/mcp_example.dart) | Connect an MCP server and pin its tool listing (beta) |
| [`managed_agents_example.dart`](example/managed_agents_example.dart) | Managed agents: agents, sessions, vaults, multiagent rosters, outcomes, webhooks, credential validation (beta) |
| [`managed_agents_workflow_example.dart`](example/managed_agents_workflow_example.dart) | Configure dynamic workflows and follow workflow run events (Managed Agents beta) |
| [`environments_example.dart`](example/environments_example.dart) | Managed Agents cloud and self-hosted environment lifecycle (beta) |
| [`mcp_tunnels_example.dart`](example/mcp_tunnels_example.dart) | MCP tunnel, proxy token and certificate management (research preview) |
| [`environment_work_example.dart`](example/environment_work_example.dart) | Self-hosted environment work polling and lease heartbeat (beta) |
| [`session_threads_example.dart`](example/session_threads_example.dart) | Session threads: list, retrieve, stream events, archive (beta) |
| [`deployments_example.dart`](example/deployments_example.dart) | Scheduled deployments and deployment runs: cron schedule, pause/resume, run-now (beta) |
| [`memory_stores_example.dart`](example/memory_stores_example.dart) | Managed agents memory stores, memories, and versions (beta) |
| [`dreams_example.dart`](example/dreams_example.dart) | Dreams: memory-consolidation jobs — create, poll, list, archive (beta, research preview) |
| [`current_user_profiles_example.dart`](example/current_user_profiles_example.dart) | Inspect enforcement status and paginate user profiles |
| [`user_profiles_example.dart`](example/user_profiles_example.dart) | Legacy user profiles and enrollment URLs (beta) |
| [`service_accounts_example.dart`](example/service_accounts_example.dart) | List service accounts and their workspace memberships |
| [`organization_admin_example.dart`](example/organization_admin_example.dart) | Read-only organization and workspace administration |
| [`organization_rbac_example.dart`](example/organization_rbac_example.dart) | List RBAC groups, members, roles and permissions |
| [`organization_spend_example.dart`](example/organization_spend_example.dart) | List effective spend limits and pending increase requests |
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
