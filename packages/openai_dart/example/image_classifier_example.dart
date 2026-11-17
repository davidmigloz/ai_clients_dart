// ignore_for_file: avoid_print
/// Decodes synthetic image classifier results with a local HTTP fixture.
///
/// Run: dart run example/image_classifier_example.dart
/// Live classifier access requires an approved organization.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final transport = MockClient((_) async {
    return http.Response(
      jsonEncode({
        'id': 'modr_fixture',
        'model': 'omni-moderation-csam-latest',
        'results': [
          {
            'flagged': false,
            'categories': {'likely-csam': false, 'likely-csam/gen-ai': false},
            'category_scores': {
              'likely-csam': 0.08,
              'likely-csam/gen-ai': 0.02,
            },
            'category_applied_input_types': {
              'likely-csam': ['image'],
              'likely-csam/gen-ai': ['image'],
            },
          },
        ],
      }),
      200,
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://fixture.invalid/v1',
      authProvider: ApiKeyProvider('local-fixture'),
    ),
    httpClient: transport,
  );
  try {
    final classification = await client.moderations.classifyImage(
      'https://fixture.invalid/synthetic-image.png',
    );
    final result = classification.result;
    print('Flagged: ${result.flagged}');
    print('Category signals: ${result.categories}');
    print('Category scores: ${result.categoryScores}');
    print('Applied input types: ${result.categoryAppliedInputTypes}');
  } finally {
    client.close();
    transport.close();
  }
}
