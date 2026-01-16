import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateResponseRequest', () {
    test('constructs with required fields', () {
      const request = CreateResponseRequest(model: 'gpt-4o', input: 'Hello');

      expect(request.model, 'gpt-4o');
      expect(request.input, 'Hello');
    });

    test('toJson produces correct JSON for string input', () {
      const request = CreateResponseRequest(model: 'gpt-4o', input: 'Hello');
      final json = request.toJson();

      expect(json['model'], 'gpt-4o');
      expect(json['input'], 'Hello');
    });

    test('toJson produces correct JSON for item list input', () {
      final request = CreateResponseRequest(
        model: 'gpt-4o',
        input: [MessageItem.userText('Hello')],
      );
      final json = request.toJson();

      expect(json['model'], 'gpt-4o');
      expect(json['input'], isList);
      expect(
        ((json['input'] as List).first as Map<String, dynamic>)['type'],
        'message',
      );
    });

    test('toJson includes optional fields when set', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: 'Hello',
        instructions: 'Be helpful',
        maxOutputTokens: 1000,
        temperature: 0.7,
        stream: true,
      );
      final json = request.toJson();

      expect(json['instructions'], 'Be helpful');
      expect(json['max_output_tokens'], 1000);
      expect(json['temperature'], 0.7);
      expect(json['stream'], true);
    });

    test('toJson omits null optional fields', () {
      const request = CreateResponseRequest(model: 'gpt-4o', input: 'Hello');
      final json = request.toJson();

      expect(json.containsKey('instructions'), isFalse);
      expect(json.containsKey('max_output_tokens'), isFalse);
      expect(json.containsKey('temperature'), isFalse);
    });

    test('text factory creates simple text request', () {
      final request = CreateResponseRequest.text(
        model: 'gpt-4o',
        input: 'Hello',
        temperature: 0.5,
      );

      expect(request.model, 'gpt-4o');
      expect(request.input, 'Hello');
      expect(request.temperature, 0.5);
    });

    test('copyWith creates modified copy', () {
      const original = CreateResponseRequest(model: 'gpt-4o', input: 'Hello');
      final modified = original.copyWith(model: 'gpt-5', temperature: 0.8);

      expect(modified.model, 'gpt-5');
      expect(modified.temperature, 0.8);
      expect(modified.input, 'Hello'); // Preserved from original
    });

    test('copyWith preserves original when no changes', () {
      const original = CreateResponseRequest(
        model: 'gpt-4o',
        input: 'Hello',
        temperature: 0.7,
      );
      final copy = original.copyWith();

      expect(copy.model, original.model);
      expect(copy.input, original.input);
      expect(copy.temperature, original.temperature);
    });

    test('includes tools in JSON when specified', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: 'Hello',
        tools: [
          FunctionTool(
            name: 'get_weather',
            description: 'Get the weather',
            parameters: {
              'type': 'object',
              'properties': {
                'location': {'type': 'string'},
              },
            },
          ),
        ],
      );
      final json = request.toJson();

      expect(json['tools'], isList);
      final tools = json['tools'] as List;
      expect((tools.first as Map<String, dynamic>)['name'], 'get_weather');
    });

    test('includes reasoning config when specified', () {
      const request = CreateResponseRequest(
        model: 'o1',
        input: 'Solve this math problem',
        reasoning: ReasoningConfig(
          effort: ReasoningEffort.high,
          summary: ReasoningSummary.detailed,
        ),
      );
      final json = request.toJson();
      final reasoning = json['reasoning'] as Map<String, dynamic>;

      expect(reasoning['effort'], 'high');
      expect(reasoning['summary'], 'detailed');
    });

    test('includes text config with JSON schema when specified', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: 'List 3 fruits',
        text: TextConfig(
          format: JsonSchemaFormat(
            name: 'fruits',
            schema: {
              'type': 'object',
              'properties': {
                'fruits': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
              },
            },
            strict: true,
          ),
        ),
      );
      final json = request.toJson();
      final text = json['text'] as Map<String, dynamic>;
      final format = text['format'] as Map<String, dynamic>;

      expect(format['type'], 'json_schema');
      expect(format['name'], 'fruits');
      expect(format['strict'], true);
    });
  });
}
