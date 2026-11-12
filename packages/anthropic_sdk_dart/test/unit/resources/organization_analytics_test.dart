import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _start = '2026-10-01T08:09:30.000Z';
const _end = '2026-10-02T08:09:30.000Z';
const _beta = 'analytics-usage-cost-2026-08-24';
const _group = {
  'actor': null,
  'actor_type': null,
  'agent_id': null,
  'api_key_id': null,
  'claude_tag_category': null,
  'claude_tag_user_id': null,
  'context_window': null,
  'deployment_id': null,
  'environment_id': null,
  'inference_geo': null,
  'model': null,
  'organization_id': null,
  'product': null,
  'rbac_group_id': null,
  'service_tier': null,
  'session_id': null,
  'slack_channel_id': null,
  'speed': null,
  'user_profile_id': null,
  'workspace_id': null,
};

void main() {
  late AnthropicClient client;
  late MockHttpClient transport;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        baseUrl: 'https://proxy.fixture/admin',
        authProvider: ApiKeyProvider('fixture-admin'),
        workspaceId: 'wrkspc_request_scope',
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  test(
    'preserves configured or per-call betas with the required gate',
    () async {
      final betaClient = AnthropicClient(
        config: const AnthropicConfig(
          authProvider: ApiKeyProvider('fixture-admin'),
          defaultHeaders: {'anthropic-beta': 'configured-beta,$_beta'},
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: transport,
      );
      addTearDown(betaClient.close);
      const emptyPage = {
        'data': <Object>[],
        'has_more': false,
        'next_page': null,
      };
      transport
        ..queueJsonResponse(emptyPage)
        ..queueJsonResponse(emptyPage);
      final analytics = betaClient.organization.analytics;
      final query = UsageCostAnalyticsQuery(startingAt: DateTime.parse(_start));
      await analytics.usage(query);
      await analytics.cost(query, betas: ['caller-beta']);
      expect(
        transport.requests.map((request) => request.headers['anthropic-beta']),
        ['configured-beta,$_beta', 'caller-beta,$_beta'],
      );
    },
  );

  test(
    'usage sends UTC timestamps, dimensions and repeat filters on both pages',
    () async {
      final row = {
        'starting_at': '2026-10-01T08:00:00Z',
        'ending_at': '2026-10-01T09:00:00Z',
        'group': {
          ..._group,
          'actor': {
            'type': 'user_actor',
            'user_id': 'user_fixture',
            'name': null,
            'email_address': 'current@example.com',
            'deleted': false,
          },
          'organization_id': 'd1937daa-177f-4be4-b522-4b5f5482e378',
          'model': 'claude-sonnet-5',
        },
        'usage': {
          'cache_creation': {
            'ephemeral_1h_input_tokens': 8,
            'ephemeral_5m_input_tokens': 13,
          },
          'cache_read_input_tokens': 144,
          'uncached_input_tokens': 20,
          'output_tokens': 34,
          'server_tool_use': {'web_search_requests': 3},
          'total_tokens': 219,
          'requests': null,
        },
      };
      transport
        ..queueJsonResponse({
          'data': [row],
          'has_more': true,
          'next_page': 'opaque_cursor',
          'data_refreshed_at': '2026-10-03T00:00:00Z',
        })
        ..queueJsonResponse({
          'data': <Object>[],
          'has_more': false,
          'next_page': null,
          'data_refreshed_at': '2026-10-03T00:00:00Z',
        });

      final query = UsageCostAnalyticsQuery(
        startingAt: DateTime.parse('2026-10-01T10:09:30+02:00'),
        endingAt: DateTime.parse(_end),
        timeBucketWidth: AnalyticsBucketWidth.hour,
        groupBy: const ['actor', 'model', 'organization_id'],
        filters: const {
          AnalyticsFilter.actorType: ['user_actor', 'service_account_actor'],
          AnalyticsFilter.organizationId: [
            'd1937daa-177f-4be4-b522-4b5f5482e378',
            '2b64f906-b99c-4f5b-928f-a5681b2c8fb1',
          ],
          AnalyticsFilter.apiKeyId: ['apikey_fixture', ''],
          AnalyticsFilter.workspaceId: [],
          AnalyticsFilter.claudeTagCategory: ['engaged'],
        },
        orderBy: 'time',
        order: 'asc',
        excludeDeletedUsers: false,
        limit: 5,
      );
      final report = await client.organization.analytics.usage(query);
      expect(
        report.data.single.group.actor?.emailAddress,
        'current@example.com',
      );
      expect(
        report.data.single.group.organizationId,
        'd1937daa-177f-4be4-b522-4b5f5482e378',
      );
      expect(report.data.single.usage.cacheCreation.ephemeral1hInputTokens, 8);
      expect(report.data.single.usage.serverToolUse.webSearchRequests, 3);
      expect(report.data.single.usage.totalTokens, 219);
      expect(report.data.single.usage.requests, isNull);
      expect(report.data.single.toJson(), row);
      expect(report.nextPage, 'opaque_cursor');
      expect(report.hasMore, isTrue);
      final following = await client.organization.analytics.usage(
        query.withPage(report.nextPage),
      );
      expect(following.data, isEmpty);
      expect(following.dataRefreshedAt, report.dataRefreshedAt);
      expect(following.hasMore, isFalse);
      expect(following.nextPage, isNull);

      const firstQuery = {
        'starting_at': [_start],
        'ending_at': [_end],
        'time_bucket_width': ['1h'],
        'group_by[]': ['actor', 'model', 'organization_id'],
        'actor_types[]': ['user_actor', 'service_account_actor'],
        'organization_ids[]': [
          'd1937daa-177f-4be4-b522-4b5f5482e378',
          '2b64f906-b99c-4f5b-928f-a5681b2c8fb1',
        ],
        'api_key_ids[]': ['apikey_fixture', ''],
        'claude_tag_categories[]': ['engaged'],
        'order_by': ['time'],
        'order': ['asc'],
        'exclude_deleted_users': ['false'],
        'limit': ['5'],
      };
      expect(transport.requests.first.url.queryParametersAll, firstQuery);
      expect(transport.requests.last.url.queryParametersAll, {
        ...firstQuery,
        'page': ['opaque_cursor'],
      });
      for (final request in transport.requests) {
        expect(request.method, 'GET');
        expect(request.url.path, '/admin/v1/organizations/analytics/usage');
        expect(request.headers['anthropic-beta'], _beta);
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(request.headers['anthropic-workspace-id'], isNull);
        expect(request.headers['x-api-key'], 'fixture-admin');
      }
    },
  );

  test(
    'cost preserves precise amounts, provider identity and nullable dimensions',
    () async {
      const cost = {
        'amount': '1000000000000000.123456789',
        'list_amount': '1000000000000000.123456799',
        'currency': 'USD',
        'requests': null,
      };
      transport.queueJsonResponse({
        'data': [
          {
            'starting_at': _start,
            'ending_at': _end,
            'group': {
              ..._group,
              'actor': {
                'type': 'federated_actor',
                'subject': null,
                'provider': {
                  'type': 'aws',
                  'account_id': '123456789012',
                  'signed_principal': 'fixture',
                },
              },
              'cost_type': 'tokens',
              'token_type': null,
            },
            'cost': cost,
          },
        ],
        'has_more': false,
        'next_page': null,
        'data_refreshed_at': '2026-10-03T00:00:00Z',
      });
      final report = await client.organization.analytics.cost(
        UsageCostAnalyticsQuery(
          startingAt: DateTime.parse(_start),
          groupBy: const ['actor', 'cost_type'],
          filters: const {
            AnalyticsFilter.apiKeyId: ['apikey_fixture'],
            AnalyticsFilter.deploymentId: ['dpl_fixture'],
          },
        ),
      );
      final row = report.data.single;
      expect(row.group.actor?.provider?.accountId, '123456789012');
      expect(row.group.costType, 'tokens');
      expect(row.group.tokenType, isNull);
      expect(row.cost.toJson(), cost);
      expect(row.cost.amount, '1000000000000000.123456789');
      expect(row.cost.listAmount, '1000000000000000.123456799');
      final request = transport.lastRequest!;
      expect(request.url.path, '/admin/v1/organizations/analytics/cost');
      expect(request.headers['anthropic-beta'], _beta);
      expect(request.url.queryParametersAll, {
        'starting_at': [_start],
        'group_by[]': ['actor', 'cost_type'],
        'api_key_ids[]': ['apikey_fixture'],
        'deployment_ids[]': ['dpl_fixture'],
      });
    },
  );

  test('time bucket without an end date is rejected before dispatch', () {
    expect(
      () => client.organization.analytics.usage(
        UsageCostAnalyticsQuery(
          startingAt: DateTime.parse(_start),
          timeBucketWidth: AnalyticsBucketWidth.hour,
        ),
      ),
      throwsArgumentError,
    );
    expect(transport.requests, isEmpty);
  });

  test(
    'HTTP analytics permission failure retains provider diagnostics',
    () async {
      transport.queueJsonResponse({
        'type': 'error',
        'request_id': 'req_analytics',
        'error': {
          'type': 'permission_error',
          'message': 'Analytics scope required',
        },
      }, statusCode: 403);
      await expectLater(
        client.organization.analytics.cost(
          UsageCostAnalyticsQuery(startingAt: DateTime.parse(_start)),
        ),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', 403)
              .having(
                (error) => error.requestId,
                'request ID',
                'req_analytics',
              ),
        ),
      );
      expect(transport.lastRequest?.headers['anthropic-beta'], _beta);
    },
  );
}
