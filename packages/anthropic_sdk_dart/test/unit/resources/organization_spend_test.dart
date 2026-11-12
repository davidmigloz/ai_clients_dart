import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _date = '2026-11-11T00:00:00Z';
const Map<String, Object?> _actor = {
  'type': 'user_actor',
  'user_id': 'user_fixture',
  'name': null,
  'email_address': null,
  'deleted': false,
};
const _scope = {'type': 'user', 'user_id': 'user_fixture'};
const Map<String, Object> _limit = {
  'type': 'spend_limit',
  'id': 'spl_fixture',
  'amount': '50000',
  'created_at': _date,
  'updated_at': _date,
  'currency': 'USD',
  'is_enabled': true,
  'period': 'monthly',
  'scope': _scope,
};
const Map<String, Object?> _effective = {
  'actor': _actor,
  'amount': null,
  'currency': 'USD',
  'period': 'daily',
  'period_to_date_spend': '12050.571',
  'scope': _scope,
  'source': {
    'type': 'future_scope',
    'future': [1, 2],
  },
  'spend_limit_id': 'spl_fixture',
};
const Map<String, Object?> _increase = {
  'type': 'spend_limit_increase_request',
  'id': 'slir_fixture',
  'actor': _actor,
  'created_at': _date,
  'period': 'monthly',
  'resolved_at': null,
  'resolved_by': null,
  'spend_summary': _effective,
  'status': 'pending',
};

