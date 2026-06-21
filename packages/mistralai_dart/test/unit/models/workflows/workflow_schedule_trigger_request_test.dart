import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowScheduleTriggerRequest', () {
    test('fromJson parses overlap', () {
      final request = WorkflowScheduleTriggerRequest.fromJson(const {
        'overlap': 1,
      });

      expect(request.overlap, ScheduleOverlapPolicy.skip);
    });

    test('toJson omits null overlap', () {
      const request = WorkflowScheduleTriggerRequest();

      expect(request.toJson(), <String, dynamic>{});
    });

    test('toJson round-trips with overlap', () {
      const request = WorkflowScheduleTriggerRequest(
        overlap: ScheduleOverlapPolicy.bufferOne,
      );

      expect(request.toJson(), {'overlap': 2});
      expect(
        WorkflowScheduleTriggerRequest.fromJson(request.toJson()),
        equals(request),
      );
    });

    test('copyWith clears overlap', () {
      const request = WorkflowScheduleTriggerRequest(
        overlap: ScheduleOverlapPolicy.skip,
      );

      expect(request.copyWith(overlap: null).overlap, isNull);
      expect(request.copyWith().overlap, ScheduleOverlapPolicy.skip);
    });

    test('equality and hashCode', () {
      const a = WorkflowScheduleTriggerRequest(
        overlap: ScheduleOverlapPolicy.skip,
      );
      const b = WorkflowScheduleTriggerRequest(
        overlap: ScheduleOverlapPolicy.skip,
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains overlap', () {
      const request = WorkflowScheduleTriggerRequest(
        overlap: ScheduleOverlapPolicy.skip,
      );

      expect(request.toString(), contains('overlap:'));
    });
  });
}
