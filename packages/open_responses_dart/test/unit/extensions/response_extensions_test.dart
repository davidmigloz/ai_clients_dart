import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

import '../../fixtures/responses.dart';

void main() {
  group('ResponseResourceExtensions', () {
    group('outputText', () {
      test('returns concatenated text from single MessageOutputItem', () {
        final json = basicCompletedResponse(outputText: 'Hello world!');
        final response = ResponseResource.fromJson(json);

        expect(response.outputText, equals('Hello world!'));
      });

      test('returns concatenated text from multiple text parts', () {
        final json = multiTextResponse(texts: ['Hello', ' ', 'world', '!']);
        final response = ResponseResource.fromJson(json);

        expect(response.outputText, equals('Hello world!'));
      });

      test('returns null for empty output', () {
        final response = ResponseResource.fromJson(const {
          'id': 'resp_123',
          'object': 'response',
          'created_at': 1700000000,
          'model': 'gpt-4o',
          'status': 'completed',
          'output': <Map<String, dynamic>>[],
        });

        expect(response.outputText, isNull);
      });

      test('returns null for response with no text content', () {
        final json = functionCallResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.outputText, isNull);
      });

      test('handles mixed content types (text and function calls)', () {
        final json = mixedOutputResponse(
          text: 'Here is the result:',
          functionName: 'get_data',
        );
        final response = ResponseResource.fromJson(json);

        expect(response.outputText, equals('Here is the result:'));
      });
    });

    group('functionCalls', () {
      test('returns list of FunctionCallOutputItemResponse', () {
        final json = functionCallResponse(
          functionName: 'get_weather',
          arguments: '{"location": "NYC"}',
        );
        final response = ResponseResource.fromJson(json);

        expect(response.functionCalls, hasLength(1));
        expect(response.functionCalls.first.name, equals('get_weather'));
        expect(
          response.functionCalls.first.arguments,
          equals('{"location": "NYC"}'),
        );
      });

      test('returns empty list when no tool calls', () {
        final json = basicCompletedResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.functionCalls, isEmpty);
      });

      test('returns multiple function calls', () {
        final json = multipleFunctionCallsResponse(
          functions: [
            ('get_weather', '{"location": "NYC"}'),
            ('get_time', '{"timezone": "EST"}'),
          ],
        );
        final response = ResponseResource.fromJson(json);

        expect(response.functionCalls, hasLength(2));
        expect(response.functionCalls[0].name, equals('get_weather'));
        expect(response.functionCalls[1].name, equals('get_time'));
      });
    });

    group('reasoningItems', () {
      test('returns list of ReasoningItem', () {
        final json = reasoningResponse(summaryText: 'Step by step analysis');
        final response = ResponseResource.fromJson(json);

        expect(response.reasoningItems, hasLength(1));
        expect(
          response.reasoningItems.first.summary.first.text,
          equals('Step by step analysis'),
        );
      });

      test('returns empty list when no reasoning', () {
        final json = basicCompletedResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.reasoningItems, isEmpty);
      });
    });

    group('hasToolCalls', () {
      test('returns true when functionCalls not empty', () {
        final json = functionCallResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.hasToolCalls, isTrue);
      });

      test('returns false when empty', () {
        final json = basicCompletedResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.hasToolCalls, isFalse);
      });
    });

    group('isCompleted', () {
      test('returns true when status is completed', () {
        final json = basicCompletedResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.isCompleted, isTrue);
      });

      test('returns false when status is not completed', () {
        final json = inProgressResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.isCompleted, isFalse);
      });
    });

    group('isFailed', () {
      test('returns true when status is failed', () {
        final json = failedResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.isFailed, isTrue);
      });

      test('returns false when status is not failed', () {
        final json = basicCompletedResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.isFailed, isFalse);
      });
    });

    group('isInProgress', () {
      test('returns true when status is inProgress', () {
        final json = inProgressResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.isInProgress, isTrue);
      });

      test('returns false when status is not inProgress', () {
        final json = basicCompletedResponse();
        final response = ResponseResource.fromJson(json);

        expect(response.isInProgress, isFalse);
      });
    });
  });
}
