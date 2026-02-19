import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Batch', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'batch_abc123',
        'object': 'batch',
        'endpoint': '/v1/chat/completions',
        'input_file_id': 'file-input123',
        'completion_window': '24h',
        'status': 'completed',
        'created_at': 1699472000,
        'output_file_id': 'file-output456',
        'request_counts': {'total': 100, 'completed': 95, 'failed': 5},
        'metadata': {'key': 'value'},
      };

      final batch = Batch.fromJson(json);

      expect(batch.id, 'batch_abc123');
      expect(batch.object, 'batch');
      expect(batch.endpoint, '/v1/chat/completions');
      expect(batch.inputFileId, 'file-input123');
      expect(batch.completionWindow, '24h');
      expect(batch.status, BatchStatus.completed);
      expect(batch.createdAt, 1699472000);
      expect(batch.outputFileId, 'file-output456');
      expect(batch.requestCounts?.total, 100);
      expect(batch.requestCounts?.completed, 95);
      expect(batch.requestCounts?.failed, 5);
      expect(batch.metadata?['key'], 'value');
    });

    test('fromJson handles errors', () {
      final json = {
        'id': 'batch_abc123',
        'object': 'batch',
        'endpoint': '/v1/chat/completions',
        'input_file_id': 'file-input123',
        'completion_window': '24h',
        'status': 'failed',
        'created_at': 1699472000,
        'errors': {
          'object': 'list',
          'data': [
            {
              'code': 'invalid_format',
              'message': 'Invalid JSON on line 5',
              'line': 5,
            },
          ],
        },
      };

      final batch = Batch.fromJson(json);

      expect(batch.status, BatchStatus.failed);
      expect(batch.errors?.data.length, 1);
      expect(batch.errors?.data[0].code, 'invalid_format');
      expect(batch.errors?.data[0].line, 5);
    });

    test('toJson serializes correctly', () {
      const batch = Batch(
        id: 'batch_abc123',
        object: 'batch',
        endpoint: '/v1/chat/completions',
        inputFileId: 'file-input123',
        completionWindow: '24h',
        status: BatchStatus.inProgress,
        createdAt: 1699472000,
        requestCounts: BatchRequestCounts(total: 50, completed: 25, failed: 0),
      );

      final json = batch.toJson();

      expect(json['id'], 'batch_abc123');
      expect(json['status'], 'in_progress');
      expect((json['request_counts'] as Map)['total'], 50);
    });

    test('helper getters work correctly', () {
      const processing = Batch(
        id: 'batch_1',
        object: 'batch',
        endpoint: '/v1/chat/completions',
        inputFileId: 'file-1',
        completionWindow: '24h',
        status: BatchStatus.inProgress,
        createdAt: 1699472000,
      );

      const completed = Batch(
        id: 'batch_2',
        object: 'batch',
        endpoint: '/v1/chat/completions',
        inputFileId: 'file-2',
        completionWindow: '24h',
        status: BatchStatus.completed,
        createdAt: 1699472000,
      );

      const failed = Batch(
        id: 'batch_3',
        object: 'batch',
        endpoint: '/v1/chat/completions',
        inputFileId: 'file-3',
        completionWindow: '24h',
        status: BatchStatus.failed,
        createdAt: 1699472000,
      );

      expect(processing.isProcessing, isTrue);
      expect(processing.isCompleted, isFalse);
      expect(completed.isCompleted, isTrue);
      expect(completed.isProcessing, isFalse);
      expect(failed.isFailed, isTrue);
    });
  });

  group('BatchList', () {
    test('fromJson parses correctly', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'id': 'batch_1',
            'object': 'batch',
            'endpoint': '/v1/chat/completions',
            'input_file_id': 'file-1',
            'completion_window': '24h',
            'status': 'completed',
            'created_at': 1699472000,
          },
          {
            'id': 'batch_2',
            'object': 'batch',
            'endpoint': '/v1/embeddings',
            'input_file_id': 'file-2',
            'completion_window': '24h',
            'status': 'in_progress',
            'created_at': 1699472001,
          },
        ],
        'first_id': 'batch_1',
        'last_id': 'batch_2',
        'has_more': false,
      };

      final list = BatchList.fromJson(json);

      expect(list.object, 'list');
      expect(list.data.length, 2);
      expect(list.data[0].id, 'batch_1');
      expect(list.data[1].id, 'batch_2');
      expect(list.firstId, 'batch_1');
      expect(list.lastId, 'batch_2');
      expect(list.hasMore, isFalse);
    });
  });

  group('CreateBatchRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'input_file_id': 'file-abc123',
        'endpoint': '/v1/chat/completions',
        'completion_window': '24h',
        'metadata': {'project': 'test'},
      };

      final request = CreateBatchRequest.fromJson(json);

      expect(request.inputFileId, 'file-abc123');
      expect(request.endpoint, BatchEndpoint.chatCompletions);
      expect(request.completionWindow, CompletionWindow.hours24);
      expect(request.metadata?['project'], 'test');
    });

    test('toJson serializes correctly', () {
      const request = CreateBatchRequest(
        inputFileId: 'file-abc123',
        endpoint: BatchEndpoint.embeddings,
        completionWindow: CompletionWindow.hours24,
        metadata: {'key': 'value'},
      );

      final json = request.toJson();

      expect(json['input_file_id'], 'file-abc123');
      expect(json['endpoint'], '/v1/embeddings');
      expect(json['completion_window'], '24h');
      expect((json['metadata'] as Map)['key'], 'value');
    });
  });

  group('BatchRequestCounts', () {
    test('fromJson parses correctly', () {
      final json = {'total': 100, 'completed': 80, 'failed': 10};

      final counts = BatchRequestCounts.fromJson(json);

      expect(counts.total, 100);
      expect(counts.completed, 80);
      expect(counts.failed, 10);
    });

    test('pending calculation is correct', () {
      const counts = BatchRequestCounts(total: 100, completed: 60, failed: 10);

      expect(counts.pending, 30);
    });

    test('completion percentage is correct', () {
      const counts = BatchRequestCounts(total: 100, completed: 80, failed: 10);

      expect(counts.completionPercentage, 90.0);
    });

    test('completion percentage handles zero total', () {
      const counts = BatchRequestCounts(total: 0, completed: 0, failed: 0);

      expect(counts.completionPercentage, 0.0);
    });
  });

  group('BatchStatus', () {
    test('fromJson parses all values', () {
      expect(BatchStatus.fromJson('validating'), BatchStatus.validating);
      expect(BatchStatus.fromJson('failed'), BatchStatus.failed);
      expect(BatchStatus.fromJson('in_progress'), BatchStatus.inProgress);
      expect(BatchStatus.fromJson('finalizing'), BatchStatus.finalizing);
      expect(BatchStatus.fromJson('completed'), BatchStatus.completed);
      expect(BatchStatus.fromJson('expired'), BatchStatus.expired);
      expect(BatchStatus.fromJson('cancelling'), BatchStatus.cancelling);
      expect(BatchStatus.fromJson('cancelled'), BatchStatus.cancelled);
    });

    test('toJson returns correct string', () {
      expect(BatchStatus.validating.toJson(), 'validating');
      expect(BatchStatus.inProgress.toJson(), 'in_progress');
      expect(BatchStatus.completed.toJson(), 'completed');
    });

    test('fromJson throws on unknown value', () {
      expect(() => BatchStatus.fromJson('unknown'), throwsFormatException);
    });
  });

  group('BatchEndpoint', () {
    test('fromJson parses all values', () {
      expect(BatchEndpoint.fromJson('/v1/responses'), BatchEndpoint.responses);
      expect(
        BatchEndpoint.fromJson('/v1/chat/completions'),
        BatchEndpoint.chatCompletions,
      );
      expect(
        BatchEndpoint.fromJson('/v1/embeddings'),
        BatchEndpoint.embeddings,
      );
      expect(
        BatchEndpoint.fromJson('/v1/completions'),
        BatchEndpoint.completions,
      );
      expect(
        BatchEndpoint.fromJson('/v1/moderations'),
        BatchEndpoint.moderations,
      );
      expect(
        BatchEndpoint.fromJson('/v1/images/generations'),
        BatchEndpoint.imagesGenerations,
      );
      expect(
        BatchEndpoint.fromJson('/v1/images/edits'),
        BatchEndpoint.imagesEdits,
      );
    });

    test('toJson returns correct string', () {
      expect(BatchEndpoint.responses.toJson(), '/v1/responses');
      expect(BatchEndpoint.chatCompletions.toJson(), '/v1/chat/completions');
      expect(BatchEndpoint.embeddings.toJson(), '/v1/embeddings');
      expect(BatchEndpoint.moderations.toJson(), '/v1/moderations');
      expect(
        BatchEndpoint.imagesGenerations.toJson(),
        '/v1/images/generations',
      );
      expect(BatchEndpoint.imagesEdits.toJson(), '/v1/images/edits');
    });
  });

  group('CompletionWindow', () {
    test('fromJson parses correctly', () {
      expect(CompletionWindow.fromJson('24h'), CompletionWindow.hours24);
    });

    test('toJson returns correct string', () {
      expect(CompletionWindow.hours24.toJson(), '24h');
    });
  });

  group('BatchError', () {
    test('fromJson parses correctly', () {
      final json = {
        'code': 'invalid_request',
        'message': 'Missing required field',
        'param': 'model',
        'line': 10,
      };

      final error = BatchError.fromJson(json);

      expect(error.code, 'invalid_request');
      expect(error.message, 'Missing required field');
      expect(error.param, 'model');
      expect(error.line, 10);
    });

    test('handles null fields', () {
      final json = <String, dynamic>{};

      final error = BatchError.fromJson(json);

      expect(error.code, isNull);
      expect(error.message, isNull);
      expect(error.param, isNull);
      expect(error.line, isNull);
    });
  });
}
