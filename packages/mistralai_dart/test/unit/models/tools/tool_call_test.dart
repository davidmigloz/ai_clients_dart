import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolCall', () {
    test('creates with required fields', () {
      const toolCall = ToolCall(
        id: 'call_123',
        function: FunctionCall(
          name: 'get_weather',
          arguments: '{"location": "Paris"}',
        ),
      );

      expect(toolCall.id, 'call_123');
      expect(toolCall.type, 'function');
      expect(toolCall.function.name, 'get_weather');
      expect(toolCall.function.arguments, '{"location": "Paris"}');
    });

    test('deserializes with all fields present', () {
      final json = {
        'id': 'call_123',
        'type': 'function',
        'function': {
          'name': 'get_weather',
          'arguments': '{"location": "Paris"}',
        },
      };
      final toolCall = ToolCall.fromJson(json);

      expect(toolCall.id, 'call_123');
      expect(toolCall.type, 'function');
      expect(toolCall.function.name, 'get_weather');
      expect(toolCall.function.arguments, '{"location": "Paris"}');
    });

    test('deserializes with missing id defaults to empty string', () {
      final json = {
        'type': 'function',
        'function': {'name': 'test', 'arguments': '{}'},
      };
      final toolCall = ToolCall.fromJson(json);

      expect(toolCall.id, '');
    });

    test('deserializes with missing type defaults to function', () {
      final json = {
        'id': 'call_123',
        'function': {'name': 'test', 'arguments': '{}'},
      };
      final toolCall = ToolCall.fromJson(json);

      expect(toolCall.type, 'function');
    });

    test('deserializes with missing function defaults to empty function', () {
      final json = {'id': 'call_123', 'type': 'function'};
      final toolCall = ToolCall.fromJson(json);

      expect(toolCall.function.name, '');
      expect(toolCall.function.arguments, '{}');
    });

    test('deserializes with empty JSON', () {
      final json = <String, dynamic>{};
      final toolCall = ToolCall.fromJson(json);

      expect(toolCall.id, '');
      expect(toolCall.type, 'function');
      expect(toolCall.function.name, '');
    });

    test('serializes to JSON', () {
      const toolCall = ToolCall(
        id: 'call_123',
        type: 'function',
        function: FunctionCall(
          name: 'get_weather',
          arguments: '{"location": "Paris"}',
        ),
      );
      final json = toolCall.toJson();

      expect(json['id'], 'call_123');
      expect(json['type'], 'function');
      final functionJson = json['function'] as Map<String, dynamic>;
      expect(functionJson['name'], 'get_weather');
      expect(functionJson['arguments'], '{"location": "Paris"}');
    });

    test('equality works correctly', () {
      const toolCall1 = ToolCall(
        id: 'call_123',
        function: FunctionCall(name: 'test', arguments: '{}'),
      );
      const toolCall2 = ToolCall(
        id: 'call_123',
        function: FunctionCall(name: 'test', arguments: '{}'),
      );
      const toolCall3 = ToolCall(
        id: 'call_456',
        function: FunctionCall(name: 'test', arguments: '{}'),
      );

      expect(toolCall1, equals(toolCall2));
      expect(toolCall1.hashCode, equals(toolCall2.hashCode));
      expect(toolCall1, isNot(equals(toolCall3)));
    });

    test('toString includes all fields', () {
      const toolCall = ToolCall(
        id: 'call_123',
        function: FunctionCall(name: 'get_weather', arguments: '{}'),
      );

      expect(toolCall.toString(), contains('call_123'));
      expect(toolCall.toString(), contains('function'));
      expect(toolCall.toString(), contains('get_weather'));
    });
  });
}
