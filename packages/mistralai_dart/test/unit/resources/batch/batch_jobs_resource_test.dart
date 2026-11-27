@TestOn('vm')
library;

import 'dart:async';
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
    test('creates an agent batch with inline requests and timeout', () async {
      final client = clientReturning({
        'id': 'batch-123',
        'agent_id': 'agent-123',
        'model': null,
        'endpoint': '/v1/agents/completions',
        'input_files': <String>[],
        'status': 'QUEUED',
        'created_at': 1705312800,
        'errors': <Map<String, dynamic>>[],
        'total_requests': 1,
        'completed_requests': 0,
        'succeeded_requests': 0,
        'failed_requests': 0,
      });
      addTearDown(client.close);

      final result = await client.batch.jobs.create(
        request: const CreateBatchJobRequest(
          endpoint: '/v1/agents/completions',
          agentId: 'agent-123',
          timeoutHours: 5,
          requests: [
            BatchRequest(body: {'prompt': 'Hi'}, customId: 'request-1'),
          ],
        ),
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/batch/jobs');
      expect(jsonDecode((captured as http.Request).body), {
        'endpoint': '/v1/agents/completions',
        'agent_id': 'agent-123',
        'timeout_hours': 5,
        'requests': [
          {
            'body': {'prompt': 'Hi'},
            'custom_id': 'request-1',
          },
        ],
      });
      expect(result.agentId, 'agent-123');
      expect(result.model, isNull);
      expect(result.toJson()['created_at'], 1705312800);
      expect(result.toJson()['errors'], isEmpty);
    });

    test('sends status arrays and all documented list filters', () async {
      final client = clientReturning({
        'data': <Map<String, dynamic>>[],
        'total': 0,
      });
      addTearDown(client.close);

      final result = await client.batch.jobs.list(
        page: 2,
        pageSize: 7,
        model: 'mistral-small-latest',
        agentId: 'agent-123',
        statuses: [BatchJobStatus.success, BatchJobStatus.timedOut],
        metadata: {'project': 'offline'},
        createdAfter: '2026-11-27T00:00:00Z',
        createdByMe: true,
        orderBy: 'created',
      );

      expect(captured.method, 'GET');
      expect(captured.url.queryParametersAll, {
        'page': ['2'],
        'page_size': ['7'],
        'model': ['mistral-small-latest'],
        'agent_id': ['agent-123'],
        'status': ['SUCCESS', 'TIMEOUT_EXCEEDED'],
        'project': ['offline'],
        'created_after': ['2026-11-27T00:00:00Z'],
        'created_by_me': ['true'],
        'order_by': ['created'],
      });
      expect(result.total, 0);
    });

    test(
      'retrieves inline outputs and preserves the canonical file keys',
      () async {
        final client = clientReturning({
          'id': 'batch-123',
          'status': 'SUCCESS',
          'output_file': 'file-1',
          'error_file': 'file-2',
          'outputs': [
            {
              'custom_id': 'request-1',
              'response': {'status_code': 200},
            },
          ],
        });
        addTearDown(client.close);

        final job = await client.batch.jobs.retrieve(
          jobId: 'batch-123',
          inline: true,
        );

        expect(captured.url.path, '/v1/batch/jobs/batch-123');
        expect(captured.url.queryParameters, {'inline': 'true'});
        expect(job.outputFileId, 'file-1');
        expect(job.errorFileId, 'file-2');
        expect(job.outputs?.single['response'], {'status_code': 200});
        expect(job.toJson()['output_file'], 'file-1');
        expect(job.toJson()['error_file'], 'file-2');
        final roundTrip = BatchJob.fromJson(
          jsonDecode(jsonEncode(job.toJson())) as Map<String, dynamic>,
        );
        expect(roundTrip, job);
        expect(roundTrip.hashCode, job.hashCode);
      },
    );

    test('polls parallel jobs independently until they stop', () async {
      final statusQueues = {
        'batch-1': ['CANCELLATION_REQUESTED', 'CANCELLED'],
        'batch-2': ['RUNNING', 'SUCCESS'],
      };
      final client = MistralClient(
        httpClient: MockClient((request) async {
          final id = request.url.pathSegments.last;
          final status = statusQueues[id]!.removeAt(0);
          return http.Response(jsonEncode({'id': id, 'status': status}), 200);
        }),
      );
      addTearDown(client.close);

      final progress = <BatchJobStatus>[];
      final canceled = BatchJobPoller(
        client: client,
        jobId: 'batch-1',
        pollInterval: Duration.zero,
        onProgress: (job) => progress.add(job.status),
      ).poll();
      final error = expectLater(
        canceled,
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('CANCELLED'),
          ),
        ),
      );
      final done = await BatchJobPoller(
        client: client,
        jobId: 'batch-2',
        pollInterval: Duration.zero,
      ).poll();

      await error;
      expect(progress, [
        BatchJobStatus.cancellationRequested,
        BatchJobStatus.cancelled,
      ]);
      expect(done.status, BatchJobStatus.success);
      expect(statusQueues.values.expand((queue) => queue), isEmpty);
    });

    test('reports a server timeout as a terminal job failure', () async {
      final client = clientReturning({
        'id': 'batch-1',
        'status': 'TIMEOUT_EXCEEDED',
      });
      addTearDown(client.close);

      await expectLater(
        BatchJobPoller(client: client, jobId: 'batch-1').poll(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('TIMEOUT_EXCEEDED'),
          ),
        ),
      );
    });

    test('enforces the polling deadline during a stalled request', () async {
      final response = Completer<http.Response>();
      final client = MistralClient(
        httpClient: MockClient((_) => response.future),
      );
      addTearDown(client.close);

      final progress = <BatchJob>[];
      await expectLater(
        BatchJobPoller(
          client: client,
          jobId: 'batch-1',
          timeout: const Duration(milliseconds: 20),
          onProgress: progress.add,
        ).poll(),
        throwsA(isA<TimeoutException>()),
      );
      response.complete(
        http.Response('{"id":"batch-1","status":"SUCCESS"}', 200),
      );
      await Future<void>.delayed(Duration.zero);
      expect(progress, isEmpty);
    });
  });
}
