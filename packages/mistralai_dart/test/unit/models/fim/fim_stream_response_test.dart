import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FimCompletionStreamResponse', () {
    test('creates with required fields', () {
      const response = FimCompletionStreamResponse(
        id: 'fim-stream-123',
        object: 'chat.completion.chunk',
        created: 1699000000,
        model: 'codestral-latest',
        choices: [],
      );

      expect(response.id, 'fim-stream-123');
      expect(response.object, 'chat.completion.chunk');
      expect(response.created, 1699000000);
      expect(response.model, 'codestral-latest');
      expect(response.choices, isEmpty);
      expect(response.usage, isNull);
    });

    test('creates with all fields', () {
      const response = FimCompletionStreamResponse(
        id: 'fim-stream-456',
        object: 'chat.completion.chunk',
        created: 1699000001,
        model: 'codestral-latest',
        choices: [FimChoiceDelta(index: 0, delta: 'return ')],
        usage: UsageInfo(
          promptTokens: 10,
          totalTokens: 11,
          completionTokens: 1,
        ),
      );

      expect(response.choices.length, 1);
      expect(response.choices.first.delta, 'return ');
      expect(response.usage, isNotNull);
    });

    test('fromJson parses correctly', () {
      final json = {
        'id': 'fim-stream-789',
        'object': 'chat.completion.chunk',
        'created': 1699000002,
        'model': 'codestral-latest',
        'choices': [
          {'index': 0, 'delta': 'fib', 'finish_reason': null},
        ],
      };

      final response = FimCompletionStreamResponse.fromJson(json);

      expect(response.id, 'fim-stream-789');
      expect(response.choices.first.delta, 'fib');
      expect(response.choices.first.finishReason, isNull);
    });

    test('fromJson handles final chunk with finish_reason', () {
      final json = {
        'id': 'fim-stream-final',
        'object': 'chat.completion.chunk',
        'created': 1699000003,
        'model': 'codestral-latest',
        'choices': [
          {'index': 0, 'delta': null, 'finish_reason': 'stop'},
        ],
        'usage': {
          'prompt_tokens': 15,
          'completion_tokens': 50,
          'total_tokens': 65,
        },
      };

      final response = FimCompletionStreamResponse.fromJson(json);

      expect(response.choices.first.delta, isNull);
      expect(response.choices.first.finishReason, FinishReason.stop);
      expect(response.usage!.totalTokens, 65);
    });

    test('fromJson handles missing fields gracefully', () {
      final json = <String, dynamic>{};

      final response = FimCompletionStreamResponse.fromJson(json);

      expect(response.id, '');
      expect(response.object, 'chat.completion.chunk');
      expect(response.created, 0);
      expect(response.model, '');
      expect(response.choices, isEmpty);
    });

    test('toJson serializes correctly', () {
      const response = FimCompletionStreamResponse(
        id: 'fim-json',
        object: 'chat.completion.chunk',
        created: 1699000004,
        model: 'codestral-latest',
        choices: [FimChoiceDelta(index: 0, delta: 'chunk')],
      );

      final json = response.toJson();

      expect(json['id'], 'fim-json');
      expect(json['object'], 'chat.completion.chunk');
      expect(json['choices'], isA<List<dynamic>>());
      expect(json.containsKey('usage'), isFalse);
    });

    test('equality works correctly', () {
      const response1 = FimCompletionStreamResponse(
        id: 'fim-eq',
        object: 'chat.completion.chunk',
        created: 1699000005,
        model: 'codestral-latest',
        choices: [],
      );
      const response2 = FimCompletionStreamResponse(
        id: 'fim-eq',
        object: 'chat.completion.chunk',
        created: 1699000005,
        model: 'codestral-latest',
        choices: [],
      );
      const response3 = FimCompletionStreamResponse(
        id: 'fim-different',
        object: 'chat.completion.chunk',
        created: 1699000005,
        model: 'codestral-latest',
        choices: [],
      );

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });

    test('toString provides useful representation', () {
      const response = FimCompletionStreamResponse(
        id: 'fim-str',
        object: 'chat.completion.chunk',
        created: 1699000006,
        model: 'codestral-latest',
        choices: [],
      );

      expect(response.toString(), contains('FimCompletionStreamResponse'));
      expect(response.toString(), contains('fim-str'));
    });
  });

  group('FimChoiceDelta', () {
    test('creates with required fields', () {
      const delta = FimChoiceDelta(index: 0);

      expect(delta.index, 0);
      expect(delta.delta, isNull);
      expect(delta.finishReason, isNull);
    });

    test('creates with all fields', () {
      const delta = FimChoiceDelta(
        index: 0,
        delta: 'code chunk',
        finishReason: FinishReason.stop,
      );

      expect(delta.index, 0);
      expect(delta.delta, 'code chunk');
      expect(delta.finishReason, FinishReason.stop);
    });

    test('fromJson parses correctly', () {
      final json = {
        'index': 1,
        'delta': 'parsed chunk',
        'finish_reason': 'length',
      };

      final delta = FimChoiceDelta.fromJson(json);

      expect(delta.index, 1);
      expect(delta.delta, 'parsed chunk');
      expect(delta.finishReason, FinishReason.length);
    });

    test('fromJson handles null delta', () {
      final json = {'index': 0, 'delta': null, 'finish_reason': 'stop'};

      final delta = FimChoiceDelta.fromJson(json);

      expect(delta.delta, isNull);
      expect(delta.finishReason, FinishReason.stop);
    });

    test('toJson serializes correctly', () {
      const delta = FimChoiceDelta(
        index: 2,
        delta: 'json chunk',
        finishReason: FinishReason.stop,
      );

      final json = delta.toJson();

      expect(json['index'], 2);
      expect(json['delta'], 'json chunk');
      expect(json['finish_reason'], 'stop');
    });

    test('toJson excludes null fields', () {
      const delta = FimChoiceDelta(index: 0);

      final json = delta.toJson();

      expect(json.containsKey('delta'), isFalse);
      expect(json.containsKey('finish_reason'), isFalse);
    });

    test('equality works correctly', () {
      const delta1 = FimChoiceDelta(index: 0, delta: 'same');
      const delta2 = FimChoiceDelta(index: 0, delta: 'same');
      const delta3 = FimChoiceDelta(index: 1, delta: 'different');

      expect(delta1, equals(delta2));
      expect(delta1, isNot(equals(delta3)));
      expect(delta1.hashCode, delta2.hashCode);
    });

    test('toString provides useful representation', () {
      const delta = FimChoiceDelta(index: 0, delta: 'test');

      expect(delta.toString(), contains('FimChoiceDelta'));
      expect(delta.toString(), contains('index: 0'));
    });
  });
}
