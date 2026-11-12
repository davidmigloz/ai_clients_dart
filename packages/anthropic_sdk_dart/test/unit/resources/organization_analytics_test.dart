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
    'continuing a report snapshots the original filters and dimensions',
    () async {
      final models = ['original-model'];
      final filters = {AnalyticsFilter.model: models};
      final dimensions = ['model'];
      final query = UsageCostAnalyticsQuery(
        startingAt: DateTime.parse(_start),
        filters: filters,
        groupBy: dimensions,
      );
      transport
        ..queueJsonResponse({
          'data': <Object>[],
          'has_more': true,
          'next_page': 'keep + / =',
        })
        ..queueJsonResponse({
          'data': <Object>[],
          'has_more': false,
          'next_page': null,
        });
      final analytics = client.organization.analytics;
      final report = await analytics.usage(query);
      models.add('another-model');
      filters.clear();
      dimensions.add('actor');
      expect(query.filters.clear, throwsUnsupportedError);
      expect(
        () => query.filters[AnalyticsFilter.model]!.clear(),
        throwsUnsupportedError,
      );
      expect(query.groupBy.clear, throwsUnsupportedError);
      await analytics.usage(query.withPage(report.nextPage));
      expect(transport.requests.last.url.queryParametersAll, {
        ...transport.requests.first.url.queryParametersAll,
        'page': ['keep + / ='],
      });
    },
  );

  test('a continuing report with a null or empty cursor fails', () async {
    final analytics = client.organization.analytics;
    final query = UsageCostAnalyticsQuery(startingAt: DateTime.parse(_start));
    for (final cursor in [null, '']) {
      transport.queueJsonResponse({
        'data': <Object>[],
        'has_more': true,
        'next_page': cursor,
      });
      await expectLater(
        analytics.cost(query),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Missing analytics continuation token',
          ),
        ),
      );
    }
  });

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

  test('legacy Console selectors preserve beta overrides', () async {
    final configured = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-admin'),
        defaultHeaders: {'anthropic-beta': 'configured-beta'},
      ),
      httpClient: transport,
    );
    addTearDown(configured.close);
    for (var index = 0; index < 2; index++) {
      transport.queueJsonResponse({
        'data': <Object>[],
        'has_more': false,
        'next_page': null,
      });
    }
    final analytics = configured.organization.analytics;
    final start = DateTime.parse(_start);
    await analytics.messagesUsageReport(startingAt: start);
    await analytics.consoleCostReport(
      startingAt: start,
      betas: ['caller-beta'],
    );
    expect(
      transport.requests.map((request) => request.headers['anthropic-beta']),
      ['configured-beta', 'caller-beta'],
    );
  });

  group('legacy usage and cost reports', () {
    const usage = {
      'cache_creation': {
        'ephemeral_1h_input_tokens': 0,
        'ephemeral_5m_input_tokens': 2,
      },
      'cache_read_input_tokens': 3,
      'uncached_input_tokens': 17,
      'output_tokens': 5,
      'server_tool_use': {'web_search_requests': 1},
    };
    const enterpriseDimensions = {
      'claude_tag_category': null,
      'claude_tag_user_id': null,
      'context_window': null,
      'inference_geo': null,
      'model': null,
      'product': 'claude_code',
      'rbac_group_id': null,
      'requests': null,
      'slack_channel_id': null,
      'speed': null,
    };
    const cost = {'amount': '0.0123456789', 'currency': 'USD'};
    const userActor = {
      'type': 'user_actor',
      'user_id': 'user_fixture',
      'name': null,
      'email': 'legacy@example.com',
      'deleted': false,
    };

    Map<String, dynamic> page(
      List<Map<String, dynamic>> data, {
      bool enterprise = false,
    }) => {
      'data': data,
      'has_more': true,
      'next_page': 'next_cursor',
      if (enterprise) 'organization_id': 'd1937daa-177f-4be4-b522-4b5f5482e378',
      if (enterprise) 'data_refreshed_at': null,
    };

    Map<String, dynamic> bucket(Map<String, dynamic> result) => {
      'starting_at': '2026-10-01T00:00:00Z',
      'ending_at': '2026-10-02T00:00:00Z',
      'results': [result],
    };

    void checkRequest(
      String path,
      Map<String, List<String>> query, {
      String version = '2026-10-21',
    }) {
      final request = transport.lastRequest!;
      expect(request.url.path, '/admin/v1/organizations$path');
      expect(request.method, 'GET');
      expect(request.url.queryParametersAll, query);
      expect(request.headers['anthropic-beta'], isNull);
      expect(request.headers['anthropic-version'], version);
      expect(request.headers['anthropic-workspace-id'], isNull);
      expect(request.headers['x-api-key'], 'fixture-admin');
    }

    test(
      'Console Messages usage uses repeated singular context_window',
      () async {
        transport.queueJsonResponse(
          page([
            bucket({
              ...usage,
              'api_key_id': null,
              'workspace_id': null,
              'account_id': 'user_fixture',
              'service_account_id': null,
              'model': 'claude-sonnet-5',
              'service_tier': null,
              'context_window': null,
              'inference_geo': null,
              'speed': null,
            }),
          ]),
        );

        final result = await client.organization.analytics.messagesUsageReport(
          startingAt: DateTime.parse(_start),
          endingAt: DateTime.parse(_end),
          bucketWidth: AnalyticsBucketWidth.day,
          accountIds: const ['user_fixture'],
          serviceAccountIds: const ['svac_first', 'svac_second'],
          contextWindows: const ['0-200k', '200k-1M'],
          groupBy: const ['account_id', 'model'],
          limit: 2,
          page: 'previous_cursor',
        );
        final row = result.data.single.results.single;
        expect(row.group.accountId, 'user_fixture');
        expect(row.group.model, 'claude-sonnet-5');
        expect(row.usage.uncachedInputTokens, 17);
        expect(row.usage.totalTokens, isNull);
        expect(result.nextPage, 'next_cursor');
        checkRequest('/usage_report/messages', {
          'starting_at': [_start],
          'ending_at': [_end],
          'bucket_width': ['1d'],
          'account_ids[]': ['user_fixture'],
          'service_account_ids[]': ['svac_first', 'svac_second'],
          'context_window[]': ['0-200k', '200k-1M'],
          'group_by[]': ['account_id', 'model'],
          'limit': ['2'],
          'page': ['previous_cursor'],
        });
      },
    );

    test(
      'Console cost preserves daily bucket and decimal minor units',
      () async {
        transport.queueJsonResponse(
          page([
            bucket({
              ...cost,
              'workspace_id': null,
              'description': 'Token costs',
              'cost_type': 'tokens',
              'context_window': '0-200k',
              'model': 'claude-sonnet-5',
              'service_tier': 'standard',
              'token_type': 'output_tokens',
              'inference_geo': 'global',
              'speed': 'standard',
            }),
          ]),
        );
        final report = await client.organization.analytics.consoleCostReport(
          startingAt: DateTime.parse(_start),
          groupBy: const ['description', 'workspace_id'],
        );
        final row = report.data.single.results.single;
        expect(row.group.description, 'Token costs');
        expect(row.cost.amount, '0.0123456789');
        expect(row.cost.listAmount, isNull);
        expect(report.data.single.startingAt, DateTime.utc(2026, 10, 1));
        checkRequest('/cost_report', {
          'starting_at': [_start],
          'bucket_width': ['1d'],
          'group_by[]': ['description', 'workspace_id'],
        });
      },
    );

    test(
      'Claude Code report uses a calendar day and retains model counters',
      () async {
        transport.queueJsonResponse(
          page([
            {
              'actor': {'type': 'api_actor', 'api_key_name': 'fixture-key'},
              'core_metrics': {
                'commits_by_claude_code': 4,
                'lines_of_code': {'added': 43, 'removed': 5},
                'num_sessions': 2,
                'pull_requests_by_claude_code': 1,
              },
              'customer_type': 'api',
              'date': '2026-10-01T00:00:00Z',
              'is_remote': true,
              'model_breakdown': [
                {
                  'estimated_cost': {'amount': 14, 'currency': 'USD'},
                  'model': 'claude-sonnet-5',
                  'tokens': {
                    'cache_creation': 1,
                    'cache_read': 3,
                    'input': 15,
                    'output': 9,
                  },
                },
              ],
              'organization_id': 'd1937daa-177f-4be4-b522-4b5f5482e378',
              'subscription_type': null,
              'terminal_type': 'vscode',
              'tool_actions': {
                'Edit': {'accepted': 2, 'rejected': 1},
              },
            },
          ]),
        );
        final report = await client.organization.analytics
            .claudeCodeUsageReport(date: '2026-10-01', page: 'previous_cursor');
        final row = report.data.single;
        expect(row.actor.apiKeyName, 'fixture-key');
        expect(row.date, DateTime.utc(2026, 10, 1));
        expect(row.coreMetrics.linesAdded, 43);
        expect(row.models.single.estimatedCost, 14);
        expect(row.models.single.cacheReadTokens, 3);
        expect(row.toolActions['Edit']?.rejected, 1);
        checkRequest('/usage_report/claude_code', {
          'starting_at': ['2026-10-01'],
          'page': ['previous_cursor'],
        });

        expect(
          () => client.organization.analytics.claudeCodeUsageReport(
            date: '2026-02-31',
          ),
          throwsArgumentError,
        );
        expect(transport.requests, hasLength(1));
      },
    );

    test(
      'Enterprise usage report reads bucketed results and user filters',
      () async {
        transport.queueJsonResponse(
          page([
            bucket({...usage, ...enterpriseDimensions}),
          ], enterprise: true),
        );
        final result = await client.organization.analytics.usageReport(
          LegacyEnterpriseAnalyticsQuery(
            startingAt: DateTime.parse(_start),
            filters: const {
              AnalyticsFilter.userId: ['user_a', 'user_b'],
            },
            bucketWidth: AnalyticsBucketWidth.day,
            page: 'previous_cursor',
          ),
        );
        expect(result.data.single.results.single.usage.outputTokens, 5);
        expect(result.organizationId, isNotNull);
        expect(result.toJson(), containsPair('data_refreshed_at', null));
        checkRequest('/analytics/usage_report', {
          'starting_at': [_start],
          'bucket_width': ['1d'],
          'user_ids[]': ['user_a', 'user_b'],
          'page': ['previous_cursor'],
        });
      },
    );

    test(
      'Enterprise cost report keeps list-price amounts and cost group',
      () async {
        transport.queueJsonResponse(
          page([
            bucket({
              ...cost,
              ...enterpriseDimensions,
              'cost_type': 'tokens',
              'token_type': 'output_tokens',
              'list_amount': '0.02000',
            }),
          ], enterprise: true),
        );
        final result = await client.organization.analytics.costReport(
          LegacyEnterpriseAnalyticsQuery(
            startingAt: DateTime.parse(_start),
            groupBy: const ['cost_type', 'token_type'],
            filters: const {
              AnalyticsFilter.userId: ['user_a', 'user_b'],
            },
          ),
        );
        final row = result.data.single.results.single;
        expect(row.group.tokenType, 'output_tokens');
        expect(row.cost.listAmount, '0.02000');
        checkRequest('/analytics/cost_report', {
          'starting_at': [_start],
          'group_by[]': ['cost_type', 'token_type'],
          'user_ids[]': ['user_a', 'user_b'],
        });
      },
    );

    test('Enterprise user usage accepts legacy actor email', () async {
      final legacy = AnthropicClient(
        config: client.config.copyWith(
          apiVersion: AnthropicConfig.legacyApiVersion,
        ),
        httpClient: transport,
      );
      addTearDown(legacy.close);
      transport.queueJsonResponse(
        page([
          {
            ...usage,
            ...enterpriseDimensions,
            'actor': userActor,
            'starting_at': null,
            'ending_at': null,
            'total_tokens': 27,
          },
        ], enterprise: true),
      );
      final result = await legacy.organization.analytics.userUsageReport(
        LegacyEnterpriseAnalyticsQuery(startingAt: DateTime.parse(_start)),
        orderBy: 'total_tokens',
        order: 'desc',
        excludeDeletedUsers: true,
      );
      final row = result.data.single;
      expect(row.group.actor?.emailAddress, 'legacy@example.com');
      expect(row.group.actor?.toJson(), userActor);
      expect(row.startingAt, isNull);
      checkRequest('/analytics/user_usage_report', {
        'starting_at': [_start],
        'order_by': ['total_tokens'],
        'order': ['desc'],
        'exclude_deleted_users': ['true'],
      }, version: '2023-06-01');
    });

    test(
      'Enterprise user cost reads current email_address and optional times',
      () async {
        final actor = {...userActor}..remove('email');
        transport.queueJsonResponse(
          page([
            {
              ...cost,
              ...enterpriseDimensions,
              'actor': {...actor, 'email_address': null},
              'starting_at': _start,
              'ending_at': _end,
              'cost_type': 'tokens',
              'token_type': null,
              'list_amount': '0.02000',
            },
          ], enterprise: true),
        );
        final result = await client.organization.analytics.userCostReport(
          LegacyEnterpriseAnalyticsQuery(
            startingAt: DateTime.parse(_start),
            endingAt: DateTime.parse(_end),
            bucketWidth: AnalyticsBucketWidth.hour,
          ),
          orderBy: 'amount',
        );
        final row = result.data.single;
        expect(row.group.actor?.emailAddress, isNull);
        expect(row.group.actor?.toJson(), containsPair('email_address', null));
        expect(row.endingAt, DateTime.parse(_end));
        expect(row.cost.amount, '0.0123456789');
        checkRequest('/analytics/user_cost_report', {
          'starting_at': [_start],
          'ending_at': [_end],
          'bucket_width': ['1h'],
          'order_by': ['amount'],
        });
      },
    );
  });
}
