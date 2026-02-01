import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EvalOutputItem', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'output-abc123',
        'eval_id': 'eval-xyz',
        'run_id': 'run-123',
        'created_at': 1614807352,
        'object': 'eval.run.output_item',
        'status': 'pass',
        'datasource_item': {'prompt': 'Say hello', 'expected': 'hello'},
        'datasource_item_id': 42,
        'sample': {
          'input': [
            {'role': 'user', 'content': 'Say hello'},
          ],
          'output': [
            {'role': 'assistant', 'content': 'Hello! How can I help you?'},
          ],
          'model': 'gpt-4o-mini',
          'finish_reason': 'stop',
          'usage': {
            'prompt_tokens': 10,
            'completion_tokens': 8,
            'total_tokens': 18,
          },
        },
        'results': [
          {
            'name': 'contains_hello',
            'passed': true,
            'score': 1.0,
            'type': 'string_check',
          },
        ],
      };

      final item = EvalOutputItem.fromJson(json);

      expect(item.id, 'output-abc123');
      expect(item.evalId, 'eval-xyz');
      expect(item.runId, 'run-123');
      expect(item.status, 'pass');
      expect(item.passed, isTrue);
      expect(item.failed, isFalse);
      expect(item.datasourceItem['prompt'], 'Say hello');
      expect(item.datasourceItemId, 42);
      expect(item.sample.model, 'gpt-4o-mini');
      expect(item.sample.outputText, 'Hello! How can I help you?');
      expect(item.results, hasLength(1));
      expect(item.passedCount, 1);
      expect(item.failedCount, 0);
    });
  });

  group('EvalOutputItemList', () {
    test('fromJson parses correctly', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'id': 'item-1',
            'eval_id': 'eval-1',
            'run_id': 'run-1',
            'created_at': 1614807352,
            'object': 'eval.run.output_item',
            'status': 'pass',
            'datasource_item': <String, dynamic>{},
            'datasource_item_id': 1,
            'sample': <String, dynamic>{},
            'results': <dynamic>[],
          },
        ],
        'has_more': true,
        'first_id': 'item-1',
        'last_id': 'item-1',
      };

      final list = EvalOutputItemList.fromJson(json);

      expect(list.object, 'list');
      expect(list.data, hasLength(1));
      expect(list.hasMore, isTrue);
      expect(list.firstId, 'item-1');
    });
  });

  group('EvalOutputItemResult', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'quality_check',
        'passed': true,
        'score': 0.95,
        'sample': 'positive',
        'type': 'label_model',
      };

      final result = EvalOutputItemResult.fromJson(json);

      expect(result.name, 'quality_check');
      expect(result.passed, isTrue);
      expect(result.score, 0.95);
      expect(result.sample, 'positive');
      expect(result.type, 'label_model');
    });

    test('fromJson handles minimal fields', () {
      final json = {'name': 'check', 'passed': false};

      final result = EvalOutputItemResult.fromJson(json);

      expect(result.name, 'check');
      expect(result.passed, isFalse);
      expect(result.score, isNull);
      expect(result.sample, isNull);
      expect(result.type, isNull);
    });

    test('toJson serializes correctly', () {
      const result = EvalOutputItemResult(
        name: 'test',
        passed: true,
        score: 0.8,
        type: 'score_model',
      );

      final json = result.toJson();

      expect(json['name'], 'test');
      expect(json['passed'], true);
      expect(json['score'], 0.8);
      expect(json['type'], 'score_model');
      expect(json.containsKey('sample'), isFalse);
    });
  });

  group('EvalOutputItemSample', () {
    test('fromJson parses correctly', () {
      final json = {
        'input': [
          {'role': 'system', 'content': 'Be helpful'},
          {'role': 'user', 'content': 'Hello'},
        ],
        'output': [
          {'role': 'assistant', 'content': 'Hi there!'},
        ],
        'model': 'gpt-4o',
        'finish_reason': 'stop',
        'usage': {
          'prompt_tokens': 20,
          'completion_tokens': 5,
          'total_tokens': 25,
        },
        'max_completion_tokens': 100,
        'temperature': 0.7,
        'top_p': 0.9,
        'seed': 42,
      };

      final sample = EvalOutputItemSample.fromJson(json);

      expect(sample.input, hasLength(2));
      expect(sample.output, hasLength(1));
      expect(sample.model, 'gpt-4o');
      expect(sample.finishReason, 'stop');
      expect(sample.usage?.totalTokens, 25);
      expect(sample.temperature, 0.7);
      expect(sample.outputText, 'Hi there!');
    });

    test('outputText concatenates multiple messages', () {
      const sample = EvalOutputItemSample(
        output: [
          EvalSampleMessage(role: 'assistant', content: 'Hello '),
          EvalSampleMessage(role: 'assistant', content: 'World!'),
        ],
      );

      expect(sample.outputText, 'Hello World!');
    });

    test('outputText returns empty string when no output', () {
      const sample = EvalOutputItemSample();

      expect(sample.outputText, '');
    });

    test('handles error response', () {
      final json = {'error': 'Rate limit exceeded', 'model': 'gpt-4o'};

      final sample = EvalOutputItemSample.fromJson(json);

      expect(sample.error, 'Rate limit exceeded');
      expect(sample.output, isNull);
    });
  });

  group('EvalSampleMessage', () {
    test('fromJson parses correctly', () {
      final json = {'role': 'assistant', 'content': 'Hello!'};

      final message = EvalSampleMessage.fromJson(json);

      expect(message.role, 'assistant');
      expect(message.content, 'Hello!');
    });

    test('toJson serializes correctly', () {
      const message = EvalSampleMessage(role: 'user', content: 'Test');

      final json = message.toJson();

      expect(json['role'], 'user');
      expect(json['content'], 'Test');
    });
  });

  group('EvalSampleUsage', () {
    test('fromJson parses correctly', () {
      final json = {
        'prompt_tokens': 50,
        'completion_tokens': 30,
        'total_tokens': 80,
        'cached_tokens': 10,
      };

      final usage = EvalSampleUsage.fromJson(json);

      expect(usage.promptTokens, 50);
      expect(usage.completionTokens, 30);
      expect(usage.totalTokens, 80);
      expect(usage.cachedTokens, 10);
    });

    test('toJson serializes correctly', () {
      const usage = EvalSampleUsage(
        promptTokens: 100,
        completionTokens: 50,
        totalTokens: 150,
      );

      final json = usage.toJson();

      expect(json['prompt_tokens'], 100);
      expect(json['completion_tokens'], 50);
      expect(json['total_tokens'], 150);
      expect(json.containsKey('cached_tokens'), isFalse);
    });
  });

  group('EvalOutputItemStatus', () {
    test('fromJson parses correctly', () {
      expect(EvalOutputItemStatus.fromJson('pass'), EvalOutputItemStatus.pass);
      expect(EvalOutputItemStatus.fromJson('fail'), EvalOutputItemStatus.fail);
    });

    test('toJson returns correct string', () {
      expect(EvalOutputItemStatus.pass.toJson(), 'pass');
      expect(EvalOutputItemStatus.fail.toJson(), 'fail');
    });

    test('fromJson throws on unknown value', () {
      expect(
        () => EvalOutputItemStatus.fromJson('unknown'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
