# Migration Guide

This guide covers breaking changes between major versions of `anthropic_sdk_dart`.

For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).

---

## Migrating from v3.x to v4.0.0

**Most users will not need to make any changes.** v4.0.0 syncs to the latest Anthropic spec for the [Claude Opus 4.8](https://www.anthropic.com/news/claude-opus-4-8) release. The breaking surface is limited to two source-level additions — a new variant on the exported sealed union `InputContentBlock` and a new value on the `MessageRole` enum — which only affect code with *exhaustive* `switch` statements that lack a wildcard or `Unknown*`/`default` branch. Everything else in this release (mid-conversation system messages, `outputTokensDetails`, advisor `stopReason`) is purely additive. Pure-deserialization consumers — and anyone already using a wildcard / `Unknown*` / `default` branch — are unaffected.

### 1) New `MidConversationSystemInputBlock` variant on `InputContentBlock`

The `mid_conv_system` content block adds a `MidConversationSystemInputBlock` variant to the exported sealed `InputContentBlock` union. As in v3.0.0, this is breaking only for exhaustive `switch` statements over `InputContentBlock` that lack a wildcard or `UnknownInputContentBlock` branch.

```dart
// Before — exhaustive over the prior variant set (stops compiling on upgrade)
final label = switch (block) {
  TextInputBlock() => 'text',
  ImageInputBlock() => 'image',
  // ... all other variants
};

// After — handle the new variant, or add a wildcard `_` / UnknownInputContentBlock()
final label = switch (block) {
  TextInputBlock() => 'text',
  ImageInputBlock() => 'image',
  MidConversationSystemInputBlock() => 'mid_conv_system',
  UnknownInputContentBlock() => 'unknown',
};
```

### 2) New `system` value on the `MessageRole` enum

The spec adds `system` to the message `role` enum (enabling `role: "system"` entries in the `messages` array). `MessageRole` gains a `system` value, and `InputMessage` gains `system(...)` / `systemBlocks(...)` factories. This is breaking only for exhaustive `switch` statements over `MessageRole` that lack a `default` branch.

```dart
// Before — exhaustive over user/assistant (stops compiling on upgrade)
final s = switch (role) {
  MessageRole.user => 'user',
  MessageRole.assistant => 'assistant',
};

// After — add the system case (or a default branch)
final s = switch (role) {
  MessageRole.user => 'user',
  MessageRole.assistant => 'assistant',
  MessageRole.system => 'system',
};
```

All newly added *fields* in this release (`Usage.outputTokensDetails`, `MessageDeltaUsage.outputTokensDetails`, `AdvisorResult.stopReason`, `AdvisorRedactedResult.stopReason`) are optional and nullable, so they are non-breaking on their own.

---

## Migrating from v2.x to v3.0.0

v3.0.0 completes the four-part Anthropic spec refresh. The breaking surface is small and mostly about forward-compatibility: several **exported `sealed` unions gained new variants**, so only code that `switch`es over them *exhaustively* (without a wildcard or `Unknown*` branch) needs updating. There is one concrete API break — `UserProfile.relationship` is now a required constructor parameter. Pure-deserialization consumers (no exhaustive `switch` over these types) are unaffected.

### 1) `UserProfile.relationship` is now required

The spec marks `relationship` as required and non-nullable, so it is now a required constructor parameter. Only code that constructs `UserProfile` directly (tests, mocks, fixtures) is affected — `UserProfile.fromJson` is unchanged.

```dart
// Before (v2.x)
final profile = UserProfile(
  id: 'uprof_…',
  metadata: {},
  trustGrants: {},
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// After (v3.0.0) — relationship is now required
final profile = UserProfile(
  id: 'uprof_…',
  relationship: BetaUserProfileRelationship.external,
  metadata: {},
  trustGrants: {},
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### 2) New variants on exported `sealed` unions

Adding variants to a `sealed` type is source-breaking for downstream `switch` statements that were exhaustive over the previous variant set. The fix is the same in every case: handle the new variant(s), or add a wildcard / `Unknown*` catch-all so future additions stay non-breaking.

The affected unions and their new variants:

- **`Citation`** ([#233](https://github.com/davidmigloz/ai_clients_dart/issues/233)) — `SearchResultLocationCitation`, `UnknownCitation`. (Bonus: `Citation.fromJson` previously *threw* `FormatException` on unrecognized types; with `UnknownCitation` it is now forward-compatible.)
- **`InputContentBlock`** ([#235](https://github.com/davidmigloz/ai_clients_dart/issues/235)) — `SearchResultInputBlock`.
- **`SessionEvent`** ([#236](https://github.com/davidmigloz/ai_clients_dart/issues/236), [#230](https://github.com/davidmigloz/ai_clients_dart/issues/230), [#224](https://github.com/davidmigloz/ai_clients_dart/issues/224)) — `SessionUpdatedEvent`, `UserToolResultEvent`, `SpanOutcomeEvaluationStartEvent`, `SpanOutcomeEvaluationOngoingEvent`, `SpanOutcomeEvaluationEndEvent`, `UserDefineOutcomeEvent`, plus the session-thread lifecycle events.
- **`EventParams`** ([#236](https://github.com/davidmigloz/ai_clients_dart/issues/236), [#230](https://github.com/davidmigloz/ai_clients_dart/issues/230)) — `UserToolResultEventParams`, `UserDefineOutcomeEventParams`.

```dart
// Before — exhaustive over the prior variant set (stops compiling on upgrade)
final label = switch (citation) {
  CharLocationCitation() => 'char',
  PageLocationCitation() => 'page',
  ContentBlockLocationCitation() => 'block',
  WebSearchResultLocationCitation() => 'web',
};

// After — handle the new variant, and use UnknownCitation (or a wildcard `_`)
// so subsequent additions are non-breaking
final label = switch (citation) {
  CharLocationCitation() => 'char',
  PageLocationCitation() => 'page',
  ContentBlockLocationCitation() => 'block',
  WebSearchResultLocationCitation() => 'web',
  SearchResultLocationCitation() => 'search_result',
  UnknownCitation() => 'unknown',
};
```

The same pattern applies to `InputContentBlock`, `SessionEvent`, and `EventParams` — add the new branches, or a wildcard `_` (or the union's `Unknown*` variant) to stay forward-compatible.

All newly added *fields* in this release (`Message.diagnostics`, `MessageCreateRequest.diagnostics`, `ThinkingDelta.estimatedTokens`, `UpdateSessionParams.agent`, the new `DocumentInputBlock`/`TextInputBlock` citation fields, etc.) are optional and nullable, so they are non-breaking on their own.

---

## Migrating from v1.x to v2.0.0

v2.0.0 tightens `Session` field nullability to match the `BetaManagedAgentsSession` spec. Six fields that were previously nullable are now required non-nullable, so code constructing `Session` instances directly (for tests, mocks, or fixtures) must provide them.

### 1) Non-Nullable Required Fields on `Session`

Six fields on `Session` are no longer nullable and are required constructor parameters: `environmentId`, `metadata`, `resources`, `vaultIds`, `stats`, and `usage`. The `title` and `archivedAt` fields stay nullable (spec `nullable: true`) but are now `required` parameters in the constructor.

```dart
// Before (v1.x) — fields were optional and nullable
final session = Session(
  id: 'sess_1',
  type: 'session',
  agentId: 'agent_1',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// After (v2.0.0) — all required fields must be provided
final session = Session(
  id: 'sess_1',
  type: 'session',
  agentId: 'agent_1',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  title: null,
  archivedAt: null,
  environmentId: 'env_1',
  metadata: const {},
  resources: const [],
  vaultIds: const [],
  stats: SessionStats(...),
  usage: SessionUsage(...),
);
```

Deserialization from JSON (`Session.fromJson`) is unchanged — the API always returns these fields, so only direct construction is affected.

---

## Migrating from v0.1.x to v1.0.0

This guide helps you migrate from the old `anthropic_sdk_dart` client (v0.1.x) to the new **v1.0.0** (complete rewrite with resource-based organization and comprehensive API coverage).

## Overview of Changes

The new client mirrors the official REST structure with **resource-based APIs**. Instead of calling methods directly on the client, you now use resource objects:

* `client.messages` — Message creation, streaming, token counting
* `client.messages.batches` — Batch message processing
* `client.models` — Model listing and retrieval
* `client.files` — File upload/management (Beta)
* `client.skills` — Custom skills management (Beta)

## Quick Reference Table

| Operation             | Old API (v0.1.x)                                    | New API (v1.0.0)                                                              |
| --------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------- |
| **Initialize Client** | `AnthropicClient(apiKey: 'KEY')`                    | `AnthropicClient(config: AnthropicConfig(authProvider: ApiKeyProvider('KEY')))` |
| **Create Message**    | `client.createMessage(request: ...)`                | `client.messages.create(...)`                                                 |
| **Stream Message**    | `client.createMessageStream(request: ...)`          | `client.messages.createStream(...)`                                           |
| **Count Tokens**      | `client.countMessageTokens(request: ...)`           | `client.messages.countTokens(...)`                                            |
| **List Models**       | `client.listModels()`                               | `client.models.list()`                                                        |
| **Get Model**         | `client.retrieveModel(modelId: ...)`                | `client.models.retrieve(...)`                                                 |
| **List Batches**      | `client.listMessageBatches()`                       | `client.messages.batches.list()`                                              |
| **Create Batch**      | `client.createMessageBatch(request: ...)`           | `client.messages.batches.create(...)`                                         |
| **Upload File**       | ❌ Not available                                    | `client.files.upload(...)` *(Beta)*                                           |
| **Create Skill**      | ❌ Not available                                    | `client.skills.create(...)` *(Beta)*                                          |

## 1) Client Initialization

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

// Before
final old = AnthropicClient(
  apiKey: Platform.environment['ANTHROPIC_API_KEY'],
);
old.endSession();

// After
final client = AnthropicClient(
  config: AnthropicConfig(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
  ),
);
// Or from environment variables (reads ANTHROPIC_API_KEY)
final client = AnthropicClient.fromEnvironment();
client.close();
```

## 2) Message Creation

```dart
// Before
final res = await client.createMessage(
  request: CreateMessageRequest(
    model: Model.model(Models.claude35Sonnet20241022),
    maxTokens: 1024,
    messages: [
      Message(
        role: MessageRole.user,
        content: MessageContent.text('Hello, Claude'),
      ),
    ],
  ),
);
print(res.content.text);

// After
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [InputMessage.user('Hello, Claude')],
  ),
);
print(response.text);
```

**Key changes:**

* Access under `client.messages`
* `Model.model(Models.xxx)` → String model ID
* `Message(role:, content:)` → `InputMessage.user()` / `InputMessage.assistant()`
* `response.content.text` → `response.text` helper property

## 3) System Prompts

```dart
// Before
CreateMessageRequest(
  system: CreateMessageRequestSystem.text('You are helpful'),
  // or with blocks
  system: CreateMessageRequestSystem.blocks([
    Block.text(text: 'instruction'),
  ]),
  ...
)

// After
MessageCreateRequest(
  system: SystemPrompt.text('You are helpful'),
  // or with blocks (now supports cache control)
  system: SystemPrompt.blocks([
    SystemTextBlock(
      text: 'instruction',
      cacheControl: CacheControlEphemeral(),
    ),
  ]),
  ...
)
```

## 4) Streaming

```dart
// Before
final stream = client.createMessageStream(
  request: CreateMessageRequest(
    model: Model.model(Models.claude35Sonnet20241022),
    maxTokens: 1024,
    messages: [
      Message(
        role: MessageRole.user,
        content: MessageContent.text('Hello'),
      ),
    ],
  ),
);
await for (final res in stream) {
  res.map(
    messageStart: (e) { /* ... */ },
    contentBlockDelta: (e) {
      stdout.write(e.delta.text);
    },
    messageStop: (e) { /* ... */ },
    ping: (e) { /* ... */ },
    error: (e) { /* ... */ },
    // ... other handlers
  );
}

// After
final stream = client.messages.createStream(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [InputMessage.user('Hello')],
  ),
);
await for (final event in stream) {
  switch (event) {
    case MessageStartEvent(:final message):
      print('Started: ${message.id}');
    case ContentBlockDeltaEvent(:final delta):
      if (delta is TextDelta) {
        stdout.write(delta.text);
      }
    case MessageDeltaEvent(:final delta):
      print('Stop reason: ${delta.stopReason}');
    case MessageStopEvent():
      print('Done');
    case PingEvent():
      break;
    case ErrorEvent(:final message):
      print('Error: $message');
    default:
      break;
  }
}
```

**Key changes:**

* `.map()` method → `switch/case` pattern matching
* `e.delta.text` → Type check with `if (delta is TextDelta)`
* More idiomatic Dart 3 patterns

## 5) Tool Use

```dart
// Before
const tool = Tool.custom(
  name: 'get_weather',
  description: 'Get weather for a location',
  inputSchema: {
    'type': 'object',
    'properties': {
      'location': {'type': 'string'},
    },
    'required': ['location'],
  },
);

final response = await client.createMessage(
  request: CreateMessageRequest(
    model: Model.model(Models.claude35Sonnet20241022),
    tools: [tool],
    toolChoice: ToolChoice(type: ToolChoiceType.auto),
    messages: [...],
    maxTokens: 1024,
  ),
);

final toolUse = response.content.blocks.firstOrNull;
if (toolUse is ToolUseBlock) {
  print('Tool: ${toolUse.name}');
  print('Input: ${toolUse.input}');
}

// After - Typed tools with ToolDefinition
final tool = Tool(
  name: 'get_weather',
  description: 'Get weather for a location',
  inputSchema: InputSchema(
    properties: {
      'location': {'type': 'string', 'description': 'City name'},
    },
    required: ['location'],
    extra: {'additionalProperties': false},
  ),
);

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    tools: [ToolDefinition.custom(tool)],
    toolChoice: ToolChoice.auto(),
    messages: [...],
    maxTokens: 1024,
  ),
);

// New helper properties
if (response.hasToolUse) {
  for (final toolUse in response.toolUseBlocks) {
    print('Tool: ${toolUse.name}');
    print('Input: ${toolUse.input}');
  }
}
```

**Key changes:**

* `Tool.custom()` → `ToolDefinition.custom(Tool(...))` - explicit wrapper
* `ToolChoice(type: ToolChoiceType.auto)` → `ToolChoice.auto()`
* Tools now use typed `List<ToolDefinition>` instead of `List<Map<String, dynamic>>`
* New helpers: `response.hasToolUse`, `response.toolUseBlocks`

### Built-in Tools

v1.0.0 adds support for Anthropic's built-in tools:

```dart
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 4096,
    tools: [
      // Web search tool
      ToolDefinition.builtIn(
        BuiltInTool.webSearch(
          maxUses: 5,
          allowedDomains: ['wikipedia.org', 'docs.anthropic.com'],
        ),
      ),
      // Bash tool (computer use)
      ToolDefinition.builtIn(BuiltInTool.bash()),
      // Text editor tool
      ToolDefinition.builtIn(
        BuiltInTool.textEditor(maxCharacters: 50000),
      ),
      // Mix with custom tools
      ToolDefinition.custom(myCustomTool),
    ],
    toolChoice: ToolChoice.auto(),
    messages: [InputMessage.user('Search for the latest Claude release')],
  ),
);
```

### Tool Choice Options

```dart
// Let Claude decide whether to use tools
toolChoice: ToolChoice.auto()

// Force Claude to use any available tool
toolChoice: ToolChoice.any()

// Force Claude to use a specific tool
toolChoice: ToolChoice.tool('get_weather')

// Prevent tool use entirely
toolChoice: ToolChoice.none()

// Disable parallel tool use (one tool at a time)
toolChoice: ToolChoice.auto(disableParallelToolUse: true)
```

## 6) Tool Results

```dart
// Before
Message(
  role: MessageRole.user,
  content: MessageContent.blocks([
    Block.toolResult(
      toolUseId: toolUse.id,
      content: ToolResultBlockContent.text(jsonEncode(result)),
    ),
  ]),
)

// After
InputMessage.userBlocks([
  InputContentBlock.toolResult(
    toolUseId: toolUse.id,
    content: [ToolResultContent.text(jsonEncode(result))],
  ),
])
```

## 7) Vision / Images

```dart
// Before: Not well documented in the old package

// After - From URL
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [
      InputMessage.userBlocks([
        InputContentBlock.image(
          ImageSource.url('https://example.com/image.jpg'),
        ),
        InputContentBlock.text('What is in this image?'),
      ]),
    ],
  ),
);

// After - From base64
InputMessage.userBlocks([
  InputContentBlock.image(
    ImageSource.base64(
      mediaType: ImageMediaType.jpeg,
      data: base64EncodedImageData,
    ),
  ),
  InputContentBlock.text('Describe this image'),
])

// After - Multiple images
InputMessage.userBlocks([
  InputContentBlock.image(ImageSource.url('https://example.com/cat.jpg')),
  InputContentBlock.image(ImageSource.url('https://example.com/dog.jpg')),
  InputContentBlock.text('Compare these two animals'),
])
```

## 8) Documents (New)

```dart
// Process PDFs and other documents
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 2048,
    messages: [
      InputMessage.userBlocks([
        InputContentBlock.document(
          DocumentSource.base64Pdf(base64PdfData),
          title: 'Research Paper',
        ),
        InputContentBlock.text('Summarize the key findings'),
      ]),
    ],
  ),
);
```

## 9) Extended Thinking (New)

```dart
// Enable Claude to think through complex problems
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 16000,
    thinking: ThinkingConfig.enabled(budgetTokens: 10000),
    messages: [
      InputMessage.user('Solve this complex math problem: ...'),
    ],
  ),
);

// Access the thinking process
if (response.hasThinking) {
  for (final block in response.thinkingBlocks) {
    print('Thinking: ${block.thinking}');
  }
}
print('Answer: ${response.text}');

// Streaming with thinking
await for (final event in client.messages.createStream(request)) {
  switch (event) {
    case ContentBlockDeltaEvent(:final delta):
      if (delta is ThinkingDelta) {
        print('Thinking: ${delta.thinking}');
      } else if (delta is TextDelta) {
        print('Response: ${delta.text}');
      }
    default:
      break;
  }
}
```

## 10) Token Counting (New)

```dart
// Count tokens before sending a request
final count = await client.messages.countTokens(
  TokenCountRequest(
    model: 'claude-sonnet-4-20250514',
    system: SystemPrompt.text('You are helpful.'),
    messages: [InputMessage.user('Hello, how are you?')],
  ),
);
print('Input tokens: ${count.inputTokens}');
```

## 11) Files API (New, Beta)

```dart
import 'dart:io' as io;

// Upload a file
final file = await client.files.upload(
  filePath: '/path/to/document.pdf',
  mimeType: 'application/pdf',
);
print('Uploaded: ${file.id}');

// List files
final files = await client.files.list(limit: 10);
for (final f in files.data) {
  print('${f.id}: ${f.filename}');
}

// Download a file
final bytes = await client.files.download(fileId: file.id);
await io.File('downloaded.pdf').writeAsBytes(bytes);

// Delete a file
await client.files.deleteFile(fileId: file.id);
```

## 12) Message Batches

```dart
// Before
final batch = await client.createMessageBatch(request: request);
final status = await client.retrieveMessageBatch(id: batch.id);
await client.cancelMessageBatch(id: batch.id);

// After - Now nested under messages
final batch = await client.messages.batches.create(
  MessageBatchCreateRequest(
    requests: [
      BatchRequestItem(
        customId: 'req-1',
        params: MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 512,
          messages: [InputMessage.user('Question 1')],
        ),
      ),
      BatchRequestItem(
        customId: 'req-2',
        params: MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 512,
          messages: [InputMessage.user('Question 2')],
        ),
      ),
    ],
  ),
);

// Check status
final status = await client.messages.batches.retrieve(batch.id);
print('Status: ${status.processingStatus}');

// Cancel if needed
await client.messages.batches.cancel(batch.id);

// Stream results (new!)
await for (final result in client.messages.batches.results(batch.id)) {
  print('${result.customId}: ${result.result}');
}
```

## 13) Exception Handling

```dart
// Before
try {
  await client.createMessage(request: request);
} on AnthropicClientException catch (e) {
  print('Error: ${e.message}');
}

// After - Specific exception types for targeted handling
try {
  await client.messages.create(request);
} on AuthenticationException catch (e) {
  print('Authentication failed: ${e.message}');
  // Check API key
} on RateLimitException catch (e) {
  print('Rate limited: ${e.message}');
  if (e.retryAfter != null) {
    final delay = e.retryAfter!.difference(DateTime.now());
    if (!delay.isNegative) {
      await Future.delayed(delay);
    }
    // Retry request
  }
} on ValidationException catch (e) {
  print('Validation error: ${e.message}');
  // Fix request parameters
} on ApiException catch (e) {
  print('API error (${e.statusCode}): ${e.message}');
  // Handle server errors
} on TimeoutException catch (e) {
  print('Request timed out after ${e.timeout}');
  // Retry or notify user
} on AbortedException catch (e) {
  print('Request was aborted');
  // Handle cancellation
}
```

## 14) Advanced Configuration

```dart
final client = AnthropicClient(
  config: AnthropicConfig(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
    baseUrl: 'https://custom-endpoint.example.com',
    timeout: Duration(minutes: 5),
    retryPolicy: RetryPolicy(
      maxRetries: 5,
      initialDelay: Duration(seconds: 2),
      maxDelay: Duration(minutes: 1),
    ),
    logLevel: Level.INFO,
    defaultHeaders: {'X-Custom-Header': 'value'},
    apiVersion: '2023-06-01',
  ),
);
```

## 15) Enum Type Changes

Some fields that were previously `String` are now typed enums for better type safety.

### Skill.source (String → SkillSource)

```dart
// Before
if (skill.source == 'anthropic') { ... }
final skills = await client.skills.list(source: 'anthropic');

// After
if (skill.source == SkillSource.anthropic) { ... }
final skills = await client.skills.list(source: SkillSource.anthropic);
```

### Message.role (String → MessageRole)

```dart
// Before
if (message.role == 'assistant') { ... }

// After
if (message.role == MessageRole.assistant) { ... }
```

## Common Pitfalls & Notes

* **Model IDs**: Now strings (`'claude-sonnet-4-20250514'`), not enum constants
* **Session cleanup**: `endSession()` → `close()`
* **Response helpers**: Use `.text`, `.hasToolUse`, `.toolUseBlocks`, `.thinkingBlocks`
* **Streaming**: Pattern matching with `switch/case` instead of `.map()`
* **Beta features**: Files and Skills APIs require specific beta headers (handled automatically)
* **Nested resources**: Batches are now at `client.messages.batches`, not `client.batches`

## Migration Checklist

- [ ] Update client initialization to use `AnthropicConfig` with `AuthProvider`
- [ ] Replace `client.createMessage()` with `client.messages.create()`
- [ ] Replace `client.createMessageStream()` with `client.messages.createStream()`
- [ ] Update model references from `Model.model(Models.xxx)` to string IDs
- [ ] Replace `Message(role:, content:)` with `InputMessage.user()` / `InputMessage.assistant()`
- [ ] Update content blocks from `Block.xxx()` to `InputContentBlock.xxx()`
- [ ] Update streaming handlers from `.map()` to `switch/case` pattern matching
- [ ] Replace `endSession()` with `close()`
- [ ] Update error handling to use specific exception types
- [ ] Use response helper properties (`.text`, `.toolUseBlocks`, etc.)
- [ ] Update batch operations to use `client.messages.batches`
