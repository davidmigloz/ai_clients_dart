import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OutcomeEvaluation', () {
    test('round-trips with completedAt and explanation set', () {
      final json = {
        'type': 'outcome_evaluation',
        'outcome_id': 'outc_011CZkZRSw2kEfs6ncTVljxP',
        'description': 'Produce a 2-page summary as summary.md',
        'result': 'satisfied',
        'iteration': 0,
        'completed_at': '2026-03-15T10:02:31.000Z',
        'explanation': 'All five sections present with inline citations.',
      };
      final oe = OutcomeEvaluation.fromJson(json);
      expect(oe.outcomeId, 'outc_011CZkZRSw2kEfs6ncTVljxP');
      expect(oe.result, 'satisfied');
      expect(oe.iteration, 0);
      expect(oe.completedAt, isNotNull);
      expect(oe.explanation, contains('five sections'));
      expect(oe.toJson(), json);
    });

    test('round-trips with completedAt and explanation null', () {
      final json = {
        'type': 'outcome_evaluation',
        'outcome_id': 'outc_1',
        'description': 'task',
        'result': 'pending',
        'iteration': 0,
        'completed_at': null,
        'explanation': null,
      };
      final oe = OutcomeEvaluation.fromJson(json);
      expect(oe.completedAt, isNull);
      expect(oe.explanation, isNull);
      expect(oe.toJson(), json);
    });

    test('copyWith clears nullable fields with explicit null', () {
      final oe = OutcomeEvaluation.fromJson(const {
        'type': 'outcome_evaluation',
        'outcome_id': 'outc_1',
        'description': 'task',
        'result': 'satisfied',
        'iteration': 1,
        'completed_at': '2026-03-15T10:02:31.000Z',
        'explanation': 'done',
      });
      final cleared = oe.copyWith(completedAt: null, explanation: null);
      expect(cleared.completedAt, isNull);
      expect(cleared.explanation, isNull);
      // Unspecified fields are preserved.
      expect(cleared.copyWith(result: 'failed').iteration, 1);
    });
  });

  group('Rubric', () {
    test('FileRubric round-trips via dispatch', () {
      final json = {'type': 'file', 'file_id': 'file_011CNha8iCJcU1wXNR6q4V8w'};
      final r = Rubric.fromJson(json);
      expect(r, isA<FileRubric>());
      expect((r as FileRubric).fileId, 'file_011CNha8iCJcU1wXNR6q4V8w');
      expect(r.toJson(), json);
    });

    test('TextRubric round-trips via dispatch', () {
      final json = {'type': 'text', 'content': 'Must cover all five sections.'};
      final r = Rubric.fromJson(json);
      expect(r, isA<TextRubric>());
      expect((r as TextRubric).content, 'Must cover all five sections.');
      expect(r.toJson(), json);
    });

    test('unknown type falls back to UnknownRubric', () {
      final json = {'type': 'mystery', 'foo': 'bar'};
      final r = Rubric.fromJson(json);
      expect(r, isA<UnknownRubric>());
      expect(r.toJson(), json);
    });
  });

  group('RubricParams', () {
    test('FileRubricParams round-trips via dispatch', () {
      final json = {'type': 'file', 'file_id': 'file_1'};
      final r = RubricParams.fromJson(json);
      expect(r, isA<FileRubricParams>());
      expect(r.toJson(), json);
    });

    test('TextRubricParams round-trips via dispatch', () {
      final json = {'type': 'text', 'content': 'rubric body'};
      final r = RubricParams.fromJson(json);
      expect(r, isA<TextRubricParams>());
      expect((r as TextRubricParams).content, 'rubric body');
      expect(r.toJson(), json);
    });

    test('unknown type falls back to UnknownRubricParams', () {
      final json = {'type': 'mystery'};
      final r = RubricParams.fromJson(json);
      expect(r, isA<UnknownRubricParams>());
      expect(r.toJson(), json);
    });
  });
}