Map<String, dynamic> _page(Map<String, dynamic> record, {String? next}) => {
  'data': [record],
  'next_page': next,
};

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;
  late OrganizationSpendLimitsResource spend;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      httpClient: transport,
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-admin'),
        workspaceId: 'workspace-default',
        baseUrl: 'https://example.invalid/proxy',
        defaultHeaders: {'Anthropic-Beta': 'base-beta'},
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
    );
    spend = client.organization.spendLimits;
    addTearDown(client.close);
  });

  void sent(
    String method,
    String path, {
    String beta = 'base-beta',
    Map<String, List<String>> query = const {},
    Map<String, dynamic>? body,
  }) {
    final request = transport.requests.last as http.Request;
    expect(request.method, method);
    expect(request.url.path, '/proxy/v1/organizations$path');
    expect(request.url.queryParametersAll, query);
    expect(request.headers['anthropic-beta'], beta);
    expect(request.headers['anthropic-workspace-id'], isNull);
    expect(request.headers['x-api-key'], 'fixture-admin');
    expect(request.followRedirects, isFalse);
    expect(request.body.isEmpty ? null : jsonDecode(request.body), body);
  }

  test('configured limits preserve preview beta and workspace query', () async {
    transport
      ..queueJsonResponse(_page(_limit, next: 'opaque/+='))
      ..queueJsonResponse(_page({..._limit, 'amount': null}));
    final first = await spend.list(
      workspaceId: 'workspace-filter',
      scopeTypes: const ['user', 'workspace'],
      limit: 5,
    );
    expect(first.hasMore, isTrue);
    expect(first.data.single.amount, '50000');
    expect(first.data.single.toJson(), _limit);
    sent(
      'GET',
      '/spend_limits',
      beta: 'base-beta,spend-limit-reads-2026-09-26',
      query: {
        'scope_type[]': ['user', 'workspace'],
        'workspace_id': ['workspace-filter'],
        'limit': ['5'],
      },
    );
    final next = await spend.list(
      workspaceId: 'workspace-filter',
      scopeTypes: const ['user', 'workspace'],
      limit: 5,
      page: first.nextPage,
      betas: const ['caller-beta'],
    );
    expect(next.hasMore, isFalse);
    expect(next.data.single.amount, isNull);
    expect(next.data.single.toJson(), containsPair('amount', null));
    sent(
      'GET',
      '/spend_limits',
      beta: 'caller-beta,spend-limit-reads-2026-09-26',
      query: {
        'scope_type[]': ['user', 'workspace'],
        'workspace_id': ['workspace-filter'],
        'limit': ['5'],
        'page': ['opaque/+='],
      },
    );
  });

  test('retrieve, set and delete use documented scope and receipt', () async {
    transport
      ..queueJsonResponse(_limit)
      ..queueJsonResponse({..._limit, 'amount': null})
      ..queueJsonResponse({'type': 'spend_limit_deleted', 'id': 'spl_fixture'});
    final configured = await spend.retrieve('spl_fixture');
    expect(configured, OrganizationSpendLimit.fromJson(_limit));
    expect(
      configured.hashCode,
      OrganizationSpendLimit.fromJson(_limit).hashCode,
    );
    sent('GET', '/spend_limits/spl_fixture');
    await spend.set(
      scope: OrganizationSpendScope.workspace('workspace-fixture'),
      amount: null,
      period: OrganizationSpendPeriod.weekly,
    );
    sent(
      'POST',
      '/spend_limits',
      body: {
        'scope': {'type': 'workspace', 'workspace_id': 'workspace-fixture'},
        'amount': null,
        'period': 'weekly',
      },
    );
    expect((await spend.delete('spl_fixture')).id, 'spl_fixture');
    sent('DELETE', '/spend_limits/spl_fixture');
  });

  test(
    'writes reject non-integer amounts and read-only scopes before send',
    () {
      expect(
        () => spend.set(
          scope: OrganizationSpendScope.organization(),
          amount: '1.2',
        ),
        throwsArgumentError,
      );
      expect(
        () => spend.set(
          scope: OrganizationSpendScope.fromJson(const {'type': 'usage_tier'}),
          amount: '1',
        ),
        throwsArgumentError,
      );
      expect(transport.requests, isEmpty);
    },
  );

  test(
    'effective report retains exact decimal and future scope JSON',
    () async {
      transport.queueJsonResponse(_page(_effective));
      final page = await spend.listEffective(
        userIds: const ['user_fixture', 'user_second'],
        periods: const [
          OrganizationSpendPeriod.daily,
          OrganizationSpendPeriod.monthly,
        ],
      );
      final row = page.data.single;
      expect(row.periodToDateSpend, '12050.571');
      expect(row.source.type, 'future_scope');
      expect(row.actor.userId, 'user_fixture');
      expect(row.toJson(), _effective);
      sent(
        'GET',
        '/spend_limits/effective',
        query: {
          'user_ids[]': ['user_fixture', 'user_second'],
          'period[]': ['daily', 'monthly'],
        },
      );
    },
  );

  test('list and retrieve increase requests with repeated filters', () async {
    transport
      ..queueJsonResponse(_page(_increase, next: 'opaque'))
      ..queueJsonResponse(_increase);
    final page = await spend.increaseRequests.list(
      statuses: const ['pending', 'approved'],
      actorIds: const ['user_fixture', 'user_other'],
      limit: 6,
    );
    expect(page.data.single.resolvedBy, isNull);
    expect(page.data.single.spendSummary?.periodToDateSpend, '12050.571');
    sent(
      'GET',
      '/spend_limit_increase_requests',
      query: {
        'status[]': ['pending', 'approved'],
        'actor_ids[]': ['user_fixture', 'user_other'],
        'limit': ['6'],
      },
    );
    final pending = await spend.increaseRequests.retrieve('slir_fixture');
    expect(pending.toJson(), _increase);
    sent('GET', '/spend_limit_increase_requests/slir_fixture');
  });

  test(
    'approve and deny serialize exact amounts, period and false options',
    () async {
      transport
        ..queueJsonResponse({
          ..._increase,
          'status': 'approved',
          'spend_limit': _limit,
        })
        ..queueJsonResponse({..._increase, 'status': 'denied'});
      final approved = await spend.increaseRequests.approve(
        'slir_fixture',
        amount: '100000000000000000001',
        period: OrganizationSpendPeriod.weekly,
        suppressNotification: false,
      );
      expect(approved.spendLimit?.id, 'spl_fixture');
      sent(
        'POST',
        '/spend_limit_increase_requests/slir_fixture/approve',
        body: {
          'amount': '100000000000000000001',
          'period': 'weekly',
          'suppress_notification': false,
        },
      );
      final denied = await spend.increaseRequests.deny(
        'slir_fixture',
        suppressNotification: true,
      );
      expect(denied.status, 'denied');
      sent(
        'POST',
        '/spend_limit_increase_requests/slir_fixture/deny',
        body: {'suppress_notification': true},
      );
    },
  );

  test(
    'approval requires nullable spend_limit and delete requires a receipt',
    () async {
      transport
        ..queueJsonResponse(_increase)
        ..queueResponse(const MockResponse(body: '', statusCode: 204));
      await expectLater(
        spend.increaseRequests.approve('slir_fixture', amount: '0'),
        throwsFormatException,
      );
      await expectLater(spend.delete('spl_fixture'), throwsFormatException);
    },
  );
}
