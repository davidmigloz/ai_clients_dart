// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Requires Ollama v0.35.0+ and a compatible decision model.
/// Pull a local model before running, for example `ollama pull nimble`.
/// Use `clef:cloud` through a signed-in local server (v0.40.5+) for cloud access.
/// For image input (v0.40.0+ locally), pass a vision model and image path:
/// `dart run example/system_one_example.dart clef receipt.png`.
Future<void> main(List<String> args) async {
  final client = OllamaClient();
  // Direct cloud access instead uses OllamaClient.withApiKey(
  //   Platform.environment['OLLAMA_API_KEY']!,
  //   baseUrl: 'https://ollama.com',
  // ) and a model such as 'clef' (without the local ':cloud' suffix).

  try {
    final response = await client.systemOne.create(
      request: SystemOneRequest(
        model: args.isEmpty ? 'nimble' : args.first,
        state: SystemOneContent.object(const {
          'message': 'My parcel arrived damaged. Please refund my order.',
          'order_status': 'delivered',
        }),
        questions: {
          'intent': SystemOneQuestion.choice(
            instructions: const SystemOneContent.string(
              'Classify the customer request.',
            ),
            criteria: const {
              'refund': 'The customer requests money back',
              'replacement': 'The customer requests another item',
              'other': null,
            },
          ),
          'needs_follow_up': const SystemOneQuestion.noul(
            instructions: SystemOneContent.string(
              'Does this request require follow-up by customer support?',
            ),
            criteria: SystemOneNoulCriteria(
              falseDescription: 'No follow-up is needed',
              trueDescription: 'Customer support should follow up',
            ),
          ),
          'urgency': SystemOneQuestion.score(
            instructions: const SystemOneContent.string(
              'Rate the urgency of this customer request.',
            ),
            criteria: const [
              'Routine request with no urgency',
              'A problem requiring timely attention',
              'An emergency requiring immediate attention',
            ],
          ),
        },
        keepAlive: const KeepAlive.duration('5m'),
      ),
    );

    for (final entry in response.answers.entries) {
      print('${entry.key}: ${entry.value}');
    }
    print('Usage: ${response.usage}');

    if (args.length > 1) {
      final imageResponse = await client.systemOne.create(
        request: SystemOneRequest(
          model: args.first,
          state: const SystemOneContent.string('A customer sent this image.'),
          images: [base64Encode(await File(args[1]).readAsBytes())],
          questions: const {
            'is_receipt': SystemOneQuestion.noul(
              instructions: SystemOneContent.string(
                'Is the image a purchase receipt?',
              ),
            ),
          },
        ),
      );
      print('Image answer: ${imageResponse.answers['is_receipt']}');
    }

    // Noul answers contain a probability of true, not a Boolean.
    // Scores are weighted averages of zero-based criterion indices.
    // Confidence describes probability concentration, not correctness.
  } finally {
    client.close();
  }
}
