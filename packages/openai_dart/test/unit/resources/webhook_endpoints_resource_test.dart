import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Webhook endpoint public resources', () {
    for (final operation in _operations()) {
      test(
        '${operation.name} uses its exact route and standard headers',
        () async {
          final requests = <http.Request>[];
          final client = _client((request) async {
            requests.add(request);
            return _response(operation.response());
          });
          addTearDown(client.close);

          final result = await operation.invoke(client, 'endpoint_demo', null);

          expect(requests, hasLength(1));
          final request = requests.single;
          expect(request.method, operation.method);
          expect(request.url.path, '/v1${operation.path('endpoint_demo')}');
          expect(request.url.queryParametersAll, {
            'gateway': ['webhooks'],
            'k': ['one', 'two'],
          });
          expect(request.headers['authorization'], 'Bearer fixture-api-key');
          expect(request.headers['openai-organization'], 'org-fixture');
          expect(request.headers['openai-project'], 'proj-fixture');
          expect(request.headers['openai-version'], '2026-10-08');
          expect(request.headers['x-trace-label'], 'webhook-fixture');
          expect(request.headers['x-request-id'], isNotEmpty);
          expect(request.headers['content-type'], contains('application/json'));
          expect(request.headers.containsKey('openai-beta'), isFalse);
          if (operation.body == null) {
            expect(request.body, isEmpty);
          } else {
            expect(jsonDecode(request.body), operation.body);
          }
          expect(operation.jsonOf(result), operation.response());
        },
      );

      test(
        '${operation.name} rejects malformed successful JSON safely',
        () async {
          for (final malformed in [
            '{"signing_secret":"private-response-value",',
            'null',
            '["private-response-value"]',
            '{"signing_secret":"private-response-value"}',
          ]) {
            final client = _client(
              (request) async => http.Response(malformed, 200),
            );
            try {
              await expectLater(
                operation.invoke(client, 'endpoint_demo', null),
                throwsA(
                  isA<FormatException>()
                      .having((error) => error.source, 'source', isNull)
                      .having(
                        (error) => error.message,
                        'context',
                        contains('response'),
                      )
                      .having(
                        (error) => error.toString(),
                        'safe diagnostics',
                        isNot(contains('private-response-value')),
                      ),
                ),
              );
            } finally {
              client.close();
            }
          }
        },
      );

      test('${operation.name} preserves typed HTTP error metadata', () async {
        final body = {
          'error': {
            'message': 'Endpoint request rejected',
            'type': 'invalid_request_error',
            'code': 'endpoint_invalid',
            'param': 'event_types',
          },
        };
        final client = _client(
          (request) async => http.Response(
            jsonEncode(body),
            400,
            headers: {'x-request-id': 'req_webhook_error'},
          ),
        );
        addTearDown(client.close);

        await expectLater(
          operation.invoke(client, 'endpoint_demo', null),
          throwsA(
            isA<BadRequestException>()
                .having((error) => error.statusCode, 'statusCode', 400)
                .having(
                  (error) => error.message,
                  'message',
                  'Endpoint request rejected',
                )
                .having((error) => error.type, 'type', 'invalid_request_error')
                .having((error) => error.code, 'code', 'endpoint_invalid')
                .having((error) => error.param, 'param', 'event_types')
                .having(
                  (error) => error.requestId,
                  'requestId',
                  'req_webhook_error',
                )
                .having((error) => error.body, 'body', body),
          ),
        );
      });

      test(
        '${operation.name} rejects a closed client before authentication',
        () async {
          final auth = _CountingAuthProvider();
          var sends = 0;
          final client = _client((request) async {
            sends++;
            return _response(operation.response());
          }, auth: auth);
          // Cache both resource levels before closing, then use those cached paths.
          expect(client.webhooks, same(client.webhooks));
          expect(client.webhooks.eventTypes, same(client.webhooks.eventTypes));
          client.close();

          await expectLater(
            operation.invoke(client, 'endpoint_demo', null),
            throwsStateError,
          );
          expect(auth.calls, 0);
          expect(sends, 0);
        },
      );

      test(
        '${operation.name} retains conservative 5xx retry behavior',
        () async {
          final requests = <http.Request>[];
          final client = _client((request) async {
            requests.add(request);
            if (requests.length == 1) {
              return http.Response(
                '{"error":{"message":"Temporary failure"}}',
                503,
              );
            }
            return _response(operation.response());
          }, retry: _instantRetry);
          addTearDown(client.close);

          if (operation.method == 'POST') {
            await expectLater(
              operation.invoke(client, 'endpoint_demo', null),
              throwsA(isA<InternalServerException>()),
            );
            expect(requests, hasLength(1));
          } else {
            final result = await operation.invoke(
              client,
              'endpoint_demo',
              null,
            );
            expect(operation.jsonOf(result), operation.response());
            expect(requests, hasLength(2));
            expect(requests[0].url, requests[1].url);
            expect(
              requests[0].headers['x-request-id'],
              requests[1].headers['x-request-id'],
            );
          }
        },
      );

      test(
        '${operation.name} replays a transient 429 with its exact body',
        () async {
          final requests = <http.Request>[];
          final client = _client((request) async {
            requests.add(request);
            if (requests.length == 1) {
              return http.Response(
                '{"error":{"message":"Slow down","code":"rate_limit_exceeded"}}',
                429,
              );
            }
            return _response(operation.response());
          }, retry: _instantRetry);
          addTearDown(client.close);

          final result = await operation.invoke(client, 'endpoint_demo', null);
          expect(operation.jsonOf(result), operation.response());
          expect(requests, hasLength(2));
          expect(requests[0].body, requests[1].body);
          expect(requests[0].url, requests[1].url);
          expect(
            requests[0].headers['x-request-id'],
            requests[1].headers['x-request-id'],
          );
        },
      );

      test(
        '${operation.name} propagates a pending abort with the full body',
        () async {
          final abort = Completer<void>();
          final transport = _AbortAwareClient(operation, waitForAbort: false);
          final client = OpenAIClient(
            config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
            httpClient: transport,
          );
          addTearDown(client.close);

          final result = await operation.invoke(
            client,
            'endpoint_demo',
            abort.future,
          );
          expect(operation.jsonOf(result), operation.response());
          expect(transport.request, isA<http.Abortable>());
          expect(
            (transport.request! as http.Abortable).abortTrigger,
            same(abort.future),
          );
          if (operation.body == null) {
            expect(transport.body, isEmpty);
          } else {
            expect(jsonDecode(transport.body!), operation.body);
          }
          expect(
            transport.request!.contentLength,
            utf8.encode(transport.body!).length,
          );
        },
      );

      test(
        '${operation.name} converts transport abort without retrying',
        () async {
          final abort = Completer<void>();
          final transport = _AbortAwareClient(operation, waitForAbort: true);
          final client = OpenAIClient(
            config: const OpenAIConfig(retryPolicy: _instantRetry),
            httpClient: transport,
          );
          addTearDown(client.close);

          final pending = operation.invoke(
            client,
            'endpoint_demo',
            abort.future,
          );
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

      if (operation.hasId) {
        for (final id in [
          'with/slash?query#fragment% space',
          '%2F',
          '%2E%2E',
          'unicode-😀',
          'id.with.dots',
        ]) {
          test('${operation.name} encodes ID ${jsonEncode(id)} once', () async {
            late Uri actual;
            final client = _client((request) async {
              actual = request.url;
              return _response(operation.response());
            });
            addTearDown(client.close);

            await operation.invoke(client, id, null);
            expect(
              actual.toString(),
              contains('/webhook_endpoints/${Uri.encodeComponent(id)}'),
            );
            expect(actual.pathSegments[2], id);
            expect(actual.queryParametersAll, {
              'gateway': ['webhooks'],
              'k': ['one', 'two'],
            });
          });
        }

        for (final id in ['', '.', '..']) {
          test(
            '${operation.name} rejects unsafe path ID ${jsonEncode(id)} before auth',
            () async {
              final auth = _CountingAuthProvider();
              var sends = 0;
              final client = _client((request) async {
                sends++;
                return _response(operation.response());
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
            },
          );
        }
      }
    }

    test(
      'list uses explicit server cursors and preserves repeated base queries',
      () async {
        final requests = <http.Request>[];
        final client = _client((request) async {
          requests.add(request);
          return _response(_listJson());
        });
        addTearDown(client.close);

        final first = await client.webhooks.list(limit: 1);
        await client.webhooks.list(limit: 100, after: first.lastId);
        await client.webhooks.list(after: null);
        expect(requests[0].url.queryParametersAll, {
          'gateway': ['webhooks'],
          'k': ['one', 'two'],
          'limit': ['1'],
        });
        expect(requests[1].url.queryParametersAll, {
          'gateway': ['webhooks'],
          'k': ['one', 'two'],
          'limit': ['100'],
          'after': ['cursor_last'],
        });
        expect(requests[2].url.queryParameters.containsKey('after'), isFalse);
        expect(requests[2].url.queryParameters.containsKey('limit'), isFalse);
        expect(first.hasMore, isTrue);
        expect(first.firstId, 'cursor_first');
        expect(first.lastId, 'cursor_last');
        expect(first.data.single.id, 'endpoint_demo');
      },
    );

    test('list encodes an opaque cursor as query data', () async {
      late Uri actual;
      final client = _client((request) async {
        actual = request.url;
        return _response(_listJson());
      });
      addTearDown(client.close);
      await client.webhooks.list(after: 'cursor/+?&=😀');
      expect(actual.queryParameters['after'], 'cursor/+?&=😀');
      expect(actual.queryParametersAll['k'], ['one', 'two']);
    });

    for (final limit in [-1, 0, 101]) {
      test('list rejects limit $limit before authentication', () async {
        final auth = _CountingAuthProvider();
        var sends = 0;
        final client = _client((request) async {
          sends++;
          return _response(_listJson());
        }, auth: auth);
        addTearDown(client.close);
        await expectLater(
          client.webhooks.list(limit: limit),
          throwsArgumentError,
        );
        expect(auth.calls, 0);
        expect(sends, 0);
      });
    }

    test(
      'create and update write the complete 23-choice subscription set',
      () async {
        final requests = <http.Request>[];
        final client = _client((request) async {
          requests.add(request);
          return _response(
            requests.length == 1 ? _withSecretJson() : _endpointJson(),
          );
        });
        addTearDown(client.close);

        await client.webhooks.create(
          WebhookEndpointCreateRequest(
            name: 'All subscriptions',
            url: 'https://receiver.example/webhooks',
            eventTypes: WebhookEventType.values,
          ),
        );
        await client.webhooks.update(
          'endpoint_demo',
          WebhookEndpointUpdateRequest(eventTypes: WebhookEventType.values),
        );
        final expected = WebhookEventType.values
            .map((value) => value.value)
            .toList();
        expect(expected, hasLength(23));
        expect((jsonDecode(requests[0].body) as Map)['event_types'], expected);
        expect(jsonDecode(requests[1].body), {'event_types': expected});
        expect(
          expected,
          containsAll([
            'video.completed',
            'video.failed',
            'safety.alert.created',
          ]),
        );
      },
    );

    for (final choice in WebhookEventType.values) {
      test('test sends exact writable event ${choice.value}', () async {
        late http.Request sent;
        final client = _client((request) async {
          sent = request;
          return _response(_testJson(eventType: choice.value));
        });
        addTearDown(client.close);

        final result = await client.webhooks.test(
          'endpoint_demo',
          WebhookEndpointTestRequest(eventType: choice),
        );
        expect(jsonDecode(sent.body), {'event_type': choice.value});
        expect(result.eventType, choice.value);
        expect(result.success, isTrue);
      });
    }

    test('empty update remains an explicit JSON object', () async {
      late http.Request sent;
      final client = _client((request) async {
        sent = request;
        return _response(_endpointJson());
      });
      addTearDown(client.close);
      await client.webhooks.update(
        'endpoint_demo',
        WebhookEndpointUpdateRequest(),
      );
      expect(sent.method, 'POST');
      expect(sent.body, '{}');
    });

    test(
      'rotation distinguishes omitted, empty, false and true options',
      () async {
        final requests = <http.Request>[];
        final client = _client((request) async {
          requests.add(request);
          return _response(_withSecretJson());
        }, webhookSecret: 'configured-local-secret');
        addTearDown(client.close);

        final rotated = await client.webhooks.rotateSecret('endpoint_demo');
        await client.webhooks.rotateSecret(
          'endpoint_demo',
          request: WebhookEndpointRotateSecretRequest(),
        );
        await client.webhooks.rotateSecret(
          'endpoint_demo',
          request: WebhookEndpointRotateSecretRequest(
            keepOldSecretActiveFor24Hours: false,
          ),
        );
        await client.webhooks.rotateSecret(
          'endpoint_demo',
          request: WebhookEndpointRotateSecretRequest(
            keepOldSecretActiveFor24Hours: true,
          ),
        );
        expect(requests.map((request) => request.body).toList(), [
          '',
          '{}',
          '{"keep_old_secret_active_for_24_hours":false}',
          '{"keep_old_secret_active_for_24_hours":true}',
        ]);
        expect(rotated.signingSecret, 'synthetic-endpoint-secret');
        expect(client.config.webhookSecret, 'configured-local-secret');
      },
    );

    for (final statusCode in [200, 400, 500]) {
      test(
        'test success means completed request with receiver status $statusCode',
        () async {
          final client = _client(
            (request) async => _response(_testJson(statusCode: statusCode)),
          );
          addTearDown(client.close);
          final result = await client.webhooks.test(
            'endpoint_demo',
            _testRequest(),
          );
          expect(result.success, isTrue);
          expect(result.statusCode, statusCode);
        },
      );
    }

    test(
      'discovery and endpoint responses preserve future event strings',
      () async {
        final client = _client(
          (request) async => _response(
            request.url.path.endsWith('/webhook_event_types')
                ? _eventTypesJson()
                : _endpointJson(),
          ),
        );
        addTearDown(client.close);
        final endpoint = await client.webhooks.retrieve('endpoint_demo');
        final available = await client.webhooks.eventTypes.list();
        expect(endpoint.eventTypes, [
          'response.completed',
          'future.event.created',
        ]);
        expect(available.data, ['video.completed', 'future.event.created']);
      },
    );

    test(
      'created secrets and future metadata remain caller-accessible but diagnostics redact them',
      () async {
        final fixture = {
          ..._withSecretJson(),
          'updated_at': 2,
          'future_metadata': {
            'nested': ['private-future-value'],
          },
        };
        final client = _client((request) async => _response(fixture));
        addTearDown(client.close);

        final result = await client.webhooks.create(_createRequest());
        expect(result.signingSecret, 'synthetic-endpoint-secret');
        expect(result.updatedAt, 2);
        expect(result.toJson(), fixture);
        expect(result.rawJson['future_metadata'], fixture['future_metadata']);
        expect(result.toString(), isNot(contains('synthetic-endpoint-secret')));
        expect(result.toString(), isNot(contains('private-future-value')));
      },
    );

    test(
      'known malformed secret and optional timestamp fields fail with safe response context',
      () async {
        for (final fixture in [
          {
            ..._withSecretJson(),
            'signing_secret': ['private-response-value'],
          },
          {..._withSecretJson(), 'updated_at': null},
          {..._withSecretJson(), 'updated_at': 'private-response-value'},
        ]) {
          final client = _client((request) async => _response(fixture));
          try {
            await expectLater(
              client.webhooks.create(_createRequest()),
              throwsA(
                isA<FormatException>()
                    .having((error) => error.source, 'source', isNull)
                    .having(
                      (error) => error.message,
                      'context',
                      contains('WebhookEndpointWithSecret'),
                    )
                    .having(
                      (error) => error.toString(),
                      'diagnostics',
                      isNot(contains('private-response-value')),
                    ),
              ),
            );
          } finally {
            client.close();
          }
        }
      },
    );

    for (final operation in _operations().where(
      (operation) =>
          operation.name != 'delete' &&
          operation.name != 'test' &&
          operation.name != 'eventTypes.list',
    )) {
      test(
        '${operation.name} requires nullable response keys to be present',
        () async {
          final fixture = operation.response();
          if (operation.name == 'list') {
            fixture.remove('first_id');
          } else {
            fixture.remove('signing_secret_hint');
          }
          final client = _client((request) async => _response(fixture));
          addTearDown(client.close);
          await expectLater(
            operation.invoke(client, 'endpoint_demo', null),
            throwsFormatException,
          );
        },
      );
    }

    test('nullable hints and cursors survive public parsing', () async {
      final client = _client(
        (request) async => _response({
          'object': 'list',
          'data': [_endpointJson()],
          'first_id': null,
          'last_id': null,
          'has_more': false,
        }),
      );
      addTearDown(client.close);
      final page = await client.webhooks.list();
      expect(page.firstId, isNull);
      expect(page.lastId, isNull);
      expect(page.data.single.signingSecretHint, isNull);
      expect(page.data.single.updatedAt, isNull);
      expect(page.toJson()['first_id'], isNull);
      expect(page.toJson().containsKey('first_id'), isTrue);
      expect(page.data.single.toJson().containsKey('updated_at'), isFalse);
    });

    for (final invalid in [
      () => WebhookEndpointCreateRequest(
        name: '',
        url: 'https://receiver.example',
        eventTypes: const [WebhookEventType.responseCompleted],
      ),
      () => WebhookEndpointCreateRequest(
        name: 'Receiver',
        url: 'http://receiver.example',
        eventTypes: const [WebhookEventType.responseCompleted],
      ),
      () => WebhookEndpointCreateRequest(
        name: 'Receiver',
        url: 'https://receiver.example',
        eventTypes: const [],
      ),
    ]) {
      test(
        'invalid create input fails before authentication or HTTP',
        () async {
          final auth = _CountingAuthProvider();
          var sends = 0;
          final client = _client((request) async {
            sends++;
            return _response(_withSecretJson());
          }, auth: auth);
          addTearDown(client.close);
          await expectLater(
            () => client.webhooks.create(invalid()),
            throwsFormatException,
          );
          expect(auth.calls, 0);
          expect(sends, 0);
        },
      );
    }

    for (final invalid in [
      () => WebhookEndpointUpdateRequest(name: ''),
      () => WebhookEndpointUpdateRequest(url: 'http://receiver.example'),
      () => WebhookEndpointUpdateRequest(eventTypes: const []),
      () => WebhookEndpointUpdateRequest.fromJson(const {'name': null}),
      () => WebhookEndpointUpdateRequest.fromJson(const {'url': null}),
      () => WebhookEndpointUpdateRequest.fromJson(const {'event_types': null}),
    ]) {
      test(
        'invalid update input fails before authentication or HTTP',
        () async {
          final auth = _CountingAuthProvider();
          var sends = 0;
          final client = _client((request) async {
            sends++;
            return _response(_endpointJson());
          }, auth: auth);
          addTearDown(client.close);
          await expectLater(
            () => client.webhooks.update('endpoint_demo', invalid()),
            throwsFormatException,
          );
          expect(auth.calls, 0);
          expect(sends, 0);
        },
      );
    }

    for (final json in <Map<String, dynamic>>[
      {},
      {'event_type': null},
      {'event_type': 'future.event.created'},
      {'event_type': 'live.call.incoming'},
      {'event_type': 'safety.warning_issued'},
    ]) {
      test('invalid test choice fails before authentication or HTTP', () async {
        final auth = _CountingAuthProvider();
        var sends = 0;
        final client = _client((request) async {
          sends++;
          return _response(_testJson());
        }, auth: auth);
        addTearDown(client.close);
        await expectLater(
          () => client.webhooks.test(
            'endpoint_demo',
            WebhookEndpointTestRequest.fromJson(json),
          ),
          throwsFormatException,
        );
        expect(auth.calls, 0);
        expect(sends, 0);
      });
    }
  });
}

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
  String? webhookSecret,
}) => OpenAIClient(
  config: OpenAIConfig(
    authProvider: auth,
    baseUrl: 'https://gateway.example/v1?gateway=webhooks&k=one&k=two',
    organization: 'org-fixture',
    project: 'proj-fixture',
    apiVersion: '2026-10-08',
    defaultHeaders: const {'X-Trace-Label': 'webhook-fixture'},
    retryPolicy: retry,
    webhookSecret: webhookSecret,
  ),
  httpClient: MockClient(respond),
);

