# Implementation Patterns (anthropic_sdk_dart)

Extends [implementation-patterns-core.md](../../../shared/openapi-toolkit/references/implementation-patterns-core.md).

## Anthropic-Specific Patterns

### Authentication

Anthropic uses API key authentication via `x-api-key` header (not Bearer token):

```dart
class AuthInterceptor implements Interceptor {
  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    final credentials = await authProvider.getCredentials();

    if (credentials is ApiKeyCredentials) {
      final request = _cloneWithHeaders(context.request, {
        'x-api-key': credentials.apiKey,
      });
      return next(context.copyWith(request: request));
    }

    return next(context);
  }
}
```

### API Version Header

All requests require the `anthropic-version` header:

```dart
class RequestBuilder {
  Map<String, String> buildHeaders({Map<String, String>? additionalHeaders}) {
    return {
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
      ...config.defaultHeaders,
      ...?additionalHeaders,
    };
  }
}
```

### Beta Features

Beta features require the `anthropic-beta` header:

```dart
class BetaMessagesResource extends ResourceBase {
  Future<Message> create({
    required MessageCreateRequest request,
    List<String> betas = const [],
  }) async {
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {
        if (betas.isNotEmpty) 'anthropic-beta': betas.join(','),
      },
    );
    // ...
  }
}
```

### Beta Header Values

**CRITICAL**: Always verify beta header values from official sources. Wrong values cause `400 Bad Request`.

**Where to find correct values**:
1. [Official TypeScript SDK](https://github.com/anthropics/anthropic-sdk-typescript) - Check `src/resources/*.ts`
2. [Anthropic API Docs](https://docs.anthropic.com/en/api) - Beta feature documentation
3. OpenAPI spec beta annotations

**Current beta headers** (verify before use):

| Feature | Header Value | Source |
|---------|--------------|--------|
| Files API | `files-api-2025-04-14` | TypeScript SDK |
| Skills API | `skills-2025-10-02` | TypeScript SDK |
| Computer Use | `computer-use-2024-10-22` | TypeScript SDK |
| Token Counting | `token-counting-2024-11-01` | TypeScript SDK |
| PDF Support | `pdfs-2024-09-25` | TypeScript SDK |
| Prompt Caching | `prompt-caching-2024-07-31` | TypeScript SDK |
| Message Batches | `message-batches-2024-09-24` | TypeScript SDK |
| MCP | `mcp-2025-04-14` | TypeScript SDK |

**Common mistake**: Using made-up header values
```dart
// WRONG - This header doesn't exist!
const _betaHeader = 'skills-api-2025-02-20';  // 400 Bad Request

// RIGHT - Verified from TypeScript SDK
const _betaHeader = 'skills-2025-10-02';
```

### Streaming (SSE)

Anthropic uses Server-Sent Events for streaming:

```dart
Stream<MessageStreamEvent> parseSSE(Stream<List<int>> byteStream) async* {
  final lines = byteStream
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  String? eventType;
  StringBuffer dataBuffer = StringBuffer();

  await for (final line in lines) {
    if (line.startsWith('event: ')) {
      eventType = line.substring(7);
    } else if (line.startsWith('data: ')) {
      dataBuffer.write(line.substring(6));
    } else if (line.isEmpty && dataBuffer.isNotEmpty) {
      final data = dataBuffer.toString();
      dataBuffer.clear();

      if (data != '[DONE]') {
        final json = jsonDecode(data) as Map<String, dynamic>;
        yield MessageStreamEvent.fromJson(json, eventType);
      }
      eventType = null;
    }
  }
}
```

### Content Blocks (Sealed Class)

Content blocks use sealed class pattern:

```dart
sealed class ContentBlock {
  const ContentBlock();

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text' => TextBlock.fromJson(json),
      'image' => ImageBlock.fromJson(json),
      'tool_use' => ToolUseBlock.fromJson(json),
      'tool_result' => ToolResultBlock.fromJson(json),
      _ => throw FormatException('Unknown content block type: $type'),
    };
  }

  Map<String, dynamic> toJson();
}

class TextBlock extends ContentBlock {
  final String text;

  const TextBlock({required this.text});

  factory TextBlock.fromJson(Map<String, dynamic> json) => TextBlock(
    text: json['text'] as String,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'text',
    'text': text,
  };
}
```

### Nested Resources

Batches are nested under messages:

```dart
class MessagesResource extends ResourceBase with StreamingResource {
  late final MessageBatchesResource batches;

  MessagesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  }) {
    batches = MessageBatchesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
    );
  }
}

// Usage: client.messages.batches.create(...)
```

### Request/Response Pattern

```dart
class MessagesResource extends ResourceBase with StreamingResource {
  Future<Message> create({
    required MessageCreateRequest request,
    Future<void>? abortTrigger,
  }) async {
    final url = requestBuilder.buildUrl('/v1/messages');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Message.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Stream<MessageStreamEvent> createStream({
    required MessageCreateRequest request,
    Future<void>? abortTrigger,
  }) async* {
    final url = requestBuilder.buildUrl('/v1/messages');
    final headers = requestBuilder.buildHeaders();

    final requestData = request.copyWith(stream: true);
    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    yield* parseSSE(streamedResponse.stream);
  }
}
```

### Extension Methods

```dart
extension MessageExtensions on Message {
  /// Gets the text content from the first text block.
  String? get text {
    for (final block in content) {
      if (block is TextBlock) return block.text;
    }
    return null;
  }

  /// Gets all tool use blocks.
  List<ToolUseBlock> get toolUse =>
      content.whereType<ToolUseBlock>().toList();

  /// Checks if the message was stopped due to tool use.
  bool get hasToolUse => stopReason == StopReason.toolUse;
}
```
