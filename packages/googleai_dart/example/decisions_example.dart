// ignore_for_file: avoid_print
/// Evaluates several questions against the same input with Gemini Decision 1.
library;

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment(apiVersion: ApiVersion.v1beta);
  try {
    final response = await client.decisions.create(
      model: 'gemini-decision-1',
      input: const DecisionInput.text(
        'A customer reports that a delivery arrived two days late and asks '
        'for a refund of the express shipping fee.',
      ),
      questions: const {
        'refund_requested': DecisionQuestion.noul(
          instructions: DecisionInstructions.text(
            'Is the customer explicitly asking for a refund?',
          ),
        ),
        'team': DecisionQuestion.choice(
          instructions: DecisionInstructions.text(
            'Which team should handle this request?',
          ),
          criteria: {
            'billing': 'Refunds and charges.',
            'shipping': 'Tracking and delivery logistics.',
          },
        ),
      },
    );

    final answers = response.answers ?? const <String, DecisionAnswer>{};
    for (final entry in answers.entries) {
      switch (entry.value) {
        case NoulAnswer(:final noul):
          print('${entry.key} probability: $noul');
        case ChoiceAnswer(:final choice, :final confidence):
          print('${entry.key}: $choice ($confidence confidence)');
        case ScoreAnswer(:final score):
          print('${entry.key} score: $score');
        case UnknownDecisionAnswer(:final type):
          print('${entry.key}: unrecognized answer type $type');
      }
    }
  } finally {
    client.close();
  }
}
