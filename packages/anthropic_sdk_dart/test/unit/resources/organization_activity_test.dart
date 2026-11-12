import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

void main() {
  late AnthropicClient client;
  late MockHttpClient transport;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        baseUrl: 'https://proxy.fixture/admin',
        authProvider: ApiKeyProvider('analytics-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  test(
    'activity continuation snapshots filters and normalizes empty cursors',
    () async {
      final filters = ['rbac_group_id:rbac_group_a'];
      final groups = ['rbac_group_id'];
      final query = AnalyticsActivityQuery(
        date: '2026-10-01',
        filters: filters,
        groupBy: groups,
      );
      const cursor = 'page +/%=?';
      transport
        ..queueJsonResponse({'data': <Object>[], 'next_page': cursor})
        ..queueJsonResponse({'data': <Object>[], 'next_page': ''});
      final analytics = client.organization.analytics;
      final page = await analytics.users(query);
      filters.clear();
      groups.clear();
      final finalPage = await analytics.users(query.withPage(page.nextPage));
      expect(finalPage.nextPage, isNull);
      expect(finalPage.toJson()['next_page'], '');
      expect(transport.requests.last.url.queryParametersAll, {
        ...transport.requests.first.url.queryParametersAll,
        'page': [cursor],
      });
    },
  );

  void activityRoute<T extends AnalyticsResponseRecord>(
    String path,
    Future<AnalyticsActivityPage<T>> Function(OrganizationAnalyticsResource)
    invoke,
    Map<String, dynamic> row,
    Map<String, List<String>> query,
    void Function(T) check, {
    String? beta,
  }) {
    test('GET $path sends query and returns typed activity', () async {
      transport.queueJsonResponse({
        'data': [row],
        'next_page': 'cursor_next',
      });
      final page = await invoke(client.organization.analytics);
      expect(page.nextPage, 'cursor_next');
      expect(page.data.single.toJson(), row);
      check(page.data.single);
      final request = transport.lastRequest!;
      expect(request.url.path, '/admin/v1/organizations$path');
      expect(request.method, 'GET');
      expect(request.url.queryParametersAll, query);
      expect(request.headers['x-api-key'], 'analytics-key');
      expect(request.headers['anthropic-version'], '2026-10-21');
      expect(request.headers['anthropic-beta'], beta);
    });
  }

  test(
    'summaries preserves Claude Tag counts and the legacy envelope',
    () async {
      final old = AnthropicClient(
        config: client.config.copyWith(
          apiVersion: AnthropicConfig.legacyApiVersion,
        ),
        httpClient: transport,
      );
      addTearDown(old.close);
      const historical = {
        'summaries': [_summary],
      };
      const current = {
        'data': [_summary],
        'next_page': null,
      };
      transport
        ..queueJsonResponse(historical)
        ..queueJsonResponse(current);
      final previous = await old.organization.analytics.summaries(
        startingDate: '2026-10-01',
        endingDate: '2026-10-02',
      );
      final page = await client.organization.analytics.summaries(
        startingDate: '2026-10-01',
        endingDate: '2026-10-02',
      );
      expect(previous.toJson(), historical);
      expect(page.toJson(), current);
      expect(page.data.single.claudeTagDailyActiveUserCount, 13);
      expect(page.data.single.claudeTagWeeklyActiveUserCount, 21);
      expect(page.data.single.claudeTagMonthlyActiveUserCount, isNull);
      expect(page.nextPage, isNull);
      expect(
        transport.requests.first.headers['anthropic-version'],
        '2023-06-01',
      );
      expect(
        transport.requests.last.headers['anthropic-version'],
        '2026-10-21',
      );
      for (final request in transport.requests) {
        expect(request.method, 'GET');
        expect(request.url.path, '/admin/v1/organizations/analytics/summaries');
        expect(request.url.queryParametersAll, {
          'starting_date': ['2026-10-01'],
          'ending_date': ['2026-10-02'],
        });
        expect(request.headers['anthropic-beta'], isNull);
      }
    },
  );

  activityRoute(
    '/analytics/users',
    (analytics) => analytics.users(
      AnalyticsActivityQuery(
        startingDate: '2026-10-01',
        endingDate: '2026-10-04',
        filters: const [
          'rbac_group_id:rbac_group_a',
          'rbac_group_id:rbac_group_b',
        ],
        groupBy: const ['rbac_group_id'],
        order: 'desc',
        limit: 20,
      ).withPage('cursor_previous'),
    ),
    _userActivity,
    {
      'starting_date': ['2026-10-01'],
      'ending_date': ['2026-10-04'],
      'filter[]': ['rbac_group_id:rbac_group_a', 'rbac_group_id:rbac_group_b'],
      'group_by[]': ['rbac_group_id'],
      'order': ['desc'],
      'limit': ['20'],
      'page': ['cursor_previous'],
    },
    (row) {
      expect(row.user, isNull);
      expect(row.distinctUserCount, 4);
      expect(row.chatMetrics.messageCount, 11);
      expect(row.claudeTagMetrics?.activeMessageCount, 3);
      expect(row.lastActivityDate, '2026-10-01');
    },
  );

  activityRoute(
    '/analytics/apps/chat/projects',
    (analytics) => analytics.projects(
      AnalyticsActivityQuery(
        date: '2026-10-01',
        filters: const ['project_id:claude_proj_fixture'],
      ),
    ),
    _projectActivity,
    {
      'date': ['2026-10-01'],
      'filter[]': ['project_id:claude_proj_fixture'],
    },
    (row) {
      expect(row.projectId, 'claude_proj_fixture');
      expect(row.createdBy?.emailAddress, 'owner@example.com');
      expect(row.messageCount, 15);
    },
  );

  activityRoute(
    '/analytics/skills',
    (analytics) => analytics.skills(
      AnalyticsActivityQuery(date: '2026-10-01', groupBy: const ['product']),
    ),
    _skillActivity,
    {
      'date': ['2026-10-01'],
      'group_by[]': ['product'],
    },
    (row) {
      expect(row.skillDisplayName, 'Test Skill');
      expect(row.attributedListPrice, '123.456789');
      expect(row.estimatedOverageSpend, '0.0123456789');
      expect(row.claudeCodeMetrics.distinctSessionSkillUsedCount, 3);
    },
  );

  activityRoute(
    '/analytics/connectors',
    (analytics) => analytics.connectors(
      AnalyticsActivityQuery(date: '2026-10-01'),
      betas: const ['analytics-opt-in'],
    ),
    _connectorActivity,
    {
      'date': ['2026-10-01'],
    },
    (row) {
      expect(row.connectorDisplayName, 'Fixture connector');
      expect(row.managedAuthDistinctUserCount, 8);
      expect(row.chatMetrics.distinctConversationConnectorUsedCount, 6);
    },
    beta: 'analytics-opt-in',
  );

  activityRoute(
    '/analytics/plugins',
    (analytics) => analytics.plugins(
      AnalyticsActivityQuery(
        date: '2026-10-01',
        groupBy: const ['product'],
        filters: const ['product:cowork'],
      ),
    ),
    _pluginActivity,
    {
      'date': ['2026-10-01'],
      'group_by[]': ['product'],
      'filter[]': ['product:cowork'],
    },
    (row) {
      expect(row.pluginName, 'Fixture plugin');
      expect(row.installCount, 3);
      expect(row.invocationCount, 13);
    },
  );

  activityRoute(
    '/analytics/artifacts',
    (analytics) => analytics.artifacts(
      date: '2026-10-01',
      filters: const ['artifact_type:text/markdown', 'is_shared:true'],
      groupBy: const ['product'],
    ),
    _artifactActivity,
    {
      'date': ['2026-10-01'],
      'filter[]': ['artifact_type:text/markdown', 'is_shared:true'],
      'group_by[]': ['product'],
    },
    (row) {
      expect(row.artifactType, 'text/markdown');
      expect(row.isShared, isTrue);
      expect(row.publishedArtifactsCreatedCount, 2);
    },
  );

  test('activity validates calendar dates and incompatible query fields', () {
    final analytics = client.organization.analytics;
    expect(() => analytics.artifacts(date: '2026-02-31'), throwsArgumentError);
    expect(
      () => analytics.users(
        AnalyticsActivityQuery(date: '2026-10-01', startingDate: '2026-10-01'),
      ),
      throwsArgumentError,
    );
    expect(
      () => analytics.plugins(AnalyticsActivityQuery(endingDate: '2026-10-02')),
      throwsArgumentError,
    );
    expect(transport.requests, isEmpty);
  });
}

