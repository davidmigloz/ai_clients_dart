import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('BatchJobStatus', () {
    test('has correct string values', () {
      expect(BatchJobStatus.queued.value, 'QUEUED');
      expect(BatchJobStatus.running.value, 'RUNNING');
      expect(BatchJobStatus.success.value, 'SUCCESS');
      expect(BatchJobStatus.failed.value, 'FAILED');
      expect(BatchJobStatus.timedOut.value, 'TIMED_OUT');
      expect(BatchJobStatus.cancelled.value, 'CANCELLED');
      expect(
        BatchJobStatus.cancellationRequested.value,
        'CANCELLATION_REQUESTED',
      );
    });

    group('fromString', () {
      test('parses valid status strings', () {
        expect(BatchJobStatus.fromString('QUEUED'), BatchJobStatus.queued);
        expect(BatchJobStatus.fromString('RUNNING'), BatchJobStatus.running);
        expect(BatchJobStatus.fromString('SUCCESS'), BatchJobStatus.success);
        expect(BatchJobStatus.fromString('FAILED'), BatchJobStatus.failed);
        expect(BatchJobStatus.fromString('TIMED_OUT'), BatchJobStatus.timedOut);
        expect(
          BatchJobStatus.fromString('CANCELLED'),
          BatchJobStatus.cancelled,
        );
        expect(
          BatchJobStatus.fromString('CANCELLATION_REQUESTED'),
          BatchJobStatus.cancellationRequested,
        );
      });

      test('returns queued for unknown values', () {
        expect(BatchJobStatus.fromString('UNKNOWN'), BatchJobStatus.queued);
        expect(BatchJobStatus.fromString(''), BatchJobStatus.queued);
        expect(BatchJobStatus.fromString('invalid'), BatchJobStatus.queued);
      });
    });
  });
}
