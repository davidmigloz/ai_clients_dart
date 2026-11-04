import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart_admin.dart';
import 'package:openai_dart/src/utils/admin_redaction.dart';
import 'package:test/test.dart';

import '../../models/admin/admin_fixtures.dart';

const _private = 'PRIVATE/café🚀%2F?';
const _ops = [
  'keys.create',
  'keys.list',
  'keys.retrieve',
  'keys.delete',
  'keys.validate',
  'storage.create',
  'storage.list',
  'storage.retrieve',
  'storage.delete',
  'storage.validate',
  'key.update',
  'usage',
];

void main() {
  final oldHierarchy = hierarchicalLoggingEnabled;
  setUpAll(() => hierarchicalLoggingEnabled = true);
  tearDownAll(() => hierarchicalLoggingEnabled = oldHierarchy);

  test(
    'explicit Admin configuration and cached namespace perform no authentication',
    () {
      final auth = _Auth();
      final transport = _Transport((_) async => throw StateError('not sent'));
      final client = _client(transport, auth: auth);
      expect(client.organization, same(client.organization));
      expect(
        client.organization.externalKeys,
        same(client.organization.externalKeys),
      );
      expect(
        client.organization.externalStorage,
        same(client.organization.externalStorage),
      );
      expect(
        client.organization.projects.apiKeys,
        same(client.organization.projects.apiKeys),
      );
      expect(client.organization.usage, same(client.organization.usage));
      expect(auth.calls, 0);
      final keys = client.organization.externalKeys;
      client
        ..close()
        ..close();
      expect(() => client.organization, throwsStateError);
      expect(() => keys.retrieve('id'), throwsStateError);
      expect(transport.closed, 0);
    },
  );

  for (final op in _ops) {
    test(
      '$op exact HTTP200/auth/query/body/opaque IDs and header snapshots',
      () async {
        final transport = _Transport((_) async => _response(op));
        final defaults = {'X-Default': 'captured'};
        final auth = _Auth(conflicting: true);
        final client = OpenAIAdminClient(
          config: OpenAIAdminConfig(
            authProvider: auth,
            baseUrl: 'https://fixture.invalid/proxy/v1?k=a&k=b',
            organization: 'org-admin',
            defaultHeaders: defaults,
            retryPolicy: const RetryPolicy(maxRetries: 0),
          ),
          httpClient: transport,
        );
        defaults.clear();
        addTearDown(client.close);
        final headers = {
          'X-Caller': 'captured',
          'Idempotency-Key': 'caller-value',
          'Content-Type': 'text/plain; charset=iso-8859-1',
          'Accept': 'wrong',
        };
        final result = _call(client, op, headers: headers);
        headers.clear();
        await result;
        expect(transport.requests, hasLength(1));
        final request = transport.requests.single;
        expect(isAdminRequest(request), isTrue);
        expect(request.followRedirects, isFalse);
        expect(
          request.method,
          op.endsWith('delete')
              ? 'DELETE'
              : op.endsWith('create') ||
                    op.endsWith('validate') ||
                    op == 'key.update'
              ? 'POST'
              : 'GET',
        );
        expect(request.url.pathSegments, [
          'proxy',
          'v1',
          'organization',
          if (op.startsWith('keys')) 'external_keys',
          if (op.startsWith('storage')) 'external_storage',
          if (op == 'key.update') ...[
            'projects',
            _private,
            'api_keys',
            _private,
          ],
          if (op == 'usage') ...['usage', 'decisions'],
          if (op.endsWith('retrieve') ||
              op.endsWith('delete') ||
              op.endsWith('validate'))
            _private,
          if (op.endsWith('validate')) 'validate',
        ]);
        expect(request.headers['authorization'], 'Bearer synthetic_admin_only');
        expect(request.headers['openai-project'], isNull);
        expect(request.headers['openai-beta'], isNull);
        expect(request.headers['openai-organization'], 'org-admin');
        expect(request.headers['x-default'], 'captured');
        expect(request.headers['x-caller'], 'captured');
        expect(request.headers['idempotency-key'], 'caller-value');
        expect(request.headers['accept'], 'application/json');
        if (op.endsWith('create') || op == 'key.update') {
          expect(request.headers['content-type'], 'application/json');
          expect(jsonDecode(utf8.decode(transport.bodies.single)), _body(op));
        } else {
          expect(transport.bodies.single, isEmpty);
          expect(request.headers.containsKey('content-type'), isFalse);
        }
        final query = request.url.queryParametersAll;
        expect(query['k'], ['a', 'b']);
        if (op.endsWith('list')) {
          expect(query['limit'], [if (op.startsWith('keys')) '0' else '17']);
          expect(query['order'], ['desc']);
          expect(query['after'], [_private]);
        }
        if (op == 'storage.list') expect(query['project_id'], [_private]);
        if (op == 'keys.list') expect(query['purpose'], ['psp_decryption']);
        if (op == 'usage') {
          expect(query, {
            'k': ['a', 'b'],
            'start_time': ['10'],
            'end_time': ['20'],
            'bucket_width': ['1m'],
            'limit': ['1440'],
            'page': [_private],
            'batch': ['false'],
            'project_ids': [_private, 'second'],
            'user_ids': ['user'],
            'api_key_ids': ['key'],
            'models': ['future-model'],
            'group_by': ['api_source', 'model'],
          });
          expect(request.url.query, isNot(contains('%5B%5D')));
        }
        expect(auth.calls, 1);
      },
    );

    test('$op preabort/closed guards avoid provider and dispatch', () async {
      final auth = _Auth();
      final transport = _Transport((_) async => _response(op));
      final client = _client(transport, auth: auth);
      await expectLater(
        _call(client, op, abort: Future<void>.value()),
        throwsA(isA<AbortedException>()),
      );
      expect(auth.calls, 0);
      expect(transport.requests, isEmpty);
      client.close();
      await expectLater(Future.sync(() => _call(client, op)), throwsStateError);
      expect(auth.calls, 0);
      expect(transport.requests, isEmpty);
    });

    test(
      '$op preserves concrete HTTP/parse failures and private diagnostics',
      () async {
        for (final status in [302, 400, 401, 403, 404, 409, 422, 429, 500]) {
          final transport = _Transport(
            (_) async => http.StreamedResponse(
              Stream.value(
                utf8.encode(
                  jsonEncode({
                    'error': {
                      'message': _private,
                      'type': _private,
                      'code': _private,
                      'param': _private,
                    },
                  }),
                ),
              ),
              status,
              headers: {
                'x-request-id': _private,
                'content-type': 'application/json',
              },
              request: http.Request(
                'GET',
                Uri.parse('https://wrong.invalid/public'),
              ),
            ),
          );
          final client = _client(transport);
          try {
            await _call(client, op);
            fail('expected error');
          } on ApiException catch (error) {
            expect(error.statusCode, status);
            expect(error.message, _private);
            expect(error.body, isNotNull);
            expect(error.toString(), isNot(contains('PRIVATE')));
            expect(error.cause, isA<http.Response>());
            expect(
              (error.cause! as http.Response).request!.url.host,
              'fixture.invalid',
            );
          } finally {
            client.close();
          }
        }
        final bad = _client(
          _Transport(
            (_) async =>
                http.StreamedResponse(Stream.value(utf8.encode(_private)), 200),
          ),
        );
        addTearDown(bad.close);
        await expectLater(
          _call(bad, op),
          throwsA(
            isA<ParseException>().having(
              (e) => e.toString(),
              'diagnostic',
              isNot(contains('PRIVATE')),
            ),
          ),
        );
        final wrongStatus = _client(
          _Transport(
            (_) async =>
                http.StreamedResponse(Stream.value(utf8.encode('{}')), 201),
          ),
        );
        addTearDown(wrongStatus.close);
        await expectLater(
          _call(wrongStatus, op),
          throwsA(isA<ParseException>()),
        );
      },
    );
  }

  test(
    'provider and send/stream typed failures are private at their origin',
    () async {
      const failure = ApiException(message: _private, statusCode: 418);
      final auth = _Auth(failure: failure);
      final client = _client(
        _Transport((_) async => throw StateError('no send')),
        auth: auth,
      );
      await expectLater(
        client.organization.externalKeys.list(),
        throwsA(
          isA<ConnectionException>()
              .having((e) => e.cause, 'cause', same(failure))
              .having(
                (e) => e.toString(),
                'private',
                isNot(contains('PRIVATE')),
              ),
        ),
      );
      client.close();
      for (final inStream in [false, true]) {
        final transport = _Transport((_) async {
          if (!inStream) throw failure;
          return http.StreamedResponse(Stream.error(failure), 200);
        });
        final client = _client(transport);
        await expectLater(
          client.organization.externalKeys.list(),
          throwsA(
            isA<ConnectionException>().having(
              (e) => e.toString(),
              'private',
              isNot(contains('PRIVATE')),
            ),
          ),
        );
        client.close();
      }
    },
  );

  test(
    'invalid bearer provider and invalid URI inputs never dispatch',
    () async {
      final transport = _Transport((_) async => throw StateError('no send'));
      final client = _client(transport, auth: _Auth(invalid: true));
      await expectLater(
        client.organization.externalKeys.list(),
        throwsA(isA<ConnectionException>()),
      );
      client.close();
      final auth = _Auth();
      final good = _client(transport, auth: auth);
      addTearDown(good.close);
      for (final value in [
        '',
        '.',
        '..',
        String.fromCharCode(0xd800),
        String.fromCharCode(0xdc00),
      ]) {
        await expectLater(
          Future.sync(() => good.organization.externalKeys.retrieve(value)),
          throwsFormatException,
        );
      }
      for (final value in [
        String.fromCharCode(0xd800),
        String.fromCharCode(0xdc00),
      ]) {
        await expectLater(
          Future.sync(() => good.organization.externalKeys.list(after: value)),
          throwsFormatException,
        );
        await expectLater(
          Future.sync(
            () => good.organization.usage.decisions(
              startTime: 0,
              models: [value],
            ),
          ),
          throwsFormatException,
        );
      }
      expect(auth.calls, 0);
      expect(transport.requests, isEmpty);
    },
  );

  test(
    'query limits are source-specific and no page or model defaults are invented',
    () async {
      final transport = _Transport((_) async => _response('usage'));
      final auth = _Auth();
      final client = _client(transport, auth: auth);
      addTearDown(client.close);
      for (final width in [
        DecisionsUsageBucketWidth.day,
        DecisionsUsageBucketWidth.hour,
        DecisionsUsageBucketWidth.minute,
      ]) {
        final max = width == DecisionsUsageBucketWidth.day
            ? 31
            : width == DecisionsUsageBucketWidth.hour
            ? 168
            : 1440;
        await expectLater(
          Future.sync(
            () => client.organization.usage.decisions(
              startTime: 0,
              bucketWidth: width,
              limit: max + 1,
            ),
          ),
          throwsFormatException,
        );
      }
      await expectLater(
        Future.sync(() => client.organization.externalKeys.list(limit: -1)),
        throwsFormatException,
      );
      await expectLater(
        Future.sync(() => client.organization.externalStorage.list(limit: 0)),
        throwsFormatException,
      );
      await expectLater(
        Future.sync(
          () => client.organization.externalKeys.list(
            order: AdminListOrder.fromJson('future'),
          ),
        ),
        throwsFormatException,
      );
      expect(auth.calls, 0);
      final models = <String>[];
      await client.organization.usage.decisions(
        startTime: 0,
        models: models,
        projectIds: [],
        groupBy: [],
      );
      expect(transport.requests.single.url.queryParameters, {
        'start_time': '0',
      });
      expect(transport.requests, hasLength(1));
    },
  );

  test(
    'transient 429 retries preserve relative expiry body, caller idempotency and Admin headers',
    () async {
      var attempts = 0;
      final transport = _Transport(
        (_) async => ++attempts == 1
            ? http.StreamedResponse(
                Stream.value(utf8.encode('{"error":{"message":"retry"}}')),
                429,
              )
            : _response('key.update'),
      );
      final client = OpenAIAdminClient(
        config: OpenAIAdminConfig(
          authProvider: _Auth(),
          retryPolicy: const RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration.zero,
            jitter: 0,
          ),
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      await client.organization.projects.apiKeys.update(
        'p',
        'k',
        UpdateProjectApiKeyRequest(expiresInSeconds: 300),
        additionalHeaders: {'Idempotency-Key': 'caller-value'},
      );
      expect(attempts, 2);
      expect(transport.bodies[0], transport.bodies[1]);
      for (final request in transport.requests) {
        expect(request.followRedirects, isFalse);
        expect(request.headers['authorization'], 'Bearer synthetic_admin_only');
        expect(request.headers['idempotency-key'], 'caller-value');
      }
    },
  );

  test(
    'native abort and ordinary per-attempt timeout preserve their classes',
    () async {
      final abort = Completer<void>();
      final transport = _Transport((r) async {
        await (r as http.Abortable).abortTrigger;
        throw http.RequestAbortedException(r.url);
      });
      final client = _client(transport);
      addTearDown(client.close);
      final pending = client.organization.externalKeys.list(
        abortTrigger: abort.future,
      );
      await Future<void>.delayed(Duration.zero);
      abort.complete();
      await expectLater(pending, throwsA(isA<AbortedException>()));
      final timed = OpenAIAdminClient(
        config: OpenAIAdminConfig(
          authProvider: _Auth(),
          timeout: const Duration(milliseconds: 5),
          retryPolicy: const RetryPolicy(maxRetries: 0),
        ),
        httpClient: _Transport(
          (_) => Completer<http.StreamedResponse>().future,
        ),
      );
      addTearDown(timed.close);
      await expectLater(
        timed.organization.externalKeys.list(),
        throwsA(isA<RequestTimeoutException>()),
      );
    },
  );

  test(
    'private classifier is limited to the twelve bounded methods/routes',
    () {
      expect(
        isAdminRequest(
          http.Request('GET', Uri.parse('https://x/v1/organization/projects')),
        ),
        isFalse,
      );
      expect(
        isAdminRequest(
          http.Request(
            'POST',
            Uri.parse('https://x/v1/organization/usage/decisions'),
          ),
        ),
        isFalse,
      );
      expect(
        isAdminRequest(
          http.Request(
            'GET',
            Uri.parse('https://x/v1/organization/external_keys/x/validate'),
          ),
        ),
        isFalse,
      );
    },
  );

  test(
    'verbose logging never emits provider metadata, key IDs, usage filters or bodies',
    () async {
      final records = <String>[];
      final logger = Logger('OpenAIAdminClient')..level = Level.ALL;
      final sub = logger.onRecord.listen((r) => records.add(r.message));
      addTearDown(sub.cancel);
      final client = OpenAIAdminClient(
        config: OpenAIAdminConfig(
          authProvider: _Auth(),
          logLevel: Level.FINEST,
          retryPolicy: const RetryPolicy(maxRetries: 0),
        ),
        httpClient: _Transport((_) async => _response('keys.retrieve')),
      );
      addTearDown(client.close);
      await client.organization.externalKeys.retrieve(_private);
      expect(records, isNotEmpty);
      expect(records.join(), isNot(contains('PRIVATE')));
      expect(records.join(), isNot(contains('synthetic-private')));
      expect(records.join(), isNot(contains('synthetic_admin_only')));
    },
  );
}

OpenAIAdminClient _client(http.Client transport, {AuthProvider? auth}) =>
    OpenAIAdminClient(
      config: OpenAIAdminConfig(
        authProvider: auth ?? _Auth(),
        baseUrl: 'https://fixture.invalid/v1',
        retryPolicy: const RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );

Future<Object> _call(
  OpenAIAdminClient c,
  String op, {
  Map<String, String>? headers,
  Future<void>? abort,
}) => switch (op) {
  'keys.create' => c.organization.externalKeys.create(
    ExternalKeyParams.fromJson(adminFixture('AwsExternalKeyParams')),
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'keys.list' => c.organization.externalKeys.list(
    limit: 0,
    order: AdminListOrder.desc,
    after: _private,
    purpose: ExternalKeyPurpose.pspDecryption,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'keys.retrieve' => c.organization.externalKeys.retrieve(
    _private,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'keys.delete' => c.organization.externalKeys.delete(
    _private,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'keys.validate' => c.organization.externalKeys.validate(
    _private,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'storage.create' => c.organization.externalStorage.create(
    CreateExternalStorageRequest.fromJson(
      adminFixture('CreateExternalStorageBody'),
    ),
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'storage.list' => c.organization.externalStorage.list(
    limit: 17,
    order: AdminListOrder.desc,
    after: _private,
    projectId: _private,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'storage.retrieve' => c.organization.externalStorage.retrieve(
    _private,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'storage.delete' => c.organization.externalStorage.delete(
    _private,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'storage.validate' => c.organization.externalStorage.validate(
    _private,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'key.update' => c.organization.projects.apiKeys.update(
    _private,
    _private,
    UpdateProjectApiKeyRequest(scopes: const [], expiresInSeconds: 300),
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  _ => c.organization.usage.decisions(
    startTime: 10,
    endTime: 20,
    bucketWidth: DecisionsUsageBucketWidth.minute,
    limit: 1440,
    page: _private,
    projectIds: [_private, 'second'],
    userIds: ['user'],
    apiKeyIds: ['key'],
    models: ['future-model'],
    groupBy: [DecisionsUsageGroupBy.apiSource, DecisionsUsageGroupBy.model],
    batch: false,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
};
Object _body(String op) => switch (op) {
  'keys.create' => adminFixture('AwsExternalKeyParams'),
  'storage.create' => adminFixture('CreateExternalStorageBody'),
  _ => {'scopes': <String>[], 'expires_in_seconds': 300},
};
http.StreamedResponse _response(String op) => http.StreamedResponse(
  Stream.value(
    utf8.encode(
      jsonEncode(
        adminFixture(switch (op) {
          'keys.list' => 'ListExternalKeysResource',
          'keys.validate' => 'ValidateExternalKeyResource',
          'storage.list' => 'ExternalStorageListResource',
          'storage.delete' => 'ExternalStorageDeletedResource',
          'key.update' => 'ProjectApiKey',
          'usage' => 'PublicDecisionsUsageResponseResource',
          _ =>
            op.startsWith('storage')
                ? 'ExternalStorageResponse'
                : 'ExternalKeyResource',
        }),
      ),
    ),
  ),
  200,
);

final class _Auth implements AuthProvider {
  _Auth({this.conflicting = false, this.failure, this.invalid = false});
  final bool conflicting;
  final Exception? failure;
  final bool invalid;
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    if (failure != null) throw failure!;
    if (invalid) return {'api-key': 'synthetic_project'};
    return {
      'Authorization': 'Bearer synthetic_admin_only',
      if (conflicting) ...{
        'OpenAI-Project': 'synthetic_project',
        'Content-Type': 'text/plain; charset=iso-8859-1',
        'Accept': 'wrong',
        'Idempotency-Key': 'provider-wrong',
      },
    };
  }
}

final class _Transport extends http.BaseClient {
  _Transport(this.handler);
  final Future<http.StreamedResponse> Function(http.BaseRequest) handler;
  final requests = <http.BaseRequest>[];
  final bodies = <List<int>>[];
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    bodies.add(await request.finalize().toBytes());
    return handler(request);
  }

  @override
  void close() => closed++;
}
