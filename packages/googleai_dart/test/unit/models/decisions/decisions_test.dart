import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateDecisionRequest', () {
    test('round-trips all question and instruction forms', () {
      final json = <String, dynamic>{
        'model': 'gemini-decision-1',
        'input': [
          {'type': 'text', 'text': 'Compare the attachment with the message.'},
          {
            'type': 'document',
            'mime_type': 'application/pdf',
            'uri': 'https://example.com/report.pdf',
          },
        ],
        'questions': {
          'repeat': {
            'type': 'noul',
            'instructions': 'Did the customer request a repeat delivery?',
            'criteria': {
              'true_description': 'The customer asks for another delivery.',
              'false_description': 'The customer asks about tracking only.',
            },
          },
          'destination': {
            'type': 'choice',
            'instructions': {
              'type': 'text',
              'text': 'Select a delivery route.',
            },
            'criteria': {'courier': '', 'post': 'Delivers by post.'},
          },
          'deadline': {
            'type': 'score',
            'instructions': [
              {'type': 'text', 'text': 'Assess the urgency.'},
              {'type': 'text', 'text': 'Consider the specified deadline.'},
            ],
            'criteria': ['Flexible', 'Urgent'],
          },
        },
      };

      final request = CreateDecisionRequest.fromJson(json);
      expect(request.input, isA<DecisionContentListInput>());
      expect(request.questions['repeat'], isA<NoulQuestion>());
      expect(request.questions['destination'], isA<ChoiceQuestion>());
      expect(request.questions['deadline'], isA<ScoreQuestion>());
      expect(request.toJson(), json);

      final question = request.questions['repeat']! as NoulQuestion;
      expect(question.copyWith(criteria: null).toJson(), {
        'type': 'noul',
        'instructions': 'Did the customer request a repeat delivery?',
      });
    });

    test('preserves text and single-block input wire shapes', () {
      final image = <String, dynamic>{
        'type': 'image',
        'mime_type': 'image/png',
        'data': 'AA==',
      };

      expect(DecisionInput.fromJson('shared text').toJson(), 'shared text');
      expect(DecisionInput.fromJson(image), isA<DecisionSingleContentInput>());
      expect(DecisionInput.fromJson(image).toJson(), image);
    });

    test('rejects missing required fields and inadmissible content', () {
      expect(
        () => CreateDecisionRequest.fromJson({'input': 'shared text'}),
        throwsFormatException,
      );
      expect(
        () => CreateDecisionRequest.fromJson({
          'model': 'gemini-decision-1',
          'input': 'shared text',
        }),
        throwsFormatException,
      );
      expect(
        () => DecisionQuestion.fromJson({'type': 'noul'}),
        throwsFormatException,
      );
      expect(
        () => DecisionQuestion.fromJson({
          'type': 'choice',
          'instructions': 'Pick a choice.',
        }),
        throwsFormatException,
      );
      expect(
        () => ScoreQuestion.fromJson({
          'type': 'choice',
          'instructions': 'Pick a choice.',
          'criteria': ['One', 'Two'],
        }),
        throwsFormatException,
      );
      expect(
        () => DecisionInstructions.fromJson([
          {'type': 'text', 'text': 'Consider this.'},
          {'type': 'image', 'data': 'AA=='},
        ]),
        throwsFormatException,
      );
      expect(
        () =>
            DecisionInput.fromJson({'type': 'function_call', 'name': 'check'}),
        throwsFormatException,
      );
      expect(
        () => DecisionInput.fromJson({'type': 'text'}),
        throwsFormatException,
      );
    });

    test('enforces required collection sizes on parsing and serialization', () {
      const instructions = DecisionInstructions.text('Choose the best result.');
      const choice = DecisionQuestion.choice(
        instructions: instructions,
        criteria: {'only_choice': ''},
      );
      const score = DecisionQuestion.score(
        instructions: instructions,
        criteria: ['Low', ''],
      );

      expect(choice.toJson, throwsArgumentError);
      expect(score.toJson, throwsArgumentError);
      expect(
        () => DecisionQuestion.fromJson({
          'type': 'choice',
          'instructions': 'Choose one.',
          'criteria': {'only_choice': ''},
        }),
        throwsFormatException,
      );
      expect(
        () => DecisionQuestion.fromJson({
          'type': 'score',
          'instructions': 'Rate the score.',
          'criteria': ['Low', ''],
        }),
        throwsFormatException,
      );

      const request = CreateDecisionRequest(
        model: 'gemini-decision-1',
        input: DecisionInput.text('Input'),
        questions: {},
      );
      expect(request.toJson, throwsArgumentError);
      expect(
        () => CreateDecisionRequest.fromJson({
          'model': request.model,
          'input': request.input.toJson(),
          'questions': <String, Object?>{},
        }),
        throwsFormatException,
      );
      expect(const DecisionInput.contentList([]).toJson, throwsArgumentError);
      expect(
        const DecisionInstructions.contentList([]).toJson,
        throwsArgumentError,
      );
      expect(() => DecisionInput.fromJson(<Object>[]), throwsFormatException);
      expect(
        () => DecisionInstructions.fromJson(<Object>[]),
        throwsFormatException,
      );
    });

    test('preserves unknown question discriminator and nested payload', () {
      final json = {
        'type': 'future',
        'criteria': {
          'nested': [1, 2],
        },
      };

      final question = DecisionQuestion.fromJson(json);
      expect(question, isA<UnknownDecisionQuestion>());
      expect(question.toJson(), json);
    });
  });

  group('CreateDecisionResponse', () {
    test('decodes all calibrated answer variants and usage', () {
      final json = <String, dynamic>{
        'answers': {
          'repeat': {'type': 'noul', 'noul': 0.05, 'confidence': 0.95},
          'destination': {
            'type': 'choice',
            'choice': 'courier',
            'probabilities': {'courier': 1, 'post': 0},
            'confidence': 1,
          },
          'deadline': {
            'type': 'score',
            'score': 0.75,
            'probabilities': {'0': 0.25, '1': 0.75},
            'legend': {'0': 'Flexible', '1': 'Urgent'},
            'confidence': 0.75,
          },
          'unknown': {
            'type': 'future',
            'data': {
              'items': [1, 2],
            },
          },
        },
        'usage': {
          'total_input_tokens': 19,
          'input_tokens_by_modality': [
            {'tokens': 7, 'modality': 'text'},
            {'tokens': 12, 'modality': 'image'},
          ],
          'total_output_tokens': 0,
          'total_tokens': 19,
        },
      };

      final response = CreateDecisionResponse.fromJson(json);
      final answers = response.answers!;
      expect((answers['repeat']! as NoulAnswer).noul, 0.05);
      expect((answers['destination']! as ChoiceAnswer).probabilities, {
        'courier': 1.0,
        'post': 0.0,
      });
      expect((answers['deadline']! as ScoreAnswer).legend['0'], 'Flexible');
      expect(answers['unknown'], isA<UnknownDecisionAnswer>());
      expect(response.usage?.totalOutputTokens, 0);
      expect(response.usage?.inputTokensByModality, hasLength(2));
      expect(response.toJson(), json);
    });

    test('rejects incomplete known answers and mismatched tags', () {
      expect(
        () => DecisionAnswer.fromJson({'type': 'noul', 'noul': 0.95}),
        throwsFormatException,
      );
      expect(
        () => DecisionAnswer.fromJson({
          'type': 'score',
          'score': 1.0,
          'confidence': 1.0,
          'probabilities': {'1': 1.0},
        }),
        throwsFormatException,
      );
      expect(
        () => NoulAnswer.fromJson({
          'type': 'choice',
          'noul': 0.95,
          'confidence': 0.95,
        }),
        throwsFormatException,
      );
    });

    test('round-trips blocked feedback with absent and empty answers', () {
      const feedbackJson = {
        'block_reason': 'future_reason',
        'block_reason_message': 'A newer filter blocked the prompt.',
      };
      final response = CreateDecisionResponse.fromJson({
        'prompt_feedback': feedbackJson,
      });
      expect(response.answers, isNull);
      expect(response.promptFeedback?.blockReason?.value, 'future_reason');
      expect(response.toJson(), {'prompt_feedback': feedbackJson});

      final empty = response.copyWith(answers: <String, DecisionAnswer>{});
      expect(empty.toJson(), {
        'answers': <String, Object?>{},
        'prompt_feedback': feedbackJson,
      });
      expect(empty.copyWith(promptFeedback: null).toJson(), {
        'answers': <String, Object?>{},
      });
    });
  });
}
