import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FunctionCall', () {
    test('creates with required fields', () {
      const functionCall = FunctionCall(
        name: 'get_weather',
        arguments: '{"location": "Paris"}',
      );

      expect(functionCall.name, 'get_weather');
      expect(functionCall.arguments, '{"location": "Paris"}');
    });

    test('deserializes with all fields', () {
      final json = {
        'name': 'get_weather',
        'arguments': '{"location": "Paris"}',
      };
      final functionCall = FunctionCall.fromJson(json);

      expect(functionCall.name, 'get_weather');
      expect(functionCall.arguments, '{"location": "Paris"}');
    });

    test('deserializes with missing name defaults to empty string', () {
      final json = {'arguments': '{"test": true}'};
      final functionCall = FunctionCall.fromJson(json);

      expect(functionCall.name, '');
      expect(functionCall.arguments, '{"test": true}');
    });

    test('deserializes with missing arguments defaults to empty object', () {
      final json = {'name': 'get_weather'};
      final functionCall = FunctionCall.fromJson(json);

      expect(functionCall.name, 'get_weather');
      expect(functionCall.arguments, '{}');
    });

    test('deserializes with empty JSON', () {
      final json = <String, dynamic>{};
      final functionCall = FunctionCall.fromJson(json);

      expect(functionCall.name, '');
      expect(functionCall.arguments, '{}');
    });

    test('serializes to JSON', () {
      const functionCall = FunctionCall(
        name: 'get_weather',
        arguments: '{"location": "Paris"}',
      );
      final json = functionCall.toJson();

      expect(json['name'], 'get_weather');
      expect(json['arguments'], '{"location": "Paris"}');
    });

    test('equality works correctly', () {
      const fc1 = FunctionCall(name: 'test', arguments: '{}');
      const fc2 = FunctionCall(name: 'test', arguments: '{}');
      const fc3 = FunctionCall(name: 'other', arguments: '{}');

      expect(fc1, equals(fc2));
      expect(fc1.hashCode, equals(fc2.hashCode));
      expect(fc1, isNot(equals(fc3)));
    });

    test('toString includes all fields', () {
      const functionCall = FunctionCall(
        name: 'get_weather',
        arguments: '{"location": "Paris"}',
      );

      expect(functionCall.toString(), contains('get_weather'));
      expect(functionCall.toString(), contains('location'));
    });

    test('handles complex arguments JSON string', () {
      final json = {
        'name': 'complex_function',
        'arguments':
            '{"array": [1, 2, 3], "nested": {"a": "b"}, "unicode": "日本語"}',
      };
      final functionCall = FunctionCall.fromJson(json);

      expect(functionCall.arguments, contains('array'));
      expect(functionCall.arguments, contains('nested'));
      expect(functionCall.arguments, contains('日本語'));
    });
  });
}
