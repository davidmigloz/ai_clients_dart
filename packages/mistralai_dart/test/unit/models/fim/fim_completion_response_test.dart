import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FimCompletionResponse', () {
    test('creates with required fields', () {
      const response = FimCompletionResponse(
        id: 'fim-123',
        object: 'chat.completion',
        created: 1699000000,
        model: 'codestral-latest',
        choices: [],
      );

      expect(response.id, 'fim-123');
      expect(response.object, 'chat.completion');
      expect(response.created, 1699000000);
      expect(response.model, 'codestral-latest');
      expect(response.choices, isEmpty);
      expect(response.usage, isNull);
    });

    test('creates with all fields including usage', () {
      const response = FimCompletionResponse(
        id: 'fim-456',
        object: 'chat.completion',
        created: 1699000001,
        model: 'codestral-latest',
        choices: [
          FimChoice(
            index: 0,
            message: 'return n + fibonacci(n-1)',
            finishReason: FinishReason.stop,
          ),
        ],
        usage: UsageInfo(
          promptTokens: 10,
          totalTokens: 25,
          completionTokens: 15,
        ),
      );

      expect(response.id, 'fim-456');
      expect(response.choices.length, 1);
      expect(response.choices.first.message, 'return n + fibonacci(n-1)');
      expect(response.usage, isNotNull);
      expect(response.usage!.promptTokens, 10);
      expect(response.usage!.completionTokens, 15);
    });

    test('fromJson parses correctly', () {
      final json = {
        'id': 'fim-789',
        'object': 'chat.completion',
        'created': 1699000002,
        'model': 'codestral-latest',
        'choices': [
          {'index': 0, 'message': 'completed code', 'finish_reason': 'stop'},
        ],
        'usage': {
          'prompt_tokens': 5,
          'completion_tokens': 20,
          'total_tokens': 25,
        },
      };

      final response = FimCompletionResponse.fromJson(json);

      expect(response.id, 'fim-789');
      expect(response.object, 'chat.completion');
      expect(response.created, 1699000002);
      expect(response.model, 'codestral-latest');
      expect(response.choices.length, 1);
      expect(response.choices.first.index, 0);
      expect(response.choices.first.message, 'completed code');
      expect(response.choices.first.finishReason, FinishReason.stop);
      expect(response.usage!.promptTokens, 5);
      expect(response.usage!.completionTokens, 20);
      expect(response.usage!.totalTokens, 25);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'fim-minimal',
        'object': 'chat.completion',
        'created': 1699000003,
        'model': 'codestral-latest',
        'choices': <Map<String, dynamic>>[],
      };

      final response = FimCompletionResponse.fromJson(json);

      expect(response.usage, isNull);
      expect(response.choices, isEmpty);
    });

    test('fromJson provides defaults for missing required fields', () {
      final json = <String, dynamic>{'choices': <Map<String, dynamic>>[]};

      final response = FimCompletionResponse.fromJson(json);

      expect(response.id, '');
      expect(response.object, 'chat.completion');
      expect(response.created, 0);
      expect(response.model, '');
      expect(response.choices, isEmpty);
    });

    test('toJson serializes correctly', () {
      const response = FimCompletionResponse(
        id: 'fim-test',
        object: 'chat.completion',
        created: 1699000004,
        model: 'codestral-latest',
        choices: [
          FimChoice(
            index: 0,
            message: 'code here',
            finishReason: FinishReason.length,
          ),
        ],
        usage: UsageInfo(
          promptTokens: 8,
          totalTokens: 18,
          completionTokens: 10,
        ),
      );

      final json = response.toJson();

      expect(json['id'], 'fim-test');
      expect(json['object'], 'chat.completion');
      expect(json['created'], 1699000004);
      expect(json['model'], 'codestral-latest');
      expect(json['choices'], isA<List<dynamic>>());
      expect((json['choices'] as List).length, 1);
      expect(json['usage'], isNotNull);
    });

    test('toJson excludes null usage', () {
      const response = FimCompletionResponse(
        id: 'fim-no-usage',
        object: 'chat.completion',
        created: 1699000005,
        model: 'codestral-latest',
        choices: [],
      );

      final json = response.toJson();

      expect(json.containsKey('usage'), isFalse);
    });

    test('equality works correctly', () {
      const response1 = FimCompletionResponse(
        id: 'fim-eq',
        object: 'chat.completion',
        created: 1699000006,
        model: 'codestral-latest',
        choices: [],
      );
      const response2 = FimCompletionResponse(
        id: 'fim-eq',
        object: 'chat.completion',
        created: 1699000006,
        model: 'codestral-latest',
        choices: [],
      );
      const response3 = FimCompletionResponse(
        id: 'fim-different',
        object: 'chat.completion',
        created: 1699000006,
        model: 'codestral-latest',
        choices: [],
      );

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });

    test('toString provides useful representation', () {
      const response = FimCompletionResponse(
        id: 'fim-str',
        object: 'chat.completion',
        created: 1699000007,
        model: 'codestral-latest',
        choices: [],
      );

      expect(response.toString(), contains('FimCompletionResponse'));
      expect(response.toString(), contains('fim-str'));
      expect(response.toString(), contains('codestral-latest'));
    });
  });

  group('FimChoice', () {
    test('creates with required fields', () {
      const choice = FimChoice(index: 0, message: 'generated code');

      expect(choice.index, 0);
      expect(choice.message, 'generated code');
      expect(choice.finishReason, isNull);
    });

    test('creates with all fields', () {
      const choice = FimChoice(
        index: 1,
        message: 'complete code',
        finishReason: FinishReason.stop,
      );

      expect(choice.index, 1);
      expect(choice.message, 'complete code');
      expect(choice.finishReason, FinishReason.stop);
    });

    test('fromJson parses correctly', () {
      final json = {
        'index': 2,
        'message': 'parsed code',
        'finish_reason': 'length',
      };

      final choice = FimChoice.fromJson(json);

      expect(choice.index, 2);
      expect(choice.message, 'parsed code');
      expect(choice.finishReason, FinishReason.length);
    });

    test('fromJson handles missing optional fields', () {
      final json = {'index': 0, 'message': 'minimal'};

      final choice = FimChoice.fromJson(json);

      expect(choice.finishReason, isNull);
    });

    test('toJson serializes correctly', () {
      const choice = FimChoice(
        index: 0,
        message: 'json code',
        finishReason: FinishReason.stop,
      );

      final json = choice.toJson();

      expect(json['index'], 0);
      expect(json['message'], 'json code');
      expect(json['finish_reason'], 'stop');
    });

    test('toJson excludes null finishReason', () {
      const choice = FimChoice(index: 0, message: 'no finish');

      final json = choice.toJson();

      expect(json.containsKey('finish_reason'), isFalse);
    });

    test('equality works correctly', () {
      const choice1 = FimChoice(
        index: 0,
        message: 'same',
        finishReason: FinishReason.stop,
      );
      const choice2 = FimChoice(
        index: 0,
        message: 'same',
        finishReason: FinishReason.stop,
      );
      const choice3 = FimChoice(index: 1, message: 'different');

      expect(choice1, equals(choice2));
      expect(choice1, isNot(equals(choice3)));
      expect(choice1.hashCode, choice2.hashCode);
    });

    test('toString provides useful representation', () {
      const choice = FimChoice(index: 0, message: 'test message');

      expect(choice.toString(), contains('FimChoice'));
      expect(choice.toString(), contains('index: 0'));
    });
  });
}
