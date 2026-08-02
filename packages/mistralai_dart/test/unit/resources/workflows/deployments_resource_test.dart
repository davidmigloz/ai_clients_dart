@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DeploymentsResource', () {
    late http.Request captured;

    MistralClient clientReturning(Object body, {int statusCode = 200}) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(body),
          statusCode,
          headers: {'content-type': 'application/json'},
        );
      });
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    Map<String, dynamic> managedJson() => {
      'service_id': 'svc-1',
      'name': 'my-deployment',
      'spec': {'github_url': 'https://github.com/org/repo'},
      'resources': <String, dynamic>{},
      'status': <String, dynamic>{},
      'created_at': '2030-01-01T00:00:00Z',
      'updated_at': '2030-01-02T00:00:00Z',
    };

    test(
      'create POSTs to the deployments path with the request body',
      () async {
        final client = clientReturning(managedJson(), statusCode: 202);
        addTearDown(client.close);

        final result = await client.workflows.deployments.create(
          request: const CreateDeploymentRequest(
            name: 'my-deployment',
            spec: DeploymentWorkerSpecInput(
              githubUrl: 'https://github.com/org/repo',
            ),
          ),
        );

        expect(captured.method, 'POST');
        expect(captured.url.path, '/v1/workflows/deployments');
        expect(jsonDecode(captured.body), {
          'name': 'my-deployment',
          'spec': {
            'github_url': 'https://github.com/org/repo',
            'entrypoint': 'worker:main',
            'revision': 'main',
          },
        });
        expect(result.serviceId, 'svc-1');
      },
    );

    test('update PATCHes the named deployment', () async {
      final client = clientReturning(managedJson(), statusCode: 202);
      addTearDown(client.close);

      await client.workflows.deployments.update(
        name: 'my-deployment',
        request: const UpdateDeploymentRequest(
          spec: WorkflowsWorkerSpecUpdate(revision: 'v2'),
        ),
      );

      expect(captured.method, 'PATCH');
      expect(captured.url.path, '/v1/workflows/deployments/my-deployment');
      expect(jsonDecode(captured.body), {
        'spec': {'revision': 'v2'},
      });
    });

    test('delete DELETEs the named deployment', () async {
      final client = clientReturning(managedJson(), statusCode: 202);
      addTearDown(client.close);

      final result = await client.workflows.deployments.delete(
        name: 'my-deployment',
      );

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/v1/workflows/deployments/my-deployment');
      expect(result.serviceId, 'svc-1');
    });

    test('start/stop/restart POST to their respective action paths', () async {
      final client = clientReturning(managedJson(), statusCode: 202);
      addTearDown(client.close);

      await client.workflows.deployments.start(name: 'my-deployment');
      expect(captured.method, 'POST');
      expect(
        captured.url.path,
        '/v1/workflows/deployments/my-deployment/start',
      );

      await client.workflows.deployments.stop(name: 'my-deployment');
      expect(captured.url.path, '/v1/workflows/deployments/my-deployment/stop');

      await client.workflows.deployments.restart(name: 'my-deployment');
      expect(
        captured.url.path,
        '/v1/workflows/deployments/my-deployment/restart',
      );
    });

    test('getLogs hits /logs and plumbs query params', () async {
      final client = clientReturning({
        'results': [
          {
            'timestamp': '2030-01-01T00:00:00Z',
            'trace_id': 'trace-1',
            'span_id': 'span-1',
            'severity_text': 'INFO',
            'body': 'hello',
            'log_attributes': {'k': 'v'},
          },
        ],
        'next_cursor': 'cursor-1',
      });
      addTearDown(client.close);

      final result = await client.workflows.deployments.getLogs(
        name: 'my-deployment',
        workerName: 'worker-1',
        workflowName: 'wf',
        after: '2030-01-01T00:00:00Z',
        before: '2030-02-01T00:00:00Z',
        order: 'desc',
        cursor: 'cur-1',
        limit: 25,
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/workflows/deployments/my-deployment/logs');
      expect(captured.url.queryParameters['worker_name'], 'worker-1');
      expect(captured.url.queryParameters['workflow_name'], 'wf');
      expect(captured.url.queryParameters['after'], '2030-01-01T00:00:00Z');
      expect(captured.url.queryParameters['before'], '2030-02-01T00:00:00Z');
      expect(captured.url.queryParameters['order'], 'desc');
      expect(captured.url.queryParameters['cursor'], 'cur-1');
      expect(captured.url.queryParameters['limit'], '25');
      expect(result.results, hasLength(1));
      expect(result.nextCursor, 'cursor-1');
    });
  });

  group('DeploymentsResource.streamLogs', () {
    Uri? capturedUrl;
    Map<String, String>? capturedHeaders;

    MistralClient streamingClient(List<String> sseLines) {
      final mockClient = MockClient.streaming((request, _) async {
        capturedUrl = request.url;
        capturedHeaders = request.headers;
        return http.StreamedResponse(
          Stream.fromIterable(sseLines.map(utf8.encode)),
          200,
        );
      });

      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    String logEvent(String body) =>
        'event: log\n'
        'data: ${jsonEncode({
          'timestamp': '2030-01-01T00:00:00Z',
          'trace_id': 'trace-1',
          'span_id': 'span-1',
          'severity_text': 'INFO',
          'body': body,
          'log_attributes': {'k': 'v'},
        })}\n\n';

    test('parses log events into DeploymentLogRecord', () async {
      final client = streamingClient([
        logEvent('first'),
        logEvent('second'),
        'data: [DONE]\n\n',
      ]);
      addTearDown(client.close);

      final records = await client.workflows.deployments
          .streamLogs(name: 'my-deployment', workerName: 'worker-1')
          .toList();

      expect(records, hasLength(2));
      expect(records.first.body, 'first');
      expect(records.last.body, 'second');
      expect(
        capturedUrl?.path,
        '/v1/workflows/deployments/my-deployment/logs/stream',
      );
      expect(capturedUrl?.queryParameters['worker_name'], 'worker-1');
    });

    test(
      'sends lastEventId as both query param and Last-Event-ID header',
      () async {
        final client = streamingClient(['data: [DONE]\n\n']);
        addTearDown(client.close);

        await client.workflows.deployments
            .streamLogs(name: 'my-deployment', lastEventId: 'evt-42')
            .toList();

        expect(capturedUrl?.queryParameters['last_event_id'], 'evt-42');
        expect(capturedHeaders?['Last-Event-ID'], 'evt-42');
      },
    );

    test('error event raises StreamException', () async {
      final errorPayload = jsonEncode({'error': 'internal', 'reason': 'boom'});
      final client = streamingClient([
        'event: error\ndata: $errorPayload\n\n',
        'data: [DONE]\n\n',
      ]);
      addTearDown(client.close);

      await expectLater(
        client.workflows.deployments.streamLogs(name: 'my-deployment').toList(),
        throwsA(isA<StreamException>()),
      );
    });
  });
}
