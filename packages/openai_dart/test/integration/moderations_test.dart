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
  });
}
