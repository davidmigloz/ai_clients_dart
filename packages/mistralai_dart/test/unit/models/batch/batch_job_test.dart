import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('BatchJob', () {
    group('fromJson', () {
      test('parses minimal job', () {
        final json = {
          'id': 'batch-123',
          'input_file_id': 'file-abc',
          'endpoint': '/v1/chat/completions',
          'model': 'mistral-small-latest',
          'status': 'QUEUED',
        };

        final job = BatchJob.fromJson(json);

        expect(job.id, 'batch-123');
        expect(job.object, 'batch');
        expect(job.inputFileId, 'file-abc');
        expect(job.endpoint, '/v1/chat/completions');
        expect(job.model, 'mistral-small-latest');
        expect(job.status, BatchJobStatus.queued);
        expect(job.outputFileId, isNull);
        expect(job.errorFileId, isNull);
        expect(job.errors, isEmpty);
      });

      test('parses full job with all fields', () {
        final json = {
          'id': 'batch-456',
          'object': 'batch',
          'input_file_id': 'file-input',
          'endpoint': '/v1/embeddings',
          'model': 'mistral-embed',
          'output_file_id': 'file-output',
          'error_file_id': 'file-errors',
          'status': 'SUCCESS',
          'total_requests': 100,
          'completed_requests': 100,
          'succeeded_requests': 98,
          'failed_requests': 2,
          'started_at': '2024-01-15T10:00:00Z',
          'completed_at': '2024-01-15T10:30:00Z',
          'created_at': '2024-01-15T09:00:00Z',
          'errors': [
            {'code': 'invalid_input', 'message': 'Missing field', 'count': 2},
          ],
          'metadata': {'project': 'test'},
        };

        final job = BatchJob.fromJson(json);

        expect(job.id, 'batch-456');
        expect(job.object, 'batch');
        expect(job.inputFileId, 'file-input');
        expect(job.endpoint, '/v1/embeddings');
        expect(job.model, 'mistral-embed');
        expect(job.outputFileId, 'file-output');
        expect(job.errorFileId, 'file-errors');
        expect(job.status, BatchJobStatus.success);
        expect(job.totalRequests, 100);
        expect(job.completedRequests, 100);
        expect(job.succeededRequests, 98);
        expect(job.failedRequests, 2);
        expect(job.startedAt, isNotNull);
        expect(job.completedAt, isNotNull);
        expect(job.createdAt, isNotNull);
        expect(job.errors, hasLength(1));
        expect(job.errors.first.code, 'invalid_input');
        expect(job.metadata, {'project': 'test'});
      });

      test('parses alternative field names (input_files, output_file)', () {
        final json = {
          'id': 'batch-789',
          'input_files': 'file-alt-input',
          'output_file': 'file-alt-output',
          'error_file': 'file-alt-errors',
          'endpoint': '/v1/chat/completions',
          'model': 'mistral-small-latest',
          'status': 'RUNNING',
        };

        final job = BatchJob.fromJson(json);

        expect(job.inputFileId, 'file-alt-input');
        expect(job.outputFileId, 'file-alt-output');
        expect(job.errorFileId, 'file-alt-errors');
      });

      test('parses timestamps as epoch seconds', () {
        final json = {
          'id': 'batch-epoch',
          'input_file_id': 'file-abc',
          'endpoint': '/v1/chat/completions',
          'model': 'mistral-small-latest',
          'status': 'SUCCESS',
          'created_at': 1705312800, // Unix timestamp
        };

        final job = BatchJob.fromJson(json);

        expect(job.createdAt, isNotNull);
        expect(job.createdAt!.year, 2024);
      });
    });

    group('toJson', () {
      test('serializes to JSON', () {
        const job = BatchJob(
          id: 'batch-123',
          inputFileId: 'file-input',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          status: BatchJobStatus.running,
          totalRequests: 50,
          completedRequests: 25,
        );

        final json = job.toJson();

        expect(json['id'], 'batch-123');
        expect(json['object'], 'batch');
        expect(json['input_file_id'], 'file-input');
        expect(json['endpoint'], '/v1/chat/completions');
        expect(json['model'], 'mistral-small-latest');
        expect(json['status'], 'RUNNING');
        expect(json['total_requests'], 50);
        expect(json['completed_requests'], 25);
      });

      test('omits null fields', () {
        const job = BatchJob(
          id: 'batch-123',
          inputFileId: 'file-input',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          status: BatchJobStatus.queued,
        );

        final json = job.toJson();

        expect(json.containsKey('output_file_id'), isFalse);
        expect(json.containsKey('error_file_id'), isFalse);
        expect(json.containsKey('total_requests'), isFalse);
        expect(json.containsKey('metadata'), isFalse);
      });
    });

    group('helper getters', () {
      test('isRunning returns true for queued or running', () {
        expect(
          const BatchJob(
            id: '1',
            inputFileId: 'f',
            endpoint: '/v1/chat/completions',
            model: 'm',
            status: BatchJobStatus.queued,
          ).isRunning,
          isTrue,
        );
        expect(
          const BatchJob(
            id: '1',
            inputFileId: 'f',
            endpoint: '/v1/chat/completions',
            model: 'm',
            status: BatchJobStatus.running,
          ).isRunning,
          isTrue,
        );
        expect(
          const BatchJob(
            id: '1',
            inputFileId: 'f',
            endpoint: '/v1/chat/completions',
            model: 'm',
            status: BatchJobStatus.success,
          ).isRunning,
          isFalse,
        );
      });

      test('isComplete returns true for terminal states', () {
        for (final status in [
          BatchJobStatus.success,
          BatchJobStatus.failed,
          BatchJobStatus.timedOut,
          BatchJobStatus.cancelled,
        ]) {
          expect(
            BatchJob(
              id: '1',
              inputFileId: 'f',
              endpoint: '/v1/chat/completions',
              model: 'm',
              status: status,
            ).isComplete,
            isTrue,
            reason: 'Expected isComplete=true for $status',
          );
        }
      });

      test('isSuccess returns true only for success status', () {
        expect(
          const BatchJob(
            id: '1',
            inputFileId: 'f',
            endpoint: '/v1/chat/completions',
            model: 'm',
            status: BatchJobStatus.success,
          ).isSuccess,
          isTrue,
        );
        expect(
          const BatchJob(
            id: '1',
            inputFileId: 'f',
            endpoint: '/v1/chat/completions',
            model: 'm',
            status: BatchJobStatus.failed,
          ).isSuccess,
          isFalse,
        );
      });

      test('progress calculates percentage correctly', () {
        const job = BatchJob(
          id: '1',
          inputFileId: 'f',
          endpoint: '/v1/chat/completions',
          model: 'm',
          status: BatchJobStatus.running,
          totalRequests: 100,
          completedRequests: 50,
        );

        expect(job.progress, 50.0);
      });

      test('progress returns 0 when totalRequests is null or 0', () {
        expect(
          const BatchJob(
            id: '1',
            inputFileId: 'f',
            endpoint: '/v1/chat/completions',
            model: 'm',
            status: BatchJobStatus.queued,
          ).progress,
          0.0,
        );
        expect(
          const BatchJob(
            id: '1',
            inputFileId: 'f',
            endpoint: '/v1/chat/completions',
            model: 'm',
            status: BatchJobStatus.queued,
            totalRequests: 0,
          ).progress,
          0.0,
        );
      });
    });

    group('equality', () {
      test('jobs with same id are equal', () {
        const job1 = BatchJob(
          id: 'batch-123',
          inputFileId: 'file-a',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          status: BatchJobStatus.queued,
        );
        const job2 = BatchJob(
          id: 'batch-123',
          inputFileId: 'file-b', // Different file
          endpoint: '/v1/embeddings', // Different endpoint
          model: 'mistral-embed', // Different model
          status: BatchJobStatus.success, // Different status
        );

        expect(job1, equals(job2));
        expect(job1.hashCode, equals(job2.hashCode));
      });

      test('jobs with different ids are not equal', () {
        const job1 = BatchJob(
          id: 'batch-123',
          inputFileId: 'file-a',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          status: BatchJobStatus.queued,
        );
        const job2 = BatchJob(
          id: 'batch-456',
          inputFileId: 'file-a',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          status: BatchJobStatus.queued,
        );

        expect(job1, isNot(equals(job2)));
      });
    });

    test('toString returns readable representation', () {
      const job = BatchJob(
        id: 'batch-123',
        inputFileId: 'file-a',
        endpoint: '/v1/chat/completions',
        model: 'mistral-small-latest',
        status: BatchJobStatus.running,
        totalRequests: 100,
        completedRequests: 75,
      );

      expect(job.toString(), contains('batch-123'));
      expect(job.toString(), contains('RUNNING'));
      expect(job.toString(), contains('75.0%'));
    });
  });
}
