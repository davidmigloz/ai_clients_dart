// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

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

  group('Moderations - Integration', () {
    test(
      'moderates safe content',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.moderations.create(
          ModerationRequest(
            input: ModerationInput.text('Hello, how are you today?'),
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.model, contains('moderation'));
        expect(response.results, hasLength(1));
        expect(response.results.first.flagged, isFalse);
      },
    );

    test(
      'moderates multiple inputs',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.moderations.create(
          ModerationRequest(
            input: ModerationInput.textList([
              'Hello, how are you?',
              'The weather is nice today.',
            ]),
          ),
        );

        expect(response.results, hasLength(2));
        expect(response.results[0].flagged, isFalse);
        expect(response.results[1].flagged, isFalse);
      },
    );

    test(
      'returns all category scores and flags',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.moderations.create(
          ModerationRequest(
            input: ModerationInput.text('This is a perfectly safe message.'),
          ),
        );

        final result = response.first;

        // All category flags should be present
        expect(result.categories.hate, isA<bool>());
        expect(result.categories.hateThreatening, isA<bool>());
        expect(result.categories.harassment, isA<bool>());
        expect(result.categories.harassmentThreatening, isA<bool>());
        expect(result.categories.selfHarm, isA<bool>());
        expect(result.categories.selfHarmIntent, isA<bool>());
        expect(result.categories.selfHarmInstructions, isA<bool>());
        expect(result.categories.sexual, isA<bool>());
        expect(result.categories.sexualMinors, isA<bool>());
        expect(result.categories.violence, isA<bool>());
        expect(result.categories.violenceGraphic, isA<bool>());

        // All category scores should be non-negative doubles
        expect(result.categoryScores.hate, greaterThanOrEqualTo(0.0));
        expect(
          result.categoryScores.hateThreatening,
          greaterThanOrEqualTo(0.0),
        );
        expect(result.categoryScores.harassment, greaterThanOrEqualTo(0.0));
        expect(
          result.categoryScores.harassmentThreatening,
          greaterThanOrEqualTo(0.0),
        );
        // illicit scores may be null for legacy text-moderation models
        if (result.categoryScores.illicit != null) {
          expect(result.categoryScores.illicit, greaterThanOrEqualTo(0.0));
        }
        if (result.categoryScores.illicitViolent != null) {
          expect(
            result.categoryScores.illicitViolent,
            greaterThanOrEqualTo(0.0),
          );
        }
        expect(result.categoryScores.selfHarm, greaterThanOrEqualTo(0.0));
        expect(result.categoryScores.selfHarmIntent, greaterThanOrEqualTo(0.0));
        expect(
          result.categoryScores.selfHarmInstructions,
          greaterThanOrEqualTo(0.0),
        );
        expect(result.categoryScores.sexual, greaterThanOrEqualTo(0.0));
        expect(result.categoryScores.sexualMinors, greaterThanOrEqualTo(0.0));
        expect(result.categoryScores.violence, greaterThanOrEqualTo(0.0));
        expect(
          result.categoryScores.violenceGraphic,
          greaterThanOrEqualTo(0.0),
        );
      },
    );

    test(
      'omni-moderation model returns illicit categories and applied input types',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.moderations.create(
          ModerationRequest(
            input: ModerationInput.text('Hello, this is a safe message.'),
            model: 'omni-moderation-latest',
          ),
        );

        final result = response.first;
        expect(result.flagged, isFalse);

        // Omni-moderation models return illicit category flags
        expect(result.categories.illicit, isA<bool>());
        expect(result.categories.illicitViolent, isA<bool>());

        // Illicit scores are always present
        expect(result.categoryScores.illicit, greaterThanOrEqualTo(0.0));
        expect(result.categoryScores.illicitViolent, greaterThanOrEqualTo(0.0));

        // Applied input types should be present for omni-moderation
        expect(result.categoryAppliedInputTypes, isNotNull);
        final applied = result.categoryAppliedInputTypes!;
        expect(applied.hate, isNotEmpty);
        expect(applied.harassment, isNotEmpty);
        expect(applied.selfHarm, isNotEmpty);
        expect(applied.sexual, isNotEmpty);
        expect(applied.violence, isNotEmpty);
        expect(applied.illicit, isNotEmpty);
        expect(applied.illicitViolent, isNotEmpty);

        // For text-only input, applied types should contain 'text'
        expect(applied.hate, contains('text'));
        expect(applied.harassment, contains('text'));
      },
    );

    test(
      'omni-moderation with multi-modal text input',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.moderations.create(
          ModerationRequest(
            input: ModerationInput.multiModal([
              ModerationInputItem.text('Hello, how are you?'),
              ModerationInputItem.text('The weather is nice.'),
            ]),
            model: 'omni-moderation-latest',
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.model, contains('omni-moderation'));
        expect(response.results, hasLength(1));

        final result = response.first;
        expect(result.flagged, isFalse);

        // Applied input types should reflect text input
        expect(result.categoryAppliedInputTypes, isNotNull);
        expect(result.categoryAppliedInputTypes!.hate, contains('text'));
      },
    );

    test(
      'anyFlagged helper works correctly for safe content',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.moderations.create(
          ModerationRequest(
            input: ModerationInput.textList([
              'Good morning!',
              'Have a nice day!',
            ]),
          ),
        );

        expect(response.anyFlagged, isFalse);
      },
    );
  });
}
