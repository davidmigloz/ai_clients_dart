// ignore_for_file: avoid_print
/// Typed predicate, choice, and score questions through the Decisions API.
///
/// Run with: dart run example/decisions_example.dart
/// Set OPENAI_API_KEY first. The API currently supports gpt-6-luna.
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main(List<String> arguments) async {
  final client = OpenAIClient.fromEnvironment();
  try {
    // Pass an optional PNG filename to include inline image evidence.
    final input = arguments.isEmpty
        ? const DecisionInput.text(
            'The screen arrived broken. Please send a replacement.',
          )
        : DecisionInput.messages([
            DecisionInputMessage(
              content: DecisionContent.parts([
                const DecisionInputPart.text(
                  'The screen arrived broken. Please send a replacement.',
                ),
                DecisionInputPart.imageBytes(
                  await File(arguments.first).readAsBytes(),
                  mediaType: 'image/png',
                  detail: ImageDetail.auto,
                ),
              ]),
            ),
          ]);

    final response = await client.decisions.create(
      DecisionRequest(
        model: 'gpt-6-luna',
        input: input,
        questions: [
          const DecisionQuestion.predicate(
            name: 'damaged',
            instructions: 'Does the customer report a damaged item?',
          ),
          DecisionQuestion.choice(
            name: 'next_step',
            instructions: 'Choose the best next step for the support team.',
            choices: const [
              DecisionChoiceOption(
                value: DecisionChoiceValue.string('replace'),
              ),
              DecisionChoiceOption(value: DecisionChoiceValue.string('refund')),
              DecisionChoiceOption(
                value: DecisionChoiceValue.string('clarify'),
              ),
            ],
          ),
          DecisionQuestion.score(
            name: 'urgency',
            instructions: 'Score the urgency of the support request.',
            levels: const [
              DecisionScoreLevel(label: 'low'),
              DecisionScoreLevel(label: 'medium'),
              DecisionScoreLevel(label: 'high'),
            ],
          ),
        ],
      ),
    );

    for (final answer in response.answers) {
      switch (answer) {
        case PredicateDecisionAnswer(:final name, :final probability):
          print('$name: probability $probability');
        case ChoiceDecisionAnswer(
          :final name,
          :final choice,
          :final confidence,
        ):
          print('$name: ${choice.toJson()} (confidence $confidence)');
        case ScoreDecisionAnswer(:final name, :final score, :final confidence):
          // Scores can be fractional averages of the zero-based level indices.
          print('$name: score $score (confidence $confidence)');
        case RefusalDecisionAnswer(:final name):
          print('$name: refused');
        case UnknownDecisionAnswer(:final type):
          print('Unsupported answer type: $type');
      }
    }
    print('Input tokens: ${response.usage.inputTokens}');
    print(
      'Cache-write tokens: ${response.usage.inputTokensDetails?.cacheWriteTokens}',
    );
  } finally {
    client.close();
  }
}
