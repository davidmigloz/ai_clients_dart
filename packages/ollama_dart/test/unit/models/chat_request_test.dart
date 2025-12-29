import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatRequest', () {
    test('fromJson creates request correctly', () {
      final json = {
        'model': 'llama3.2',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'stream': false,
      };

      final request = ChatRequest.fromJson(json);

      expect(request.model, 'llama3.2');
      expect(request.messages.length, 1);
      expect(request.messages.first.content, 'Hello');
      expect(request.stream, false);
    });

    test('toJson converts request correctly', () {
      const request = ChatRequest(
        model: 'llama3.2',
        messages: [ChatMessage.user('Hi')],
        stream: true,
      );

      final json = request.toJson();

      expect(json['model'], 'llama3.2');
      expect(json['messages'], isA<List<dynamic>>());
      expect(json['stream'], true);
    });

    test('copyWith works correctly', () {
      const original = ChatRequest(
        model: 'llama3.2',
        messages: [ChatMessage.user('Hello')],
      );

      final copied = original.copyWith(model: 'mistral');

      expect(copied.model, 'mistral');
      expect(copied.messages.length, 1);
    });

    test('handles tools', () {
      final tools = [
        const ToolDefinition(
          type: ToolType.function,
          function: ToolFunction(
            name: 'get_weather',
            description: 'Get weather',
            parameters: {
              'type': 'object',
              'properties': {
                'city': {'type': 'string'},
              },
            },
          ),
        ),
      ];

      final request = ChatRequest(
        model: 'llama3.2',
        messages: const [ChatMessage.user('Weather in London?')],
        tools: tools,
      );

      final json = request.toJson();
      expect(json['tools'], isNotNull);
      expect((json['tools'] as List).length, 1);

      final restored = ChatRequest.fromJson(json);
      expect(restored.tools?.length, 1);
      expect(restored.tools?.first.function.name, 'get_weather');
    });

    test('handles format option', () {
      const request = ChatRequest(
        model: 'llama3.2',
        messages: [ChatMessage.user('List items')],
        format: 'json',
      );

      final json = request.toJson();
      expect(json['format'], 'json');

      final restored = ChatRequest.fromJson(json);
      expect(restored.format, 'json');
    });

    test('handles model options', () {
      const request = ChatRequest(
        model: 'llama3.2',
        messages: [ChatMessage.user('Hello')],
        options: ModelOptions(temperature: 0.7, topP: 0.9),
      );

      final json = request.toJson();
      expect(json['options'], isNotNull);
      expect((json['options'] as Map)['temperature'], 0.7);

      final restored = ChatRequest.fromJson(json);
      expect(restored.options?.temperature, 0.7);
    });

    test('equality works correctly', () {
      const request1 = ChatRequest(
        model: 'llama3.2',
        messages: [ChatMessage.user('Hello')],
      );
      const request2 = ChatRequest(
        model: 'llama3.2',
        messages: [ChatMessage.user('Hello')],
      );

      expect(request1, equals(request2));
    });
  });
}
