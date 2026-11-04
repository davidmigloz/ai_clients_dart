import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _question(String type) => {
  'type': type,
  'instructions': 'PRIVATE criteria',
  'name': 'PRIVATE question',
  if (type == 'choice')
    'choices': [
      {'value': false, 'description': 'PRIVATE false'},
      {'value': 'false'},
    ],
  if (type == 'score')
    'levels': [
      {'label': 'low'},
      {'label': 'high', 'description': 'PRIVATE high'},
    ],
};

void main() {
  for (final type in ['predicate', 'choice', 'score']) {
    test('$type preserves complete wire/value/copy/future metadata', () {
      final raw = _question(type)
        ..['future'] = <String, dynamic>{
          'list': [1, null],
        };
      final value = LiveDecisionQuestion.fromJson(raw);
      final encoded = value.toJson();
      expect(encoded, raw);
      expect(LiveDecisionQuestion.fromJson(encoded), value);
      expect(LiveDecisionQuestion.fromJson(encoded).hashCode, value.hashCode);
      expect(value.toString(), isNot(contains('PRIVATE')));
      (raw['future'] as Map<String, dynamic>)['list'] = ['changed'];
      expect(value.toJson()['future'], {
        'list': [1, null],
      });
      expect(() => value.rawJson['future'] = null, throwsUnsupportedError);
      final copy = switch (value) {
        LiveDecisionPredicateQuestionParam() => value.copyWith(name: null),
        LiveDecisionChoiceQuestionParam() => value.copyWith(name: null),
        LiveDecisionScoreQuestionParam() => value.copyWith(name: null),
      };
      expect(copy.toJson().containsKey('name'), isFalse);
      expect(copy, isNot(value));
      for (final field in ['type', 'instructions']) {
        expect(
          () => LiveDecisionQuestion.fromJson(_question(type)..remove(field)),
          throwsFormatException,
        );
        expect(
          () => LiveDecisionQuestion.fromJson(_question(type)..[field] = null),
          throwsFormatException,
        );
      }
      expect(
        () => LiveDecisionQuestion.fromJson(_question(type)..['name'] = null),
        throwsFormatException,
      );
    });
  }

  test(
    'native question branches accept unbounded strings beyond standalone limit',
    () {
      final instructions = 'x' * (1048576 + 1);
      for (final type in ['predicate', 'choice', 'score']) {
        final value = LiveDecisionQuestion.fromJson(
          _question(type)..['instructions'] = instructions,
        );
        expect(value.instructions.toJson(), instructions);
      }
      expect(const LiveDecisionInstructions.text('').toJson(), '');
    },
  );

  test(
    'native question parts retain nullable detail and unrestricted JSON policy',
    () {
      final data = <String, dynamic>{'values': List.filled(10001, 'x' * 27)};
      final raw = _question('predicate')
        ..['instructions'] = [
          {'type': 'input_text', 'text': 'PRIVATE text', 'future': 1},
          {
            'type': 'input_image',
            'image_url': 'https://example.invalid/image',
            'detail': null,
          },
          {'type': 'input_json', 'data': data},
        ];
      final parsed = LiveDecisionQuestion.fromJson(raw);
      expect(parsed.toJson(), raw);
      data['values'] = <Object?>[];
      final parts = parsed.toJson()['instructions'] as List<dynamic>;
      expect((parts[2] as Map<String, dynamic>)['data'], {
        'values': List.filled(10001, 'x' * 27),
      });
      expect(parsed.toString(), isNot(contains('PRIVATE')));
    },
  );

  test(
    'native part sequence exceeds standalone aggregate count but rejects invalid kinds',
    () {
      final part = LiveDecisionContentPart.fromJson(const {
        'type': 'input_text',
        'text': '',
      });
      final parts = LiveDecisionInstructions.parts(List.filled(16385, part));
      expect((parts.toJson() as List).length, 16385);
      expect(
        () => LiveDecisionInstructions.parts(const []),
        throwsFormatException,
      );
      expect(
        () => LiveDecisionInstructions.fromJson(const [
          {'type': 'output_text', 'text': 'x'},
        ]),
        throwsFormatException,
      );
      expect(
        () => LiveDecisionInstructions.fromJson(const [
          {'type': 'refusal', 'refusal': 'x'},
        ]),
        throwsFormatException,
      );
      expect(
        () => LiveDecisionInstructions.fromJson(true),
        throwsFormatException,
      );
    },
  );

  test('Live group enforces 64 independently of standalone 400', () {
    final question = LiveDecisionQuestion.predicate(
      instructions: const LiveDecisionInstructions.text('condition'),
    );
    final source = List<LiveDecisionQuestion>.filled(
      64,
      question,
      growable: true,
    );
    final group = LiveDecisionQuestionsInputParam(questions: source);
    source.clear();
    expect(group.questions, hasLength(64));
    expect(group.questions.clear, throwsUnsupportedError);
    expect(LiveDecisionQuestionsInputParam.fromJson(group.toJson()), group);
    expect(
      LiveDecisionQuestionsInputParam.fromJson(group.toJson()).hashCode,
      group.hashCode,
    );
    expect(
      () => LiveDecisionQuestionsInputParam(questions: const []),
      throwsFormatException,
    );
    expect(
      () =>
          LiveDecisionQuestionsInputParam(questions: List.filled(65, question)),
      throwsFormatException,
    );
    expect(group.copyWith(questions: [question]).questions, hasLength(1));
    final standalone = DecisionRequest(
      model: 'gpt-6-luna',
      input: const DecisionInput.text('Evidence'),
      questions: List.filled(
        65,
        const DecisionQuestion.predicate(instructions: 'condition'),
      ),
    );
    expect(standalone.questions, hasLength(65));
  });

  test(
    'choices and levels enforce native lengths and preserve primitive values',
    () {
      final choice = LiveDecisionChoiceQuestionParam.fromJson(
        _question('choice'),
      );
      expect(choice.choices[0].toJson()['value'], false);
      expect(choice.choices[1].toJson()['value'], 'false');
      expect(choice.copyWith(), choice);
      for (final count in [0, 1, 256]) {
        expect(
          () => choice.copyWith(
            choices: List.filled(count, choice.choices.first),
          ),
          throwsFormatException,
        );
      }
      expect(
        choice
            .copyWith(choices: List.filled(255, choice.choices.first))
            .choices,
        hasLength(255),
      );
      final score = LiveDecisionScoreQuestionParam.fromJson(_question('score'));
      expect(score.copyWith(), score);
      for (final count in [0, 1, 11]) {
        expect(
          () => score.copyWith(levels: List.filled(count, score.levels.first)),
          throwsFormatException,
        );
      }
      expect(
        score.copyWith(levels: List.filled(10, score.levels.first)).levels,
        hasLength(10),
      );
    },
  );

  test(
    'scalar choice/level copies clear descriptions and retain future metadata',
    () {
      final choice = LiveDecisionChoiceParam.fromJson(const {
        'value': true,
        'description': 'PRIVATE',
        'extra': [1],
      });
      expect(choice.copyWith(), choice);
      expect(choice.copyWith().hashCode, choice.hashCode);
      expect(choice.copyWith(description: null).toJson(), {
        'value': true,
        'extra': [1],
      });
      expect(choice.toString(), isNot(contains('PRIVATE')));
      final level = LiveDecisionScoreLevelParam.fromJson(const {
        'label': '',
        'description': 'PRIVATE',
        'extra': true,
      });
      expect(level.copyWith(), level);
      expect(level.copyWith().hashCode, level.hashCode);
      expect(level.copyWith(description: null).toJson(), {
        'label': '',
        'extra': true,
      });
      expect(level.copyWith(label: 'new'), isNot(level));
      expect(level.toString(), isNot(contains('PRIVATE')));
      expect(
        () => LiveDecisionChoiceParam.fromJson(const {'value': 1}),
        throwsFormatException,
      );
      expect(
        () => LiveDecisionChoiceParam.fromJson(const {
          'value': 'x',
          'description': null,
        }),
        throwsFormatException,
      );
      expect(
        () => LiveDecisionScoreLevelParam.fromJson(const {
          'label': 'x',
          'description': null,
        }),
        throwsFormatException,
      );
    },
  );

  test(
    'question parsing retains open metadata and rejects nonfinite/cyclic JSON',
    () {
      final raw = _question('predicate')..['future'] = double.nan;
      expect(() => LiveDecisionQuestion.fromJson(raw), throwsFormatException);
      raw['future'] = raw;
      expect(() => LiveDecisionQuestion.fromJson(raw), throwsFormatException);
      expect(
        () => LiveDecisionQuestion.fromJson(const {
          'type': 'future',
          'instructions': '',
        }),
        throwsFormatException,
      );
      final adapted = LiveDecisionQuestion.fromDecisionQuestion(
        const DecisionQuestion.predicate(instructions: 'condition'),
      );
      expect(adapted.toJson(), {
        'type': 'predicate',
        'instructions': 'condition',
      });
    },
  );
}
