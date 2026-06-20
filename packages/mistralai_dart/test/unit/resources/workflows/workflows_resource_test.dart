@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Workflows resources', () {
    late http.Request captured;

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

    test('core.listWorkflows hits GET /v1/workflows with params', () async {
      final client = clientReturning({
        'workflows': [
          {'id': 'wf-1', 'name': 'wf', 'display_name': 'WF', 'archived': false},
        ],
        'next_cursor': 'cursor-1',
      });
      addTearDown(client.close);

      final result = await client.workflows.core.listWorkflows(
        archived: false,
        status: const ['running', 'completed'],
        tags: const ['a', 'b'],
        limit: 10,
        deploymentStatus: 'active',
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/workflows');
      expect(captured.url.queryParameters['archived'], 'false');
      // Array params are serialized as repeated query parameters
      // (form/explode), not comma-joined.
      expect(captured.url.queryParametersAll['status'], [
        'running',
        'completed',
      ]);
      expect(captured.url.queryParametersAll['tags'], ['a', 'b']);
      expect(captured.url.queryParameters['limit'], '10');
      expect(captured.url.queryParameters['deployment_status'], 'active');
      expect(result.workflows, hasLength(1));
      expect(result.nextCursor, 'cursor-1');
    });

    test('schedules.get hits GET /v1/workflows/schedules/{id}', () async {
      final client = clientReturning({
        'input': {'k': 'v'},
        'schedule_id': 'sched-1',
        'workflow_name': 'wf',
        'paused': false,
      });
      addTearDown(client.close);

      final result = await client.workflows.schedules.get(
        scheduleId: 'sched-1',
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/workflows/schedules/sched-1');
      expect(result.scheduleId, 'sched-1');
      expect(result.workflowName, 'wf');
    });

    test('schedules.update issues PATCH and parses response', () async {
      final client = clientReturning({'schedule_id': 'sched-1'});
      addTearDown(client.close);

      final result = await client.workflows.schedules.update(
        scheduleId: 'sched-1',
        request: WorkflowScheduleUpdateRequest(
          schedule: PartialScheduleDefinition(jitter: 'PT5M'),
        ),
      );

      expect(captured.method, 'PATCH');
      expect(captured.url.path, '/v1/workflows/schedules/sched-1');
      expect(jsonDecode(captured.body), {
        'schedule': {'jitter': 'PT5M'},
      });
      expect(result.scheduleId, 'sched-1');
    });

    test('schedules.list plumbs query params', () async {
      final client = clientReturning({'schedules': <dynamic>[]});
      addTearDown(client.close);

      await client.workflows.schedules.list(
        workflowName: 'wf',
        userId: 'current',
        status: 'active',
        pageSize: 25,
        nextPageToken: 'token-1',
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/workflows/schedules');
      expect(captured.url.queryParameters['workflow_name'], 'wf');
      expect(captured.url.queryParameters['user_id'], 'current');
      expect(captured.url.queryParameters['status'], 'active');
      expect(captured.url.queryParameters['page_size'], '25');
      expect(captured.url.queryParameters['next_page_token'], 'token-1');
    });

    test('deployments.list plumbs new query params', () async {
      final client = clientReturning({'deployments': <dynamic>[]});
      addTearDown(client.close);

      await client.workflows.deployments.list(
        isHardened: true,
        search: 'prod',
        limit: 50,
        cursor: 'cur-1',
        workspaceId: 'ws-1',
      );

      expect(captured.url.path, '/v1/workflows/deployments');
      expect(captured.url.queryParameters['is_hardened'], 'true');
      expect(captured.url.queryParameters['search'], 'prod');
      expect(captured.url.queryParameters['limit'], '50');
      expect(captured.url.queryParameters['cursor'], 'cur-1');
      expect(captured.url.queryParameters['workspace_id'], 'ws-1');
    });

    test('core.bulkArchive PUTs /v1/workflows/archive', () async {
      final client = clientReturning({
        'archived': [
          {'id': 'wf-1', 'name': 'wf', 'display_name': 'WF'},
        ],
        'errored': [
          {'workflow_id': 'wf-2', 'message': 'failed'},
        ],
      });
      addTearDown(client.close);

      final result = await client.workflows.core.bulkArchive(
        request: WorkflowBulkArchiveRequest(
          workflowIds: const ['wf-1', 'wf-2'],
        ),
      );

      expect(captured.method, 'PUT');
      expect(captured.url.path, '/v1/workflows/archive');
      expect(jsonDecode(captured.body), {
        'workflow_ids': ['wf-1', 'wf-2'],
      });
      expect(result.archived, hasLength(1));
      expect(result.errored, hasLength(1));
      expect(result.errored?.first.workflowId, 'wf-2');
    });

    test('core.bulkUnarchive PUTs /v1/workflows/unarchive', () async {
      final client = clientReturning({
        'unarchived': [
          {'id': 'wf-1', 'name': 'wf', 'display_name': 'WF'},
        ],
      });
      addTearDown(client.close);

      final result = await client.workflows.core.bulkUnarchive(
        request: WorkflowBulkUnarchiveRequest(workflowIds: const ['wf-1']),
      );

      expect(captured.method, 'PUT');
      expect(captured.url.path, '/v1/workflows/unarchive');
      expect(jsonDecode(captured.body), {
        'workflow_ids': ['wf-1'],
      });
      expect(result.unarchived, hasLength(1));
      expect(result.errored, isNull);
    });

    test('schedules.pause POSTs to /pause with note body', () async {
      final client = clientReturning(<String, dynamic>{});
      addTearDown(client.close);

      await client.workflows.schedules.pause(
        scheduleId: 'sched-1',
        note: 'maintenance',
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/workflows/schedules/sched-1/pause');
      expect(jsonDecode(captured.body), {'note': 'maintenance'});
    });

    test('schedules.resume POSTs to /resume with empty body', () async {
      final client = clientReturning(<String, dynamic>{});
      addTearDown(client.close);

      await client.workflows.schedules.resume(scheduleId: 'sched-1');

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/workflows/schedules/sched-1/resume');
      expect(jsonDecode(captured.body), <String, dynamic>{});
    });

    test('schedules.trigger POSTs to /trigger with overlap body', () async {
      final client = clientReturning(<String, dynamic>{});
      addTearDown(client.close);

      await client.workflows.schedules.trigger(
        scheduleId: 'sched-1',
        overlap: ScheduleOverlapPolicy.skip,
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/workflows/schedules/sched-1/trigger');
      expect(jsonDecode(captured.body), {'overlap': 1});
    });

    test('executions.getLogs hits /logs and plumbs query params', () async {
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

      final result = await client.workflows.executions.getLogs(
        executionId: 'exec-1',
        runId: 'run-1',
        activityId: '42',
        after: '2030-01-01T00:00:00Z',
        before: '2030-02-01T00:00:00Z',
        order: 'desc',
        cursor: 'cur-1',
        limit: 25,
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/workflows/executions/exec-1/logs');
      expect(captured.url.queryParameters['run_id'], 'run-1');
      expect(captured.url.queryParameters['activity_id'], '42');
      expect(captured.url.queryParameters['after'], '2030-01-01T00:00:00Z');
      expect(captured.url.queryParameters['before'], '2030-02-01T00:00:00Z');
      expect(captured.url.queryParameters['order'], 'desc');
      expect(captured.url.queryParameters['cursor'], 'cur-1');
      expect(captured.url.queryParameters['limit'], '25');
      expect(result.results, hasLength(1));
      expect(result.results.first.traceId, 'trace-1');
      expect(result.nextCursor, 'cursor-1');
    });

    test('runs.list plumbs new query params', () async {
      final client = clientReturning({'executions': <dynamic>[]});
      addTearDown(client.close);

      await client.workflows.runs.list(
        deploymentName: 'dep',
        sortBy: 'start_time',
        order: 'desc',
        startTimeAfter: '2030-01-01T00:00:00Z',
        endTimeBefore: '2030-02-01T00:00:00Z',
        userId: 'current',
      );

      expect(captured.url.path, '/v1/workflows/runs');
      expect(captured.url.queryParameters['deployment_name'], 'dep');
      expect(captured.url.queryParameters['sort_by'], 'start_time');
      expect(captured.url.queryParameters['order'], 'desc');
      expect(
        captured.url.queryParameters['start_time_after'],
        '2030-01-01T00:00:00Z',
      );
      expect(
        captured.url.queryParameters['end_time_before'],
        '2030-02-01T00:00:00Z',
      );
      expect(captured.url.queryParameters['user_id'], 'current');
    });
  });
}
