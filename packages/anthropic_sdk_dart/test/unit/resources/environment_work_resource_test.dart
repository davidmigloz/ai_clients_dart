import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _env = 'env/a?b';
const _work = 'work/a?b';
const _date = '2026-11-11T00:00:00.000Z';
const _beta = 'managed-agents-2026-04-01';
const _token = 'fixture-sessions-secret';
const _key = 'fixture-environment-secret';
final String _secret = base64Url
    .encode(
      utf8.encode(
        jsonEncode({
          'sessions_token': _token,
          'api_base_url': 'https://example.invalid',
        }),
      ),
    )
    .replaceAll('=', '');
final _item = <String, Object?>{
  'type': 'work',
  'id': _work,
  'environment_id': _env,
  'data': {'type': 'session', 'id': 'session_fixture'},
  'state': 'active',
  'metadata': <String, String>{},
  'created_at': _date,
  'acknowledged_at': null,
  'latest_heartbeat_at': null,
  'started_at': null,
  'stop_requested_at': null,
  'stopped_at': null,
  'secret': null,
};

void main() {
  test(
    'all eight work operations follow auth, beta, and wire contracts',
    () async {
      final requests = <http.Request>[];
      var pollCount = 0;
      final client = AnthropicClient(
        config: const AnthropicConfig(
          baseUrl: 'https://fixture.invalid/proxy/?keep=x&keep=y',
          workspaceId: 'wrkspc_fixture',
          authProvider: ApiKeyProvider('provider-fixture'),
          defaultHeaders: {'X-Api-Key': 'default-fixture'},
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          final last = request.url.pathSegments.last;
          final Object? body = switch (last) {
            'poll' => pollCount++ == 0 ? {..._item, 'secret': _secret} : null,
            'heartbeat' => {
              'type': 'work_heartbeat',
              'last_heartbeat': '2026-11-11T00:00:00.123456789Z',
              'lease_extended': true,
              'state': 'active',
              'ttl_seconds': 60,
            },
            'stats' => {
              'type': 'work_queue_stats',
              'depth': 1,
              'oldest_queued_at': null,
              'pending': 0,
              'workers_polling': null,
            },
            'work' => {
              'data': [_item],
              'next_page': request.url.queryParameters['page'] == null
                  ? 'page +/'
                  : null,
            },
            _ => _item,
          };
          return _json(body);
        }),
      );
      addTearDown(client.close);
      final management = client.environments.work(_env);
      final environment = client.environments.work(_env, bearerToken: _key);
      final item = (await environment.poll(
        blockMs: 50,
        reclaimOlderThanMs: 300,
        workerId: 'worker_fixture',
        betas: const ['another-beta'],
      ))!;
      expect(item.data, isA<SessionEnvironmentWork>());
      expect(item.credentials?.sessionsToken, _token);
      expect(item.credentials?.apiBaseUrl, 'https://example.invalid');
      expect(item.credentials.toString(), isNot(contains(_token)));
      expect(item.toString(), isNot(contains(_secret)));
      expect(item.toJson()['secret'], _secret);
      expect(await environment.poll(), isNull);

      final session = client.environments.work(_env, bearerToken: _token);
      expect(await environment.ack(_work), EnvironmentWorkItem.fromJson(_item));
      final lease = await session.heartbeat(
        _work,
        desiredTtlSeconds: 60,
        expectedLastHeartbeat: EnvironmentWorkResource.noHeartbeat,
      );
      await session.heartbeat(
        _work,
        expectedLastHeartbeat: lease.lastHeartbeat,
      );
      expect(lease.lastHeartbeat, '2026-11-11T00:00:00.123456789Z');
      expect(lease.leaseExtended, isTrue);
      await session.stop(_work, force: false, workspaceId: 'wrkspc_override');

      expect((await management.retrieve(_work)).id, _work);
      await management.update(_work, metadata: {'remove': null, 'set': 'v'});
      final first = await environment.list(limit: 1);
      final second = await environment.list(limit: 1, page: first.nextPage);
      expect(second.nextPage, isNull);
      expect(second.toJson()['next_page'], isNull);
      expect((await environment.stats()).workersPolling, isNull);
      await expectLater(session.retrieve(_work), throwsArgumentError);

      expect(requests.map((r) => r.method), [
        'GET',
        'GET',
        'POST',
        'POST',
        'POST',
        'POST',
        'GET',
        'POST',
        'GET',
        'GET',
        'GET',
      ]);
      expect(requests.map((r) => r.url.pathSegments.skip(5).toList()), [
        ['poll'],
        ['poll'],
        [_work, 'ack'],
        [_work, 'heartbeat'],
        [_work, 'heartbeat'],
        [_work, 'stop'],
        [_work],
        [_work],
        <String>[],
        <String>[],
        ['stats'],
      ]);
      for (final (index, request) in requests.indexed) {
        expect(request.url.pathSegments.take(5).toList(), [
          'proxy',
          'v1',
          'environments',
          _env,
          'work',
        ]);
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(
          request.headers['anthropic-beta'],
          index == 0 ? 'another-beta,$_beta' : _beta,
        );
        expect(request.url.queryParametersAll['keep'], ['x', 'y']);
        expect(request.followRedirects, isFalse);
        final isManagement = index == 6 || index == 7;
        expect(
          request.headers['x-api-key'],
          isManagement ? 'default-fixture' : null,
        );
        expect(
          request.headers['authorization'],
          isManagement
              ? null
              : 'Bearer ${index >= 3 && index <= 5 ? _token : _key}',
        );
        expect(request.headers['anthropic-workspace-id'], switch (index) {
          5 => 'wrkspc_override',
          6 || 7 || 10 => 'wrkspc_fixture',
          _ => null,
        });
      }
      expect(requests[0].headers['anthropic-worker-id'], 'worker_fixture');
      expect(requests[0].url.queryParameters, containsPair('block_ms', '50'));
      expect(
        requests[0].url.queryParameters,
        containsPair('reclaim_older_than_ms', '300'),
      );
      expect(requests[2].body, isEmpty);
      expect(
        requests[3].url.queryParameters,
        containsPair('desired_ttl_seconds', '60'),
      );
      expect(
        requests[3].url.queryParameters,
        containsPair('expected_last_heartbeat', 'NO_HEARTBEAT'),
      );
      expect(
        requests[4].url.queryParameters,
        containsPair('expected_last_heartbeat', lease.lastHeartbeat),
      );
      expect(jsonDecode(requests[5].body), {'force': false});
      expect(jsonDecode(requests[7].body), {
        'metadata': {'remove': null, 'set': 'v'},
      });
      expect(requests[9].url.queryParameters, containsPair('page', 'page +/'));
    },
  );

  test(
    'heartbeat conflict exposes current state without secret diagnostics',
    () async {
      final client = AnthropicClient(
        httpClient: MockClient(
          (_) async => _json(
            {
              'type': 'error',
              'request_id': 'req_fixture',
              'error': {
                'message': 'credential echoed: $_token',
                'details': {
                  'error_code': 'heartbeat_precondition_failed',
                  'current_state': {
                    'last_heartbeat': null,
                    'lease_extended': false,
                    'state': 'starting',
                    'ttl_seconds': 60,
                  },
                },
              },
            },
            status: 412,
            headers: {'x-debug': _token},
          ),
        ),
      );
      addTearDown(client.close);
      await expectLater(
        client.environments.work(_env, bearerToken: _token).heartbeat(_work),
        throwsA(
          isA<EnvironmentHeartbeatConflictException>()
              .having((e) => e.statusCode, 'status', 412)
              .having((e) => e.requestId, 'provider ID', 'req_fixture')
              .having(
                (e) => e.currentState.lastHeartbeat,
                'last heartbeat',
                isNull,
              )
              .having(
                (e) => e.currentState.leaseExtended,
                'lease extended',
                isFalse,
              )
              .having((e) => e.currentState.state, 'state', 'starting')
              .having(
                (e) => e.responseMetadata!.bodyExcerpt,
                'excerpt',
                isEmpty,
              )
              .having((e) => e.responseMetadata!.headers, 'headers', isEmpty)
              .having(
                (e) => e.toString(),
                'description',
                isNot(contains(_token)),
              ),
        ),
      );
    },
  );

  test(
    'invalid dot-segment environment and work identifiers do not dispatch',
    () async {
      var sends = 0;
      final client = AnthropicClient(
        httpClient: MockClient((request) async {
          sends++;
          return _json(_item);
        }),
      );
      addTearDown(client.close);
      expect(() => client.environments.retrieve('..'), throwsArgumentError);
      await expectLater(
        client.environments.work('..', bearerToken: _key).poll(),
        throwsArgumentError,
      );
      await expectLater(
        client.environments.work(_env, bearerToken: _key).ack('.'),
        throwsArgumentError,
      );
      expect(sends, 0);
    },
  );

  for (final status in [400, 401, 429]) {
    test(
      'protected HTTP $status retains error code without body data',
      () async {
        final client = AnthropicClient(
          config: const AnthropicConfig(
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: MockClient(
            (_) async => _json({
              'type': 'error',
              'request_id': 'req_work',
              'error': {
                'type': 'invalid_request_error',
                'message': 'Sensitive server data $_token',
                'details': {'error_code': 'invalid_metadata'},
              },
            }, status: status),
          ),
        );
        addTearDown(client.close);
        await expectLater(
          client.environments.work(_env).update(_work, metadata: {}),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'status', status)
                .having((e) => e.requestId, 'provider ID', 'req_work')
                .having((e) => e.errorCode, 'code', 'invalid_metadata')
                .having(
                  (e) => e.toString(),
                  'safe diagnostic',
                  isNot(contains(_token)),
                ),
          ),
        );
      },
    );
  }

  test('unknown work types round-trip and malformed credential is ignored', () {
    final work = EnvironmentWorkItem.fromJson({
      ..._item,
      'secret': '!! invalid credential',
      'data': const {
        'type': 'future_work',
        'payload': [
          1,
          {'nested': true},
        ],
      },
    });
    expect(work.credentials, isNull);
    expect(work.data, isA<UnknownEnvironmentWork>());
    expect(EnvironmentWorkItem.fromJson(work.toJson()), work);
    expect(work.toString(), isNot(contains('invalid credential')));
    final healthCheck = EnvironmentWorkItem.fromJson({
      ..._item,
      'data': const {'id': 'healthcheck_fixture'},
    });
    expect(healthCheck.data, isA<HealthCheckEnvironmentWork>());
    expect(healthCheck.data.toJson(), {
      'id': 'healthcheck_fixture',
      'type': 'healthcheck',
    });
  });
}

http.Response _json(
  Object? body, {
  int status = 200,
  Map<String, String> headers = const {},
}) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json', ...headers},
);
