import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TokenCountRequest', () {
    test('fromJson deserializes with all fields', () {
      final json = {
        'model': 'claude-sonnet-4-6',
        'messages': [
          {'role': 'user', 'content': 'Hello, Claude'},
        ],
        'system': 'You are a helpful assistant.',
        'tool_choice': {'type': 'auto'},
        'tools': [
          {
            'name': 'get_weather',
            'description': 'Get the weather',
            'input_schema': {
              'type': 'object',
              'properties': {
                'location': {'type': 'string'},
              },
            },
          },
        ],
        'thinking': {'type': 'disabled'},
        'output_config': {
          'effort': 'high',
          'format': {
            'type': 'json_schema',
            'schema': {
              'type': 'object',
              'properties': {
                'answer': {'type': 'string'},
              },
            },
          },
        },
        'speed': 'fast',
        'cache_control': {'type': 'ephemeral'},
      };

      final request = TokenCountRequest.fromJson(json);

      expect(request.model, 'claude-sonnet-4-6');
      expect(request.messages, hasLength(1));
      expect(request.system, isNotNull);
      expect(request.toolChoice, isNotNull);
      expect(request.tools, hasLength(1));
      expect(request.thinking, isA<ThinkingDisabled>());
      expect(request.outputConfig, isNotNull);
      expect(request.outputConfig!.effort, EffortLevel.high);
      expect(request.speed, Speed.fast);
      expect(request.cacheControl, isNotNull);
      expect(request.cacheControl!.type, 'ephemeral');
    });

    test('fromJson deserializes with required fields only', () {
      final json = {
        'model': 'claude-sonnet-4-6',
        'messages': [
          {'role': 'user', 'content': 'Hello, Claude'},
        ],
      };

      final request = TokenCountRequest.fromJson(json);

      expect(request.model, 'claude-sonnet-4-6');
      expect(request.messages, hasLength(1));
      expect(request.system, isNull);
      expect(request.toolChoice, isNull);
      expect(request.tools, isNull);
      expect(request.thinking, isNull);
      expect(request.cacheControl, isNull);
    });

    test('fromJson deserializes system as string', () {
      final json = {
        'model': 'claude-sonnet-4-6',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'system': 'You are helpful.',
      };

      final request = TokenCountRequest.fromJson(json);

      expect(request.system, isA<TextSystemPrompt>());
      final systemText = request.system! as TextSystemPrompt;
      expect(systemText.text, 'You are helpful.');
    });

    test('fromJson deserializes system as array of blocks', () {
      final json = {
        'model': 'claude-sonnet-4-6',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'system': [
          {'type': 'text', 'text': 'You are helpful.'},
        ],
      };

      final request = TokenCountRequest.fromJson(json);

      expect(request.system, isA<BlocksSystemPrompt>());
    });

    test('toJson serializes correctly', () {
      final request = TokenCountRequest(
        model: 'claude-sonnet-4-6',
        messages: [InputMessage.user('Hello')],
        system: SystemPrompt.text('Be helpful'),
      );

      final json = request.toJson();

      expect(json['model'], 'claude-sonnet-4-6');
      expect(json['messages'], hasLength(1));
      expect(json['system'], 'Be helpful');
    });

    test('toJson serializes cache_control with TTL', () {
      final request = TokenCountRequest(
        model: 'claude-sonnet-4-6',
        messages: [InputMessage.user('Hello')],
        cacheControl: const CacheControlEphemeral(ttl: CacheTtl.ttl5m),
      );

      final json = request.toJson();

      expect(json['cache_control'], isA<Map<String, dynamic>>());
      final cc = json['cache_control'] as Map<String, dynamic>;
      expect(cc['type'], 'ephemeral');
      expect(cc['ttl'], '5m');
    });

    test('toJson serializes cache_control without TTL', () {
      final request = TokenCountRequest(
        model: 'claude-sonnet-4-6',
        messages: [InputMessage.user('Hello')],
        cacheControl: const CacheControlEphemeral(),
      );

      final json = request.toJson();

      expect(json['cache_control'], isA<Map<String, dynamic>>());
      final cc = json['cache_control'] as Map<String, dynamic>;
      expect(cc['type'], 'ephemeral');
      expect(cc.containsKey('ttl'), isFalse);
    });

    test('toJson excludes null optional fields', () {
      final request = TokenCountRequest(
        model: 'claude-sonnet-4-6',
        messages: [InputMessage.user('Hello')],
      );

      final json = request.toJson();

      expect(json.containsKey('system'), isFalse);
      expect(json.containsKey('tool_choice'), isFalse);
      expect(json.containsKey('tools'), isFalse);
      expect(json.containsKey('thinking'), isFalse);
      expect(json.containsKey('cache_control'), isFalse);
    });

    test('fromJson parses thinking config', () {
      final json = {
        'model': 'claude-sonnet-4-6',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'thinking': {'type': 'enabled', 'budget_tokens': 5000},
      };

      final request = TokenCountRequest.fromJson(json);

      expect(request.thinking, isA<ThinkingEnabled>());
      final thinking = request.thinking! as ThinkingEnabled;
      expect(thinking.budgetTokens, 5000);
    });
  });

  group('TokenCountRequest.fromMessageCreateRequest', () {
    test('copies shared fields', () {
      final request = MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        messages: [InputMessage.user('Hello')],
        maxTokens: 1024,
        system: SystemPrompt.text('Be helpful'),
        thinking: const ThinkingDisabled(),
        toolChoice: ToolChoice.auto(),
        tools: [
          ToolDefinition.custom(
            const Tool(
              name: 'get_weather',
              description: 'Get weather',
              inputSchema: InputSchema(),
            ),
          ),
        ],
        outputConfig: const OutputConfig(effort: EffortLevel.high),
        speed: Speed.fast,
        cacheControl: const CacheControlEphemeral(),
      );

      final tokenRequest = TokenCountRequest.fromMessageCreateRequest(request);

      expect(tokenRequest.model, request.model);
      expect(tokenRequest.messages, request.messages);
      expect(tokenRequest.system, request.system);
      expect(tokenRequest.thinking, request.thinking);
      expect(tokenRequest.toolChoice, request.toolChoice);
      expect(tokenRequest.tools, request.tools);
      expect(tokenRequest.outputConfig, request.outputConfig);
      expect(tokenRequest.speed, request.speed);
      expect(tokenRequest.cacheControl, request.cacheControl);
    });

    test('omits fields not in TokenCountRequest', () {
      final request = MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        messages: [InputMessage.user('Hello')],
        maxTokens: 1024,
        metadata: const Metadata(userId: 'user-123'),
        temperature: 0.7,
        topP: 0.9,
        topK: 40,
        stopSequences: const ['END'],
        stream: true,
      );

      final tokenRequest = TokenCountRequest.fromMessageCreateRequest(request);

      expect(tokenRequest.model, request.model);
      expect(tokenRequest.messages, request.messages);
      expect(tokenRequest.system, isNull);
      expect(tokenRequest.thinking, isNull);
      expect(tokenRequest.toolChoice, isNull);
      expect(tokenRequest.tools, isNull);
      expect(tokenRequest.outputConfig, isNull);
      expect(tokenRequest.speed, isNull);
      expect(tokenRequest.cacheControl, isNull);
    });

    test('handles minimal request', () {
      final request = MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        messages: [InputMessage.user('Hi')],
        maxTokens: 100,
      );

      final tokenRequest = TokenCountRequest.fromMessageCreateRequest(request);

      expect(tokenRequest.model, 'claude-sonnet-4-6');
      expect(tokenRequest.messages, hasLength(1));
      expect(tokenRequest.system, isNull);
    });
  });

  group('TokenCountResponse', () {
    test('fromJson deserializes correctly', () {
      final json = {'input_tokens': 150};

      final response = TokenCountResponse.fromJson(json);

      expect(response.inputTokens, 150);
    });

    test('toJson serializes correctly', () {
      const response = TokenCountResponse(inputTokens: 200);

      final json = response.toJson();

      expect(json['input_tokens'], 200);
    });

    test('round-trip serialization works', () {
      const original = TokenCountResponse(inputTokens: 42);

      final json = original.toJson();
      final restored = TokenCountResponse.fromJson(json);

      expect(restored.inputTokens, original.inputTokens);
    });

    test('copyWith creates modified copy', () {
      const original = TokenCountResponse(inputTokens: 100);

      final modified = original.copyWith(inputTokens: 200);

      expect(modified.inputTokens, 200);
    });

    test('equality works correctly', () {
      const response1 = TokenCountResponse(inputTokens: 100);
      const response2 = TokenCountResponse(inputTokens: 100);
      const response3 = TokenCountResponse(inputTokens: 200);

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });
  });
}
