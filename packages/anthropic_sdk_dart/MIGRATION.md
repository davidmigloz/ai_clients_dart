# Migration Guide

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

// After
const tool = Tool(
  name: 'get_weather',
  description: 'Get weather for a location',
  inputSchema: InputSchema(
    properties: {
      'location': {'type': 'string', 'description': 'City name'},
    },
    required: ['location'],
  ),
);

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    tools: [tool.toJson()],
    toolChoice: ToolChoiceAuto().toJson(),
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

* `Tool.custom()` → `Tool()` with `InputSchema` object
* `ToolChoice(type: ToolChoiceType.auto)` → `ToolChoiceAuto().toJson()`
* New helpers: `response.hasToolUse`, `response.toolUseBlocks`

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
if (response.thinkingBlock != null) {
  print('Thinking: ${response.thinkingBlock!.thinking}');
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
    await Future.delayed(e.retryAfter!);
    // Retry request
  }
} on ValidationException catch (e) {
  print('Validation error: ${e.message}');
  // Fix request parameters
} on ApiException catch (e) {
  print('API error (${e.code}): ${e.message}');
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

## Common Pitfalls & Notes

* **Model IDs**: Now strings (`'claude-sonnet-4-20250514'`), not enum constants
* **Session cleanup**: `endSession()` → `close()`
* **Response helpers**: Use `.text`, `.hasToolUse`, `.toolUseBlocks`, `.thinkingBlock`
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

## Getting Help

* Browse the [examples](example/)
* Check the [API docs](https://pub.dev/documentation/anthropic_sdk_dart/latest/)
* Open an issue: [https://github.com/davidmigloz/ai_clients_dart/issues](https://github.com/davidmigloz/ai_clients_dart/issues)

---

For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).
