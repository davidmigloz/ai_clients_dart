import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MessageBatchListResponse', () {
    test('fromJson deserializes with all fields', () {
      final json = {
        'data': [
          {
            'id': 'batch_123',
            'type': 'message_batch',
            'created_at': '2024-01-15T10:00:00Z',
            'expires_at': '2024-01-16T10:00:00Z',
            'processing_status': 'in_progress',
            'request_counts': {
              'processing': 5,
              'succeeded': 10,
              'errored': 1,
              'canceled': 0,
              'expired': 0,
            },
            'results_url': 'https://example.com/results.jsonl',
          },
        ],
        'has_more': true,
        'first_id': 'batch_123',
        'last_id': 'batch_123',
      };

      final response = MessageBatchListResponse.fromJson(json);

      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'batch_123');
      expect(response.data.first.processingStatus, ProcessingStatus.inProgress);
      expect(response.data.first.requestCounts.processing, 5);
      expect(response.data.first.requestCounts.succeeded, 10);
      expect(
        response.data.first.resultsUrl,
        'https://example.com/results.jsonl',
      );
      expect(response.hasMore, isTrue);
      expect(response.firstId, 'batch_123');
      expect(response.lastId, 'batch_123');
    });

    test('fromJson deserializes with required fields only', () {
      final json = {'data': <Map<String, dynamic>>[], 'has_more': false};

      final response = MessageBatchListResponse.fromJson(json);

      expect(response.data, isEmpty);
      expect(response.hasMore, isFalse);
      expect(response.firstId, isNull);
      expect(response.lastId, isNull);
    });

    test('fromJson deserializes with multiple batches', () {
      final json = {
        'data': [
          {
            'id': 'batch_001',
            'type': 'message_batch',
            'created_at': '2024-01-15T10:00:00Z',
            'expires_at': '2024-01-16T10:00:00Z',
            'processing_status': 'ended',
            'request_counts': {
              'processing': 0,
              'succeeded': 100,
              'errored': 0,
              'canceled': 0,
              'expired': 0,
            },
          },
          {
            'id': 'batch_002',
            'type': 'message_batch',
            'created_at': '2024-01-15T11:00:00Z',
            'expires_at': '2024-01-16T11:00:00Z',
            'processing_status': 'canceling',
            'request_counts': {
              'processing': 50,
              'succeeded': 30,
              'errored': 5,
              'canceled': 10,
              'expired': 5,
            },
          },
        ],
        'has_more': true,
        'first_id': 'batch_001',
        'last_id': 'batch_002',
      };

      final response = MessageBatchListResponse.fromJson(json);

      expect(response.data, hasLength(2));
      expect(response.data[0].id, 'batch_001');
      expect(response.data[0].processingStatus, ProcessingStatus.ended);
      expect(response.data[1].id, 'batch_002');
      expect(response.data[1].processingStatus, ProcessingStatus.canceling);
      expect(response.firstId, 'batch_001');
      expect(response.lastId, 'batch_002');
    });

    test('toJson serializes correctly', () {
      final response = MessageBatchListResponse(
        data: [
          MessageBatch(
            id: 'batch_abc',
            createdAt: DateTime.utc(2024, 1, 15, 10),
            expiresAt: DateTime.utc(2024, 1, 16, 10),
            processingStatus: ProcessingStatus.inProgress,
            requestCounts: const RequestCounts(
              processing: 5,
              succeeded: 0,
              errored: 0,
              canceled: 0,
              expired: 0,
            ),
          ),
        ],
        hasMore: false,
        firstId: 'batch_abc',
        lastId: 'batch_abc',
      );

      final json = response.toJson();

      expect(json['data'], hasLength(1));
      final dataList = json['data'] as List<dynamic>;
      expect((dataList.first as Map<String, dynamic>)['id'], 'batch_abc');
      expect(json['has_more'], false);
      expect(json['first_id'], 'batch_abc');
      expect(json['last_id'], 'batch_abc');
    });

    test('toJson excludes null optional fields', () {
      const response = MessageBatchListResponse(data: [], hasMore: false);

      final json = response.toJson();

      expect(json.containsKey('first_id'), isFalse);
      expect(json.containsKey('last_id'), isFalse);
    });

    test('round-trip serialization works', () {
      final original = MessageBatchListResponse(
        data: [
          MessageBatch(
            id: 'batch_xyz',
            createdAt: DateTime.utc(2024, 1, 15, 10),
            expiresAt: DateTime.utc(2024, 1, 16, 10),
            processingStatus: ProcessingStatus.ended,
            requestCounts: const RequestCounts(
              processing: 0,
              succeeded: 50,
              errored: 5,
              canceled: 2,
              expired: 3,
            ),
            resultsUrl: 'https://example.com/results.jsonl',
          ),
        ],
        hasMore: true,
        firstId: 'batch_xyz',
        lastId: 'batch_xyz',
      );

      final json = original.toJson();
      final restored = MessageBatchListResponse.fromJson(json);

      expect(restored.data, hasLength(1));
      expect(restored.data.first.id, original.data.first.id);
      expect(
        restored.data.first.processingStatus,
        original.data.first.processingStatus,
      );
      expect(
        restored.data.first.requestCounts.succeeded,
        original.data.first.requestCounts.succeeded,
      );
      expect(restored.hasMore, original.hasMore);
      expect(restored.firstId, original.firstId);
      expect(restored.lastId, original.lastId);
    });
  });

  group('ProcessingStatus', () {
    test('has correct number of values', () {
      expect(ProcessingStatus.values, hasLength(3));
    });

    test('all values are present', () {
      expect(
        ProcessingStatus.values,
        containsAll([
          ProcessingStatus.inProgress,
          ProcessingStatus.canceling,
          ProcessingStatus.ended,
        ]),
      );
    });

    test('serializes to correct string', () {
      expect(ProcessingStatus.inProgress.toJson(), 'in_progress');
      expect(ProcessingStatus.canceling.toJson(), 'canceling');
      expect(ProcessingStatus.ended.toJson(), 'ended');
    });
  });

  group('DeletedMessageBatch', () {
    test('fromJson deserializes correctly', () {
      final json = {'id': 'batch_abc123', 'type': 'message_batch_deleted'};

      final response = DeletedMessageBatch.fromJson(json);

      expect(response.id, 'batch_abc123');
      expect(response.type, 'message_batch_deleted');
    });

    test('toJson serializes correctly', () {
      const response = DeletedMessageBatch(
        id: 'batch_xyz789',
        type: 'message_batch_deleted',
      );

      final json = response.toJson();

      expect(json['id'], 'batch_xyz789');
      expect(json['type'], 'message_batch_deleted');
    });

    test('round-trip serialization works', () {
      const original = DeletedMessageBatch(
        id: 'batch_roundtrip',
        type: 'message_batch_deleted',
      );

      final json = original.toJson();
      final restored = DeletedMessageBatch.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
    });
  });

  group('BatchIndividualResponse', () {
    test('succeeded result deserializes correctly', () {
      final json = {
        'custom_id': 'request_001',
        'result': {
          'type': 'succeeded',
          'message': {
            'id': 'msg_123',
            'type': 'message',
            'role': 'assistant',
            'model': 'claude-sonnet-4-20250514',
            'content': [
              {'type': 'text', 'text': 'Hello!'},
            ],
            'stop_reason': 'end_turn',
            'usage': {'input_tokens': 10, 'output_tokens': 5},
          },
        },
      };

      final response = BatchIndividualResponse.fromJson(json);

      expect(response.customId, 'request_001');
      expect(response.result, isA<BatchResultSucceeded>());
      final succeeded = response.result as BatchResultSucceeded;
      expect(succeeded.message.id, 'msg_123');
      expect(succeeded.message.role, 'assistant');
    });

    test('errored result deserializes correctly', () {
      final json = {
        'custom_id': 'request_002',
        'result': {
          'type': 'errored',
          'error': {
            'type': 'invalid_request_error',
            'message': 'Invalid input',
          },
        },
      };

      final response = BatchIndividualResponse.fromJson(json);

      expect(response.customId, 'request_002');
      expect(response.result, isA<BatchResultErrored>());
      final errored = response.result as BatchResultErrored;
      expect(errored.error.message, 'Invalid input');
    });

    test('canceled result deserializes correctly', () {
      final json = {
        'custom_id': 'request_003',
        'result': {'type': 'canceled'},
      };

      final response = BatchIndividualResponse.fromJson(json);

      expect(response.customId, 'request_003');
      expect(response.result, isA<BatchResultCanceled>());
    });

    test('expired result deserializes correctly', () {
      final json = {
        'custom_id': 'request_004',
        'result': {'type': 'expired'},
      };

      final response = BatchIndividualResponse.fromJson(json);

      expect(response.customId, 'request_004');
      expect(response.result, isA<BatchResultExpired>());
    });
  });

  group('BatchResult', () {
    test('succeeded result has correct type', () {
      final json = {
        'type': 'succeeded',
        'message': {
          'id': 'msg_123',
          'type': 'message',
          'role': 'assistant',
          'model': 'claude-sonnet-4-20250514',
          'content': [
            {'type': 'text', 'text': 'Hello!'},
          ],
          'stop_reason': 'end_turn',
          'usage': {'input_tokens': 10, 'output_tokens': 5},
        },
      };
      final result = BatchResult.fromJson(json);
      expect(result, isA<BatchResultSucceeded>());
    });

    test('errored result has correct type', () {
      final json = {
        'type': 'errored',
        'error': {'type': 'invalid_request_error', 'message': 'Invalid input'},
      };
      final result = BatchResult.fromJson(json);
      expect(result, isA<BatchResultErrored>());
    });

    test('canceled result has correct type', () {
      final json = {'type': 'canceled'};
      final result = BatchResult.fromJson(json);
      expect(result, isA<BatchResultCanceled>());
    });

    test('expired result has correct type', () {
      final json = {'type': 'expired'};
      final result = BatchResult.fromJson(json);
      expect(result, isA<BatchResultExpired>());
    });
  });

  group('RequestCounts', () {
    test('fromJson deserializes correctly', () {
      final json = {
        'processing': 10,
        'succeeded': 50,
        'errored': 5,
        'canceled': 2,
        'expired': 3,
      };

      final counts = RequestCounts.fromJson(json);

      expect(counts.processing, 10);
      expect(counts.succeeded, 50);
      expect(counts.errored, 5);
      expect(counts.canceled, 2);
      expect(counts.expired, 3);
    });

    test('toJson serializes correctly', () {
      const counts = RequestCounts(
        processing: 15,
        succeeded: 75,
        errored: 10,
        canceled: 5,
        expired: 0,
      );

      final json = counts.toJson();

      expect(json['processing'], 15);
      expect(json['succeeded'], 75);
      expect(json['errored'], 10);
      expect(json['canceled'], 5);
      expect(json['expired'], 0);
    });

    test('equality works correctly', () {
      const counts1 = RequestCounts(
        processing: 10,
        succeeded: 20,
        errored: 1,
        canceled: 0,
        expired: 0,
      );
      const counts2 = RequestCounts(
        processing: 10,
        succeeded: 20,
        errored: 1,
        canceled: 0,
        expired: 0,
      );
      const counts3 = RequestCounts(
        processing: 5,
        succeeded: 20,
        errored: 1,
        canceled: 0,
        expired: 0,
      );

      expect(counts1, equals(counts2));
      expect(counts1, isNot(equals(counts3)));
    });
  });
}
