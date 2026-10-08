import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Public safety resources', () {
    for (final operation in _operations) {
      test('${operation.name} uses its exact GET route and headers', () async {
        final requests = <http.Request>[];
        final client = _client((request) async {
          requests.add(request);
          return _response(operation.json());
        });
        addTearDown(client.close);

        final result = await operation.invoke(client, 'opaque-id', null);

        expect(operation.jsonOf(result), operation.json());
        expect(requests, hasLength(1));
        final request = requests.single;
        expect(request.method, 'GET');
        expect(request.url.path, '/v1${operation.path}/opaque-id');
        expect(request.url.host, 'gateway.example');
        expect(request.url.queryParametersAll, {
          'gateway': ['safety'],
          'k': ['one', 'two'],
        });
        expect(request.body, isEmpty);
        expect(request.headers['authorization'], 'Bearer fixture-api-key');
        expect(request.headers['openai-organization'], 'org-fixture');
        expect(request.headers['openai-project'], 'proj-fixture');
        expect(request.headers['openai-version'], '2026-10-08');
        expect(request.headers['x-trace-label'], 'safety-fixture');
        expect(request.headers['x-request-id'], isNotEmpty);
        expect(request.headers['content-type'], contains('application/json'));
        expect(request.headers.containsKey('openai-beta'), isFalse);
      });

      for (final id in [
        'x',
        'with/slash?query#fragment% space',
        '%2F',
        '%2E%2E',
        '...',
        'unicode-😀',
        'id.with.dots',
      ]) {
        test('${operation.name} encodes ID ${jsonEncode(id)} once', () async {
          late Uri actual;
          final client = _client((request) async {
            actual = request.url;
            return _response(operation.json());
          });
          addTearDown(client.close);

          await operation.invoke(client, id, null);

          expect(
            actual.toString(),
            contains('${operation.path}/${Uri.encodeComponent(id)}'),
          );
          expect(actual.pathSegments.last, id);
          expect(actual.fragment, isEmpty);
          expect(actual.queryParametersAll, {
            'gateway': ['safety'],
            'k': ['one', 'two'],
          });
        });
      }

      for (final character in ['a', '😀']) {
        test(
          '${operation.name} accepts ${operation.maximumLength} scalar characters',
          () async {
            final id = character * operation.maximumLength;
            final requests = <http.Request>[];
            final client = _client((request) async {
              requests.add(request);
              return _response(operation.json());
            });
            addTearDown(client.close);

            await operation.invoke(client, id, null);

            expect(requests.single.url.pathSegments.last, id);
            expect(id.runes.length, operation.maximumLength);
          },
        );
        test(
          '${operation.name} rejects excess scalar characters safely',
          () async {
            final id = character * (operation.maximumLength + 1);
            final auth = _CountingAuthProvider();
            var sends = 0;
            final client = _client((request) async {
              sends++;
              return _response(operation.json());
            }, auth: auth);
            addTearDown(client.close);

            await expectLater(
              operation.invoke(client, id, null),
              throwsA(
                isA<ArgumentError>()
                    .having(
                      (error) => error.invalidValue,
                      'invalidValue',
                      isNull,
                    )
                    .having(
                      (error) => error.toString(),
                      'safe diagnostic',
                      isNot(contains(id)),
                    ),
              ),
            );
            expect(auth.calls, 0);
            expect(sends, 0);
          },
        );
      }

      for (final id in ['', '.', '..']) {
        test('${operation.name} rejects unusable route before auth', () async {
          final auth = _CountingAuthProvider();
          var sends = 0;
          final client = _client((request) async {
            sends++;
            return _response(operation.json());
          }, auth: auth);
          addTearDown(client.close);

          await expectLater(
            operation.invoke(client, id, null),
            throwsA(
              isA<ArgumentError>().having(
                (error) => error.invalidValue,
                'invalidValue',
                isNull,
              ),
            ),
          );
          expect(auth.calls, 0);
          expect(sends, 0);
        });
      }

      test('${operation.name} rejects closed client before auth', () async {
        final auth = _CountingAuthProvider();
        var sends = 0;
        final client = _client((request) async {
          sends++;
          return _response(operation.json());
        }, auth: auth);
        // Obtain the child before closing to cover retained resource handles.
        final invoke = operation.capture(client);
        client.close();
        await expectLater(invoke('opaque-id', null), throwsStateError);
        expect(auth.calls, 0);
        expect(sends, 0);
      });

      for (final status in [400, 401, 403, 404, 409, 422, 429, 500, 503]) {
        test('${operation.name} preserves HTTP $status metadata', () async {
          final body = {
            'error': {
              'message': 'Safety request rejected',
              'type': 'invalid_request_error',
              'code': 'safety_denied',
              'param': 'id',
            },
          };
          final client = _client(
            (request) async => http.Response(
              jsonEncode(body),
              status,
              headers: {'x-request-id': 'req_safety_error'},
            ),
          );
          addTearDown(client.close);

          await expectLater(
            operation.invoke(client, 'opaque-id', null),
            throwsA(
              isA<ApiException>()
                  .having(
                    (error) => error.runtimeType,
                    'subtype',
                    _errors[status],
                  )
                  .having((error) => error.statusCode, 'statusCode', status)
                  .having(
                    (error) => error.message,
                    'message',
                    'Safety request rejected',
                  )
                  .having(
                    (error) => error.type,
                    'type',
                    'invalid_request_error',
                  )
                  .having((error) => error.code, 'code', 'safety_denied')
                  .having((error) => error.param, 'param', 'id')
                  .having(
                    (error) => error.requestId,
                    'requestId',
                    'req_safety_error',
                  )
                  .having((error) => error.body, 'body', body),
            ),
          );
        });
      }

      for (final status in [429, 503]) {
        test(
          '${operation.name} retries transient $status with same request ID',
          () async {
            final requests = <http.Request>[];
            final client = _client((request) async {
              requests.add(request);
              if (requests.length == 1) {
                return http.Response(
                  '{"error":{"message":"Temporary failure","code":"rate_limit_exceeded"}}',
                  status,
                );
              }
              return _response(operation.json());
            }, retry: _instantRetry);
            addTearDown(client.close);

            final result = await operation.invoke(client, 'opaque-id', null);

            expect(operation.jsonOf(result), operation.json());
            expect(requests, hasLength(2));
            expect(requests[0].url, requests[1].url);
            expect(requests[0].body, isEmpty);
            expect(requests[1].body, isEmpty);
            expect(
              requests[0].headers['x-request-id'],
              requests[1].headers['x-request-id'],
            );
          },
        );
      }

      test(
        '${operation.name} passes pending abort trigger to transport',
        () async {
          final abort = Completer<void>();
          final transport = _AbortAwareClient(operation, waitForAbort: false);
          final client = OpenAIClient(
            config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
            httpClient: transport,
          );
          addTearDown(client.close);
          addTearDown(transport.close);

          final result = await operation.invoke(
            client,
            'opaque-id',
            abort.future,
          );

          expect(operation.jsonOf(result), operation.json());
          expect(transport.request, isA<http.Abortable>());
          expect(
            (transport.request! as http.Abortable).abortTrigger,
            same(abort.future),
          );
          expect(transport.request!.contentLength, 0);
        },
      );

      test(
        '${operation.name} converts transport abort without retry',
        () async {
          final abort = Completer<void>();
          final transport = _AbortAwareClient(operation, waitForAbort: true);
          final client = OpenAIClient(
            config: const OpenAIConfig(retryPolicy: _instantRetry),
            httpClient: transport,
          );
          addTearDown(client.close);
          addTearDown(transport.close);

          final pending = operation.invoke(client, 'opaque-id', abort.future);
          final assertion = expectLater(
            pending,
            throwsA(
              isA<AbortedException>()
                  .having(
                    (error) => error.stage,
                    'stage',
                    AbortionStage.duringRequest,
                  )
                  .having(
                    (error) => error.correlationId,
                    'correlationId',
                    isNotEmpty,
                  )
                  .having(
                    (error) => error.cause,
                    'cause',
                    isA<http.RequestAbortedException>(),
                  ),
            ),
          );
          await transport.sent.future;
          abort.complete();
          await assertion;
          expect(transport.sends, 1);
        },
      );

      for (final malformed in [
        '{"reason":"private-response-value",',
        'null',
        '["private-response-value"]',
        '{"reason":"private-response-value"}',
      ]) {
        test(
          '${operation.name} rejects malformed successful JSON safely',
          () async {
            final client = _client(
              (request) async => http.Response(malformed, 200),
            );
            addTearDown(client.close);
            await expectLater(
              operation.invoke(client, 'opaque-id', null),
              throwsA(_safeResponseError(operation)),
            );
          },
        );
      }

      test(
        '${operation.name} rejects invalid UTF-8 even inside JSON strings',
        () async {
          // Find the reason's unique marker without relying on UTF-8 replacement.
          final body = jsonEncode(
            operation.json()..['reason'] = 'private-response-value',
          );
          final invalid = utf8.encode(body);
          final marker = body.indexOf('private-response-value');
          invalid[marker] = 255;
          final client = _client(
            (request) async => http.Response.bytes(
              invalid,
              200,
              headers: {'content-type': 'application/json'},
            ),
          );
          addTearDown(client.close);

          await expectLater(
            operation.invoke(client, 'opaque-id', null),
            throwsA(_safeResponseError(operation)),
          );
        },
      );

      test('${operation.name} requires nullable reason key', () async {
        final json = operation.json()..remove('reason');
        final client = _client((request) async => _response(json));
        addTearDown(client.close);
        await expectLater(
          operation.invoke(client, 'opaque-id', null),
          throwsA(_safeResponseError(operation)),
        );
      });

      for (final entry in _malformedFields(operation).entries) {
        test('${operation.name} rejects invalid ${entry.key} safely', () async {
          final json = operation.json()..[entry.key] = entry.value;
          final client = _client((request) async => _response(json));
          addTearDown(client.close);
          await expectLater(
            operation.invoke(client, 'opaque-id', null),
            throwsA(_safeResponseError(operation)),
          );
        });
      }

      test(
        '${operation.name} preserves received future fields and enum values',
        () async {
          final json = operation.json()
            ..['future'] = {
              'nested': [null, false, 1],
            };
          if (operation.name == 'alerts.retrieve') {
            json['error_type'] = 'future.private-response-value';
          } else {
            json['notice'] = {
              'type': 'future.private-response-value',
              'future': 1,
            };
          }
          final client = _client((request) async => _response(json));
          addTearDown(client.close);

          final result = await operation.invoke(client, 'opaque-id', null);

          expect(operation.jsonOf(result), json);
          expect(result.toString(), isNot(contains('private-response-value')));
        },
      );
    }

    test('namespace and children are cached and publicly exported', () {
      final client = OpenAIClient();
      addTearDown(client.close);
      final SafetyResource safety = client.safety;
      final SafetyAlertsResource alerts = safety.alerts;
      final SafetyCasesResource cases = safety.cases;
      expect(client.safety, same(safety));
      expect(safety.alerts, same(alerts));
      expect(safety.cases, same(cases));
      expect(alerts, isNot(same(cases)));
    });

    test(
      'withApiKey factory exposes safety and preserves scoped headers',
      () async {
        final requests = <http.Request>[];
        final transport = MockClient((request) async {
          requests.add(request);
          return _response(_alertJson());
        });
        final client = OpenAIClient.withApiKey(
          'factory-fixture-key',
          baseUrl: 'https://project.example/v1',
          organization: 'org-factory',
          project: 'proj-factory',
          httpClient: transport,
        );
        addTearDown(client.close);
        addTearDown(transport.close);

        final alert = await client.safety.alerts.retrieve('project-alert');

        expect(alert.reason, isNull);
        expect(alert.requestPaused, isFalse);
        expect(alert.toJson().containsKey('reason'), isTrue);
        expect(
          requests.single.headers['authorization'],
          'Bearer factory-fixture-key',
        );
        expect(requests.single.headers['openai-organization'], 'org-factory');
        expect(requests.single.headers['openai-project'], 'proj-factory');
      },
    );

    test('closing a client retains borrowed HTTP ownership', () async {
      final transport = _BorrowedClient();
      final client = OpenAIClient(httpClient: transport);
      await client.safety.alerts.retrieve('alert');
      client
        ..close()
        ..close();
      expect(transport.closes, 0);
      await expectLater(client.safety.cases.retrieve('case'), throwsStateError);
      expect(transport.sends, 1);
      transport.close();
      expect(transport.closes, 1);
    });

    test(
      'verified safety notice does not authenticate or retrieve automatically',
      () {
        final auth = _CountingAuthProvider();
        var sends = 0;
        final client = _client((request) async {
          sends++;
          return _response(_alertJson());
        }, auth: auth);
        addTearDown(client.close);
        const secret = 'synthetic-notification-signing-key';
        for (final type in [
          'safety.alert.created',
          'safety.warning_issued',
          'safety.deactivation_issued',
          'safety.org_alert.created',
        ]) {
          final body = jsonEncode({
            'id': 'notification-event-id',
            'object': 'event',
            'created_at': 1,
            'type': type,
            'data': {
              'id': type.contains('alert.created')
                  ? 'alert_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                  : 'case-referenced-id',
            },
          });
          final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final signature = base64.encode(
            Hmac(
              sha256,
              utf8.encode(secret),
            ).convert(utf8.encode('delivery.$timestamp.$body')).bytes,
          );
          final event = client.webhooks.unwrapBytes(utf8.encode(body), {
            'webhook-id': 'delivery',
            'webhook-timestamp': '$timestamp',
            'webhook-signature': 'v1,$signature',
          }, secret: secret);
          expect(event.id, 'notification-event-id');
          expect(event, isNot(isA<UnknownWebhookEvent>()));
        }
        expect(auth.calls, 0);
        expect(sends, 0);
      },
    );

    test(
      'explicit lookup uses referenced IDs and separately scoped clients',
      () async {
        final requests = <http.Request>[];
        final project = OpenAIClient.withApiKey(
          'project-alert-fixture-key',
          project: 'proj-fixture',
          httpClient: MockClient((request) async {
            requests.add(request);
            return _response(_alertJson());
          }),
        );
        final organization = OpenAIClient.withApiKey(
          'organization-case-fixture-key',
          organization: 'org-fixture',
          httpClient: MockClient((request) async {
            requests.add(request);
            return _response(_caseJson());
          }),
        );
        addTearDown(project.close);
        addTearDown(organization.close);
        final alertEvent = SafetyAlertCreatedWebhookEvent.fromJson(const {
          'id': 'notification-alert-id',
          'object': 'event',
          'created_at': 1,
          'type': 'safety.alert.created',
          'data': {'id': 'alert_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'},
        });
        final caseEvent = SafetyWarningIssuedWebhookEvent.fromJson(const {
          'id': 'notification-case-id',
          'object': 'event',
          'created_at': 1,
          'type': 'safety.warning_issued',
          'data': {'id': 'organization-case-id'},
        });

        await project.safety.alerts.retrieve(alertEvent.data.id);
        final safetyCase = await organization.safety.cases.retrieve(
          caseEvent.data.id,
        );

        expect(requests, hasLength(2));
        expect(requests[0].url.pathSegments.last, alertEvent.data.id);
        expect(
          requests[0].headers['authorization'],
          'Bearer project-alert-fixture-key',
        );
        expect(requests[1].url.pathSegments.last, caseEvent.data.id);
        expect(
          requests[1].headers['authorization'],
          'Bearer organization-case-fixture-key',
        );
        expect(requests[1].headers.containsKey('openai-project'), isFalse);
        expect(safetyCase.entityIdentifier, 'application-entity-id');
        expect(safetyCase.entityIdentifier, isNot(caseEvent.id));
        expect(safetyCase.entityIdentifier, isNot(caseEvent.data.id));
      },
    );
  });
}

