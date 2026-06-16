import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

/// Fixture helpers for deployment API responses.
class DeploymentFixtures {
  DeploymentFixtures._();

  static Map<String, dynamic> deployment({
    String id = 'dpl_test123',
    String name = 'Test Deployment',
    String status = 'active',
    String? description = 'A test deployment',
    Map<String, dynamic>? schedule,
    Map<String, dynamic>? pausedReason,
    String? archivedAt,
  }) {
    return {
      'type': 'deployment',
      'id': id,
      'name': name,
      'description': description,
      'agent': {'type': 'agent', 'id': 'agent_test123', 'version': 1},
      'environment_id': 'env_test123',
      'vault_ids': <String>['vault_abc'],
      'initial_events': [
        {
          'type': 'user.message',
          'content': [
            {'type': 'text', 'text': 'Hello'},
          ],
        },
      ],
      'resources': <Map<String, dynamic>>[],
      'metadata': <String, String>{'team': 'eng'},
      'schedule': schedule,
      'status': status,
      'paused_reason': pausedReason,
      'created_at': '2026-04-01T00:00:00Z',
      'updated_at': '2026-04-01T00:00:00Z',
      'archived_at': archivedAt,
    };
  }

  static Map<String, dynamic> deploymentRun({
    String id = 'drun_test123',
    String deploymentId = 'dpl_test123',
    String? sessionId = 'session_test123',
    Map<String, dynamic>? error,
    Map<String, dynamic>? triggerContext,
  }) {
    return {
      'type': 'deployment_run',
      'id': id,
      'deployment_id': deploymentId,
      'trigger_context':
          triggerContext ??
          {'type': 'schedule', 'scheduled_at': '2026-04-01T09:00:00Z'},
      'session_id': sessionId,
      'error': error,
      'agent': {'type': 'agent', 'id': 'agent_test123', 'version': 1},
      'created_at': '2026-04-01T00:00:00Z',
    };
  }
}