http.Response _response(Map<String, dynamic> json) => http.Response(
  jsonEncode(json),
  200,
  headers: {'content-type': 'application/json'},
);

Map<String, dynamic> _endpointJson() => {
  'id': 'endpoint_demo',
  'object': 'webhook_endpoint',
  'created_at': 1,
  'name': 'Receiver',
  'url': 'https://receiver.example/webhooks',
  'event_types': ['response.completed', 'future.event.created'],
  'signing_secret_hint': null,
};

Map<String, dynamic> _withSecretJson() => {
  ..._endpointJson(),
  'signing_secret': 'synthetic-endpoint-secret',
};

Map<String, dynamic> _listJson() => {
  'object': 'list',
  'data': [_endpointJson()],
  'first_id': 'cursor_first',
  'last_id': 'cursor_last',
  'has_more': true,
};

Map<String, dynamic> _deletedJson() => {
  'id': 'endpoint_demo',
  'object': 'webhook_endpoint.deleted',
  'deleted': true,
};

Map<String, dynamic> _testJson({
  int statusCode = 200,
  String eventType = 'response.completed',
}) => {
  'object': 'webhook_endpoint.test',
  'webhook_endpoint_id': 'endpoint_demo',
  'event_type': eventType,
  'status_code': statusCode,
  'success': true,
};

