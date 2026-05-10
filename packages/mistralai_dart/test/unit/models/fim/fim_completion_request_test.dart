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
        stop: StopSequence.multiple([r'\n\n']),
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
      expect(request.stop, const StopSequence.multiple([r'\n\n']));
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
        stop: StopSequence.multiple([r'\n']),
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
      expect(json['stop'], <dynamic>[r'\n']);
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
      expect(request.stop, const StopSequence.multiple([r'\n', ';']));
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

    test('equality covers all generation parameters', () {
      const base = FimCompletionRequest(model: 'codestral-latest', prompt: 'p');

      // Each variant should be distinct from the base.
      const variants = [
        FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'p',
          temperature: 0.5,
        ),
        FimCompletionRequest(model: 'codestral-latest', prompt: 'p', topP: 0.9),
        FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'p',
          maxTokens: 100,
        ),
        FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'p',
          minTokens: 1,
        ),
        FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'p',
          stream: true,
        ),
        FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'p',
          stop: StopSequence.single('END'),
        ),
        FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'p',
          randomSeed: 42,
        ),
      ];

      for (final v in variants) {
        expect(v, isNot(equals(base)), reason: 'variant $v should differ');
      }
    });

    test('toString provides useful representation', () {
      const request = FimCompletionRequest(
        model: 'codestral-latest',
        prompt: 'test',
      );

      expect(request.toString(), contains('FimCompletionRequest'));
      expect(request.toString(), contains('codestral-latest'));
    });

    group('metadata', () {
      test('omitted from JSON when null', () {
        const request = FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'def f():',
        );

        expect(request.toJson().containsKey('metadata'), isFalse);
      });

      test('round-trips metadata', () {
        const original = FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'def f():',
          metadata: {'tenant': 'acme', 'job': 42},
        );

        final roundTripped = FimCompletionRequest.fromJson(original.toJson());

        expect(roundTripped.metadata, {'tenant': 'acme', 'job': 42});
      });

      test('copyWith clears with explicit null', () {
        const original = FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'def f():',
          metadata: {'k': 'v'},
        );

        expect(original.copyWith(metadata: null).metadata, isNull);
      });
    });

    group('promptCacheKey', () {
      test('omits prompt_cache_key from JSON when null', () {
        const request = FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'def f():',
        );

        final json = request.toJson();

        expect(json.containsKey('prompt_cache_key'), isFalse);
      });

      test('serializes prompt_cache_key when set', () {
        const request = FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'def f():',
          promptCacheKey: 'tenant-42',
        );

        final json = request.toJson();

        expect(json['prompt_cache_key'], 'tenant-42');
      });

      test('round-trips prompt_cache_key', () {
        const original = FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'def f():',
          promptCacheKey: 'tenant-42',
        );

        final roundTripped = FimCompletionRequest.fromJson(original.toJson());

        expect(roundTripped.promptCacheKey, 'tenant-42');
      });

      test('copyWith clears with explicit null', () {
        const original = FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'def f():',
          promptCacheKey: 'tenant-42',
        );

        final cleared = original.copyWith(promptCacheKey: null);

        expect(cleared.promptCacheKey, isNull);
      });

      test('equality includes prompt_cache_key', () {
        const a = FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'p',
          promptCacheKey: 'k1',
        );
        const b = FimCompletionRequest(
          model: 'codestral-latest',
          prompt: 'p',
          promptCacheKey: 'k2',
        );

        expect(a, isNot(equals(b)));
      });
    });
  });
}
