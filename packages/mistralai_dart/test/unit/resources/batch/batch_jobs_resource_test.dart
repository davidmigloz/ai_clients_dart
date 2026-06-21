@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('BatchJobsResource', () {
    late http.BaseRequest captured;

    MistralClient clientReturning(Map<String, dynamic> body) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    test('delete issues DELETE and parses response', () async {
      final client = clientReturning({
        'id': 'batch-123',
        'deleted': true,
        'object': 'batch.deleted',
      });
      addTearDown(client.close);

      final result = await client.batch.jobs.delete(jobId: 'batch-123');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/v1/batch/jobs/batch-123');
      expect(result.id, 'batch-123');
      expect(result.deleted, isTrue);
      expect(result.object, 'batch.deleted');
    });
  });
}
