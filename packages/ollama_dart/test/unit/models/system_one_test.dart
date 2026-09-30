import 'dart:convert';

import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  const instructions = SystemOneContent.string('Choose an outcome.');

  group('SystemOneContent', () {
    test('round-trips text, object, and arbitrary nested array values', () {
      for (final value in <Object>[
        'Ticket text',
        <String, dynamic>{
          'ticket': 'Refund €20',
          'details': [true, null, 1, 0.5],
        },
        <Object?>[
          {
            'frames': ['first', 'second'],
          },
          null,
          false,
        ],
        <String, dynamic>{},
        <Object?>[],
      ]) {
        final content = SystemOneContent.fromJson(value);
        expect(content.toJson(), value);
        final copy = SystemOneContent.fromJson(jsonDecode(jsonEncode(value)));
        expect(content, copy);
        expect(content.hashCode, copy.hashCode);
      }
      expect(SystemOneContent.fromJson('x'), isA<SystemOneStringContent>());
      expect(
        SystemOneContent.fromJson(const {}),
        isA<SystemOneObjectContent>(),
      );
      expect(SystemOneContent.fromJson(const []), isA<SystemOneArrayContent>());
    });

    test('validates root shape and nested JSON values', () {
      for (final value in <Object?>[null, true, 42, 1.5]) {
        expect(() => SystemOneContent.fromJson(value), throwsFormatException);
      }
      expect(
        () => SystemOneContent.object(const {'bad': Object()}),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('SystemOneObjectContent.value.bad'),
          ),
        ),
      );
      expect(
        () => SystemOneContent.array(const [double.nan]),
        throwsFormatException,
      );
    });

    test('defensively copies and freezes nested collections', () {
      final nested = <String, dynamic>{
        'items': <Object?>[1, 2],
      };
      final content =
          SystemOneContent.object({'nested': nested}) as SystemOneObjectContent;
      (nested['items'] as List<Object?>).add(3);
      nested['new'] = true;
      expect(content.toJson(), {
        'nested': {
          'items': [1, 2],
        },
      });
      expect(() => content.value['new'] = true, throwsUnsupportedError);
      final stored = content.value['nested'] as Map<String, dynamic>;
      expect(() => stored['new'] = true, throwsUnsupportedError);
      expect(
        () => (stored['items'] as List<Object?>).add(3),
        throwsUnsupportedError,
      );

      final values = <Object?>[nested];
      final array = SystemOneContent.array(values) as SystemOneArrayContent;
      values.clear();
      expect(array.values, hasLength(1));
      expect(() => array.values.add(null), throwsUnsupportedError);
    });

    test('concrete variants validate shape and support replacement copies', () {
      const text = SystemOneStringContent('one');
      expect(text.copyWith(value: 'two'), const SystemOneStringContent('two'));
      final object = SystemOneObjectContent(const {'a': 1});
      expect(object.copyWith(value: {'b': 2}).value, {'b': 2});
      final array = SystemOneArrayContent(const [1]);
      expect(array.copyWith(values: [2]).values, [2]);
      expect(() => SystemOneStringContent.fromJson(1), throwsFormatException);
      expect(
        () => SystemOneObjectContent.fromJson(const []),
        throwsFormatException,
      );
      expect(
        () => SystemOneArrayContent.fromJson(const {}),
        throwsFormatException,
      );
    });
  });

  group('SystemOneQuestion', () {
    test(
      'round-trips mixed questions and preserves null choice descriptions',
      () {
        final choice = SystemOneQuestion.choice(
          instructions: instructions,
          criteria: const {'billing': 'Charges', 'technical': null},
        );
        const noul = SystemOneQuestion.noul(
          instructions: instructions,
          criteria: SystemOneNoulCriteria(trueDescription: 'Refund requested'),
        );
        final score = SystemOneQuestion.score(
          instructions: SystemOneContent.array(const ['Consider the ticket']),
          criteria: const ['Routine', 'Urgent', 'Emergency'],
        );
        for (final question in [choice, noul, score]) {
          final copy = SystemOneQuestion.fromJson(question.toJson());
          expect(copy, question);
          expect(copy.hashCode, question.hashCode);
        }
        expect(choice, isA<SystemOneChoiceQuestion>());
        expect(noul, isA<SystemOneNoulQuestion>());
        expect(score, isA<SystemOneScoreQuestion>());
        expect(choice.toJson(), {
          'type': 'choice',
          'instructions': 'Choose an outcome.',
          'criteria': {'billing': 'Charges', 'technical': null},
        });
        expect(noul.toJson()['criteria'], {'true': 'Refund requested'});
      },
    );

    test('choice equality retains order, criteria are immutable', () {
      final criteria = <String, String?>{'a': null, 'b': 'Bee'};
      final question = SystemOneChoiceQuestion(
        instructions: instructions,
        criteria: criteria,
      );
      final same = question.copyWith();
      final reversed = question.copyWith(criteria: {'b': 'Bee', 'a': null});
      expect(question, same);
      expect(question.hashCode, same.hashCode);
      expect(question, isNot(reversed));
      expect((question.toJson()['criteria'] as Map<String, dynamic>).keys, [
        'a',
        'b',
      ]);
      criteria.clear();
      expect(question.criteria, hasLength(2));
      expect(question.criteria.clear, throwsUnsupportedError);
      expect(question.copyWith(criteria: {}).criteria, isEmpty);
    });

    test('score criteria copy and equality retain list order', () {
      final criteria = ['low', 'high'];
      final question = SystemOneScoreQuestion(
        instructions: instructions,
        criteria: criteria,
      );
      criteria.clear();
      expect(question.criteria, ['low', 'high']);
      expect(question, question.copyWith());
      expect(question.hashCode, question.copyWith().hashCode);
      expect(question, isNot(question.copyWith(criteria: ['high', 'low'])));
      expect(() => question.criteria.add('other'), throwsUnsupportedError);
    });

    test('Noul omission, empty and partial criteria have distinct JSON', () {
      const question = SystemOneNoulQuestion(instructions: instructions);
      expect(question.toJson().containsKey('criteria'), isFalse);
      expect(
        question.copyWith(criteria: const SystemOneNoulCriteria()).toJson(),
        {
          'type': 'noul',
          'instructions': instructions.toJson(),
          'criteria': <String, dynamic>{},
        },
      );
      const criteria = SystemOneNoulCriteria(
        falseDescription: 'No refund',
        trueDescription: 'Refund',
      );
      expect(criteria, SystemOneNoulCriteria.fromJson(criteria.toJson()));
      expect(
        criteria.hashCode,
        SystemOneNoulCriteria.fromJson(criteria.toJson()).hashCode,
      );
      expect(criteria.copyWith(falseDescription: null).toJson(), {
        'true': 'Refund',
      });
      expect(criteria.copyWith(trueDescription: null).toJson(), {
        'false': 'No refund',
      });
      expect(
        question.copyWith(criteria: criteria).copyWith(criteria: null),
        question,
      );
      for (final json in <Map<String, dynamic>>[
        {'false': null},
        {'true': true},
        {'yes': 'Yes'},
      ]) {
        expect(
          () => SystemOneNoulCriteria.fromJson(json),
          throwsFormatException,
        );
      }
      expect(
        () => SystemOneNoulQuestion.fromJson(const {
          'type': 'noul',
          'instructions': 'q',
          'criteria': null,
        }),
        throwsFormatException,
      );
    });

    test(
      'known variants reject mismatched discriminators and malformed fields',
      () {
        expect(
          () => SystemOneChoiceQuestion.fromJson(const {'type': 'noul'}),
          throwsFormatException,
        );
        expect(
          () => SystemOneNoulQuestion.fromJson(const {'type': 'score'}),
          throwsFormatException,
        );
        expect(
          () => SystemOneScoreQuestion.fromJson(const {'type': 'choice'}),
          throwsFormatException,
        );
        for (final json in <Map<String, dynamic>>[
          {'type': 'choice', 'instructions': 'q'},
          {
            'type': 'choice',
            'instructions': true,
            'criteria': <String, dynamic>{},
          },
          {
            'type': 'choice',
            'instructions': 'q',
            'criteria': {'a': 1},
          },
          {'type': 'noul'},
          {
            'type': 'score',
            'instructions': 'q',
            'criteria': <String, dynamic>{},
          },
          {
            'type': 'score',
            'instructions': 'q',
            'criteria': ['a', null],
          },
        ]) {
          expect(() => SystemOneQuestion.fromJson(json), throwsFormatException);
        }
      },
    );

    test('unknown questions preserve raw nested JSON and deep equality', () {
      final raw = <String, dynamic>{
        'type': 'future',
        'new': {
          'values': [1, null],
        },
      };
      final unknown =
          SystemOneQuestion.fromJson(raw) as SystemOneUnknownQuestion;
      expect(unknown.type, 'future');
      expect(unknown.toJson(), raw);
      expect(
        unknown,
        SystemOneQuestion.fromJson(
          jsonDecode(jsonEncode(raw)) as Map<String, dynamic>,
        ),
      );
      expect(unknown.hashCode, unknown.copyWith().hashCode);
      raw['new'] = false;
      expect(unknown.toJson()['new'], {
        'values': [1, null],
      });
      expect(unknown.rawJson.clear, throwsUnsupportedError);
      expect(unknown.copyWith(rawJson: {'type': 'new'}).type, 'new');
      expect(
        SystemOneQuestion.unknown(const {'type': 'new'}),
        isA<SystemOneUnknownQuestion>(),
      );
      for (final json in <Map<String, dynamic>>[
        {},
        {'type': null},
        {'type': 1},
      ]) {
        expect(() => SystemOneQuestion.fromJson(json), throwsFormatException);
        expect(() => SystemOneUnknownQuestion(json), throwsFormatException);
        expect(
          () => SystemOneUnknownQuestion.fromJson(json),
          throwsFormatException,
        );
      }
    });

    test('leaves blank text and candidate limits to the server', () {
      final choice = SystemOneQuestion.choice(
        instructions: const SystemOneContent.string(' '),
        criteria: const {'': ''},
      );
      expect(choice.toJson()['criteria'], {'': ''});
      final score = SystemOneQuestion.score(
        instructions: instructions,
        criteria: const [],
      );
      expect(score.toJson()['criteria'], isEmpty);
    });
  });

  group('SystemOneRequest', () {
    SystemOneRequest request({KeepAlive? keepAlive}) => SystemOneRequest(
      model: 'nimble',
      state: SystemOneContent.object(const {'ticket': 'Refund'}),
      questions: {
        'refund': const SystemOneQuestion.noul(instructions: instructions),
        'urgency': SystemOneQuestion.score(
          instructions: instructions,
          criteria: const ['low', 'high'],
        ),
      },
      keepAlive: keepAlive,
    );

    test('round-trips structured state, ordered questions and keep-alive', () {
      for (final keepAlive in <KeepAlive?>[
        null,
        const KeepAlive.duration('5m'),
        const KeepAlive.number(0),
        const KeepAlive.number(-1),
        const KeepAlive.number(1.5),
      ]) {
        final original = request(keepAlive: keepAlive);
        final copy = SystemOneRequest.fromJson(original.toJson());
        expect(copy, original);
        expect(copy.hashCode, original.hashCode);
        expect(copy.questions.keys, ['refund', 'urgency']);
        expect(copy.toJson()['state'], isA<Map<String, dynamic>>());
        expect(copy.toJson().containsKey('keep_alive'), keepAlive != null);
      }
      expect(
        request(keepAlive: const KeepAlive.number(0)).copyWith(keepAlive: null),
        request(),
      );
      expect(request().copyWith(model: 'tev1').model, 'tev1');
    });

    test(
      'question maps are copied and equality distinguishes request order',
      () {
        final original = request();
        final map = Map<String, SystemOneQuestion>.of(original.questions);
        final copied = original.copyWith(questions: map);
        map.clear();
        expect(copied, original);
        expect(copied.questions.clear, throwsUnsupportedError);
        final reversed = original.copyWith(
          questions: {
            'urgency': original.questions['urgency']!,
            'refund': original.questions['refund']!,
          },
        );
        expect(original, isNot(reversed));
        final encoded = jsonEncode(original.toJson());
        expect(encoded.indexOf('refund'), lessThan(encoded.indexOf('urgency')));
      },
    );

    test('malformed request fields report contextual FormatException', () {
      final json = request().toJson();
      for (final entry in <String, Object?>{
        'model': null,
        'state': true,
        'questions': [],
        'keep_alive': false,
      }.entries) {
        expect(
          () => SystemOneRequest.fromJson({...json, entry.key: entry.value}),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('SystemOneRequest.${entry.key}'),
            ),
          ),
        );
      }
      expect(
        () => SystemOneRequest.fromJson({
          ...json,
          'questions': const {'bad': 1},
        }),
        throwsFormatException,
      );
    });
  });

  group('SystemOneAnswer and SystemOneResponse', () {
    final responseJson = <String, dynamic>{
      'model': 'nimble',
      'answers': {
        'team': {
          'type': 'choice',
          'choice': 'technical',
          'probabilities': {'billing': 0, 'technical': 1},
          'confidence': 1,
        },
        'refund': {'type': 'noul', 'noul': 1},
        'urgency': {
          'type': 'score',
          'score': 1.25,
          'legend': {'0': 'Routine', '1': 'Urgent', '2': 'Emergency'},
          'probabilities': {'0': 0, '1': 0.75, '2': 0.25},
          'confidence': 0.5,
        },
      },
      'usage': {'input_tokens': 900, 'output_tokens': 7},
    };

    test(
      'decodes all variants and integer numeric values without altering scores',
      () {
        final response = SystemOneResponse.fromJson(responseJson);
        final choice = response.answers['team']! as SystemOneChoiceAnswer;
        final noul = response.answers['refund']! as SystemOneNoulAnswer;
        final score = response.answers['urgency']! as SystemOneScoreAnswer;
        expect(choice.choice, 'technical');
        expect(choice.probabilities['technical'], 1.0);
        expect(choice.confidence, 1.0);
        expect(noul.noul, 1.0);
        expect(score.score, 1.25);
        expect(score.legend.keys, ['0', '1', '2']);
        expect(
          response.usage,
          const SystemOneUsage(inputTokens: 900, outputTokens: 7),
        );
        final copy = SystemOneResponse.fromJson(response.toJson());
        expect(response, copy);
        expect(response.hashCode, copy.hashCode);
        expect(response, response.copyWith());
        expect(response.copyWith(model: 'tev1').model, 'tev1');
        expect(choice, choice.copyWith());
        expect(score, score.copyWith());
        expect(noul.copyWith(noul: 0.2), const SystemOneAnswer.noul(noul: 0.2));
        expect(
          SystemOneAnswer.choice(
            choice: 'a',
            probabilities: const {'a': 1},
            confidence: 1,
          ),
          isA<SystemOneChoiceAnswer>(),
        );
        expect(
          SystemOneAnswer.score(
            score: 0.5,
            legend: const {'0': 'low'},
            probabilities: const {'0': 1},
            confidence: 1,
          ),
          isA<SystemOneScoreAnswer>(),
        );
        expect(
          response.usage.copyWith(inputTokens: 1, outputTokens: 0),
          const SystemOneUsage(inputTokens: 1, outputTokens: 0),
        );
      },
    );

    test('copies and freezes answer and response collections', () {
      final probabilities = <String, double>{'a': 1};
      final choice = SystemOneChoiceAnswer(
        choice: 'a',
        probabilities: probabilities,
        confidence: 1,
      );
      probabilities.clear();
      expect(choice.probabilities, {'a': 1});
      expect(choice.probabilities.clear, throwsUnsupportedError);
      final legend = {'0': 'low'};
      final score = SystemOneScoreAnswer(
        score: 0,
        legend: legend,
        probabilities: const {'0': 1},
        confidence: 1,
      );
      legend.clear();
      expect(score.legend, {'0': 'low'});
      expect(score.legend.clear, throwsUnsupportedError);
      expect(score.probabilities.clear, throwsUnsupportedError);
      final answers = <String, SystemOneAnswer>{'a': choice};
      final response = SystemOneResponse(
        model: 'nimble',
        answers: answers,
        usage: const SystemOneUsage(inputTokens: 1, outputTokens: 0),
      );
      answers.clear();
      expect(response.answers, hasLength(1));
      expect(response.answers.clear, throwsUnsupportedError);
    });

    test(
      'unknown answers round-trip nested raw JSON and retain deep equality',
      () {
        final raw = <String, dynamic>{
          'type': 'future',
          'value': {
            'scores': [1, 2],
          },
        };
        final answer = SystemOneAnswer.fromJson(raw) as SystemOneUnknownAnswer;
        final copy = SystemOneUnknownAnswer.fromJson(
          jsonDecode(jsonEncode(raw)) as Map<String, dynamic>,
        );
        expect(answer.toJson(), raw);
        expect(answer.type, 'future');
        expect(answer, copy);
        expect(answer.hashCode, copy.hashCode);
        expect(answer, answer.copyWith());
        expect(answer.copyWith(rawJson: {'type': 'updated'}).type, 'updated');
        raw['value'] = null;
        expect(answer.rawJson['value'], {
          'scores': [1, 2],
        });
        expect(answer.rawJson.clear, throwsUnsupportedError);
        expect(
          SystemOneAnswer.unknown(const {'type': 'new'}),
          isA<SystemOneUnknownAnswer>(),
        );
        for (final json in <Map<String, dynamic>>[
          {},
          {'type': null},
          {'type': 1},
        ]) {
          expect(() => SystemOneAnswer.fromJson(json), throwsFormatException);
          expect(() => SystemOneUnknownAnswer(json), throwsFormatException);
          expect(
            () => SystemOneUnknownAnswer.fromJson(json),
            throwsFormatException,
          );
        }
        final response = SystemOneResponse.fromJson({
          ...responseJson,
          'answers': {'future': answer.toJson()},
        });
        expect(response.answers['future'], answer);
      },
    );

    test('validates concrete discriminators and required answer shapes', () {
      expect(
        () => SystemOneChoiceAnswer.fromJson(const {'type': 'noul'}),
        throwsFormatException,
      );
      expect(
        () => SystemOneNoulAnswer.fromJson(const {'type': 'choice'}),
        throwsFormatException,
      );
      expect(
        () => SystemOneScoreAnswer.fromJson(const {'type': 'noul'}),
        throwsFormatException,
      );
      for (final json in <Map<String, dynamic>>[
        {
          'type': 'choice',
          'choice': 'a',
          'probabilities': {'a': 'bad'},
          'confidence': 1,
        },
        {
          'type': 'choice',
          'choice': 'a',
          'probabilities': {'a': 1},
        },
        {'type': 'noul', 'noul': true},
        {'type': 'noul'},
        {
          'type': 'score',
          'score': 1,
          'legend': {'0': 1},
          'probabilities': <String, dynamic>{},
          'confidence': 0,
        },
        {
          'type': 'score',
          'score': 1,
          'legend': <String, dynamic>{},
          'probabilities': <Object?>[],
          'confidence': 0,
        },
      ]) {
        expect(() => SystemOneAnswer.fromJson(json), throwsFormatException);
      }
    });

    test('required response and usage shapes never silently default', () {
      for (final entry in <String, Object?>{
        'model': null,
        'answers': [],
        'usage': null,
      }.entries) {
        expect(
          () => SystemOneResponse.fromJson({
            ...responseJson,
            entry.key: entry.value,
          }),
          throwsFormatException,
        );
      }
      expect(
        () => SystemOneResponse.fromJson({
          ...responseJson,
          'answers': const {'bad': 1},
        }),
        throwsFormatException,
      );
      for (final json in <Map<String, dynamic>>[
        {'input_tokens': 1},
        {'input_tokens': 1, 'output_tokens': 1.5},
        {'input_tokens': null, 'output_tokens': 1},
      ]) {
        expect(() => SystemOneUsage.fromJson(json), throwsFormatException);
      }
    });
  });
}