const _errors = <int, Type>{
  400: BadRequestException,
  401: AuthenticationException,
  403: PermissionDeniedException,
  404: NotFoundException,
  409: ConflictException,
  422: UnprocessableEntityException,
  429: RateLimitException,
  500: InternalServerException,
  503: InternalServerException,
};

const _instantRetry = RetryPolicy(
  maxRetries: 1,
  initialDelay: Duration.zero,
  maxDelay: Duration.zero,
  jitter: 0,
);

OpenAIClient _client(
  Future<http.Response> Function(http.Request) respond, {
  AuthProvider auth = const ApiKeyProvider('fixture-api-key'),
  RetryPolicy retry = const RetryPolicy(maxRetries: 0),
}) => OpenAIClient(
  config: OpenAIConfig(
    authProvider: auth,
    baseUrl: 'https://gateway.example/v1?gateway=safety&k=one&k=two',
    organization: 'org-fixture',
    project: 'proj-fixture',
    apiVersion: '2026-10-08',
    defaultHeaders: const {'X-Trace-Label': 'safety-fixture'},
    retryPolicy: retry,
  ),
  httpClient: MockClient(respond),
);

http.Response _response(Map<String, dynamic> json) => http.Response(
  jsonEncode(json),
  200,
  headers: {'content-type': 'application/json'},
);

