// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Runs text and chat classification using an existing classifier model.
Future<void> main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  final model = Platform.environment['MISTRAL_CLASSIFIER_MODEL'];
  if (apiKey == null || model == null) {
    print('Set MISTRAL_API_KEY and MISTRAL_CLASSIFIER_MODEL.');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);
  try {
    final text = await client.classifications.create(
      request: ClassificationRequest.text(
        model: model,
        input: 'Please send me a copy of the invoice.',
        metadata: const {'source': 'classification_example'},
      ),
    );
    _printResults(text);

    final chat = await client.classifications.createChat(
      request: ChatClassificationRequest.batch(
        model: model,
        conversations: [
          [ChatMessage.user('Can I change my billing address?')],
          [ChatMessage.user('How do I reset my password?')],
        ],
      ),
    );
    _printResults(chat);
  } finally {
    client.close();
  }
}

void _printResults(ClassificationResponse response) {
  for (final (index, result) in response.results.indexed) {
    for (final target in result.targets.entries) {
      print('Input $index, ${target.key}: ${target.value.scores}');
    }
  }
}
