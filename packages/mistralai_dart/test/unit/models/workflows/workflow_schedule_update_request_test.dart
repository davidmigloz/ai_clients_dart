import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowScheduleUpdateRequest', () {
    test('fromJson parses nested schedule', () {
      final request = WorkflowScheduleUpdateRequest.fromJson(const {
        'schedule': {'jitter': 'PT5M', 'max_executions': 3},
      });

      expect(request.schedule.jitter, 'PT5M');
      expect(request.schedule.maxExecutions, 3);
    });

    test('toJson nests the schedule', () {
      final request = WorkflowScheduleUpdateRequest(
        schedule: PartialScheduleDefinition(jitter: 'PT5M'),
      );

      expect(request.toJson(), {
        'schedule': {'jitter': 'PT5M'},
      });
    });

    test('toJson round-trips', () {
      final request = WorkflowScheduleUpdateRequest(
        schedule: PartialScheduleDefinition(
          jitter: 'PT5M',
          timeZoneName: 'UTC',
        ),
      );

      expect(
        WorkflowScheduleUpdateRequest.fromJson(request.toJson()),
        equals(request),
      );
    });

    test('copyWith replaces the schedule', () {
      final request = WorkflowScheduleUpdateRequest(
        schedule: PartialScheduleDefinition(jitter: 'PT5M'),
      );
      final updated = request.copyWith(
        schedule: PartialScheduleDefinition(jitter: 'PT10M'),
      );

      expect(updated.schedule.jitter, 'PT10M');
      expect(request.copyWith().schedule.jitter, 'PT5M');
    });

    test('equality and hashCode', () {
      final a = WorkflowScheduleUpdateRequest(
        schedule: PartialScheduleDefinition(jitter: 'PT5M'),
      );
      final b = WorkflowScheduleUpdateRequest(
        schedule: PartialScheduleDefinition(jitter: 'PT5M'),
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains schedule', () {
      final request = WorkflowScheduleUpdateRequest(
        schedule: PartialScheduleDefinition(jitter: 'PT5M'),
      );

      expect(request.toString(), contains('schedule'));
    });
  });
}