void main() {
  late MockHttpClient mockHttpClient;
  late AnthropicClient client;

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-api-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: mockHttpClient,
    );
  });

  tearDown(() {
    client.close();
  });

  group('DeploymentsResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(DeploymentFixtures.deployment());

      final deployment = await client.deployments.create(
        const CreateDeploymentParams(
          agent: AgentParamsId(id: 'agent_test123'),
          environmentId: 'env_test123',
          name: 'Test Deployment',
          initialEvents: [
            DeploymentUserMessageEventParams(
              UserMessageEventParams(
                content: [
                  {'type': 'text', 'text': 'Hello'},
                ],
              ),
            ),
          ],
          schedule: ScheduleParams.cron(
            expression: '0 9 * * 1-5',
            timezone: 'America/Los_Angeles',
          ),
        ),
      );

      expect(deployment.id, 'dpl_test123');
      expect(deployment.name, 'Test Deployment');
      expect(deployment.status, DeploymentStatus.active);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/deployments');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
      expect(request.headers['x-api-key'], 'test-api-key');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['agent'], 'agent_test123');
      expect(body['environment_id'], 'env_test123');
      expect(body['name'], 'Test Deployment');
      expect(body['initial_events'], hasLength(1));
      expect((body['initial_events'] as List).first, {
        'type': 'user.message',
        'content': [
          {'type': 'text', 'text': 'Hello'},
        ],
      });
      expect(body['schedule'], {
        'type': 'cron',
        'expression': '0 9 * * 1-5',
        'timezone': 'America/Los_Angeles',
      });
    });

    test('list sends correct request with query params', () async {
      mockHttpClient.queueJsonResponse({
        'data': [DeploymentFixtures.deployment()],
        'next_page': null,
      });

      final response = await client.deployments.list(
        limit: 10,
        page: 'page_abc',
        agentId: 'agent_test123',
        status: 'active',
        createdAtGte: '2026-04-01T00:00:00Z',
        createdAtLte: '2026-04-30T23:59:59Z',
        includeArchived: true,
      );

      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'dpl_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/deployments');
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
      final params = request.url.queryParameters;
      expect(params['limit'], '10');
      expect(params['page'], 'page_abc');
      expect(params['agent_id'], 'agent_test123');
      expect(params['status'], 'active');
      expect(params['created_at[gte]'], '2026-04-01T00:00:00Z');
      expect(params['created_at[lte]'], '2026-04-30T23:59:59Z');
      expect(params['include_archived'], 'true');
    });

    test('retrieve sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(DeploymentFixtures.deployment());

      final deployment = await client.deployments.retrieve('dpl_test123');

      expect(deployment.id, 'dpl_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/deployments/dpl_test123');
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('update sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(
        DeploymentFixtures.deployment(name: 'Updated Deployment'),
      );

      final deployment = await client.deployments.update(
        'dpl_test123',
        const UpdateDeploymentParams(name: 'Updated Deployment'),
      );

      expect(deployment.name, 'Updated Deployment');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/deployments/dpl_test123');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['name'], 'Updated Deployment');
    });

    test('archive sends correct request with empty body', () async {
      mockHttpClient.queueJsonResponse(
        DeploymentFixtures.deployment(archivedAt: '2026-04-01T12:00:00Z'),
      );

      final deployment = await client.deployments.archive('dpl_test123');

      expect(deployment.archivedAt, isNotNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/deployments/dpl_test123/archive');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body, isEmpty);
    });

    test('pause sends correct request with empty body', () async {
      mockHttpClient.queueJsonResponse(
        DeploymentFixtures.deployment(
          status: 'paused',
          pausedReason: {'type': 'manual'},
        ),
      );

      final deployment = await client.deployments.pause('dpl_test123');

      expect(deployment.status, DeploymentStatus.paused);
      expect(deployment.pausedReason, isA<ManualDeploymentPausedReason>());

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/deployments/dpl_test123/pause');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body, isEmpty);
    });

    test('unpause sends correct request with empty body', () async {
      mockHttpClient.queueJsonResponse(DeploymentFixtures.deployment());

      final deployment = await client.deployments.unpause('dpl_test123');

      expect(deployment.status, DeploymentStatus.active);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/deployments/dpl_test123/unpause');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body, isEmpty);
    });

    test('run sends correct request and parses DeploymentRun', () async {
      mockHttpClient.queueJsonResponse(
        DeploymentFixtures.deploymentRun(triggerContext: {'type': 'manual'}),
      );

      final run = await client.deployments.run('dpl_test123');

      expect(run.id, 'drun_test123');
      expect(run.deploymentId, 'dpl_test123');
      expect(run.triggerContext, isA<ManualTriggerContext>());

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/deployments/dpl_test123/run');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body, isEmpty);
    });
  });

  group('DeploymentRunsResource', () {
    test('retrieve sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(DeploymentFixtures.deploymentRun());

      final run = await client.deploymentRuns.retrieve('drun_test123');

      expect(run.id, 'drun_test123');
      expect(run.sessionId, 'session_test123');
      expect(run.error, isNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/deployment_runs/drun_test123');
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('retrieve parses an errored run', () async {
      mockHttpClient.queueJsonResponse(
        DeploymentFixtures.deploymentRun(
          sessionId: null,
          error: {
            'type': 'agent_archived_error',
            'message': 'The agent was archived',
          },
        ),
      );

      final run = await client.deploymentRuns.retrieve('drun_test123');

      expect(run.sessionId, isNull);
      expect(run.error, isA<AgentArchivedRunError>());
      expect(
        (run.error! as AgentArchivedRunError).message,
        'The agent was archived',
      );
    });

    test('list sends correct request with query params', () async {
      mockHttpClient.queueJsonResponse({
        'data': [DeploymentFixtures.deploymentRun()],
        'next_page': 'page_next',
      });

      final response = await client.deploymentRuns.list(
        limit: 25,
        page: 'page_abc',
        deploymentId: 'dpl_test123',
        triggerType: 'schedule',
        hasError: false,
        createdAtGte: '2026-04-01T00:00:00Z',
        createdAtLte: '2026-04-30T23:59:59Z',
        createdAtGt: '2026-04-02T00:00:00Z',
        createdAtLt: '2026-04-29T00:00:00Z',
      );

      expect(response.data, hasLength(1));
      expect(response.nextPage, 'page_next');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/deployment_runs');
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
      final params = request.url.queryParameters;
      expect(params['limit'], '25');
      expect(params['page'], 'page_abc');
      expect(params['deployment_id'], 'dpl_test123');
      expect(params['trigger_type'], 'schedule');
      expect(params['has_error'], 'false');
      expect(params['created_at[gte]'], '2026-04-01T00:00:00Z');
      expect(params['created_at[lte]'], '2026-04-30T23:59:59Z');
      expect(params['created_at[gt]'], '2026-04-02T00:00:00Z');
      expect(params['created_at[lt]'], '2026-04-29T00:00:00Z');
    });
  });
}