const Map<String, Object?> _summary = {
  'assigned_seat_count': null,
  'cowork_daily_active_user_count': 0,
  'cowork_monthly_active_user_count': 0,
  'cowork_weekly_active_user_count': 0,
  'daily_active_user_count': 0,
  'daily_adoption_rate': null,
  'ending_at': '2026-10-02T00:00:00Z',
  'monthly_active_user_count': 0,
  'monthly_adoption_rate': null,
  'pending_invite_count': null,
  'starting_at': '2026-10-01T00:00:00Z',
  'weekly_active_user_count': 0,
  'weekly_adoption_rate': null,
  'claude_tag_daily_active_user_count': 13,
  'claude_tag_weekly_active_user_count': 21,
  'claude_tag_monthly_active_user_count': null,
};

const Map<String, Object?> _userActivity = {
  'chat_metrics': {
    'connectors_used_count': 0,
    'distinct_artifacts_created_count': 0,
    'distinct_connectors_used_count': null,
    'distinct_conversation_count': null,
    'distinct_files_uploaded_count': null,
    'distinct_projects_created_count': 0,
    'distinct_projects_used_count': null,
    'distinct_shared_artifacts_viewed_count': null,
    'distinct_skills_used_count': null,
    'message_count': 11,
    'shared_conversations_viewed_count': 0,
    'thinking_message_count': 0,
  },
  'claude_code_metrics': {
    'core_metrics': {
      'artifacts_created_count': 0,
      'commit_count': 0,
      'distinct_session_count': null,
      'lines_of_code': {'added_count': 0, 'removed_count': 0},
      'pull_request_count': 0,
    },
    'tool_actions': {
      'edit_tool': {'accepted_count': 0, 'rejected_count': 0},
      'multi_edit_tool': {'accepted_count': 0, 'rejected_count': 0},
      'notebook_edit_tool': {'accepted_count': 0, 'rejected_count': 0},
      'write_tool': {'accepted_count': 0, 'rejected_count': 0},
    },
  },
  'cowork_metrics': {
    'action_count': 0,
    'artifacts_created_count': 0,
    'connectors_used_count': 0,
    'dispatch_turn_count': 0,
    'distinct_connectors_used_count': null,
    'distinct_plugins_used_count': null,
    'distinct_session_count': null,
    'distinct_skills_used_count': null,
    'edit_tool_count': null,
    'file_edit_count': null,
    'message_count': 0,
    'multi_edit_tool_count': null,
    'notebook_edit_tool_count': null,
    'plugins_used_count': null,
    'sessions_with_file_edits_count': null,
    'skills_used_count': 0,
    'write_tool_count': null,
  },
  'design_metrics': {
    'distinct_projects_created_count': 0,
    'distinct_projects_used_count': null,
    'distinct_session_count': null,
    'message_count': 0,
  },
  'distinct_user_count': 4,
  'office_metrics': {
    'excel': {
      'connectors_used_count': 0,
      'distinct_connectors_used_count': null,
      'distinct_session_count': null,
      'distinct_skills_used_count': null,
      'message_count': 0,
      'skills_used_count': 0,
    },
    'outlook': {
      'connectors_used_count': 0,
      'distinct_connectors_used_count': null,
      'distinct_session_count': null,
      'distinct_skills_used_count': null,
      'message_count': 0,
      'skills_used_count': 0,
    },
    'powerpoint': {
      'connectors_used_count': 0,
      'distinct_connectors_used_count': null,
      'distinct_session_count': null,
      'distinct_skills_used_count': null,
      'message_count': 0,
      'skills_used_count': 0,
    },
    'word': {
      'connectors_used_count': 0,
      'distinct_connectors_used_count': null,
      'distinct_session_count': null,
      'distinct_skills_used_count': null,
      'message_count': 0,
      'skills_used_count': 0,
    },
  },
  'science_metrics': {
    'delegation_count': 0,
    'distinct_session_count': null,
    'message_count': 0,
    'remote_compute_job_count': 0,
    'skills_used_count': 0,
  },
  'user': null,
  'web_search_count': 0,
  'rbac_group_id': 'rbac_group_a',
  'rbac_group_name': 'Engineering',
  'last_activity_date': '2026-10-01',
  'claude_tag_metrics': {'active_day_count': 1, 'active_message_count': 3},
};

