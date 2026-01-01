import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatClassificationRequest', () {
    group('constructors', () {
      test('should create request with required fields', () {
        final request = ChatClassificationRequest(
          input: [
            ChatMessage.user('Hello'),
            ChatMessage.assistant('Hi there!'),
          ],
        );

        expect(request.input, hasLength(2));
        expect(request.model, 'mistral-moderation-latest');
      });

      test('should create request with custom model', () {
        final request = ChatClassificationRequest(
          model: 'custom-classification-model',
          input: [ChatMessage.user('Test')],
        );

        expect(request.model, 'custom-classification-model');
      });
    });

    group('fromJson', () {
      test('should parse request with messages', () {
        final json = <String, dynamic>{
          'model': 'mistral-moderation-latest',
          'input': [
            {'role': 'user', 'content': 'Hello'},
            {'role': 'assistant', 'content': 'Hi there!'},
          ],
        };

        final request = ChatClassificationRequest.fromJson(json);

        expect(request.model, 'mistral-moderation-latest');
        expect(request.input, hasLength(2));
      });

      test('should use default model if not specified', () {
        final json = <String, dynamic>{
          'input': [
            {'role': 'user', 'content': 'Test'},
          ],
        };

        final request = ChatClassificationRequest.fromJson(json);

        expect(request.model, 'mistral-moderation-latest');
      });

      test('should handle empty input list', () {
        final json = <String, dynamic>{'input': <Map<String, dynamic>>[]};

        final request = ChatClassificationRequest.fromJson(json);

        expect(request.input, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize request', () {
        final request = ChatClassificationRequest(
          model: 'mistral-moderation-latest',
          input: [ChatMessage.user('Hello'), ChatMessage.assistant('Hi!')],
        );

        final json = request.toJson();

        expect(json['model'], 'mistral-moderation-latest');
        expect(json['input'], hasLength(2));
      });
    });

    group('equality', () {
      test('should be equal when model is the same', () {
        final request1 = ChatClassificationRequest(
          input: [ChatMessage.user('Test')],
        );
        final request2 = ChatClassificationRequest(
          input: [ChatMessage.user('Test')],
        );

        expect(request1, equals(request2));
      });

      test('should not be equal when model differs', () {
        final request1 = ChatClassificationRequest(
          model: 'model-1',
          input: [ChatMessage.user('Test')],
        );
        final request2 = ChatClassificationRequest(
          model: 'model-2',
          input: [ChatMessage.user('Test')],
        );

        expect(request1, isNot(equals(request2)));
      });
    });

    group('toString', () {
      test('should return a meaningful string representation', () {
        final request = ChatClassificationRequest(
          input: [ChatMessage.user('Test')],
        );

        expect(request.toString(), contains('ChatClassificationRequest'));
        expect(request.toString(), contains('1'));
      });
    });
  });
}
