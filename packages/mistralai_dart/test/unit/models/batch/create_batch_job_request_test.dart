import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateBatchJobRequest', () {
    group('constructor', () {
      test('creates request with required fields', () {
        const request = CreateBatchJobRequest(
          inputFiles: ['file-123'],
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        expect(request.inputFiles, ['file-123']);
        expect(request.endpoint, '/v1/chat/completions');
        expect(request.model, 'mistral-small-latest');
        expect(request.metadata, isNull);
        expect(request.timeoutHours, isNull);
        expect(request.requests, isNull);
      });

      test('creates request with null inputFiles', () {
        const request = CreateBatchJobRequest(
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        expect(request.inputFiles, isNull);
        expect(request.endpoint, '/v1/chat/completions');
        expect(request.model, 'mistral-small-latest');
      });

      test('creates request with all fields', () {
        const request = CreateBatchJobRequest(
          inputFiles: ['file-456'],
          endpoint: '/v1/embeddings',
          model: 'mistral-embed',
          metadata: {'project': 'test', 'version': '1.0'},
          timeoutHours: 24,
          requests: [
            BatchRequest(body: {'prompt': 'Hello'}, customId: 'req-1'),
          ],
        );

        expect(request.inputFiles, ['file-456']);
        expect(request.endpoint, '/v1/embeddings');
        expect(request.model, 'mistral-embed');
        expect(request.metadata, {'project': 'test', 'version': '1.0'});
        expect(request.timeoutHours, 24);
        expect(request.requests, hasLength(1));
        expect(request.requests![0].customId, 'req-1');
      });

      test('creates request with inline requests instead of inputFiles', () {
        const request = CreateBatchJobRequest(
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          requests: [
            BatchRequest(body: {'prompt': 'Hello'}, customId: 'req-1'),
            BatchRequest(body: {'prompt': 'World'}, customId: 'req-2'),
          ],
        );

        expect(request.inputFiles, isNull);
        expect(request.requests, hasLength(2));
        expect(request.requests![0].body, {'prompt': 'Hello'});
        expect(request.requests![1].customId, 'req-2');
      });
    });

    group('fromJson', () {
      test('parses request with input_files field', () {
        final json = {
          'input_files': ['file-123'],
          'endpoint': '/v1/chat/completions',
          'model': 'mistral-small-latest',
        };

        final request = CreateBatchJobRequest.fromJson(json);

        expect(request.inputFiles, ['file-123']);
        expect(request.endpoint, '/v1/chat/completions');
        expect(request.model, 'mistral-small-latest');
      });

      test('parses request with input_files as list', () {
        final json = {
          'input_files': ['file-456'],
          'endpoint': '/v1/embeddings',
          'model': 'mistral-embed',
        };

        final request = CreateBatchJobRequest.fromJson(json);

        expect(request.inputFiles, ['file-456']);
      });

      test('parses request with all fields', () {
        final json = {
          'input_files': ['file-789'],
          'endpoint': '/v1/moderations',
          'model': 'mistral-moderation-latest',
          'metadata': {'key': 'value'},
          'timeout_hours': 48,
        };

        final request = CreateBatchJobRequest.fromJson(json);

        expect(request.inputFiles, ['file-789']);
        expect(request.endpoint, '/v1/moderations');
        expect(request.model, 'mistral-moderation-latest');
        expect(request.metadata, {'key': 'value'});
        expect(request.timeoutHours, 48);
      });

      test('parses request with inline requests', () {
        final json = {
          'endpoint': '/v1/chat/completions',
          'model': 'mistral-small-latest',
          'requests': [
            {
              'body': {'prompt': 'Hello'},
              'custom_id': 'req-1',
            },
            {
              'body': {'prompt': 'World'},
            },
          ],
        };

        final request = CreateBatchJobRequest.fromJson(json);

        expect(request.inputFiles, isNull);
        expect(request.requests, hasLength(2));
        expect(request.requests![0].body, {'prompt': 'Hello'});
        expect(request.requests![0].customId, 'req-1');
        expect(request.requests![1].body, {'prompt': 'World'});
        expect(request.requests![1].customId, isNull);
      });

      test('parses request with null inputFiles', () {
        final json = {
          'endpoint': '/v1/chat/completions',
          'model': 'mistral-small-latest',
        };

        final request = CreateBatchJobRequest.fromJson(json);

        expect(request.inputFiles, isNull);
        expect(request.requests, isNull);
      });
    });

    group('toJson', () {
      test('serializes with input_files field', () {
        const request = CreateBatchJobRequest(
          inputFiles: ['file-123'],
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        final json = request.toJson();

        expect(json['input_files'], ['file-123']);
        expect(json['endpoint'], '/v1/chat/completions');
        expect(json['model'], 'mistral-small-latest');
        expect(json.containsKey('metadata'), isFalse);
        expect(json.containsKey('timeout_hours'), isFalse);
        expect(json.containsKey('requests'), isFalse);
      });

      test('serializes without inputFiles when null', () {
        const request = CreateBatchJobRequest(
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        final json = request.toJson();

        expect(json.containsKey('input_files'), isFalse);
      });

      test('serializes all fields', () {
        const request = CreateBatchJobRequest(
          inputFiles: ['file-456'],
          endpoint: '/v1/embeddings',
          model: 'mistral-embed',
          metadata: {'env': 'prod'},
          timeoutHours: 12,
          requests: [
            BatchRequest(body: {'prompt': 'Hello'}, customId: 'req-1'),
          ],
        );

        final json = request.toJson();

        expect(json['input_files'], ['file-456']);
        expect(json['endpoint'], '/v1/embeddings');
        expect(json['model'], 'mistral-embed');
        expect(json['metadata'], {'env': 'prod'});
        expect(json['timeout_hours'], 12);
        expect(json['requests'], isList);
        expect(json['requests'] as List, hasLength(1));
      });

      test('serializes with inline requests', () {
        const request = CreateBatchJobRequest(
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          requests: [
            BatchRequest(body: {'prompt': 'Hello'}, customId: 'req-1'),
          ],
        );

        final json = request.toJson();

        expect(json.containsKey('input_files'), isFalse);
        expect(json['requests'], isList);
        final requests = json['requests'] as List;
        expect(requests, hasLength(1));
        expect((requests[0] as Map<String, dynamic>)['custom_id'], 'req-1');
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        const original = CreateBatchJobRequest(
          inputFiles: ['file-123'],
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        final copy = original.copyWith(
          inputFiles: ['file-456'],
          model: 'mistral-large-latest',
          timeoutHours: 24,
        );

        expect(copy.inputFiles, ['file-456']);
        expect(copy.endpoint, '/v1/chat/completions'); // Unchanged
        expect(copy.model, 'mistral-large-latest');
        expect(copy.timeoutHours, 24);
      });

      test('preserves existing values when not specified', () {
        const original = CreateBatchJobRequest(
          inputFiles: ['file-123'],
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          metadata: {'key': 'value'},
          timeoutHours: 48,
          requests: [
            BatchRequest(body: {'prompt': 'Hello'}, customId: 'req-1'),
          ],
        );

        final copy = original.copyWith();

        expect(copy.inputFiles, ['file-123']);
        expect(copy.endpoint, '/v1/chat/completions');
        expect(copy.model, 'mistral-small-latest');
        expect(copy.metadata, {'key': 'value'});
        expect(copy.timeoutHours, 48);
        expect(copy.requests, hasLength(1));
      });

      test('copies with new requests', () {
        const original = CreateBatchJobRequest(
          inputFiles: ['file-123'],
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        final copy = original.copyWith(
          requests: const [
            BatchRequest(body: {'prompt': 'New'}, customId: 'req-new'),
          ],
        );

        expect(copy.inputFiles, ['file-123']);
        expect(copy.requests, hasLength(1));
        expect(copy.requests![0].customId, 'req-new');
      });
    });

    group('equality', () {
      test('requests with same key fields are equal', () {
        const request1 = CreateBatchJobRequest(
          inputFiles: ['file-123'],
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );
        const request2 = CreateBatchJobRequest(
          inputFiles: ['file-123'],
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
          timeoutHours: 24, // Different but not part of equality
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('requests with different fields are not equal', () {
        const request1 = CreateBatchJobRequest(
          inputFiles: ['file-123'],
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );
        const request2 = CreateBatchJobRequest(
          inputFiles: ['file-456'], // Different
          endpoint: '/v1/chat/completions',
          model: 'mistral-small-latest',
        );

        expect(request1, isNot(equals(request2)));
      });
    });

    test('toString returns readable representation', () {
      const request = CreateBatchJobRequest(
        inputFiles: ['file-123'],
        endpoint: '/v1/chat/completions',
        model: 'mistral-small-latest',
      );

      expect(request.toString(), contains('file-123'));
      expect(request.toString(), contains('/v1/chat/completions'));
      expect(request.toString(), contains('mistral-small-latest'));
    });
  });
}