const Map<String, Object?> _projectActivity = {
  'created_at': null,
  'created_by': {
    'type': 'user',
    'id': 'user_fixture',
    'email_address': 'owner@example.com',
  },
  'distinct_conversation_count': null,
  'distinct_user_count': 0,
  'message_count': 15,
  'project_id': 'claude_proj_fixture',
  'project_name': 'Fixture project',
};

const Map<String, Object?> _skillActivity = {
  'attributed_list_price': '123.456789',
  'chat_metrics': {'distinct_conversation_skill_used_count': null},
  'claude_code_metrics': {'distinct_session_skill_used_count': 3},
  'cowork_metrics': {'distinct_session_skill_used_count': null},
  'currency': 'USD',
  'distinct_user_count': 0,
  'enable_count': null,
  'estimated_overage_spend': '0.0123456789',
  'invocation_count': null,
  'office_metrics': {
    'excel': {'distinct_session_skill_used_count': null},
    'outlook': {'distinct_session_skill_used_count': null},
    'powerpoint': {'distinct_session_skill_used_count': null},
    'word': {'distinct_session_skill_used_count': null},
  },
  'share_status': null,
  'skill_display_name': 'Test Skill',
  'skill_name': 'test-skill',
  'product': 'claude_code',
};

const Map<String, Object?> _connectorActivity = {
  'chat_metrics': {'distinct_conversation_connector_used_count': 6},
  'claude_code_metrics': {'distinct_session_connector_used_count': null},
  'connector_display_name': 'Fixture connector',
  'connector_name': 'fixture_connector',
  'cowork_metrics': {'distinct_session_connector_used_count': null},
  'distinct_user_count': 0,
  'individual_auth_distinct_user_count': 3,
  'managed_auth_distinct_user_count': 8,
  'office_metrics': {
    'excel': {'distinct_session_connector_used_count': null},
    'outlook': {'distinct_session_connector_used_count': null},
    'powerpoint': {'distinct_session_connector_used_count': null},
    'word': {'distinct_session_connector_used_count': null},
  },
  'read_call_count': 4,
  'unclassified_call_count': null,
  'write_call_count': null,
};

const Map<String, Object?> _pluginActivity = {
  'claude_code_metrics': {'distinct_session_plugin_used_count': null},
  'cowork_metrics': {'distinct_session_plugin_used_count': null},
  'distinct_user_count': 0,
  'install_count': 3,
  'invocation_count': 13,
  'plugin_id': 'plugin_fixture',
  'plugin_name': 'Fixture plugin',
  'product': 'cowork',
};

const Map<String, Object?> _artifactActivity = {
  'artifact_type': 'text/markdown',
  'artifacts_created_count': 7,
  'distinct_user_count': 3,
  'is_shared': true,
  'published_artifacts_created_count': 2,
  'product': 'chat',
};
