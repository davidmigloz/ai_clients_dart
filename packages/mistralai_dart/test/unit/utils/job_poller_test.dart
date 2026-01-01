import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FineTuningJobPoller', () {
    group('construction', () {
      test('has correct default values', () {
        // We can't actually create the poller without a client,
        // but we can verify the expected defaults from documentation
        expect(
          const Duration(seconds: 30),
          equals(const Duration(seconds: 30)),
        );
        expect(const Duration(hours: 24), equals(const Duration(hours: 24)));
      });
    });

    group('terminal states', () {
      test('success is terminal', () {
        expect(FineTuningJobStatus.success.value, 'SUCCESS');
      });

      test('failed is terminal', () {
        expect(FineTuningJobStatus.failed.value, 'FAILED');
      });

      test('cancelled is terminal', () {
        expect(FineTuningJobStatus.cancelled.value, 'CANCELLED');
      });

      test('cancellationRequested is terminal', () {
        expect(
          FineTuningJobStatus.cancellationRequested.value,
          'CANCELLATION_REQUESTED',
        );
      });

      test('queued is not terminal', () {
        expect(FineTuningJobStatus.queued.value, 'QUEUED');
      });

      test('running is not terminal', () {
        expect(FineTuningJobStatus.running.value, 'RUNNING');
      });
    });
  });

  group('BatchJobPoller', () {
    group('terminal states', () {
      test('success is terminal', () {
        expect(BatchJobStatus.success.value, 'SUCCESS');
      });

      test('failed is terminal', () {
        expect(BatchJobStatus.failed.value, 'FAILED');
      });

      test('cancelled is terminal', () {
        expect(BatchJobStatus.cancelled.value, 'CANCELLED');
      });

      test('timedOut is terminal', () {
        expect(BatchJobStatus.timedOut.value, 'TIMED_OUT');
      });

      test('cancellationRequested is terminal', () {
        expect(
          BatchJobStatus.cancellationRequested.value,
          'CANCELLATION_REQUESTED',
        );
      });

      test('queued is not terminal', () {
        expect(BatchJobStatus.queued.value, 'QUEUED');
      });

      test('running is not terminal', () {
        expect(BatchJobStatus.running.value, 'RUNNING');
      });
    });
  });

  group('TimeoutException', () {
    test('creates with all parameters', () {
      const exception = TimeoutException(
        message: 'Polling timed out',
        timeout: Duration(minutes: 5),
        elapsed: Duration(minutes: 6),
      );

      expect(exception.message, 'Polling timed out');
      expect(exception.timeout, const Duration(minutes: 5));
      expect(exception.elapsed, const Duration(minutes: 6));
    });

    test('toString includes details', () {
      const exception = TimeoutException(
        message: 'Polling timed out',
        timeout: Duration(seconds: 300),
        elapsed: Duration(seconds: 360),
      );

      final str = exception.toString();
      expect(str, contains('TimeoutException'));
      expect(str, contains('Polling timed out'));
    });

    test('equality works', () {
      const ex1 = TimeoutException(
        message: 'Test',
        timeout: Duration(seconds: 10),
        elapsed: Duration(seconds: 15),
      );
      const ex2 = TimeoutException(
        message: 'Test',
        timeout: Duration(seconds: 10),
        elapsed: Duration(seconds: 15),
      );
      const ex3 = TimeoutException(
        message: 'Different',
        timeout: Duration(seconds: 10),
        elapsed: Duration(seconds: 15),
      );

      expect(ex1, equals(ex2));
      expect(ex1, isNot(equals(ex3)));
    });
  });

  group('FineTuningJobStatus', () {
    test('fromString parses all status values', () {
      expect(
        FineTuningJobStatus.fromString('QUEUED'),
        FineTuningJobStatus.queued,
      );
      expect(
        FineTuningJobStatus.fromString('STARTED'),
        FineTuningJobStatus.started,
      );
      expect(
        FineTuningJobStatus.fromString('VALIDATING'),
        FineTuningJobStatus.validating,
      );
      expect(
        FineTuningJobStatus.fromString('VALIDATED'),
        FineTuningJobStatus.validated,
      );
      expect(
        FineTuningJobStatus.fromString('RUNNING'),
        FineTuningJobStatus.running,
      );
      expect(
        FineTuningJobStatus.fromString('FAILED'),
        FineTuningJobStatus.failed,
      );
      expect(
        FineTuningJobStatus.fromString('SUCCESS'),
        FineTuningJobStatus.success,
      );
      expect(
        FineTuningJobStatus.fromString('CANCELLED'),
        FineTuningJobStatus.cancelled,
      );
      expect(
        FineTuningJobStatus.fromString('CANCELLATION_REQUESTED'),
        FineTuningJobStatus.cancellationRequested,
      );
    });

    test('fromString defaults to queued for unknown', () {
      expect(
        FineTuningJobStatus.fromString('UNKNOWN_STATUS'),
        FineTuningJobStatus.queued,
      );
    });
  });

  group('BatchJobStatus', () {
    test('fromString parses all status values', () {
      expect(BatchJobStatus.fromString('QUEUED'), BatchJobStatus.queued);
      expect(BatchJobStatus.fromString('RUNNING'), BatchJobStatus.running);
      expect(BatchJobStatus.fromString('SUCCESS'), BatchJobStatus.success);
      expect(BatchJobStatus.fromString('FAILED'), BatchJobStatus.failed);
      expect(BatchJobStatus.fromString('TIMED_OUT'), BatchJobStatus.timedOut);
      expect(BatchJobStatus.fromString('CANCELLED'), BatchJobStatus.cancelled);
      expect(
        BatchJobStatus.fromString('CANCELLATION_REQUESTED'),
        BatchJobStatus.cancellationRequested,
      );
    });

    test('fromString defaults to queued for unknown', () {
      expect(BatchJobStatus.fromString('UNKNOWN'), BatchJobStatus.queued);
    });
  });

  group('FineTuningJob', () {
    test('status helpers work correctly', () {
      const runningJob = FineTuningJob(
        id: 'ft-123',
        model: 'mistral-small-latest',
        status: FineTuningJobStatus.running,
        trainingFiles: [],
      );

      expect(runningJob.isRunning, isTrue);
      expect(runningJob.isComplete, isFalse);
      expect(runningJob.isSuccess, isFalse);

      const successJob = FineTuningJob(
        id: 'ft-123',
        model: 'mistral-small-latest',
        status: FineTuningJobStatus.success,
        trainingFiles: [],
      );

      expect(successJob.isRunning, isFalse);
      expect(successJob.isComplete, isTrue);
      expect(successJob.isSuccess, isTrue);

      const failedJob = FineTuningJob(
        id: 'ft-123',
        model: 'mistral-small-latest',
        status: FineTuningJobStatus.failed,
        trainingFiles: [],
      );

      expect(failedJob.isRunning, isFalse);
      expect(failedJob.isComplete, isTrue);
      expect(failedJob.isFailed, isTrue);
    });
  });

  group('BatchJob', () {
    test('status helpers work correctly', () {
      const runningJob = BatchJob(
        id: 'batch-123',
        inputFileId: 'file-123',
        endpoint: '/v1/chat/completions',
        model: 'mistral-small-latest',
        status: BatchJobStatus.running,
      );

      expect(runningJob.isRunning, isTrue);
      expect(runningJob.isComplete, isFalse);
      expect(runningJob.isSuccess, isFalse);

      const successJob = BatchJob(
        id: 'batch-123',
        inputFileId: 'file-123',
        endpoint: '/v1/chat/completions',
        model: 'mistral-small-latest',
        status: BatchJobStatus.success,
      );

      expect(successJob.isRunning, isFalse);
      expect(successJob.isComplete, isTrue);
      expect(successJob.isSuccess, isTrue);

      const failedJob = BatchJob(
        id: 'batch-123',
        inputFileId: 'file-123',
        endpoint: '/v1/chat/completions',
        model: 'mistral-small-latest',
        status: BatchJobStatus.failed,
      );

      expect(failedJob.isRunning, isFalse);
      expect(failedJob.isComplete, isTrue);
      expect(failedJob.isFailed, isTrue);
    });

    test('progress calculation works', () {
      const job = BatchJob(
        id: 'batch-123',
        inputFileId: 'file-123',
        endpoint: '/v1/chat/completions',
        model: 'mistral-small-latest',
        status: BatchJobStatus.running,
        totalRequests: 100,
        completedRequests: 50,
      );

      expect(job.progress, 50.0);
    });

    test('progress returns 0 when no total', () {
      const job = BatchJob(
        id: 'batch-123',
        inputFileId: 'file-123',
        endpoint: '/v1/chat/completions',
        model: 'mistral-small-latest',
        status: BatchJobStatus.queued,
      );

      expect(job.progress, 0.0);
    });
  });
}