Map<String, dynamic> _alertJson() => {
  'id': 'project-alert-id',
  'object': 'safety.alert',
  'created_at': 1,
  'request_id': 'request-id',
  'response_id': 'response-id',
  'model': 'fixture-model',
  'request_paused': false,
  'error_type': 'other',
  'reason': null,
};

Map<String, dynamic> _caseJson() => {
  'id': 'organization-case-id',
  'object': 'safety.case',
  'created_at': 1,
  'entity_identifier': 'application-entity-id',
  'reason': null,
  'notice': {'type': 'warning'},
};

Map<String, dynamic> _malformedFields(_Operation operation) => {
  'id': null,
  'object': 'private-response-value',
  'created_at': 1.5,
  'reason': {'private-response-value': true},
  if (operation.name == 'alerts.retrieve') ...{
    'request_id': null,
    'response_id': false,
    'model': <Object?>[],
    'request_paused': null,
    'error_type': 1,
  } else ...{
    'entity_identifier': null,
    'notice': {'type': false, 'private-response-value': true},
  },
};

Matcher _safeResponseError(_Operation operation) => isA<FormatException>()
    .having((error) => error.source, 'source', isNull)
    .having((error) => error.offset, 'offset', isNull)
    .having(
      (error) => error.message,
      'context',
      'Invalid ${operation.type} response.',
    )
    .having(
      (error) => error.toString(),
      'safe diagnostic',
      isNot(contains('private-response-value')),
    );