Map<String, dynamic> _eventTypesJson() => {
  'object': 'list',
  'data': ['video.completed', 'future.event.created'],
};

WebhookEndpointCreateRequest _createRequest() => WebhookEndpointCreateRequest(
  name: 'Receiver',
  url: 'https://receiver.example/webhooks',
  eventTypes: const [WebhookEventType.responseCompleted],
);

WebhookEndpointTestRequest _testRequest() =>
    WebhookEndpointTestRequest(eventType: WebhookEventType.responseCompleted);

typedef _Invoke = Future<Object> Function(OpenAIClient, String, Future<void>?);

class _Operation {
  _Operation(
    this.name,
    this.method,
    this.path,
    this.response,
    this.invoke,
    this.jsonOf, {
    this.body,
    this.hasId = false,
  });
  final String name;
  final String method;
  final String Function(String) path;
  final Map<String, dynamic> Function() response;
  final _Invoke invoke;
  final Map<String, dynamic> Function(Object) jsonOf;
  final Map<String, dynamic>? body;
  final bool hasId;
}

List<_Operation> _operations() => [
  _Operation(
    'list',
    'GET',
    (_) => '/webhook_endpoints',
    _listJson,
    (client, _, abort) => client.webhooks.list(abortTrigger: abort),
    (result) => (result as WebhookEndpointList).toJson(),
  ),
  _Operation(
    'create',
    'POST',
    (_) => '/webhook_endpoints',
    _withSecretJson,
    (client, _, abort) =>
        client.webhooks.create(_createRequest(), abortTrigger: abort),
    (result) => (result as WebhookEndpointWithSecret).toJson(),
    body: _createRequest().toJson(),
  ),
  _Operation(
    'retrieve',
    'GET',
    (id) => '/webhook_endpoints/$id',
    _endpointJson,
    (client, id, abort) => client.webhooks.retrieve(id, abortTrigger: abort),
    (result) => (result as WebhookEndpoint).toJson(),
    hasId: true,
  ),
  _Operation(
    'update',
    'POST',
    (id) => '/webhook_endpoints/$id',
    _endpointJson,
    (client, id, abort) => client.webhooks.update(
      id,
      WebhookEndpointUpdateRequest(name: 'Renamed'),
      abortTrigger: abort,
    ),
    (result) => (result as WebhookEndpoint).toJson(),
    body: {'name': 'Renamed'},
    hasId: true,
  ),
  _Operation(
    'delete',
    'DELETE',
    (id) => '/webhook_endpoints/$id',
    _deletedJson,
    (client, id, abort) => client.webhooks.delete(id, abortTrigger: abort),
    (result) => (result as DeletedWebhookEndpoint).toJson(),
    hasId: true,
  ),
  _Operation(
    'rotateSecret',
    'POST',
    (id) => '/webhook_endpoints/$id/rotate_secret',
    _withSecretJson,
    (client, id, abort) =>
        client.webhooks.rotateSecret(id, abortTrigger: abort),
    (result) => (result as WebhookEndpointWithSecret).toJson(),
    hasId: true,
  ),
  _Operation(
    'test',
    'POST',
    (id) => '/webhook_endpoints/$id/test',
    _testJson,
    (client, id, abort) =>
        client.webhooks.test(id, _testRequest(), abortTrigger: abort),
    (result) => (result as WebhookEndpointTestResult).toJson(),
    body: _testRequest().toJson(),
    hasId: true,
  ),
  _Operation(
    'eventTypes.list',
    'GET',
    (_) => '/webhook_event_types',
    _eventTypesJson,
    (client, _, abort) => client.webhooks.eventTypes.list(abortTrigger: abort),
    (result) => (result as WebhookEventTypeList).toJson(),
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
  String? body;
  int sends = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sends++;
    this.request = request;
    body = utf8.decode(await request.finalize().toBytes());
    sent.complete();
    if (waitForAbort) {
      await (request as http.Abortable).abortTrigger;
      throw http.RequestAbortedException(request.url);
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(operation.response()))),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}
