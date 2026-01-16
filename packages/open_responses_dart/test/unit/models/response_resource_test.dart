import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

import '../../fixtures/responses.dart';

void main() {
  group('ResponseResource', () {
    test('fromJson parses basic response', () {
      final json = basicCompletedResponse();
      final response = ResponseResource.fromJson(json);

      expect(response.id, 'resp_123');
      expect(response.model, 'gpt-4o');
      expect(response.status, ResponseStatus.completed);
      expect(response.output, isNotEmpty);
      expect(response.usage, isNotNull);
      expect(response.usage!.inputTokens, 10);
      expect(response.usage!.outputTokens, 5);
    });

    test('toJson produces correct JSON', () {
      final json = basicCompletedResponse();
      final response = ResponseResource.fromJson(json);
      final roundTripped = ResponseResource.fromJson(response.toJson());

      expect(roundTripped.id, response.id);
      expect(roundTripped.model, response.model);
      expect(roundTripped.status, response.status);
    });

    test('outputText extension returns concatenated text', () {
      final json = basicCompletedResponse(outputText: 'Hello, world!');
      final response = ResponseResource.fromJson(json);

      expect(response.outputText, 'Hello, world!');
    });

    test('outputText returns null when no text content', () {
      final json = functionCallResponse();
      final response = ResponseResource.fromJson(json);

      expect(response.outputText, isNull);
    });

    test('functionCalls extension returns function calls', () {
      final json = functionCallResponse(
        functionName: 'get_weather',
        arguments: '{"location": "NYC"}',
      );
      final response = ResponseResource.fromJson(json);

      expect(response.functionCalls, hasLength(1));
      expect(response.functionCalls.first.name, 'get_weather');
      expect(response.functionCalls.first.arguments, '{"location": "NYC"}');
    });

    test('hasToolCalls returns true when function calls present', () {
      final json = functionCallResponse();
      final response = ResponseResource.fromJson(json);

      expect(response.hasToolCalls, isTrue);
    });

    test('hasToolCalls returns false when no function calls', () {
      final json = basicCompletedResponse();
      final response = ResponseResource.fromJson(json);

      expect(response.hasToolCalls, isFalse);
    });

    test('isCompleted returns true for completed status', () {
      final json = basicCompletedResponse();
      final response = ResponseResource.fromJson(json);

      expect(response.isCompleted, isTrue);
      expect(response.isFailed, isFalse);
    });

    test('isFailed returns true for failed status', () {
      final json = failedResponse();
      final response = ResponseResource.fromJson(json);

      expect(response.isFailed, isTrue);
      expect(response.isCompleted, isFalse);
    });

    test('copyWith creates modified copy', () {
      final json = basicCompletedResponse();
      final original = ResponseResource.fromJson(json);
      final modified = original.copyWith(model: 'gpt-5');

      expect(modified.model, 'gpt-5');
      expect(modified.id, original.id);
      expect(original.model, 'gpt-4o'); // Original unchanged
    });
  });
}
