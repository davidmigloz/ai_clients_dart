import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatCompletionRequest', () {
    test('creates minimal request', () {
      final request = ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [ChatMessage.user('Hello!')],
      );

      expect(request.model, 'mistral-small-latest');
      expect(request.messages, hasLength(1));
      expect(request.temperature, isNull);
      expect(request.maxTokens, isNull);
      expect(request.stream, isNull);
    });

    test('creates request with all parameters', () {
      final request = ChatCompletionRequest(
        model: 'mistral-large-latest',
        messages: [
          ChatMessage.system('You are helpful.'),
          ChatMessage.user('Hi'),
        ],
        temperature: 0.7,
        topP: 0.9,
        maxTokens: 1024,
        stream: false,
        randomSeed: 42,
        safePrompt: true,
        presencePenalty: 0.1,
        frequencyPenalty: 0.2,
        n: 1,
        parallelToolCalls: true,
      );

      expect(request.model, 'mistral-large-latest');
      expect(request.messages, hasLength(2));
      expect(request.temperature, 0.7);
      expect(request.topP, 0.9);
      expect(request.maxTokens, 1024);
      expect(request.stream, false);
      expect(request.randomSeed, 42);
      expect(request.safePrompt, true);
      expect(request.presencePenalty, 0.1);
      expect(request.frequencyPenalty, 0.2);
      expect(request.n, 1);
      expect(request.parallelToolCalls, true);
    });

    test('serializes minimal request to JSON', () {
      final request = ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [ChatMessage.user('Hello!')],
      );
      final json = request.toJson();

      expect(json['model'], 'mistral-small-latest');
      expect(json['messages'], isList);
      final firstMessage =
          (json['messages'] as List).first as Map<String, dynamic>;
      expect(firstMessage['role'], 'user');
      expect(firstMessage['content'], 'Hello!');
      // Optional fields should not be present if null
      expect(json.containsKey('temperature'), isFalse);
      expect(json.containsKey('max_tokens'), isFalse);
    });

    test('serializes request with optional fields to JSON', () {
      final request = ChatCompletionRequest(
        model: 'mistral-large-latest',
        messages: [ChatMessage.user('Test')],
        temperature: 0.5,
        maxTokens: 512,
        stream: true,
        safePrompt: true,
      );
      final json = request.toJson();

      expect(json['model'], 'mistral-large-latest');
      expect(json['temperature'], 0.5);
      expect(json['max_tokens'], 512);
      expect(json['stream'], true);
      expect(json['safe_prompt'], true);
    });

    test('deserializes from JSON', () {
      final json = {
        'model': 'mistral-medium-latest',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'temperature': 0.8,
        'max_tokens': 256,
      };
      final request = ChatCompletionRequest.fromJson(json);

      expect(request.model, 'mistral-medium-latest');
      expect(request.messages, hasLength(1));
      expect(request.temperature, 0.8);
      expect(request.maxTokens, 256);
    });

    group('with tools', () {
      test('creates request with tools', () {
        final request = ChatCompletionRequest(
          model: 'mistral-large-latest',
          messages: [ChatMessage.user('What is the weather in Paris?')],
          tools: [
            Tool.function(
              name: 'get_weather',
              description: 'Get current weather',
              parameters: const {
                'type': 'object',
                'properties': {
                  'location': {'type': 'string'},
                },
                'required': ['location'],
              },
            ),
          ],
          toolChoice: ToolChoice.auto,
        );

        expect(request.tools, hasLength(1));
        expect(request.tools!.first, isA<FunctionTool>());
        expect(
          (request.tools!.first as FunctionTool).function.name,
          'get_weather',
        );
        expect(request.toolChoice, isA<ToolChoiceAuto>());
      });

      test('serializes tools to JSON', () {
        final request = ChatCompletionRequest(
          model: 'mistral-large-latest',
          messages: [ChatMessage.user('Call a function')],
          tools: [
            Tool.function(name: 'test_func', description: 'A test function'),
          ],
          toolChoice: ToolChoice.none,
        );
        final json = request.toJson();

        expect(json['tools'], isList);
        final tool = (json['tools'] as List).first as Map<String, dynamic>;
        expect(tool['type'], 'function');
        expect((tool['function'] as Map)['name'], 'test_func');
        expect(json['tool_choice'], 'none');
      });
    });

    group('with response format', () {
      test('creates request with JSON object format', () {
        final request = ChatCompletionRequest(
          model: 'mistral-large-latest',
          messages: [ChatMessage.user('Return as JSON')],
          responseFormat: ResponseFormat.jsonObject,
        );

        expect(request.responseFormat, isA<ResponseFormatJsonObject>());
      });

      test('serializes response format to JSON', () {
        final request = ChatCompletionRequest(
          model: 'mistral-large-latest',
          messages: [ChatMessage.user('Test')],
          responseFormat: ResponseFormat.text,
        );
        final json = request.toJson();

        expect(json['response_format'], isMap);
        expect((json['response_format'] as Map)['type'], 'text');
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        final original = ChatCompletionRequest(
          model: 'mistral-small-latest',
          messages: [ChatMessage.user('Hello')],
          temperature: 0.5,
        );
        final copied = original.copyWith(temperature: 0.9, maxTokens: 100);

        expect(copied.model, 'mistral-small-latest');
        expect(copied.messages, hasLength(1));
        expect(copied.temperature, 0.9);
        expect(copied.maxTokens, 100);
      });

      test('preserves original when no changes', () {
        final original = ChatCompletionRequest(
          model: 'mistral-large-latest',
          messages: [ChatMessage.user('Test')],
          temperature: 0.7,
        );
        final copied = original.copyWith();

        expect(copied.model, original.model);
        expect(copied.temperature, original.temperature);
      });
    });
  });
}
