import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateBatchJobRequest', () {
    group('constructor', () {
      test('creates request with required fields', () {
        const request = CreateBatchJobRequest(
          inputFileId: 'file-123',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        expect(request.inputFileId, 'file-123');
        expect(request.endpoint, '/v1/chat/completions');
        expect(request.model, 'mistral-small-latest');
        expect(request.metadata, isNull);
        expect(request.timeoutHours, isNull);
      });

      test('creates request with all fields', () {
        const request = CreateBatchJobRequest(
          inputFileId: 'file-456',
          endpoint: '/v1/embeddings',
          model: 'mistral-embed',
          metadata: {'project': 'test', 'version': '1.0'},
          timeoutHours: 24,
        );

        expect(request.inputFileId, 'file-456');
        expect(request.endpoint, '/v1/embeddings');
        expect(request.model, 'mistral-embed');
        expect(request.metadata, {'project': 'test', 'version': '1.0'});
        expect(request.timeoutHours, 24);
      });
    });

    group('fromJson', () {
      test('parses request with input_files field', () {
        final json = {
          'input_files': 'file-123',
          'endpoint': '/v1/chat/completions',
          'model': 'mistral-small-latest',
        };

        final request = CreateBatchJobRequest.fromJson(json);

        expect(request.inputFileId, 'file-123');
        expect(request.endpoint, '/v1/chat/completions');
        expect(request.model, 'mistral-small-latest');
      });

      test('parses request with input_file_id field', () {
        final json = {
          'input_file_id': 'file-456',
          'endpoint': '/v1/embeddings',
          'model': 'mistral-embed',
        };

        final request = CreateBatchJobRequest.fromJson(json);

        expect(request.inputFileId, 'file-456');
      });

      test('parses request with all fields', () {
        final json = {
          'input_files': 'file-789',
          'endpoint': '/v1/moderations',
          'model': 'mistral-moderation-latest',
          'metadata': {'key': 'value'},
          'timeout_hours': 48,
        };

        final request = CreateBatchJobRequest.fromJson(json);

        expect(request.inputFileId, 'file-789');
        expect(request.endpoint, '/v1/moderations');
        expect(request.model, 'mistral-moderation-latest');
        expect(request.metadata, {'key': 'value'});
        expect(request.timeoutHours, 48);
      });
    });

    group('toJson', () {
      test('serializes with input_files field', () {
        const request = CreateBatchJobRequest(
          inputFileId: 'file-123',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        final json = request.toJson();

        expect(json['input_files'], 'file-123');
        expect(json['endpoint'], '/v1/chat/completions');
        expect(json['model'], 'mistral-small-latest');
        expect(json.containsKey('metadata'), isFalse);
        expect(json.containsKey('timeout_hours'), isFalse);
      });

      test('serializes all fields', () {
        const request = CreateBatchJobRequest(
          inputFileId: 'file-456',
          endpoint: '/v1/embeddings',
          model: 'mistral-embed',
          metadata: {'env': 'prod'},
          timeoutHours: 12,
        );

        final json = request.toJson();

        expect(json['input_files'], 'file-456');
        expect(json['endpoint'], '/v1/embeddings');
        expect(json['model'], 'mistral-embed');
        expect(json['metadata'], {'env': 'prod'});
        expect(json['timeout_hours'], 12);
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        const original = CreateBatchJobRequest(
          inputFileId: 'file-123',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        final copy = original.copyWith(
          inputFileId: 'file-456',
          model: 'mistral-large-latest',
          timeoutHours: 24,
        );

        expect(copy.inputFileId, 'file-456');
        expect(copy.endpoint, '/v1/chat/completions'); // Unchanged
        expect(copy.model, 'mistral-large-latest');
        expect(copy.timeoutHours, 24);
      });

      test('preserves existing values when not specified', () {
        const original = CreateBatchJobRequest(
          inputFileId: 'file-123',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          metadata: {'key': 'value'},
          timeoutHours: 48,
        );

        final copy = original.copyWith();

        expect(copy.inputFileId, 'file-123');
        expect(copy.endpoint, '/v1/chat/completions');
        expect(copy.model, 'mistral-small-latest');
        expect(copy.metadata, {'key': 'value'});
        expect(copy.timeoutHours, 48);
      });
    });

    group('equality', () {
      test('requests with same key fields are equal', () {
        const request1 = CreateBatchJobRequest(
          inputFileId: 'file-123',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );
        const request2 = CreateBatchJobRequest(
          inputFileId: 'file-123',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          timeoutHours: 24, // Different but not part of equality
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('requests with different fields are not equal', () {
        const request1 = CreateBatchJobRequest(
          inputFileId: 'file-123',
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );
        const request2 = CreateBatchJobRequest(
          inputFileId: 'file-456', // Different
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        expect(request1, isNot(equals(request2)));
      });
    });

    test('toString returns readable representation', () {
      const request = CreateBatchJobRequest(
        inputFileId: 'file-123',
        endpoint: '/v1/chat/completions',
        model: 'mistral-small-latest',
      );

      expect(request.toString(), contains('file-123'));
      expect(request.toString(), contains('/v1/chat/completions'));
      expect(request.toString(), contains('mistral-small-latest'));
    });
  });
}
