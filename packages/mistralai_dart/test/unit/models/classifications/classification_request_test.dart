import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ClassificationRequest', () {
    group('constructors', () {
      test('should create request with single input via factory', () {
        final request = ClassificationRequest.single(input: 'Test content');

        expect(request.input, ['Test content']);
        expect(request.model, 'mistral-moderation-latest');
      });

      test('should create request with list input', () {
        const request = ClassificationRequest(
          input: ['Content 1', 'Content 2', 'Content 3'],
        );

        expect(request.input, ['Content 1', 'Content 2', 'Content 3']);
        expect(request.model, 'mistral-moderation-latest');
      });

      test('should create request with custom model', () {
        final request = ClassificationRequest.single(
          model: 'custom-classification-model',
          input: 'Test content',
        );

        expect(request.model, 'custom-classification-model');
      });
    });

    group('fromJson', () {
      test('should parse request with list input', () {
        final json = <String, dynamic>{
          'model': 'mistral-moderation-latest',
          'input': ['Content 1', 'Content 2'],
        };

        final request = ClassificationRequest.fromJson(json);

        expect(request.model, 'mistral-moderation-latest');
        expect(request.input, ['Content 1', 'Content 2']);
      });

      test('should parse request with string input', () {
        final json = <String, dynamic>{
          'model': 'mistral-moderation-latest',
          'input': 'Single content',
        };

        final request = ClassificationRequest.fromJson(json);

        expect(request.input, ['Single content']);
      });

      test('should use default model if not specified', () {
        final json = <String, dynamic>{
          'input': ['Test'],
        };

        final request = ClassificationRequest.fromJson(json);

        expect(request.model, 'mistral-moderation-latest');
      });

      test('should handle empty input list', () {
        final json = <String, dynamic>{'input': <String>[]};

        final request = ClassificationRequest.fromJson(json);

        expect(request.input, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize request', () {
        final request = ClassificationRequest.single(
          model: 'mistral-moderation-latest',
          input: 'Test content',
        );

        final json = request.toJson();

        expect(json['model'], 'mistral-moderation-latest');
        expect(json['input'], ['Test content']);
      });

      test('should serialize multiple inputs', () {
        const request = ClassificationRequest(
          input: ['Content 1', 'Content 2'],
        );

        final json = request.toJson();

        expect(json['input'], ['Content 1', 'Content 2']);
      });
    });

    group('equality', () {
      test('should be equal when model is the same', () {
        final request1 = ClassificationRequest.single(input: 'Test');
        final request2 = ClassificationRequest.single(input: 'Test');

        expect(request1, equals(request2));
      });

      test('should not be equal when model differs', () {
        final request1 = ClassificationRequest.single(
          model: 'model-1',
          input: 'Test',
        );
        final request2 = ClassificationRequest.single(
          model: 'model-2',
          input: 'Test',
        );

        expect(request1, isNot(equals(request2)));
      });
    });

    group('toString', () {
      test('should return a meaningful string representation', () {
        final request = ClassificationRequest.single(input: 'Test');

        expect(request.toString(), contains('ClassificationRequest'));
        expect(request.toString(), contains('1'));
      });
    });
  });
}
