# Anthropic Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![anthropic_sdk_dart](https://img.shields.io/pub/v/anthropic_sdk_dart.svg)](https://pub.dev/packages/anthropic_sdk_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[Anthropic API](https://platform.claude.com/docs/en/api/overview)** to build with Claude — messages, streaming, tool calling, extended thinking, multimodal prompts, files, skills, and batches. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

> [!TIP]
> Coding agents: start with [llms.txt](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/llms.txt). It links to the package docs, examples, and optional references in a compact format.

<details>
<summary><b>Table of Contents</b></summary>

- [Quickstart](#quickstart)
- [Features](#features)
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

## Quickstart

Requires Dart 3.12 or later. Set `ANTHROPIC_API_KEY` to your API key or `ANTHROPIC_AUTH_TOKEN` to a scoped OAuth access token. See the [Migration Guide](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/MIGRATION.md) for upgrade instructions.

```sh
dart pub add 'anthropic_sdk_dart:^11.0.0'
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

## Features

### Generation and streaming

- Messages with typed inputs, system prompts, and multi-turn history
- Mid-conversation system messages (`InputMessage.system`), turn-scoped reminders (`clearAt`), and per-message effort (`InputMessage.systemEffort`) inside the messages array, no user turn required
- SSE streaming with cancelation, token counting, and typed structured output
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
- Lazy page and item streams over list operations
- Compliance Activity Feed, directory, organization settings, app content, sessions, and artifact downloads. Security Posture is beta.
- Model discovery with lifecycle filters, model lines, and thinking and server-tool capabilities
- MCP tunnel and certificate management in approved Claude API workspaces (research preview)
- Organization Admin API for keys, users, invites, workspaces, rate limits, compliance settings, RBAC and spend limits
- Service account lifecycle and workspace memberships with scoped OAuth
- Customer-managed encryption keys and validation through the Admin API
- Usage and cost analytics with actor, workspace, and organization dimensions (beta)
- Claude Enterprise activity reports for users, projects, skills, connectors, plugins, and artifacts
- Organization webhook endpoint management and signed event verification (beta)
- Organization OpenTelemetry destination setup, test spans, and workspace selection (beta)
- Claude Tag Slack settings, inheritance and access bundle attachments for Claude Enterprise (beta)
- Claude Enterprise plugins, version archives, installation settings and marketplace validation (beta)
- Files (expiration, cursor pagination) and skills (multi-file uploads, container skills)
- Managed agents with environments, self-hosted work, sessions, thread status filters, execution principals, tool permission evaluation, vaults, and streaming events (beta)
- Scheduled deployments on the Claude API, Claude Platform on AWS, and Anthropic-managed Claude Models on Google Cloud (beta)
- Multiagent orchestration with dynamic workflows, subagents, and an advisor, plus per-tool configs, session budgets, and outcome evaluations (beta)
- Typed webhook event parsing and MCP-OAuth / static-bearer / environment-variable credential validation (beta)
- Memory stores for persistent agent memories with versioning and redaction (beta)
- Dreams: asynchronous memory-consolidation jobs over memory stores and session transcripts, with `create_new`/`update_existing` output behavior (Claude API research preview with access approval)
- Generally available user profiles with end-customer attribution, enforcement filters, program status, and action URLs. The legacy beta profile methods remain available.
- Claude Platform on AWS, Amazon Bedrock Mantle and Runtime, Anthropic-managed Google Cloud, Vertex AI, and Microsoft Foundry transports

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models.
- Streaming, retries, interceptors, and cancellation built into the client.
- Follows Anthropic resource naming closely, so official docs translate directly into Dart code.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Configuration

<details>
<summary><b>Configure auth, retries, and custom Anthropic endpoints</b></summary>

Use `AnthropicClient.fromEnvironment()` to read `ANTHROPIC_API_KEY` or an
`ANTHROPIC_AUTH_TOKEN` OAuth access token. The API key takes precedence when
both are set. To run the quickstart with OAuth, set `ANTHROPIC_AUTH_TOKEN` to a
token with inference access and unset `ANTHROPIC_API_KEY`. The factory reads a
static token. Use `AnthropicClient.withWorkloadIdentity()` for automatic
federation exchange and refresh. Use `AnthropicConfig` for a custom timeout or
retry policy.

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
chunks. The first timer starts after a configured `AuthProvider` resolves.
Cloud credentials acquired by a provider transport count toward the HTTP
attempt. A timeout throws
`TimeoutException`. The retry policy can retry idempotent requests sent
through the buffered client pipeline.

Environment variables:

- `ANTHROPIC_API_KEY` for an API key
- `ANTHROPIC_AUTH_TOKEN` for a scoped OAuth access token
- `ANTHROPIC_BASE_URL` for a custom API or proxy URL

The client defaults to Claude API version `2026-10-21`. If your requests rely
on sampling parameters or other legacy input behavior, set
`apiVersion: AnthropicConfig.legacyApiVersion` in `AnthropicConfig`.
See the [API version migration](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/MIGRATION.md#claude-api-version-2026-10-21).

Set `AnthropicConfig.workspaceId` to select a workspace with a key that can
access multiple workspaces. Messages, Batches and Models also accept a
per-call `workspaceId`. Single-workspace keys can normally omit it. Claude
Platform on AWS requires workspace selection on workspace-scoped endpoints.
Workload Identity Federation tokens select their workspace at token exchange.
Use a new token exchange to change it.
[Workspace selection](https://platform.claude.com/docs/en/manage-claude/authentication#select-a-workspace)

Use explicit configuration on web builds where runtime environment variables are unavailable. Files operations that take bytes or IDs also work on Web. Uploading from a local path requires a Dart I/O platform.

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

[Workload Identity Federation guide](https://platform.claude.com/docs/en/manage-claude/workload-identity-federation) · [Runnable example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/workload_identity_example.dart)

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

[Manage WIF with the Admin API](https://platform.claude.com/docs/en/manage-claude/wif-admin-api) · [Runnable issuer example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/federation_issuers_example.dart)

Inspect organization federation rules through `client.organization.federation.rules`
with the same `org:admin` OAuth scope. A rule binds an issuer and
service account to a scope, workspace selection, and JWT claim matches.
OAuth callers can modify `workspace:developer` and `workspace:inference`
rules. Configure rules for higher scopes in Claude Console.

```dart
final client = AnthropicClient.withAuthToken(orgAdminAccessToken);
try {
  final page = await client.organization.federation.rules.list(
    issuerId: 'fdis_...',
    includeArchived: false,
    limit: 20,
  );
  print(page.data.length);
} finally {
  client.close();
}
```

Use `rules.workspaces` to list, add, or remove individual workspace
bindings. Its list returns the explicit bindings and a null cursor. Inspect
the rule for legacy single-workspace and all-workspace bindings. Rules with
`appliesToAllWorkspaces` also cover future workspaces.

[Runnable federation rules example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/federation_rules_example.dart)

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

Use `client.messages.createWithResponse(...)` when you need the HTTP
status or provider identifiers from a successful response. Read
`response.message` for the decoded message. `requestId` and `workspaceId`
are available when the server supplies them and they are safe to expose.
On AWS or Foundry, `awsRequestId` and `azureRequestId` preserve platform
tracing alongside the Claude request ID. Browser proxies must expose the
relevant response headers through CORS.

[Basic Messages example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/messages_example.dart) · [Response metadata example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_response_metadata_example.dart)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/streaming_example.dart)

</details>

### How do I decode a structured response?

<details>
<summary><b>Show example</b></summary>

Give Claude a [supported JSON Schema](https://platform.claude.com/docs/en/build-with-claude/structured-outputs) and supply a Dart decoder for the result.

```dart
final answer = StructuredOutput<int>(
  schema: {
    'type': 'object',
    'properties': {
      'answer': {'type': 'integer'},
    },
    'required': ['answer'],
    'additionalProperties': false,
  },
  decode: (json) => switch (json) {
    {'answer': final int value} => value,
    _ => throw const FormatException('Expected an integer answer.'),
  },
);

final result = await client.messages.parse(
  MessageCreateRequest(
    model: 'claude-sonnet-5',
    maxTokens: 128,
    messages: [InputMessage.user('What is 2 + 2?')],
  ),
  output: answer,
);
print(result.parsedOutput);
```

`parseStream(...).finalParsedMessage()` decodes after streaming finishes. The result keeps the original message, including refusal details and token usage. For a refusal, tool request, or truncated generation, inspect the raw stop reason. The decoder handles application validation. Supply a schema compatible with your selected model and platform.

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/structured_output_example.dart)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/tool_calling_example.dart)

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

[Runnable inline tool example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/inline_tools_example.dart) · [Tool changes guide](https://platform.claude.com/docs/en/build-with-claude/mid-conversation-system-messages)

</details>

### How do I run a loop with custom tools?

<details>
<summary><b>Show example</b></summary>

Register a custom `Tool`, a Dart input decoder, and a callback with `client.messages.runTools`. The runner sends the assistant reply and its paired tool results to Claude until it reaches a terminal stop or the request budget.

```dart
final square = RunnableMessageTool<int>(
  definition: const Tool(
    name: 'square',
    description: 'Square an integer.',
    inputSchema: InputSchema(
      properties: {'number': {'type': 'integer'}},
      required: ['number'],
      extra: {'additionalProperties': false},
    ),
    strict: true,
  ),
  decode: (input) => switch (input) {
    {'number': final int value} => value,
    _ => throw const FormatException('Expected an integer.'),
  },
  run: (value, call) => MessageToolResult.text('${value * value}'),
);
final result = await client.messages.runTools(
  MessageCreateRequest(
    model: 'claude-sonnet-5',
    maxTokens: 512,
    messages: [InputMessage.user('Use the square tool to calculate 17².')],
  ),
  tools: [square],
  maxIterations: 4,
);
print(result.message.text);
```

Use `onEvent` for streamed events and `onTurn` for completed responses. `useThread: true` opts into the Messages threads beta. A tool request on the last permitted iteration remains available in the raw reply. Register a `RunnableMessageToolset` for browser or computer actions. Calls to
unregistered toolsets leave the whole turn available for your application. The runner supports server-side threshold compaction through `contextManagement`.

For a stateless run, `compactBeforeNextTurn` can request one signed summary
between assistant requests. Include `compact-2026-09-04` and leave any task
budget's `remaining` unset. Use either a signed summary or threshold compaction.
The runner preserves its replay history if the API omits a usable summary.
[Claude on-demand compaction](https://platform.claude.com/docs/en/build-with-claude/compaction-on-demand)

The runner passes an expired thread continuation error to the caller. Use the default stateless mode when your provider or context edit requires full conversation replay.

Toolset executors receive typed actions and supply result blocks. Use a
`confirm` callback for enabled browser JavaScript and upload, and for enabled
computer typing, key and hold-key actions. Browser uploads also need a
`filePolicy` that approves the paths and document IDs. The executor validates
input bounds, applies its navigation and filesystem policies, and supplies
browser state or screenshots as appropriate.

[Custom tool runner example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_tool_runner_example.dart) · [Browser callback example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_toolset_runner_example.dart)

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

[Runnable web fetch example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/web_fetch_example.dart) · [Claude web fetch guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-fetch-tool)

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
void inspectBrowserActions(Message response) {
  for (final call in response.toolUseBlocks) {
    if (call.toolsetAction case BrowserNavigateAction(:final url, :final tabId)) {
      print('Browser navigation to $url on ${tabId ?? 'the active tab'}');
    }
  }
}
```

Your application executes supported actions. Send the result with the matching
`toolUseId` and `toolsetName`. For browser actions, include `browser_state` when
reporting tabs or side effects. Successful tab management returns one
`browser_state` block, and a successful screenshot includes image content.
The runnable examples use stub executors.

[Browser example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/browser_use_example.dart) · [Computer example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/computer_use_example.dart) · [Claude toolset guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/browser-use-sdk)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/token_counting_example.dart)

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

[Vision example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/vision_example.dart) · [Custom document example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/custom_content_document_example.dart) · [Claude citations guide](https://platform.claude.com/docs/en/build-with-claude/citations)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/thinking_example.dart)

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

[Runnable thread example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_threads_example.dart) · [Runnable thread helper](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_thread_helper_example.dart) · [Claude message threads guide](https://platform.claude.com/docs/en/build-with-claude/message-threads)

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

[Runnable context editing example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/context_management_example.dart) · [Context editing guide](https://platform.claude.com/docs/en/build-with-claude/context-editing)

[Runnable compaction example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/on_demand_compaction_example.dart) · [Claude on-demand compaction guide](https://platform.claude.com/docs/en/build-with-claude/compaction-on-demand)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/models_example.dart)

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

Use `CursorPagination` to visit batch history a page or an item at a time.
Keep the limit, workspace, and beta flags in the fetch callback. The batch
selector uses `hasMore` and `lastId` to continue. Canceling the stream stops
further requests and aborts an in-flight request when the callback forwards
`abortTrigger`. Item selection and iteration errors end the traversal.

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_batches_example.dart) · [Paginate batch history](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/batch_pagination_example.dart)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/files_example.dart) · [Files API and platform support](https://platform.claude.com/docs/en/build-with-claude/files) · [Managed Agents output files](https://platform.claude.com/docs/en/managed-agents/files)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/skills_example.dart) · [Skills API and compatibility](https://platform.claude.com/docs/en/build-with-claude/skills-guide)

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

[Runnable MCP example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/mcp_example.dart) · [Claude MCP connector guide](https://platform.claude.com/docs/en/agents-and-tools/mcp-connector)

</details>

### How do I use Claude Platform on AWS?

<details>
<summary><b>Send a message from an AWS workspace</b></summary>

Use `AnthropicAwsClient` with your workspace's AWS region and workspace ID. Supply an AWS-issued API key, or inject a callback that obtains AWS IAM credentials for SigV4. The client also reads `AWS_REGION`, `AWS_DEFAULT_REGION`, `ANTHROPIC_AWS_WORKSPACE_ID`, and the standard credential environment variables.

```dart
final client = AnthropicAwsClient(
  region: 'us-east-1',
  workspaceId: workspaceId,
  credentials: loadAwsCredentials,
);
```

The callback returns `ClaudeAwsCredentials` with an access key ID, secret access key, and optional session token. Use your AWS credential provider for SSO, shared profiles, instance metadata, and role renewal. The configured workspace covers resource calls, including self-hosted work queues. AWS workers use IAM or an AWS-issued key. Organization Admin and Compliance Activity Feed routes use organization scope. User Profile action URLs are unavailable on AWS. AWS IAM controls the available APIs and actions. [Claude Platform on AWS](https://platform.claude.com/docs/en/build-with-claude/claude-platform-on-aws)

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/claude_aws_example.dart)

</details>


### How do I use Claude on Amazon Bedrock?

<details>
<summary><b>Choose Mantle or Runtime for Claude inference</b></summary>

Choose `AnthropicBedrockMantleClient` for native Messages, SSE, and `messages.countTokens`. Choose `AnthropicBedrockClient` for Runtime's InvokeModel operations and AWS binary event streams. Pass the provider model ID or inference profile required by your endpoint and region. The client accepts `AWS_BEARER_TOKEN_BEDROCK`, AWS environment credentials, or an injected AWS credential callback. [Bedrock Mantle](https://platform.claude.com/docs/en/build-with-claude/claude-in-amazon-bedrock) · [Bedrock Runtime](https://platform.claude.com/docs/en/build-with-claude/claude-on-amazon-bedrock-legacy)

```dart
final client = AnthropicBedrockClient(region: 'us-east-1');
final message = await client.messages.create(request);
```

Mantle sends the configured or per-call workspace ID when supplied. Bedrock
Mantle and Runtime use stateless Messages. Server-held Message threads and
server-side fallback are unavailable on these endpoints.

Use `countInvokeTokens(request)` for a Runtime model that supports AWS CountTokens. It takes the same body as InvokeModel, including `maxTokens`. Model and region support differ, especially for models available only through cross-region inference. Use Mantle's Claude token-counting endpoint where Runtime lacks it. Mantle maps `userProfileId` to the request body's `user_profile_id`. Runtime does not support profile attribution. [Amazon Bedrock token counting](https://docs.aws.amazon.com/bedrock/latest/userguide/count-tokens.html)

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/bedrock_example.dart)

</details>

### How do I use Claude on Google Cloud?

<details>
<summary><b>Choose an Anthropic-managed or Google-managed project</b></summary>

Use `AnthropicGoogleCloudClient` for the native Claude gateway through your Google Cloud project. Provide the project and workspace IDs. Organization routes and user profile management use the project-level gateway automatically. Managed Agents remain subject to beta and IAM access. MCP tunnels and prebuilt sandbox workers are unavailable on this provider. [Anthropic-managed Google Cloud](https://platform.claude.com/docs/en/build-with-claude/claude-models-on-google-cloud/anthropic-managed)

```dart
final client = AnthropicGoogleCloudClient(
  projectId: 'my-project',
  workspaceId: workspaceId,
  tokenProvider: refreshGoogleAccessToken,
);
final message = await client.messages.create(request);
```

Use `AnthropicVertexClient` for Google-managed Vertex. Select the project, region, and publisher model ID. Vertex supports Messages, streaming, and token counting. For Files, Batches, Managed Agents, Admin, Compliance, and profile management, check the availability of each API on the native gateway or Claude API. The Vertex transport puts `anthropic_version` in the request body and uses the provider's model-specific route. To attribute a request, create the profile on the Claude API or Claude Platform on AWS and link the Google Cloud project as documented. [User profile attribution](https://platform.claude.com/docs/en/manage-claude/user-profiles#attribute-requests-on-amazon-bedrock-and-google-cloud) [Google-managed Vertex](https://platform.claude.com/docs/en/build-with-claude/claude-models-on-google-cloud/google-managed)

Both clients accept a Google OAuth access token or a callback that refreshes it with your Google credentials. Connect the callback to your Application Default Credentials or service-account provider in a long-running application.

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/google_cloud_example.dart)

</details>

### How do I use Claude in Microsoft Foundry?

<details>
<summary><b>Send a message to a Foundry deployment</b></summary>

Use `AnthropicFoundryClient` with your Foundry resource and an Azure API key or Entra token provider. Set `model` in the Messages request to the deployment name. The Entra callback should obtain a token for `https://ai.azure.com/.default`.

```dart
final client = AnthropicFoundryClient(
  resource: 'my-foundry-resource',
  tokenProvider: refreshEntraToken,
);
final message = await client.messages.create(request);
```

Set `azureHosted: true` for an Azure-hosted deployment. Files, Skills, code execution, programmatic tool calling, and newer web search and web fetch versions require an Anthropic-hosted deployment. Foundry omits Admin, Compliance, Models, Message Batches, user profile management, Managed Agents, and the advisor tool. Use client-side model fallback. Profile attribution requires an Anthropic-hosted deployment and an Anthropic-linked Foundry resource. [Foundry feature support](https://platform.claude.com/docs/en/build-with-claude/claude-in-microsoft-foundry#feature-support)

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/foundry_example.dart)

</details>

### How do I use managed agents?

<details>
<summary><b>Show example</b></summary>

Use `client.agents`, `client.sessions`, and `client.vaults` for the Managed Agents beta API. Create an agent configuration, start sessions to interact with Claude, list session events and session thread events as the agent works, and store vault credentials securely.

Use `Multiagent20261001Params` to configure workflow workers, subagents, and the advisor. Agent and session responses expose the resolved topology. Updating a configuration within the same version preserves omitted fields, and an explicit `null` resets a field to its default.

The session event list and stream expose dynamic workflow progress as `WorkflowRunEvent`. A workflow error can arrive before the run is created, or before an existing run ends. Follow the terminal result through the workflow end event. Session and thread idle events also expose model refusals and their optional details. Retrieve the thread to inspect a `SessionInlineAgent` snapshot for an unsaved workflow worker. Use `SessionErrorEvent.errorDetails` for typed session errors and retry status. See the runnable [workflow example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/managed_agents_workflow_example.dart).

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/managed_agents_example.dart)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/environments_example.dart)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/environment_work_example.dart)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/mcp_tunnels_example.dart)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/memory_stores_example.dart)

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
base URL. The [Anthropic guide](https://platform.claude.com/docs/en/manage-claude/user-profiles)
lists cross-platform attribution requirements.

See [the user profiles example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/current_user_profiles_example.dart)
for enforcement status and pagination. Legacy `client.userProfiles` responses can omit
enforcement fields. Use `client.userProfiles.current` when checking
enforcement. Treat an unfamiliar status as
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

[Runnable Admin example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_admin_example.dart) · [Claude Admin API](https://platform.claude.com/docs/en/manage-claude/admin-api)

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

[Service account example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/service_accounts_example.dart) · [Manage WIF with the Admin API](https://platform.claude.com/docs/en/manage-claude/wif-admin-api)

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

[Runnable RBAC example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_rbac_example.dart) · [Claude RBAC API](https://platform.claude.com/docs/en/manage-claude/user-management#groups)

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

[Runnable spend example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_spend_example.dart) · [Claude spend limits API](https://platform.claude.com/docs/en/manage-claude/spend-limits-api)

</details>

<details>
<summary><b>Sign out a Claude Enterprise member</b></summary>

`admin.organization.users.signOut(userId)` ends the member's active Claude
sessions, trusted devices, and push-notification registrations across their
account, including other organizations and individual plans. OAuth revocation
is scoped to your organization. This Enterprise beta requires an Admin API key
with `write:members`. The operation preserves membership and excludes the
organization's primary owner. The member can sign back in afterward. If the
server returns `503`, call `signOut` again to finish the operation.

[Runnable sign-out example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_sign_out_example.dart) · [Claude Enterprise sign-out API](https://platform.claude.com/docs/en/manage-claude/user-management#sign-a-member-out-everywhere)

</details>

<details>
<summary><b>Inspect organization external keys</b></summary>

Enable customer-managed encryption keys for your organization and use a
Claude Platform Admin key. `client.organization.externalKeys` supports AWS
KMS, Google Cloud KMS, and Azure Key Vault or Managed HSM where available.
Specify a user profile at key registration when binding a key to a customer.

```dart
final page = await admin.organization.externalKeys.list(limit: 10);
for (final key in page.data) {
  print('${key.providerConfig.type}: ${key.attachment.type}');
}
```

The standalone `externalKeys.validate` call applies to supported Claude
Platform accounts. Claude Platform on AWS uses the full KMS ARN as the key ID
and validates the key when attaching it to a workspace.

[Runnable external keys example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/external_keys_example.dart) · [Claude CMEK Admin API](https://platform.claude.com/docs/en/manage-claude/cmek-admin-api)

</details>

### How do I report organization usage and costs?

<details>
<summary><b>Show example</b></summary>

Use `client.organization.analytics` with a scoped organization credential.
Console organizations can use an Admin API key or an `org:admin` OAuth token.
Claude Enterprise organizations use an Analytics API key with `read:analytics`. Usage and cost
calls add the required beta header. Group by dimensions such as `model`,
`actor` and `organization_id`, and reuse the query with `nextPage`.

```dart
final report = await admin.organization.analytics.usage(
  UsageCostAnalyticsQuery(
    startingAt: DateTime.utc(2026, 10, 1),
    endingAt: DateTime.utc(2026, 10, 2),
    groupBy: const ['model'],
  ),
);
for (final row in report.data) {
  print('${row.group.model}: ${row.usage.totalTokens}');
}
```

Cost amounts are decimal strings in the currency's minor unit.

The legacy Console reports remain available as `messagesUsageReport`,
`consoleCostReport` and `claudeCodeUsageReport`. Enterprise reports retain
`usageReport`, `costReport`, `userUsageReport` and `userCostReport`.
Their buckets and filters differ from the dimensioned routes.

[Runnable analytics example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_analytics_example.dart) · [Legacy reports example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_legacy_analytics_example.dart) · [Usage and cost analytics](https://platform.claude.com/docs/en/manage-claude/usage-cost-analytics-api)

Claude Enterprise activity reports cover daily adoption summaries, users, Chat
projects, skills, connectors, plugins, and artifacts. Use a key with
`read:analytics`. Pass UTC dates as `YYYY-MM-DD`. Activity summaries include
Claude Tag active-user counts when the organization reports them.

[Runnable activity example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_activity_example.dart) · [Claude Enterprise Analytics](https://platform.claude.com/docs/en/manage-claude/analytics-api)

</details>

### How do I subscribe to organization webhook events?

<details>
<summary><b>Manage an endpoint and verify signed deliveries</b></summary>

Use `client.organization.webhooks` with an Admin API key, an `org:admin`
OAuth token, or a personal or service-account key without workspace scope.
Anthropic must enable organization webhooks for your account. They require
a default workspace and are unavailable with HIPAA readiness or
customer-managed encryption on that workspace. At the November 11, 2026
audit cutoff, Anthropic documented enforcement opened and resolved
subscriptions and listed delivery as pending. The pinned SDK types also
include `program_status_updated` without a documented delivery guarantee.

Register a receiver with a public DNS name over HTTPS on port 443 using
`create`. Endpoint writes require an admin or owner role. Store its signing secret when
Anthropic returns it. `regenerateSigningSecret` replaces the credential and
invalidates the previous one immediately. The resource adds the required beta
header to each request.

Verify the untouched UTF-8 request body before using the event. Use the event
ID to deduplicate deliveries.

```dart
final event = WebhookEvent.unwrap(
  rawRequestBody,
  headers: deliveryHeaders,
  signingSecret: webhookSecret,
);
if (event.data case WebhookUserProfileEventData(:final event, :final id)) {
  print('${event.value} for $id');
}
```

[Webhook endpoint example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_webhooks_example.dart) · [Receiver example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_webhook_receiver_example.dart) · [Claude organization webhooks](https://platform.claude.com/docs/en/manage-claude/organization-webhooks)

</details>

### How do I send Claude API traces to a collector?

<details>
<summary><b>Configure an organization OpenTelemetry destination</b></summary>

Use `client.organization.telemetryDestinations` with an Admin API key or
service account on the Claude API, or IAM on Claude Platform on AWS. The
resource adds the required `telemetry-destinations-2026-08-11` beta header.
Use an HTTPS collector with a DNS hostname on port 443 that accepts OTLP/HTTP
protobuf. A separate traces URL must use the same origin. Choose all workspaces
or an include/exclude list. Content export depends on organization, model, and
platform eligibility. Metadata-only is the default.

```dart
final destination = await admin.organization.telemetryDestinations.create(
  endpointUrl: 'https://collector.example.com/otlp',
  workspaces: const TelemetryWorkspaceSelection.all(),
  headers: {'authorization': collectorToken},
);
final delivery = await admin.organization.telemetryDestinations.test(
  destination.id,
);
print(delivery.result.succeeded ? 'Delivered' : delivery.result.error);
```

Read responses return header names. For updates, pass `null` inside the
headers map to remove one header, and include the endpoint URL when setting a
value. Moving to a new host clears registered headers. A failed test delivery
is reported in the result of a successful API request.

[Runnable destinations example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_telemetry_example.dart) · [Claude API OpenTelemetry export](https://platform.claude.com/docs/en/manage-claude/opentelemetry/api)

</details>

### How do I inventory and validate Claude Enterprise plugins?

<details>
<summary><b>List plugins and validate a marketplace</b></summary>

Use `client.organization.plugins` and `client.organization.pluginMarketplaces`.
Both resources add the required `ce-plugins-2026-09-01` beta header.
The API is available in beta for Claude Enterprise organizations without HIPAA
readiness. Reads accept `read:plugins`, `read:org_audit`, or a Compliance Access
Key with `read:compliance_org_data`. Writes require `write:plugins`. Either
plugin scope can validate a marketplace. A key with audit or Compliance access
for linked organizations can select a child organization on read endpoints.

```dart
final plugins = await admin.organization.plugins.list(ownerType: 'organization');
final report = await admin.organization.pluginMarketplaces.validateRepository(
  repositoryUrl: 'https://github.com/example-org/example-marketplace',
  ref: 'main',
);
print('${plugins.data.length} plugins on this page, marketplace valid=${report.valid}');
```

Upload `.claude-plugin/plugin.json` with the other plugin files, or pass a
complete archive as one file. Pin an existing version to control which version
members receive. `versions.download` returns the exact ZIP bytes for a
specific version. Member-owned archive downloads are recorded in the
Compliance Activity Feed. A plugin deletion removes every stored version.

[Runnable plugins example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_plugins_example.dart) · [Claude Plugins API](https://platform.claude.com/docs/en/manage-claude/plugins-api)

</details>

### How do I audit Claude Tag settings in Slack?

<details>
<summary><b>Read effective settings and where they come from</b></summary>

Use `client.organization.claudeTag` for a Claude Enterprise organization with
Claude Tag and Slack set up. Use an organization-level Admin API key with
`read:claude_tag` for reads and `write:claude_tag` for writes. Anthropic must
enable writes separately. Use API version `2026-10-21`. The resource adds the
required `experimental-claude-tag-2026-10-21` beta header.

```dart
final channels = await admin.organization.claudeTag.slackChannels.list(
  slackWorkspaceId: slackWorkspaceId,
  includeInherited: true,
);
for (final channel in channels.data) {
  print('${channel.id}: ${channel.settings.enabled} from ${channel.sources.enabled?.type}');
}
```

List filters use Slack's own IDs. Retrieve, update, and attach bundles using
the `slch_...` or `slws_...` IDs from the response. An update leaves omitted
settings unchanged. Send `null` to clear an inheritable setting.
For a stored channel reply mode, send `ClaudeTagReplyMode.automatic` to
restore default behavior. A null reply mode leaves an unset mode unchanged.
Omit the reply mode on workspace updates.
If channel setup succeeds and applying settings fails, read `slack_channel_id`
from the API exception's `errorDetails` to identify the channel.
Removing a channel deletes its Claude Tag data, including sessions and memory.

[Runnable Claude Tag example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_claude_tag_example.dart) · [Claude Tag API](https://platform.claude.com/docs/en/manage-claude/claude-tag-api)

</details>

### How do I use the Compliance API?

<details>
<summary><b>Read scoped Compliance activity, directory and content</b></summary>

Use a client configured with a separate Compliance Access Key. For the
Activity Feed, a Claude Console organization can also use an Admin API key
created while Compliance is enabled. It carries `read:compliance_activities`
as its sole Compliance scope. Other Compliance endpoints require a scoped
Compliance Access Key. [Compliance key setup](https://platform.claude.com/docs/en/manage-claude/compliance-api-access)

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

[Activity Feed example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/compliance_example.dart) · [Content example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/compliance_content_example.dart) · [Compliance API access](https://platform.claude.com/docs/en/manage-claude/compliance-api-access) · [Directory guide](https://platform.claude.com/docs/en/manage-claude/compliance-org-data)

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

→ [Full example](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/error_handling_example.dart)

</details>

## Examples

Run an example from the package directory with `dart run example/<file>.dart`. The example header lists any credentials, arguments, or feature access it needs.

| Example | Description |
|---------|-------------|
| [`messages_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/messages_example.dart) | Basic message creation |
| [`message_response_metadata_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_response_metadata_example.dart) | Read status and provider IDs from a Messages response |
| [`federation_issuers_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/federation_issuers_example.dart) | List OIDC issuers with an organization OAuth token |
| [`federation_rules_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/federation_rules_example.dart) | List federation rules and workspace bindings |
| [`workload_identity_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/workload_identity_example.dart) | Exchange a workload identity JWT and call Messages |
| [`api_version_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/api_version_example.dart) | Current API version and legacy opt-out |
| [`mid_conversation_system_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/mid_conversation_system_example.dart) | Mid-conversation, turn-scoped, and effort-only system messages |
| [`streaming_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/streaming_example.dart) | Streaming responses |
| [`structured_output_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/structured_output_example.dart) | Typed JSON output with buffered or streamed responses |
| [`tool_calling_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/tool_calling_example.dart) | Tool calling with schemas |
| [`message_tool_runner_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_tool_runner_example.dart) | Bounded typed custom tool loop with optional streaming and threads |
| [`message_toolset_runner_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_toolset_runner_example.dart) | Typed browser actions with a stub executor |
| [`web_search_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/web_search_example.dart) | Web search tool |
| [`advisor_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/advisor_example.dart) | Advisor tool (beta) |
| [`computer_use_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/computer_use_example.dart) | Computer-use toolset (`computer_toolset_20260801`) |
| [`browser_use_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/browser_use_example.dart) | Browser-use toolset with `browser_state` tool results |
| [`thinking_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/thinking_example.dart) | Adaptive thinking, progress updates, block binding, and multi-turn replay |
| [`diagnostics_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/diagnostics_example.dart) | Prompt-cache diagnostics on the Claude API |
| [`message_threads_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_threads_example.dart) | Create and continue a Messages thread (beta) |
| [`message_thread_helper_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_thread_helper_example.dart) | Track a thread and opt into bounded recovery (beta) |
| [`on_demand_compaction_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/on_demand_compaction_example.dart) | Stream a signed summary and replay it (beta) |
| [`context_management_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/context_management_example.dart) | Edit context and preview input token counts (beta) |
| [`fallback_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/fallback_example.dart) | Server-side fallback chain and refusal credit-token retry (beta) |
| [`vision_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/vision_example.dart) | Image and document inputs |
| [`document_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/document_example.dart) | Document inputs with citations |
| [`custom_content_document_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/custom_content_document_example.dart) | Cite custom document chunks by block index |
| [`web_fetch_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/web_fetch_example.dart) | Restrict URL sources and inspect web fetch results |
| [`search_result_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/search_result_example.dart) | Supplying your own cited `search_result` blocks (RAG) |
| [`token_counting_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/token_counting_example.dart) | Token counting |
| [`message_batches_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/message_batches_example.dart) | Create a batch, inspect its status, and stream results |
| [`batch_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/batch_example.dart) | Poll batch progress with a bounded wait |
| [`batch_pagination_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/batch_pagination_example.dart) | Stream batch history by page or item |
| [`files_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/files_example.dart) | File management |
| [`skills_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/skills_example.dart) | Skills management |
| [`inline_tools_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/inline_tools_example.dart) | Define a client tool partway through a conversation (beta) |
| [`mcp_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/mcp_example.dart) | Connect an MCP server and pin its tool listing (beta) |
| [`claude_aws_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/claude_aws_example.dart) | Native Claude Platform on AWS authentication and Messages |
| [`bedrock_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/bedrock_example.dart) | Stream Claude through Bedrock Mantle or Runtime |
| [`google_cloud_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/google_cloud_example.dart) | Send a message through Anthropic-managed Google Cloud or Vertex |
| [`foundry_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/foundry_example.dart) | Stream a Foundry deployment with Azure authentication |
| [`managed_agents_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/managed_agents_example.dart) | Managed agents: agents, sessions, vaults, multiagent rosters, outcomes, webhooks, credential validation (beta) |
| [`managed_agents_workflow_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/managed_agents_workflow_example.dart) | Configure dynamic workflows and follow workflow run events (Managed Agents beta) |
| [`environments_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/environments_example.dart) | Managed Agents cloud and self-hosted environment lifecycle (beta) |
| [`mcp_tunnels_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/mcp_tunnels_example.dart) | MCP tunnel, proxy token and certificate management (research preview) |
| [`environment_work_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/environment_work_example.dart) | Self-hosted environment work polling and lease heartbeat (beta) |
| [`session_threads_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/session_threads_example.dart) | Session threads: list, retrieve, stream events, archive (beta) |
| [`deployments_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/deployments_example.dart) | Scheduled deployments and deployment runs: cron schedule, pause/resume, run-now (beta) |
| [`memory_stores_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/memory_stores_example.dart) | Managed agents memory stores, memories, and versions (beta) |
| [`dreams_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/dreams_example.dart) | Dreams: memory-consolidation jobs — create, poll, list, archive (beta, research preview) |
| [`current_user_profiles_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/current_user_profiles_example.dart) | Inspect enforcement status and paginate user profiles |
| [`user_profiles_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/user_profiles_example.dart) | Legacy user profiles and enrollment URLs (beta) |
| [`service_accounts_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/service_accounts_example.dart) | List service accounts and their workspace memberships |
| [`organization_admin_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_admin_example.dart) | Read-only organization and workspace administration |
| [`external_keys_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/external_keys_example.dart) | List registered customer-managed encryption keys |
| [`organization_analytics_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_analytics_example.dart) | Dimensioned organization usage and cost with cursor pagination (beta) |
| [`organization_legacy_analytics_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_legacy_analytics_example.dart) | Legacy Console or Enterprise usage report with time buckets |
| [`organization_activity_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_activity_example.dart) | Claude Enterprise daily summaries and paginated user activity |
| [`organization_rbac_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_rbac_example.dart) | List RBAC groups, members, roles and permissions |
| [`organization_spend_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_spend_example.dart) | List effective spend limits and pending increase requests |
| [`organization_sign_out_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_sign_out_example.dart) | Sign out a specified Claude Enterprise member (beta) |
| [`organization_webhooks_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_webhooks_example.dart) | List organization webhook endpoints (beta) |
| [`organization_webhook_receiver_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_webhook_receiver_example.dart) | Verify and parse signed webhook deliveries |
| [`organization_telemetry_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_telemetry_example.dart) | Page through OpenTelemetry destinations and inspect delivery health (beta) |
| [`organization_claude_tag_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_claude_tag_example.dart) | Audit Slack channel settings and inheritance in Claude Tag (beta) |
| [`organization_plugins_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/organization_plugins_example.dart) | List plugins and optionally validate a marketplace repository (beta) |
| [`models_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/models_example.dart) | Model lifecycle filters, pagination, and capabilities |
| [`compliance_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/compliance_example.dart) | Scoped Compliance Activity Feed |
| [`compliance_content_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/compliance_content_example.dart) | Scoped Compliance app content and artifact downloads |
| [`error_handling_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/error_handling_example.dart) | Exception handling patterns |
| [`abort_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/abort_example.dart) | Cancel buffered requests and streams with an abort trigger |
| [`anthropic_sdk_dart_example.dart`](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/example/anthropic_sdk_dart_example.dart) | Quick-start overview |

## API Coverage

| API | Dart coverage |
| --- | --- |
| Messages | Create, stream, count tokens, response metadata, tools, multimodal inputs, and beta stateful workflows |
| Cloud transports | Claude Platform on AWS, Bedrock Mantle and Runtime, Anthropic-managed Google Cloud and Vertex, Microsoft Foundry |
| Message Batches | Create, list, retrieve, cancel, delete, and stream results |
| Models | List and retrieve model capabilities and lifecycle status |
| Files and Skills | Upload, list, retrieve, delete, and work with file content and skill versions |
| Managed Agents | Agents, sessions, workflow events, session threads, environments and work leases, vaults, memory stores, Dreams, deployments, and typed webhook events (beta) |
| MCP tunnels | Workspace-scoped tunnels and CA certificates (research preview) |
| User Profiles | Profile management and attribution, including the legacy beta operations |
| Authentication | API keys, scoped OAuth bearer tokens, and workload identity federation |
| Organization Admin | Organization, workspaces, users, invites, API keys, rate and spend limits, roles, sign-out, and compliance settings |
| Organization Analytics | Dimensioned usage and cost reports (beta), legacy reports, and Enterprise activity |
| Organization webhooks | Endpoint management and signature verification (beta) |
| Organization telemetry | OpenTelemetry destinations, test deliveries, and workspace selection (beta) |
| Enterprise plugins | Plugins, versions, ZIP archives, installation settings, shares, and marketplace validation (beta) |
| Claude Tag | Slack channels, inherited settings, and access bundles for Claude Enterprise (beta) |
| Compliance | Activity Feed, directory, settings, Security Posture (beta), app content, sessions, and Code Artifacts |

API availability depends on the model, provider, and organization access. [Claude features overview](https://platform.claude.com/docs/en/build-with-claude/overview)

For integrations that still use legacy Text Completions, [move to the Messages API](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/MIGRATION.md#move-text-completions-to-messages).

## Official Documentation

- [API reference](https://pub.dev/documentation/anthropic_sdk_dart/latest/)
- [Anthropic API docs](https://platform.claude.com/docs/en/api/overview)
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

This package is licensed under the [MIT License](https://github.com/davidmigloz/ai_clients_dart/blob/main/packages/anthropic_sdk_dart/LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by Anthropic.
