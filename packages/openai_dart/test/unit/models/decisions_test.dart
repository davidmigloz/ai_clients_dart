import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DecisionRequest', () {
    test(
      'serializes ordered questions and primitive choice values exactly',
      () {
        final request = DecisionRequest(
          model: 'gpt-6-luna',
          input: const DecisionInput.text('The screen arrived broken.'),
          safetyIdentifier: 'customer-123',
          questions: [
            const DecisionQuestion.predicate(
              instructions: 'Is the item damaged?',
              name: 'damaged',
            ),
            DecisionQuestion.choice(
              instructions: 'Choose a category.',
              choices: const [
                DecisionChoiceOption(
                  value: DecisionChoiceValue.string('true'),
                  description: 'The literal text.',
                ),
                DecisionChoiceOption(value: DecisionChoiceValue.boolean(true)),
              ],
            ),
            DecisionQuestion.score(
              instructions: 'How urgent is this?',
              name: 'urgency',
              levels: const [
                DecisionScoreLevel(label: 'low'),
                DecisionScoreLevel(label: 'high', description: 'Needs action.'),
              ],
            ),
          ],
        );

        final fixture = <String, dynamic>{
          'model': 'gpt-6-luna',
          'input': 'The screen arrived broken.',
          'safety_identifier': 'customer-123',
          'questions': [
            {
              'type': 'predicate',
              'instructions': 'Is the item damaged?',
              'name': 'damaged',
            },
            {
              'type': 'choice',
              'instructions': 'Choose a category.',
              'choices': [
                {'value': 'true', 'description': 'The literal text.'},
                {'value': true},
              ],
            },
            {
              'type': 'score',
              'instructions': 'How urgent is this?',
              'name': 'urgency',
              'levels': [
                {'label': 'low'},
                {'label': 'high', 'description': 'Needs action.'},
              ],
            },
          ],
        };
        expect(request.toJson(), fixture);
        expect(DecisionRequest.fromJson(fixture), request);
        expect(DecisionRequest.fromJson(fixture).hashCode, request.hashCode);
      },
    );

    test('omits absent safety identifier and copyWith can clear it', () {
      final request = DecisionRequest(
        model: 'gpt-6-luna',
        input: const DecisionInput.text(''),
        questions: const [],
        safetyIdentifier: 'customer-123',
      );

      expect(request.copyWith().safetyIdentifier, 'customer-123');
      final cleared = request.copyWith(safetyIdentifier: null);
      expect(cleared.safetyIdentifier, isNull);
      expect(cleared.toJson(), {
        'model': 'gpt-6-luna',
        'input': '',
        'questions': <dynamic>[],
      });
    });

    test('accepts an explicitly null safety identifier', () {
      final request = DecisionRequest.fromJson(const {
        'model': 'gpt-6-luna',
        'input': '',
        'questions': <dynamic>[],
        'safety_identifier': null,
      });
      expect(request.safetyIdentifier, isNull);
      expect(request.toJson().containsKey('safety_identifier'), isFalse);
    });

    test('preserves future models and leaves question limits to the API', () {
      final request = DecisionRequest(
        model: 'future-decision-model',
        input: const DecisionInput.text(''),
        questions: const [],
      );
      expect(request.toJson()['model'], 'future-decision-model');
      expect(request.toJson()['questions'], isEmpty);
    });

    test('snapshots the caller question list', () {
      final questions = <DecisionQuestion>[
        const DecisionQuestion.predicate(instructions: 'Is it damaged?'),
      ];
      final request = DecisionRequest(
        model: 'gpt-6-luna',
        input: const DecisionInput.text('broken'),
        questions: questions,
      );
      final initialHash = request.hashCode;
      questions.clear();

      expect(request.questions, hasLength(1));
      expect(request.hashCode, initialHash);
      expect(request.questions.clear, throwsUnsupportedError);
    });
  });

  group('Decisions input', () {
    test('serializes string message content with a user role', () {
      final input = DecisionInput.messages([
        DecisionInputMessage.text('Hello'),
      ]);
      final json = input.toJson() as List<dynamic>;
      final message = json.single as Map<String, dynamic>;
      expect(message['role'], 'user');
      expect(message['content'], 'Hello');
      expect(message.keys.toSet(), containsAll(['role', 'content']));
      if (message.containsKey('type')) expect(message['type'], 'message');
      expect(DecisionInput.fromJson(json), input);
    });

    test('serializes mixed text and inline images in their original order', () {
      final input = DecisionInput.messages([
        DecisionInputMessage(
          content: DecisionContent.parts([
            const DecisionInputPart.text('Inspect this photo.'),
            DecisionInputPart.imageBytes(
              const [0, 1, 2, 255],
              mediaType: 'image/png',
              detail: ImageDetail.original,
            ),
            DecisionInputPart.image(imageUrl: 'data:image/jpeg;base64,AQID'),
            const DecisionInputPart.text('Is the screen broken?'),
          ]),
        ),
      ]);
      final message =
          (input.toJson() as List<dynamic>).single as Map<String, dynamic>;
      expect(message['role'], 'user');
      expect(message['content'], [
        {'type': 'input_text', 'text': 'Inspect this photo.'},
        {
          'type': 'input_image',
          'image_url': 'data:image/png;base64,AAEC/w==',
          'detail': 'original',
        },
        {'type': 'input_image', 'image_url': 'data:image/jpeg;base64,AQID'},
        {'type': 'input_text', 'text': 'Is the screen broken?'},
      ]);
      expect(DecisionInput.fromJson(input.toJson()), input);
    });

    for (final detail in ImageDetail.values) {
      test('preserves ${detail.name} image detail', () {
        final part = DecisionInputPart.image(
          imageUrl: 'data:image/png;base64,AQID',
          detail: detail,
        );
        expect(part.toJson()['detail'], detail.name);
        expect(DecisionInputPart.fromJson(part.toJson()), part);
      });
    }

    test('allows empty text, message lists, and content part lists', () {
      expect(const DecisionInput.text('').toJson(), '');
      expect(DecisionInput.messages(const []).toJson(), isEmpty);
      expect(const DecisionContent.text('').toJson(), '');
      expect(DecisionContent.parts(const []).toJson(), isEmpty);
    });

    test('message and part lists cannot change after construction', () {
      final parts = <DecisionInputPart>[const DecisionInputPart.text('first')];
      final content = DecisionContent.parts(parts) as PartsDecisionContent;
      final messages = <DecisionInputMessage>[
        DecisionInputMessage(content: content),
      ];
      final input = DecisionInput.messages(messages) as MessagesDecisionInput;
      parts.clear();
      messages.clear();

      expect(content.parts, hasLength(1));
      expect(input.messages, hasLength(1));
      expect(content.parts.clear, throwsUnsupportedError);
      expect(input.messages.clear, throwsUnsupportedError);
    });

    for (final imageUrl in [
      'https://example.com/image.png',
      'AQID',
      'file_123',
    ]) {
      test('rejects unsupported image reference $imageUrl', () {
        expect(
          () => DecisionInputPart.image(imageUrl: imageUrl),
          throwsArgumentError,
        );
        expect(
          () => DecisionInputPart.fromJson({
            'type': 'input_image',
            'image_url': imageUrl,
          }),
          throwsFormatException,
        );
      });
    }

    test('rejects unsupported message roles and request content types', () {
      for (final role in ['assistant', 'system', 'developer', 'tool']) {
        expect(
          () => DecisionInput.fromJson([
            {'role': role, 'content': 'Hello'},
          ]),
          throwsFormatException,
        );
      }
      for (final type in [
        'input_file',
        'input_audio',
        'item_reference',
        'new',
      ]) {
        expect(
          () => DecisionInputPart.fromJson({'type': type}),
          throwsFormatException,
        );
      }
      expect(() => DecisionInput.fromJson(123), throwsFormatException);
      expect(() => DecisionContent.fromJson(true), throwsFormatException);
      expect(
        () => DecisionInputMessage.fromJson(const {
          'type': 'future_message',
          'role': 'user',
          'content': 'Hello',
        }),
        throwsFormatException,
      );
    });
  });

  group('Decisions questions', () {
    test('string and boolean choice values remain distinct', () {
      const text = DecisionChoiceValue.string('true');
      const boolean = DecisionChoiceValue.boolean(true);
      expect(text.toJson(), 'true');
      expect(boolean.toJson(), true);
      expect(text, isNot(boolean));
      expect(DecisionChoiceValue.fromJson('true'), text);
      expect(DecisionChoiceValue.fromJson(true), boolean);
      expect(DecisionChoiceValue.fromJson(false).toJson(), false);
    });

    for (final value in <Object?>[null, 0, 1.5, [], {}]) {
      test('rejects non-string/boolean choice value $value', () {
        expect(
          () => DecisionChoiceValue.fromJson(value),
          throwsFormatException,
        );
        expect(
          () => DecisionQuestion.fromJson({
            'type': 'choice',
            'instructions': 'Choose.',
            'choices': [
              {'value': value},
            ],
          }),
          throwsFormatException,
        );
      });
    }

    test('choice and level lists are defensive immutable snapshots', () {
      final choices = <DecisionChoiceOption>[
        const DecisionChoiceOption(value: DecisionChoiceValue.string('first')),
      ];
      final levels = <DecisionScoreLevel>[
        const DecisionScoreLevel(label: 'first'),
      ];
      final choice =
          DecisionQuestion.choice(instructions: 'Choose.', choices: choices)
              as ChoiceDecisionQuestion;
      final score =
          DecisionQuestion.score(instructions: 'Score.', levels: levels)
              as ScoreDecisionQuestion;
      choices.clear();
      levels.clear();

      expect(choice.choices, hasLength(1));
      expect(score.levels, hasLength(1));
      expect(choice.choices.clear, throwsUnsupportedError);
      expect(score.levels.clear, throwsUnsupportedError);
    });

    test(
      'nullable names and descriptions can be cleared without losing data',
      () {
        const question = PredicateDecisionQuestion(
          instructions: 'Check.',
          name: 'check',
        );
        const option = DecisionChoiceOption(
          value: DecisionChoiceValue.boolean(false),
          description: 'No.',
        );
        const level = DecisionScoreLevel(label: 'low', description: 'Low.');

        expect(question.copyWith().name, 'check');
        expect(question.copyWith(name: null).toJson(), {
          'type': 'predicate',
          'instructions': 'Check.',
        });
        expect(option.copyWith(description: null).toJson(), {'value': false});
        expect(level.copyWith(description: null).toJson(), {'label': 'low'});
      },
    );

    test('rejects unknown and malformed question variants', () {
      for (final fixture in <Map<String, dynamic>>[
        {'type': 'future', 'instructions': 'Check.'},
        {'type': 'predicate'},
        {'type': 'choice', 'instructions': 'Choose.'},
        {'type': 'score', 'instructions': 'Score.'},
        {
          'type': 'score',
          'instructions': 'Score.',
          'levels': [<String, dynamic>{}],
        },
      ]) {
        expect(() => DecisionQuestion.fromJson(fixture), throwsFormatException);
      }
    });
  });

  group('DecisionResponse', () {
    test('retains ordered typed answers, fractional scores, and all usage', () {
      final fixture = _responseFixture();
      final response = DecisionResponse.fromJson(fixture);

      expect(response.model, 'gpt-6-luna');
      expect(response.answers, hasLength(4));
      final predicate = response.answers[0] as PredicateDecisionAnswer;
      final choice = response.answers[1] as ChoiceDecisionAnswer;
      final score = response.answers[2] as ScoreDecisionAnswer;
      final refusal = response.answers[3] as RefusalDecisionAnswer;
      expect(predicate.name, 'damaged');
      expect(predicate.probability, 1.0);
      expect(choice.choice, const DecisionChoiceValue.boolean(true));
      expect(choice.confidence, 1.0);
      expect(choice.probabilities.map((p) => p.value.toJson()), ['true', true]);
      expect(choice.probabilities.map((p) => p.probability), [0.0, 1.0]);
      expect(score.score, 0.75);
      expect(score.confidence, 0.9);
      expect(score.probabilities.map((p) => p.value), [0, 1]);
      expect(score.probabilities.map((p) => p.label), ['low', 'high']);
      expect(refusal.name, isNull);
      expect(refusal.toJson(), {'type': 'refusal', 'name': null});
      expect(response.usage.inputTokens, 10);
      expect(response.usage.outputTokens, 2);
      expect(response.usage.totalTokens, 12);
      expect(response.usage.inputTokensDetails!.cachedTokens, 0);
      expect(response.usage.inputTokensDetails!.cacheWriteTokens, 4);
      expect(response.usage.outputTokensDetails!.reasoningTokens, 0);
      expect(response.toJson(), fixture);
      expect(DecisionResponse.fromJson(_responseFixture()), response);
      expect(
        DecisionResponse.fromJson(_responseFixture()).hashCode,
        response.hashCode,
      );
    });

    test('accepts integer JSON for every numeric answer field', () {
      final answer =
          DecisionAnswer.fromJson({
                'type': 'score',
                'name': null,
                'score': 1,
                'confidence': 1,
                'probabilities': [
                  {'value': 1, 'label': 'high', 'probability': 1},
                ],
              })
              as ScoreDecisionAnswer;
      expect(answer.score, 1.0);
      expect(answer.confidence, 1.0);
      expect(answer.probabilities.single.value, 1);
      expect(answer.probabilities.single.probability, 1.0);
    });

    test('does not clamp reported probabilities or round scores', () {
      final answer =
          DecisionAnswer.fromJson({
                'type': 'predicate',
                'name': null,
                'probability': 1.25,
              })
              as PredicateDecisionAnswer;
      expect(answer.probability, 1.25);
    });

    test('preserves nested unknown answers with deep equality and hashing', () {
      final raw = <String, dynamic>{
        'type': 'future_answer',
        'name': null,
        'payload': {
          'candidates': [
            {
              'value': true,
              'scores': [0, 0.25],
            },
          ],
        },
      };
      final expected = _clone(raw);
      final answer = DecisionAnswer.fromJson(raw) as UnknownDecisionAnswer;
      final reordered = <String, dynamic>{
        'payload': expected['payload'],
        'name': null,
        'type': 'future_answer',
      };
      final equal = DecisionAnswer.fromJson(reordered);
      final payload = raw['payload'] as Map<String, dynamic>;
      (payload['candidates'] as List<dynamic>).clear();

      expect(answer.toJson(), expected);
      expect(answer, equal);
      expect(answer.hashCode, equal.hashCode);
      expect(
        answer,
        isNot(DecisionAnswer.fromJson({...expected, 'name': 'changed'})),
      );
      expect(DecisionAnswer.fromJson(answer.toJson()), answer);
    });

    test('distinguishes explicit null names from missing required names', () {
      for (final answer in _responseFixture()['answers'] as List<dynamic>) {
        final fixture = Map<String, dynamic>.from(
          answer as Map<String, dynamic>,
        )..remove('name');
        expect(() => DecisionAnswer.fromJson(fixture), throwsFormatException);
      }
    });

    test('rejects malformed known answer values and distributions', () {
      for (final fixture in <Map<String, dynamic>>[
        {'type': 'predicate', 'name': null},
        {'type': 'predicate', 'name': null, 'probability': '0.5'},
        {
          'type': 'choice',
          'name': null,
          'choice': 1,
          'confidence': 1,
          'probabilities': <dynamic>[],
        },
        {'type': 'choice', 'name': null, 'choice': true, 'confidence': 1},
        {
          'type': 'score',
          'name': null,
          'score': 0.5,
          'confidence': 1,
          'probabilities': [
            {'value': 0.5, 'label': 'invalid', 'probability': 1},
          ],
        },
      ]) {
        expect(() => DecisionAnswer.fromJson(fixture), throwsFormatException);
      }
    });

    for (final field in ['model', 'answers', 'usage']) {
      test('rejects a response missing $field', () {
        final fixture = _responseFixture()..remove(field);
        expect(() => DecisionResponse.fromJson(fixture), throwsFormatException);
      });
    }

    for (final field in [
      'input_tokens',
      'output_tokens',
      'total_tokens',
      'input_tokens_details',
      'output_tokens_details',
    ]) {
      test('rejects Decisions usage missing $field', () {
        final fixture = _responseFixture();
        (fixture['usage'] as Map<String, dynamic>).remove(field);
        expect(() => DecisionResponse.fromJson(fixture), throwsFormatException);
      });
    }

    test('rejects invalid usage counts and non-object detail payloads', () {
      for (final field in ['input_tokens', 'output_tokens', 'total_tokens']) {
        for (final invalid in <Object?>[null, '1', 1.5, true]) {
          final fixture = _responseFixture();
          (fixture['usage'] as Map<String, dynamic>)[field] = invalid;
          expect(
            () => DecisionResponse.fromJson(fixture),
            throwsFormatException,
          );
        }
      }
      for (final field in ['input_tokens_details', 'output_tokens_details']) {
        for (final invalid in <Object?>[null, [], 0]) {
          final fixture = _responseFixture();
          (fixture['usage'] as Map<String, dynamic>)[field] = invalid;
          expect(
            () => DecisionResponse.fromJson(fixture),
            throwsFormatException,
          );
        }
      }
    });

    for (final entry in {
      'input_tokens_details': ['cached_tokens', 'cache_write_tokens'],
      'output_tokens_details': ['reasoning_tokens'],
    }.entries) {
      for (final counter in entry.value) {
        test('rejects missing or invalid Decisions ${entry.key}.$counter', () {
          for (final invalid in <Object?>[null, '0', 0.5, false]) {
            final fixture = _responseFixture();
            final usage = fixture['usage'] as Map<String, dynamic>;
            final details = usage[entry.key] as Map<String, dynamic>;
            if (invalid == null) {
              details.remove(counter);
            } else {
              details[counter] = invalid;
            }
            expect(
              () => DecisionResponse.fromJson(fixture),
              throwsFormatException,
            );
          }
        });
      }
    }
  });

  group('shared cache-write token details', () {
    test(
      'preserves zero, omission, sentinel clearing, equality, and hashing',
      () {
        const details = InputTokensDetails(
          cachedTokens: 3,
          cacheWriteTokens: 0,
        );
        expect(details.toJson(), {'cached_tokens': 3, 'cache_write_tokens': 0});
        expect(InputTokensDetails.fromJson(details.toJson()), details);
        expect(
          InputTokensDetails.fromJson(details.toJson()).hashCode,
          details.hashCode,
        );
        expect(details, isNot(const InputTokensDetails(cachedTokens: 3)));
        expect(details.copyWith(), details);
        expect(details.copyWith(cacheWriteTokens: null).toJson(), {
          'cached_tokens': 3,
        });
        expect(details.copyWith(cachedTokens: null).toJson(), {
          'cache_write_tokens': 0,
        });
        expect(details.toString(), contains('cacheWriteTokens: 0'));
      },
    );

    test(
      'older Responses and provider usage still accept optional details',
      () {
        final basic = ResponseUsage.fromJson(const {
          'input_tokens': 1,
          'output_tokens': 2,
          'total_tokens': 3,
        });
        expect(basic.inputTokensDetails, isNull);
        expect(basic.outputTokensDetails, isNull);

        final emptyDetails = ResponseUsage.fromJson(const {
          'input_tokens': 1,
          'output_tokens': 2,
          'total_tokens': 3,
          'input_tokens_details': <String, dynamic>{},
          'output_tokens_details': <String, dynamic>{},
        });
        expect(emptyDetails.inputTokensDetails!.cachedTokens, isNull);
        expect(emptyDetails.inputTokensDetails!.cacheWriteTokens, isNull);
        expect(emptyDetails.outputTokensDetails!.reasoningTokens, isNull);

        final provider = ResponseUsage.fromJson(const {
          'prompt_tokens': 4,
          'completion_tokens': 2,
          'total_tokens': 6,
          'prompt_tokens_details': {'cached_tokens': 1},
          'completion_tokens_details': {'reasoning_tokens': 0},
        });
        expect(provider.inputTokens, 4);
        expect(provider.inputTokensDetails!.cachedTokens, 1);
        expect(provider.inputTokensDetails!.cacheWriteTokens, isNull);
        expect(provider.outputTokensDetails!.reasoningTokens, 0);
      },
    );
  });
}

Map<String, dynamic> _responseFixture() => {
  'model': 'gpt-6-luna',
  'answers': [
    {'type': 'predicate', 'name': 'damaged', 'probability': 1},
    {
      'type': 'choice',
      'name': 'category',
      'choice': true,
      'confidence': 1,
      'probabilities': [
        {'value': 'true', 'probability': 0},
        {'value': true, 'probability': 1},
      ],
    },
    {
      'type': 'score',
      'name': 'urgency',
      'score': 0.75,
      'confidence': 0.9,
      'probabilities': [
        {'value': 0, 'label': 'low', 'probability': 0.25},
        {'value': 1, 'label': 'high', 'probability': 0.75},
      ],
    },
    {'type': 'refusal', 'name': null},
  ],
  'usage': <String, dynamic>{
    'input_tokens': 10,
    'output_tokens': 2,
    'total_tokens': 12,
    'input_tokens_details': <String, dynamic>{
      'cached_tokens': 0,
      'cache_write_tokens': 4,
    },
    'output_tokens_details': <String, dynamic>{'reasoning_tokens': 0},
  },
};

Map<String, dynamic> _clone(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
