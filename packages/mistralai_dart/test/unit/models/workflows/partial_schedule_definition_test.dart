import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('PartialScheduleDefinition', () {
    test('fromJson parses fields', () {
      final definition = PartialScheduleDefinition.fromJson(const {
        'input': {'key': 'value'},
        'cron_expressions': ['0 0 * * *'],
        'start_at': '2030-01-01T00:00:00Z',
        'end_at': '2030-02-01T00:00:00Z',
        'jitter': 'PT5M',
        'time_zone_name': 'UTC',
        'max_executions': 10,
        'policy': {'overlap': 1},
        'intervals': [
          {'every': 'PT1H'},
        ],
      });

      expect(definition.input, {'key': 'value'});
      expect(definition.cronExpressions, ['0 0 * * *']);
      expect(definition.startAt, '2030-01-01T00:00:00Z');
      expect(definition.endAt, '2030-02-01T00:00:00Z');
      expect(definition.jitter, 'PT5M');
      expect(definition.timeZoneName, 'UTC');
      expect(definition.maxExecutions, 10);
      expect(definition.policy, isNotNull);
      expect(definition.intervals, hasLength(1));
    });

    test('toJson omits absent fields', () {
      final definition = PartialScheduleDefinition(jitter: 'PT5M');

      expect(definition.toJson(), {'jitter': 'PT5M'});
    });

    test('toJson round-trips', () {
      final definition = PartialScheduleDefinition(
        input: const {'a': 1},
        cronExpressions: const ['0 0 * * *'],
        timeZoneName: 'UTC',
        maxExecutions: 3,
      );

      expect(
        PartialScheduleDefinition.fromJson(definition.toJson()),
        equals(definition),
      );
    });

    test('copyWith replaces and clears values', () {
      final definition = PartialScheduleDefinition(
        jitter: 'PT5M',
        maxExecutions: 5,
      );

      expect(definition.copyWith(jitter: 'PT10M').jitter, 'PT10M');
      expect(definition.copyWith(maxExecutions: null).maxExecutions, isNull);
      expect(definition.copyWith().jitter, 'PT5M');
    });

    test('equality and hashCode use deep input comparison', () {
      final a = PartialScheduleDefinition(
        input: const {'k': 'v'},
        jitter: 'PT5M',
      );
      final b = PartialScheduleDefinition(
        input: const {'k': 'v'},
        jitter: 'PT5M',
      );
      final c = PartialScheduleDefinition(
        input: const {'k': 'x'},
        jitter: 'PT5M',
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString contains key fields', () {
      final definition = PartialScheduleDefinition(jitter: 'PT5M');

      expect(definition.toString(), contains('jitter: PT5M'));
    });
  });
}
