import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/utils/monitoring_error_redaction.dart';
import 'package:test/test.dart';

const _request = CreateResponseRequest(
  model: 'synthetic-model',
  input: ResponseInput.text('Offline failure fixture'),
);
const _private = 'private-monitoring-fixture';

Map<String, dynamic> _details() => {
  'detailed_explanation': _private,
  'error_type': 'future-classification',
  'review_target': 'review_target.private',
  'steer': {
    'message': _private,
    'future': [_private],
  },
  'future': {'private': _private},
};

Map<String, dynamic> _body(Object? details) => {
  'error': {
    'type': 'invalid_request_error',
    'message': _private,
    'code': 'misalignment_policy_violation',
    'param': 'private-parameter',
    'misalignment': details,
  },
};

Map<String, dynamic> _failed() => {
  'id': 'private-response-id',
  'object': 'response',
  'created_at': 1,
  'status': 'failed',
  'model': 'private-model',
  'output': <Object?>[],
  'error': {
    'code': 'misalignment_policy_violation',
    'message': _private,
    'misalignment': _details(),
  },
};

void main() {
  group('Public monitoring HTTP failures', () {
    for (final streaming in [false, true]) {
      test(
        'HTTP403 ${streaming ? 'before SSE' : 'REST'} preserves context',
        () async {
          var sends = 0;
          final body = _body(_details());
          final transport = MockClient((request) async {
            sends++;
            expect(request.method, 'POST');
            expect(request.url.path, '/v1/responses');
            return http.Response(
              jsonEncode(body),
              403,
              headers: {'x-request-id': 'private-request-id'},
            );
          });
          final client = _client(transport);
          addTearDown(client.close);
          addTearDown(transport.close);
          final pending = streaming
              ? client.responses.createStream(_request).toList()
              : client.responses.create(_request);
          await expectLater(
            pending,
            throwsA(
              isA<PermissionDeniedException>()
                  .having((e) => e.statusCode, 'status', 403)
                  .having(
                    (e) => e.code,
                    'code',
                    'misalignment_policy_violation',
                  )
                  .having((e) => e.type, 'type', 'invalid_request_error')
                  .having((e) => e.param, 'param', 'private-parameter')
                  .having((e) => e.message, 'message', _private)
                  .having(
                    (e) => e.requestId,
                    'request ID',
                    'private-request-id',
                  )
                  .having((e) => e.body, 'raw body', body)
                  .having(
                    (e) => e.misalignment?.toJson(),
                    'details',
                    _details(),
                  )
                  .having(
                    (e) => e.toString(),
                    'diagnostic',
                    isNot(contains(_private)),
                  ),
            ),
          );
          expect(sends, 1); // A policy403 never retries, despite retry opt-in.
        },
      );

      for (final malformed in <Object?>[
        null,
        'private-malformed',
        [],
        {'detailed_explanation': null},
        {'error_type': null},
        {'review_target': ''},
        {'review_target': 'x' * 97},
        {'review_target': 'private-target\n'},
        {'review_target': '非ASCII'},
        {'steer': null},
        {'steer': <String, dynamic>{}},
        {
          'steer': {'message': 42},
        },
      ]) {
        test(
          'malformed optional detail ${jsonEncode(malformed)} ${streaming ? 'SSE' : 'REST'}',
          () async {
            var sends = 0;
            final body = _body(malformed);
            final transport = MockClient((request) async {
              sends++;
              return http.Response(
                jsonEncode(body),
                403,
                headers: {
                  'x-request-id': 'req-original',
                  'content-type': 'application/json; charset=utf-8',
                },
              );
            });
            final client = _client(transport);
            addTearDown(client.close);
            addTearDown(transport.close);
            final pending = streaming
                ? client.responses.createStream(_request).toList()
                : client.responses.create(_request);
            await expectLater(
              pending,
              throwsA(
                isA<PermissionDeniedException>()
                    .having(
                      (e) => e.code,
                      'original code',
                      'misalignment_policy_violation',
                    )
                    .having(
                      (e) => e.requestId,
                      'original request ID',
                      'req-original',
                    )
                    .having((e) => e.body, 'original body', body)
                    .having(
                      (e) => e.misalignment,
                      'malformed detail absent',
                      isNull,
                    )
                    .having(
                      (e) => e.toString(),
                      'redacted even if malformed',
                      isNot(contains(_private)),
                    ),
              ),
            );
            expect(sends, 1);
          },
        );
      }
    }

    for (final (status, type) in [
      (400, BadRequestException),
      (401, AuthenticationException),
      (403, PermissionDeniedException),
      (404, NotFoundException),
      (409, ConflictException),
      (422, UnprocessableEntityException),
      (429, RateLimitException),
      (503, InternalServerException),
      (418, ApiException),
    ]) {
      test('central factory HTTP$status retains subtype and details', () {
        final body = _body(_details());
        final cause = StateError('synthetic cause');
        final error = createApiException(
          statusCode: status,
          message: _private,
          type: 'invalid_request_error',
          code: 'misalignment_policy_violation',
          param: _private,
          requestId: _private,
          body: body,
          cause: cause,
          retryAfter: const Duration(seconds: 2),
        );
        expect(error.runtimeType, type);
        expect(error.statusCode, status);
        expect(error.message, _private);
        expect(error.body, same(body));
        expect(error.cause, same(cause));
        expect(error.misalignment!.toJson(), _details());
        expect(error.toString(), isNot(contains(_private)));
        if (error is RateLimitException) {
          expect(error.retryAfter, const Duration(seconds: 2));
        }
        if (error is InternalServerException) {
          expect(error.retryAfter, const Duration(seconds: 2));
        }
        // The typed snapshot remains owned even if raw caller data changes.
        (body['error'] as Map<String, dynamic>)['misalignment'] = {
          'error_type': 'changed',
        };
        expect(error.misalignment!.errorType, 'future-classification');
      });
    }

    test('manual const exception keeps shared const construction', () {
      const details = ResponsesMisalignmentDetails(
        errorType: 'future',
        steer: ResponsesMisalignmentSteer(message: _private),
      );
      const error = PermissionDeniedException(
        message: _private,
        code: 'misalignment_policy_violation',
        misalignment: details,
      );
      expect(error.misalignment, same(details));
      expect(error.message, _private);
      expect(error.toString(), isNot(contains(_private)));
    });

    test('nonfinite/cyclic optional metadata never masks original failure', () {
      final cycle = <String, dynamic>{};
      cycle['cycle'] = cycle;
      for (final details in [
        cycle,
        {'future': double.infinity},
        {'future': Object()},
      ]) {
        final body = _body(details);
        final error = createApiException(
          statusCode: 403,
          message: _private,
          code: 'misalignment_policy_violation',
          body: body,
        );
        expect(error, isA<PermissionDeniedException>());
        expect(error.body, same(body));
        expect(error.misalignment, isNull);
        expect(error.toString(), isNot(contains(_private)));
      }
    });
  });

  group('Public failed Response and stream', () {
    test('REST failed response exposes same shared details', () async {
      final transport = MockClient(
        (request) async => http.Response(jsonEncode(_failed()), 200),
      );
      final client = _client(transport);
      addTearDown(client.close);
      addTearDown(transport.close);
      final response = await client.responses.create(_request);
      expect(response.status, ResponseStatus.failed);
      expect(response.error!.misalignment!.toJson(), _details());
      expect(response.error!.toJson().containsKey('type'), isFalse);
      expect(response.toString(), isNot(contains('private-response-id')));
      expect(response.toString(), isNot(contains('private-model')));
      expect(response.id, 'private-response-id');
    });

    for (final failedLifecycle in [false, true]) {
      test(
        'output followed by ${failedLifecycle ? 'response.failed' : 'flat error'} retains passive context',
        () async {
          var sends = 0;
          final failure = failedLifecycle
              ? {
                  'type': 'response.failed',
                  'sequence_number': 2,
                  'response': _failed(),
                }
              : {
                  'type': 'error',
                  'code': null,
                  'param': null,
                  'message': _private,
                  'sequence_number': 2,
                  'future': {'private': _private},
                };
          final transport = MockClient((request) async {
            sends++;
            return http.Response(
              [
                'data: ${jsonEncode({'type': 'response.output_text.delta', 'item_id': 'item-local', 'output_index': 0, 'content_index': 0, 'delta': 'partial', 'sequence_number': 1})}\n\n',
                'data: ${jsonEncode(failure)}\n\n',
                'data: [DONE]\n\n',
              ].join(),
              200,
              headers: {'content-type': 'text/event-stream'},
            );
          });
          final client = _client(transport);
          addTearDown(client.close);
          addTearDown(transport.close);
          final events = await client.responses.createStream(_request).toList();
          expect(events, hasLength(2));
          expect(
            events.first,
            isA<OutputTextDeltaEvent>().having(
              (e) => e.delta,
              'partial output',
              'partial',
            ),
          );
          if (failedLifecycle) {
            final event = events.last as ResponseFailedEvent;
            expect(event.response.error!.misalignment!.toJson(), _details());
            expect(event.toString(), isNot(contains('private-response-id')));
            expect(event.response.error!.code, 'misalignment_policy_violation');
          } else {
            final event = events.last as ErrorEvent;
            expect(event.code, isNull);
            expect(event.param, isNull);
            expect(event.toJson(), failure);
            expect(event.toString(), isNot(contains(_private)));
          }
          expect(sends, 1);
        },
      );
    }
  });

  test(
    'monitoring response summaries redact future cache and free strings',
    () {
      final wire = _failed()
        ..['object'] = _private
        ..['service_tier'] = _private
        ..['prompt_cache_diagnostics'] = {
          'type': 'cache_miss',
          'reason': _private,
          'cache_missed_tokens': 1,
        };
      final response = Response.fromJson(wire);
      expect(response.toString(), isNot(contains(_private)));
      expect(response.object, _private);
      expect(response.serviceTier!.value, _private);
      expect(response.promptCacheDiagnostics!.toJson()['reason'], _private);
    },
  );

  for (final lifecycle in [false, true]) {
    test(
      'public malformed failed error object is contextual ($lifecycle)',
      () async {
        final failure = _failed()..['error'] = _private;
        final transport = MockClient(
          (request) async => http.Response(
            lifecycle
                ? 'data: ${jsonEncode({'type': 'response.failed', 'sequence_number': 1, 'response': failure})}\n\n'
                : jsonEncode(failure),
            200,
            headers: {if (lifecycle) 'content-type': 'text/event-stream'},
          ),
        );
        final client = _client(transport);
        addTearDown(client.close);
        addTearDown(transport.close);
        await expectLater(
          lifecycle
              ? client.responses.createStream(_request).toList()
              : client.responses.create(_request),
          throwsA(
            isA<FormatException>()
                .having(
                  (e) => e.toString(),
                  'context',
                  contains('Response.error'),
                )
                .having((e) => e.toString(), 'safe', isNot(contains(_private))),
          ),
        );
      },
    );
  }

  group('Monitoring diagnostic redaction', () {
    late List<String> records;
    late Level oldLevel;
    late bool oldHierarchical;
    setUp(() {
      records = [];
      oldHierarchical = hierarchicalLoggingEnabled;
      hierarchicalLoggingEnabled = true;
      oldLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      final sub = Logger.root.onRecord.listen(
        (record) => records.add(record.message),
      );
      addTearDown(sub.cancel);
    });
    tearDown(() {
      Logger.root.level = oldLevel;
      hierarchicalLoggingEnabled = oldHierarchical;
    });

    for (final escaped in [false, true]) {
      test(
        'malformed ${escaped ? 'escaped' : 'literal'} metadata response stays out of fallback logs',
        () async {
          final key = escaped ? r'misa\u006cignment' : 'misalignment';
          final body =
              '{"error":{"" : "", "$key":{"detailed_explanation":"$_private"}}';
          expect(redactMonitoringErrorBody(body), '[REDACTED]');
          final transport = MockClient(
            (request) async => http.Response(body, 403),
          );
          final client = _client(transport);
          addTearDown(client.close);
          addTearDown(transport.close);
          await expectLater(
            client.responses.create(_request),
            throwsA(
              isA<PermissionDeniedException>()
                  .having((e) => e.message, 'caller still sees body', body)
                  .having(
                    (e) => e.toString(),
                    'fallback diagnostic',
                    isNot(contains(_private)),
                  ),
            ),
          );
          expect(records.join('\n'), isNot(contains(_private)));
        },
      );
    }

    test(
      'shared inline stream warnings preserve raw caller data privately',
      () async {
        var sends = 0;
        final body = _body(_details());
        final transport = MockClient((request) async {
          sends++;
          return http.Response(
            'event: error\ndata: ${jsonEncode(body)}\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        });
        final client = _client(transport);
        addTearDown(client.close);
        addTearDown(transport.close);
        await expectLater(
          client.audio.transcriptions
              .createStream(
                TranscriptionRequest(
                  file: Uint8List.fromList([1, 2]),
                  filename: 'fixture.wav',
                  model: 'synthetic-model',
                ),
              )
              .toList(),
          throwsA(
            isA<StreamException>()
                .having((e) => e.message, 'original message', _private)
                .having(
                  (e) => jsonDecode(e.partialData!),
                  'original payload',
                  body,
                )
                .having((e) => e.toString(), 'safe', isNot(contains(_private))),
          ),
        );
        expect(sends, 1);
        expect(records.join('\n'), isNot(contains(_private)));
      },
    );

    test('malformed escaped policy code remains private', () async {
      const code = r'misalignment_policy_viola\u0074ion';
      const body = '{"error":{"code":"$code","message":"$_private"}';
      expect(redactMonitoringErrorBody(body), '[REDACTED]');
      final transport = MockClient((request) async => http.Response(body, 403));
      final client = _client(transport);
      addTearDown(client.close);
      addTearDown(transport.close);
      await expectLater(
        client.responses.create(_request),
        throwsA(
          isA<PermissionDeniedException>()
              .having((e) => e.message, 'original', body)
              .having((e) => e.toString(), 'safe', isNot(contains(_private))),
        ),
      );
      expect(records.join('\n'), isNot(contains(_private)));
    });

    for (final monitoring in [false, true]) {
      for (final logBody in [false, true]) {
        test(
          'binary response never fails during diagnostic detection ($monitoring/$logBody)',
          () async {
            final bytes = [
              if (monitoring)
                ...utf8.encode(
                  '{"misalignment":{"review_target":"$_private"}}',
                ),
              0xff,
            ];
            final original = http.Response.bytes(
              bytes,
              200,
              headers: {
                'content-type': 'application/octet-stream; charset=utf-8',
                if (monitoring) 'x-request-id': _private,
              },
            );
            final logger = LoggingInterceptor(
              logger: Logger('binary-monitoring'),
              logResponseBody: logBody,
            );
            final context = RequestContext(
              request: http.Request(
                'GET',
                Uri.parse('https://fixture.example/v1/files/local/content'),
              ),
            );
            final result = await logger.intercept(
              context,
              (_) async => original,
            );
            expect(result, same(original));
            expect(result.bodyBytes, bytes);
            expect(records.join('\n'), isNot(contains(_private)));
            if (monitoring) expect(result.headers['x-request-id'], _private);
          },
        );
      }
    }

    test(
      'response body and echoed header metadata redact before truncation',
      () async {
        final body = jsonEncode(_body(_details()));
        final transport = MockClient(
          (request) async => http.Response(
            body,
            200,
            headers: {
              'x-request-id': _private,
              'x-private-review': 'review_target.private',
            },
          ),
        );
        final logger = LoggingInterceptor(
          logger: Logger('monitoring-fixture'),
          logResponseBody: true,
          maxBodyLength: 20,
        );
        final chain = InterceptorChain(
          interceptors: [logger],
          httpClient: transport,
        );
        addTearDown(transport.close);
        final result = await chain.execute(
          http.Request(
            'GET',
            Uri.parse('https://fixture.example/v1/responses'),
          ),
        );
        expect(result.body, body);
        expect(result.headers['x-private-review'], 'review_target.private');
        expect(records.join('\n'), isNot(contains(_private)));
        expect(records.join('\n'), isNot(contains('review_target.private')));
        expect(records.join('\n'), contains('[REDACTED]'));
      },
    );

    test(
      'arbitrary cyclic bodies remain safe; unrelated formatting preserved',
      () {
        final cycle = <String, dynamic>{};
        cycle['nested'] = cycle;
        cycle['later'] = _details();
        expect(containsMonitoringError(cycle), isFalse);
        cycle['misalignment'] = cycle;
        expect(containsMonitoringError(cycle), isTrue);
        const body = '{ "plain" : [1, null, false] }';
        expect(redactMonitoringErrorBody(body), body);
        expect(redactMonitoringErrorValue('plain error', cycle), '[REDACTED]');
        expect(
          const ApiException(statusCode: 400, message: 'plain').toString(),
          contains('plain'),
        );
      },
    );
  });
}

OpenAIClient _client(http.Client transport) => OpenAIClient(
  config: const OpenAIConfig(
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration.zero,
      jitter: 0,
    ),
  ),
  httpClient: transport,
);
