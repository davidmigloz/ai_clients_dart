import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FimCompletionRequest', () {
    test('creates with required fields', () {
      const request = FimCompletionRequest(
        model: 'codestral-latest',
        prompt: 'def fibonacci(n):',
      );

      expect(request.model, 'codestral-latest');
      expect(request.prompt, 'def fibonacci(n):');
      expect(request.suffix, isNull);
      expect(request.temperature, isNull);
      expect(request.maxTokens, isNull);
      expect(request.topP, isNull);
      expect(request.minTokens, isNull);
      expect(request.stop, isNull);
      expect(request.randomSeed, isNull);
      expect(request.stream, isNull);
    });

    test('creates with all fields', () {
      const request = FimCompletionRequest(
        model: 'codestral-latest',
        prompt: 'def fibonacci(n):',
        suffix: '\n\nprint(fibonacci(10))',
        temperature: 0.7,
        maxTokens: 1000,
        topP: 0.9,
        minTokens: 10,
        stop: [r'\n\n'],
        randomSeed: 42,
        stream: true,
      );

      expect(request.model, 'codestral-latest');
      expect(request.prompt, 'def fibonacci(n):');
      expect(request.suffix, '\n\nprint(fibonacci(10))');
      expect(request.temperature, 0.7);
      expect(request.maxTokens, 1000);
      expect(request.topP, 0.9);
      expect(request.minTokens, 10);
      expect(request.stop, [r'\n\n']);
      expect(request.randomSeed, 42);
      expect(request.stream, true);
    });

    test('toJson includes required fields', () {
      const request = FimCompletionRequest(
        model: 'codestral-latest',
        prompt: 'def fibonacci(n):',
      );

      final json = request.toJson();

      expect(json['model'], 'codestral-latest');
      expect(json['prompt'], 'def fibonacci(n):');
      expect(json.containsKey('suffix'), isFalse);
      expect(json.containsKey('temperature'), isFalse);
      expect(json.containsKey('max_tokens'), isFalse);
    });

    test('toJson includes all fields when set', () {
      const request = FimCompletionRequest(
        model: 'codestral-latest',
        prompt: 'function hello() {',
        suffix: '}',
        temperature: 0.5,
        maxTokens: 500,
        topP: 0.95,
        minTokens: 5,
        stop: [r'\n'],
        randomSeed: 123,
        stream: false,
      );

      final json = request.toJson();

      expect(json['model'], 'codestral-latest');
      expect(json['prompt'], 'function hello() {');
      expect(json['suffix'], '}');
      expect(json['temperature'], 0.5);
      expect(json['max_tokens'], 500);
      expect(json['top_p'], 0.95);
      expect(json['min_tokens'], 5);
      expect(json['stop'], [r'\n']);
      expect(json['random_seed'], 123);
      expect(json['stream'], false);
    });

    test('fromJson parses required fields', () {
      final json = {'model': 'codestral-latest', 'prompt': 'const x = '};

      final request = FimCompletionRequest.fromJson(json);

      expect(request.model, 'codestral-latest');
      expect(request.prompt, 'const x = ');
      expect(request.suffix, isNull);
    });

    test('fromJson parses all fields', () {
      final json = {
        'model': 'codestral-latest',
        'prompt': 'const x = ',
        'suffix': ';',
        'temperature': 0.8,
        'max_tokens': 200,
        'top_p': 0.85,
        'min_tokens': 1,
        'stop': [r'\n', ';'],
        'random_seed': 999,
        'stream': true,
      };

      final request = FimCompletionRequest.fromJson(json);

      expect(request.model, 'codestral-latest');
      expect(request.prompt, 'const x = ');
      expect(request.suffix, ';');
      expect(request.temperature, 0.8);
      expect(request.maxTokens, 200);
      expect(request.topP, 0.85);
      expect(request.minTokens, 1);
      expect(request.stop, [r'\n', ';']);
      expect(request.randomSeed, 999);
      expect(request.stream, true);
    });

    test('copyWith creates new instance with updated fields', () {
      const original = FimCompletionRequest(
        model: 'codestral-latest',
        prompt: 'original prompt',
      );

      final modified = original.copyWith(
        suffix: 'new suffix',
        temperature: 0.5,
        stream: true,
      );

      expect(modified.model, 'codestral-latest');
      expect(modified.prompt, 'original prompt');
      expect(modified.suffix, 'new suffix');
      expect(modified.temperature, 0.5);
      expect(modified.stream, true);

      // Original unchanged
      expect(original.suffix, isNull);
      expect(original.temperature, isNull);
    });

    test('equality works correctly', () {
      const request1 = FimCompletionRequest(
        model: 'codestral-latest',
        prompt: 'test prompt',
        suffix: 'test suffix',
      );
      const request2 = FimCompletionRequest(
        model: 'codestral-latest',
        prompt: 'test prompt',
        suffix: 'test suffix',
      );
      const request3 = FimCompletionRequest(
        model: 'codestral-latest',
        prompt: 'different prompt',
      );

      expect(request1, equals(request2));
      expect(request1, isNot(equals(request3)));
      expect(request1.hashCode, request2.hashCode);
    });

    test('toString provides useful representation', () {
      const request = FimCompletionRequest(
        model: 'codestral-latest',
        prompt: 'test',
      );

      expect(request.toString(), contains('FimCompletionRequest'));
      expect(request.toString(), contains('codestral-latest'));
    });
  });
}
