@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  final apiKey = Platform.environment['OPENAI_API_KEY'];

  test(
    'Decisions returns typed answers for text and inline image evidence',
    () async {
      final client = OpenAIClient(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider(apiKey!),
          retryPolicy: const RetryPolicy(maxRetries: 0),
          timeout: const Duration(seconds: 60),
        ),
      );
      addTearDown(client.close);

      // Exactly one live request, with retries disabled to bound API spend.
      final response = await client.decisions.create(
        DecisionRequest(
          model: 'gpt-6-luna',
          input: DecisionInput.messages([
            DecisionInputMessage(
              content: DecisionContent.parts([
                const DecisionInputPart.text(
                  'A customer requests a replacement for a damaged screen.',
                ),
                DecisionInputPart.imageBytes(
                  base64Decode(_redSquarePng),
                  mediaType: 'image/png',
                  detail: ImageDetail.low,
                ),
              ]),
            ),
          ]),
          questions: [
            const DecisionQuestion.predicate(
              name: 'red_image',
              instructions: 'Does the image contain red pixels?',
            ),
            DecisionQuestion.choice(
              name: 'replacement_requested',
              instructions: 'Does the customer request a replacement?',
              choices: const [
                DecisionChoiceOption(
                  value: DecisionChoiceValue.boolean(true),
                  description: 'A replacement is requested.',
                ),
                DecisionChoiceOption(
                  value: DecisionChoiceValue.boolean(false),
                  description: 'No replacement is requested.',
                ),
              ],
            ),
            DecisionQuestion.score(
              name: 'screen_damage',
              instructions: 'Rate the screen damage reported in the text.',
              levels: const [
                DecisionScoreLevel(label: 'none'),
                DecisionScoreLevel(label: 'damaged'),
              ],
            ),
          ],
        ),
      );

      final usage = response.usage;
      final inputDetails = usage.inputTokensDetails;
      final outputDetails = usage.outputTokensDetails;
      // Only token counters are logged; no request, headers, or raw response.
      // ignore: avoid_print
      print(
        'Decisions token usage: input=${usage.inputTokens}, '
        'output=${usage.outputTokens}, total=${usage.totalTokens}, '
        'cached=${inputDetails?.cachedTokens}, '
        'cache_write=${inputDetails?.cacheWriteTokens}, '
        'reasoning=${outputDetails?.reasoningTokens}',
      );

      expect(response.model, startsWith('gpt-6-luna'));
      expect(response.answers, hasLength(3));
      expect(response.answers.map((answer) => answer.name), [
        'red_image',
        'replacement_requested',
        'screen_damage',
      ]);
      // Refusal is a valid outcome for an individual question. Validate each
      // scored payload when available without treating a refusal as malformed.
      final predicate = response.answers[0];
      expect(
        predicate,
        anyOf(isA<PredicateDecisionAnswer>(), isA<RefusalDecisionAnswer>()),
      );
      if (predicate is PredicateDecisionAnswer) {
        expect(predicate.probability, inInclusiveRange(0.0, 1.0));
      }

      final choice = response.answers[1];
      expect(
        choice,
        anyOf(isA<ChoiceDecisionAnswer>(), isA<RefusalDecisionAnswer>()),
      );
      if (choice is ChoiceDecisionAnswer) {
        expect(choice.choice, isA<BooleanDecisionChoiceValue>());
        expect(choice.choice.toJson(), isA<bool>());
        expect(choice.confidence, inInclusiveRange(0.0, 1.0));
        expect(choice.probabilities, hasLength(2));
        expect(
          choice.probabilities.map((item) => item.value.toJson()),
          unorderedEquals([true, false]),
        );
        for (final item in choice.probabilities) {
          expect(item.value, isA<BooleanDecisionChoiceValue>());
          expect(item.probability, inInclusiveRange(0.0, 1.0));
        }
        expect(
          choice.probabilities.fold(0.0, (sum, item) => sum + item.probability),
          closeTo(1.0, 0.001),
        );
      }

      final score = response.answers[2];
      expect(
        score,
        anyOf(isA<ScoreDecisionAnswer>(), isA<RefusalDecisionAnswer>()),
      );
      if (score is ScoreDecisionAnswer) {
        expect(score.score, inInclusiveRange(0.0, 1.0));
        expect(score.confidence, inInclusiveRange(0.0, 1.0));
        expect(score.probabilities, hasLength(2));
        expect(score.probabilities.map((item) => item.value), [0, 1]);
        expect(score.probabilities.map((item) => item.label), [
          'none',
          'damaged',
        ]);
        for (final item in score.probabilities) {
          expect(item.probability, inInclusiveRange(0.0, 1.0));
        }
        expect(
          score.probabilities.fold(0.0, (sum, item) => sum + item.probability),
          closeTo(1.0, 0.001),
        );
      }

      expect(usage.inputTokens, greaterThan(0));
      expect(usage.outputTokens, greaterThanOrEqualTo(0));
      expect(usage.totalTokens, usage.inputTokens + usage.outputTokens);
      expect(inputDetails, isNotNull);
      expect(inputDetails!.cachedTokens, isNotNull);
      expect(inputDetails.cacheWriteTokens, isNotNull);
      expect(inputDetails.cachedTokens, inInclusiveRange(0, usage.inputTokens));
      expect(
        inputDetails.cacheWriteTokens,
        inInclusiveRange(0, usage.inputTokens),
      );
      expect(outputDetails, isNotNull);
      expect(outputDetails!.reasoningTokens, isNotNull);
      expect(
        outputDetails.reasoningTokens,
        inInclusiveRange(0, usage.outputTokens),
      );
    },
    skip: apiKey == null || apiKey.trim().isEmpty
        ? 'OPENAI_API_KEY is not set.'
        : false,
    timeout: const Timeout(Duration(seconds: 60)),
  );
}

// Valid 80-byte, 16x16 RGB PNG with every pixel red, generated locally with zlib.
const _redSquarePng =
    'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAF0lEQVR4nGP4z8BAEiJN9aiGUQ1'
    'DSgMAkPn/Afnh+ngAAAAASUVORK5CYII=';