typedef _Retrieve = Future<Object> Function(String, Future<void>?);

class _Operation {
  const _Operation(
    this.name,
    this.path,
    this.maximumLength,
    this.type,
    this.json,
    this.capture,
    this.jsonOf,
  );
  final String name;
  final String path;
  final int maximumLength;
  final String type;
  final Map<String, dynamic> Function() json;
  final _Retrieve Function(OpenAIClient) capture;
  final Map<String, dynamic> Function(Object) jsonOf;

  Future<Object> invoke(OpenAIClient client, String id, Future<void>? abort) =>
      capture(client)(id, abort);
}

final _operations = <_Operation>[
  _Operation(
    'alerts.retrieve',
    '/safety/alerts',
    38,
    'SafetyAlert',
    _alertJson,
    (client) {
      final alerts = client.safety.alerts;
      return (id, abort) => alerts.retrieve(id, abortTrigger: abort);
    },
    (value) => (value as SafetyAlert).toJson(),
  ),
  _Operation(
    'cases.retrieve',
    '/safety/cases',
    128,
    'SafetyCase',
    _caseJson,
    (client) {
      final cases = client.safety.cases;
      return (id, abort) => cases.retrieve(id, abortTrigger: abort);
    },
    (value) => (value as SafetyCase).toJson(),
  ),
];

class _CountingAuthProvider implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return {'Authorization': 'Bearer fixture-api-key'};
  }
}

class _AbortAwareClient extends http.BaseClient {
  _AbortAwareClient(this.operation, {required this.waitForAbort});
  final _Operation operation;
  final bool waitForAbort;
  final sent = Completer<void>();
  http.BaseRequest? request;
  int sends = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sends++;
    this.request = request;
    await request.finalize().drain<void>();
    sent.complete();
    if (waitForAbort) {
      await (request as http.Abortable).abortTrigger;
      throw http.RequestAbortedException(request.url);
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(operation.json()))),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}

class _BorrowedClient extends http.BaseClient {
  int sends = 0;
  int closes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sends++;
    await request.finalize().drain<void>();
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(_alertJson()))),
      200,
    );
  }

  @override
  void close() => closes++;
}
