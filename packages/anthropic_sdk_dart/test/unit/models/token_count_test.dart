import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TokenCountRequest', () {
    test('fromJson deserializes with all fields', () {
      final json = {
        'model': 'claude-sonnet-4-20250514',
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
      };

      final request = TokenCountRequest.fromJson(json);

      expect(request.model, 'claude-sonnet-4-20250514');
      expect(request.messages, hasLength(1));
      expect(request.system, isNotNull);
      expect(request.toolChoice, isNotNull);
      expect(request.tools, hasLength(1));
      expect(request.thinking, isA<ThinkingDisabled>());
    });

    test('fromJson deserializes with required fields only', () {
      final json = {
        'model': 'claude-sonnet-4-20250514',
        'messages': [
          {'role': 'user', 'content': 'Hello, Claude'},
        ],
      };

      final request = TokenCountRequest.fromJson(json);

      expect(request.model, 'claude-sonnet-4-20250514');
      expect(request.messages, hasLength(1));
      expect(request.system, isNull);
      expect(request.toolChoice, isNull);
      expect(request.tools, isNull);
      expect(request.thinking, isNull);
    });

    test('fromJson deserializes system as string', () {
      final json = {
        'model': 'claude-sonnet-4-20250514',
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
        'model': 'claude-sonnet-4-20250514',
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
        model: 'claude-sonnet-4-20250514',
        messages: [InputMessage.user('Hello')],
        system: SystemPrompt.text('Be helpful'),
      );

      final json = request.toJson();

      expect(json['model'], 'claude-sonnet-4-20250514');
      expect(json['messages'], hasLength(1));
      expect(json['system'], 'Be helpful');
    });

    test('toJson excludes null optional fields', () {
      final request = TokenCountRequest(
        model: 'claude-sonnet-4-20250514',
        messages: [InputMessage.user('Hello')],
      );

      final json = request.toJson();

      expect(json.containsKey('system'), isFalse);
      expect(json.containsKey('tool_choice'), isFalse);
      expect(json.containsKey('tools'), isFalse);
      expect(json.containsKey('thinking'), isFalse);
    });

    test('fromJson parses thinking config', () {
      final json = {
        'model': 'claude-sonnet-4-20250514',
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
