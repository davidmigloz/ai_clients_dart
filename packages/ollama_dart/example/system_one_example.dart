// ignore_for_file: avoid_print
import 'package:ollama_dart/ollama_dart.dart';

/// Requires Ollama v0.35.0+ and a compatible local model (for example, nimble).
/// Pull the model before running this example; System One is local only.
Future<void> main(List<String> args) async {
  final client = OllamaClient();

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

    // Noul answers contain a probability of true, not a Boolean.
    // Scores are weighted averages of zero-based criterion indices.
    // Confidence describes probability concentration, not correctness.
  } finally {
    client.close();
  }
}
