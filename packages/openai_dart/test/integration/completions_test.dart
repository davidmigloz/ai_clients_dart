// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  // The only supported model for completions API
  const model = 'gpt-3.5-turbo-instruct';

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Completions (Legacy) - Integration', () {
    test(
      'creates a basic completion',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.completions.create(
          const CompletionRequest(
            model: model,
            prompt: CompletionPrompt.text('Say this is a test'),
            maxTokens: 10,
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.object, equals('text_completion'));
        expect(response.model, contains('gpt-3.5-turbo-instruct'));
        expect(response.choices, isNotEmpty);
        expect(response.choices.first.text, isNotEmpty);
        expect(response.choices.first.index, equals(0));
        expect(response.usage!.promptTokens, greaterThan(0));
        expect(response.usage!.completionTokens, greaterThan(0));
        expect(response.usage!.totalTokens, greaterThan(0));
      },
    );

    test(
      'respects maxTokens limit',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.completions.create(
          const CompletionRequest(
            model: model,
            prompt: CompletionPrompt.text(
              'Write a very long story about a dragon.',
            ),
            maxTokens: 5,
          ),
        );

        expect(response.choices.first.finishReason, FinishReason.length);
        expect(response.usage!.completionTokens, lessThanOrEqualTo(10));
      },
    );

    test(
      'handles single stop sequence',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.completions.create(
          const CompletionRequest(
            model: model,
            // Prompt ends at 4, model should continue with 5 and hit stop
            prompt: CompletionPrompt.text('Count: 1, 2, 3, 4,'),
            maxTokens: 100,
            stop: StopSequence.single('5'),
          ),
        );

        // Model should stop when it generates "5"
        expect(response.choices.first.text, isNotEmpty);
        expect(response.choices.first.finishReason, FinishReason.stop);
      },
    );

    test(
      'handles multiple stop sequences',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.completions.create(
          const CompletionRequest(
            model: model,
            prompt: CompletionPrompt.text('Say hello and goodbye'),
            maxTokens: 50,
            stop: StopSequence.multiple(['goodbye', 'bye', 'end']),
          ),
        );

        expect(response.choices.first.text, isNotEmpty);
        // Should have stopped at one of the stop sequences or naturally
        expect(
          response.choices.first.finishReason,
          anyOf(FinishReason.stop, FinishReason.length),
        );
      },
    );

    test(
      'generates multiple choices',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.completions.create(
          const CompletionRequest(
            model: model,
            prompt: CompletionPrompt.text('The color of the sky is'),
            maxTokens: 10,
            n: 3,
          ),
        );

        expect(response.choices, hasLength(3));
        for (var i = 0; i < response.choices.length; i++) {
          final choice = response.choices[i];
          expect(choice.index, equals(i));
          expect(choice.text, isNotEmpty);
        }
      },
    );

    test(
      'streams completion',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.completions.createStream(
          const CompletionRequest(
            model: model,
            prompt: CompletionPrompt.text('Count from 1 to 5:'),
            maxTokens: 30,
          ),
        );

        final chunks = await stream.toList();

        expect(chunks, isNotEmpty);

        // Collect all text from the stream
        final buffer = StringBuffer();
        for (final chunk in chunks) {
          buffer.write(chunk.text);
        }

        expect(buffer.toString(), isNotEmpty);
      },
    );

    test(
      'validates usage tracking',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.completions.create(
          const CompletionRequest(
            model: model,
            prompt: CompletionPrompt.text('Hello'),
            maxTokens: 10,
          ),
        );

        expect(response.usage!.promptTokens, greaterThan(0));
        expect(response.usage!.completionTokens, isNotNull);
        expect(response.usage!.completionTokens, greaterThan(0));
        expect(
          response.usage!.totalTokens,
          equals(
            response.usage!.promptTokens + response.usage!.completionTokens!,
          ),
        );
      },
    );

    test(
      'uses convenience text property',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.completions.create(
          const CompletionRequest(
            model: model,
            prompt: CompletionPrompt.text('Say hello'),
            maxTokens: 10,
          ),
        );

        // The Completion class has a convenience text getter
        expect(response.text, isNotEmpty);
        expect(response.text, equals(response.choices.first.text));
      },
    );
  });
}
