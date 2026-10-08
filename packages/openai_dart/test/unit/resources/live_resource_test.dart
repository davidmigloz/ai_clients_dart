import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE café 🚀';
const _id = 'PRIVATE/opaque%2F?café🚀';
const _recordingId = 'live_PRIVATE-recording';
const _trace = 'PRIVATE-trace';
const _clientTrace = 'PRIVATE-client-trace';
const _base =
    'https://fixture.invalid/PRIVATE-proxy/v1?token=PRIVATE-query&k=a&k=b';

void main() {
  final operations = _operations();
  group('Live public HTTP routes and wire modes', () {
    test('Live and sessions getters cache without authentication/dispatch', () {
      final fixture = _Fixture((_, _) => _success('create'));
      addTearDown(fixture.client.close);
      expect(fixture.client.live, same(fixture.client.live));
      expect(fixture.client.live.sessions, same(fixture.client.live.sessions));
      expect(fixture.auth.calls, 0);
      expect(fixture.shared.sends, 0);
      expect(fixture.factoryCalls, 0);
    });
    for (final op in operations) {
      test('${op.name} exact method/path/headers/body/response', () async {
        final fixture = _Fixture((_, _) => _success(op.name));
        addTearDown(fixture.client.close);
        final result = await op.call(fixture, null);
        final transport = op.stream ? fixture.owned : fixture.shared;
        final sent = transport.requests.single;
        expect(sent.method, op.method);
        expect(sent.url.pathSegments, [
          'PRIVATE-proxy',
          'v1',
          'live',
          'sessions',
          if (op.action != null && op.recording)
            _recordingId
          else if (op.action != null)
            _id,
          if (op.action != null) op.action!,
        ]);
        expect(sent.url.queryParametersAll, {
          'token': ['PRIVATE-query'],
          'k': ['a', 'b'],
        });
        expect(sent.headers['authorization'], 'Bearer PRIVATE-key');
        expect(sent.headers['openai-project'], 'PRIVATE-project');
        expect(sent.headers['x-fixture'], 'PRIVATE-header');
        expect(sent.headers['x-request-id'], op.stream ? isNotEmpty : _trace);
        expect(sent.headers['x-client-request-id'], _clientTrace);
        expect(
          sent.headers['accept'],
          op.recording
              ? 'audio/wav'
              : op.body == null
              ? '*/*'
              : 'application/json',
        );
        if (op.body == null) {
          expect(transport.bodies.single, isEmpty);
          expect(sent.headers.containsKey('content-type'), isFalse);
        } else {
          expect(sent.headers['content-type'], startsWith('application/json'));
          expect(jsonDecode(utf8.decode(transport.bodies.single)), op.body);
        }
        if (op.name == 'create' || op.name == 'create sip') {
          expect(result, isA<LiveSessionCreateResponse>());
          final created = result! as LiveSessionCreateResponse;
          expect(created.session.id, _id);
          expect(
            created.transport.type,
            op.name == 'create sip' ? 'sip' : 'webrtc',
          );
          if (op.name == 'create sip') {
            expect(created.transport.toJson(), {'type': 'sip'});
          }
        } else if (op.name == 'fork') {
          final forked = result! as LiveCreateResponse;
          expect(forked.session.id, 'PRIVATE-new-session');
          expect(forked.transport.sdp, _private);
        } else if (op.stream) {
          final chunks = result! as List<Uint8List>;
          expect(chunks.expand((bytes) => bytes).toList(), _wav());
          expect(fixture.owned.closes, 1);
        } else if (op.recording) {
          expect(result, _wav());
        } else {
          expect(result, isNull);
        }
        expect(transport.sends, 1);
        expect(fixture.shared.closes, 0);
        expect(fixture.factoryCalls, op.stream ? 1 : 0);
        expect(fixture.auth.calls, greaterThan(0));
      });
    }
    for (final action in ['accept', 'reject', 'refer', 'hangup', 'fork']) {
      for (final id in [
        'opaque',
        'with/slash',
        'literal%2Fescape',
        'café🚀',
        '../escape',
        '?query#fragment',
        ' spaces ',
        '%2E',
      ]) {
        test('$action opaque ID encoded once: $id', () async {
          final fixture = _Fixture((_, _) => _success(action));
          addTearDown(fixture.client.close);
          await _control(fixture, action, id);
          final url = fixture.shared.requests.single.url;
          expect(url.pathSegments, [
            'PRIVATE-proxy',
            'v1',
            'live',
            'sessions',
            id,
            action,
          ]);
          expect(
            url.toString(),
            contains('/sessions/${Uri.encodeComponent(id)}/$action'),
          );
          expect(url.queryParametersAll['k'], ['a', 'b']);
        });
      }
      for (final id in ['', '.', '..']) {
        test('$action unsendable ID safe pre-auth failure', () async {
          final fixture = _Fixture((_, _) => _success(action));
          addTearDown(fixture.client.close);
          await expectLater(
            _control(fixture, action, id),
            throwsA(_safeFormat),
          );
          expect(fixture.auth.calls, 0);
          expect(fixture.shared.sends, 0);
        });
      }
    }
    for (final streamed in [false, true]) {
      for (final id in ['live_a', 'live_${'a' * 128}', 'live_Az09_-']) {
        test(
          'download ${streamed ? 'stream' : 'buffer'} declared ID admitted',
          () async {
            final fixture = _Fixture((_, _) => _success('download'));
            addTearDown(fixture.client.close);
            await _download(fixture, id, streamed);
            expect(
              (streamed ? fixture.owned : fixture.shared)
                  .requests
                  .single
                  .url
                  .pathSegments[4],
              id,
            );
          },
        );
      }
      for (final id in [
        '',
        'live_',
        'live_${'a' * 129}',
        'other_123',
        'live_a/b',
        'live_a%20',
        'live_café',
        'live_🚀',
        'live_a\n',
        '../live_a',
      ]) {
        test(
          'download ${streamed ? 'stream' : 'buffer'} rejects content-specific bad ID safely',
          () async {
            final fixture = _Fixture((_, _) => _success('download'));
            addTearDown(fixture.client.close);
            await expectLater(
              _download(fixture, id, streamed),
              throwsA(_safeFormat),
            );
            expect(fixture.auth.calls, 0);
            expect(fixture.factoryCalls, 0);
            expect(fixture.shared.sends, 0);
          },
        );
      }
    }
    test(
      'REST fork preserves omitted versus empty overrides and receives a new ID',
      () async {
        final fixture = _Fixture((_, _) => _success('fork'));
        addTearDown(fixture.client.close);
        await fixture.client.live.sessions.fork(
          _id,
          LiveForkRequest(transport: _offer()),
        );
        await fixture.client.live.sessions.fork(
          _id,
          LiveForkRequest(
            transport: _offer(),
            session: LiveMediaSessionForkParams(),
          ),
        );
        expect(
          (jsonDecode(utf8.decode(fixture.shared.bodies[0])) as Map)
              .containsKey('session'),
          isFalse,
        );
        expect(
          (jsonDecode(utf8.decode(fixture.shared.bodies[1])) as Map)['session'],
          <String, dynamic>{},
        );
      },
    );
  });

  group('Live shared auth, native abort and closed guards', () {
    for (final op in operations) {
      for (final errorSignal in [false, true]) {
        test(
          '${op.name} completed ${errorSignal ? 'error' : 'success'} abort wins before auth/factory/dispatch',
          () async {
            final fixture = _Fixture((_, _) => _success(op.name));
            addTearDown(fixture.client.close);
            final trigger = errorSignal
                ? Future<void>.error(StateError(_private))
                : Future<void>.value();
            await expectLater(
              op.call(fixture, trigger),
              throwsA(
                isA<AbortedException>()
                    .having(
                      (e) => e.stage,
                      'stage',
                      AbortionStage.beforeRequest,
                    )
                    .having(
                      (e) => e.toString(),
                      'safe',
                      isNot(contains('PRIVATE')),
                    ),
              ),
            );
            expect(fixture.auth.calls, 0);
            expect(fixture.factoryCalls, 0);
            expect(fixture.shared.sends, 0);
          },
        );
      }
      test('${op.name} closed client fails before auth/send', () async {
        final fixture = _Fixture((_, _) => _success(op.name));
        fixture.client.close();
        await expectLater(op.call(fixture, null), throwsStateError);
        expect(fixture.auth.calls, 0);
        expect(fixture.factoryCalls, 0);
        expect(fixture.shared.sends, 0);
      });
      test(
        '${op.name} native pending-header abort preserves privacy and never replays',
        () async {
          final abort = Completer<void>();
          final fixture = _Fixture((request, _) async {
            expect(request, isA<http.Abortable>());
            await (request as http.Abortable).abortTrigger;
            throw http.RequestAbortedException(request.url);
          }, maxRetries: 3);
          addTearDown(fixture.client.close);
          final future = op.call(fixture, abort.future);
          final expectation = expectLater(
            future,
            throwsA(
              isA<AbortedException>()
                  .having(
                    (e) => e.toString(),
                    'safe',
                    isNot(contains('PRIVATE')),
                  )
                  .having(
                    (e) =>
                        e.correlationId ==
                        (op.stream
                            ? fixture
                                  .owned
                                  .requests
                                  .single
                                  .headers['x-request-id']
                            : _trace),
                    'actual sent trace',
                    isTrue,
                  ),
            ),
          );
          await (op.stream ? fixture.owned : fixture.shared).sent.future;
          abort.complete();
          await expectation;
          expect((op.stream ? fixture.owned : fixture.shared).sends, 1);
          expect(fixture.shared.closes, 0);
          if (op.stream) expect(fixture.owned.closes, 1);
        },
      );
      test(
        '${op.name} native abort during response body settles without replay',
        () async {
          final abort = Completer<void>();
          final body = StreamController<List<int>>();
          final fixture = _Fixture((request, _) {
            final trigger = (request as http.Abortable).abortTrigger!;
            unawaited(
              trigger.then(
                (_) => body.addError(http.RequestAbortedException(request.url)),
              ),
            );
            return http.StreamedResponse(
              body.stream,
              op.successStatus,
              headers: {
                'content-type': op.recording ? 'audio/wav' : 'application/json',
              },
            );
          }, maxRetries: 3);
          addTearDown(fixture.client.close);
          final expectation = expectLater(
            op.call(fixture, abort.future),
            throwsA(
              isA<AbortedException>()
                  .having(
                    (e) => e.toString(),
                    'safe',
                    isNot(contains('PRIVATE')),
                  )
                  .having(
                    (e) =>
                        e.correlationId ==
                        (op.stream
                            ? fixture
                                  .owned
                                  .requests
                                  .single
                                  .headers['x-request-id']
                            : _trace),
                    'actual sent trace',
                    isTrue,
                  ),
            ),
          );
          await (op.stream ? fixture.owned : fixture.shared).sent.future;
          await Future<void>.delayed(Duration.zero);
          abort.complete();
          await expectation;
          await body.close();
          expect((op.stream ? fixture.owned : fixture.shared).sends, 1);
          expect(fixture.shared.closes, 0);
          if (op.stream) expect(fixture.owned.closes, 1);
        },
      );
    }
    for (final op in operations) {
      test(
        '${op.name} independently reported native abort retains identical cause and actual trace',
        () async {
          late http.RequestAbortedException original;
          final fixture = _Fixture((request, _) {
            original = http.RequestAbortedException(request.url);
            throw original;
          }, maxRetries: 3);
          addTearDown(fixture.client.close);
          final error =
              await _failure(() => op.call(fixture, Completer<void>().future))
                  as AbortedException;
          expect(error.cause, same(original));
          expect(
            error.correlationId,
            (op.stream ? fixture.owned : fixture.shared)
                .requests
                .single
                .headers['x-request-id'],
          );
          expect(error.toString(), isNot(contains('PRIVATE')));
          expect((op.stream ? fixture.owned : fixture.shared).sends, 1);
          if (op.stream) expect(fixture.owned.closes, 1);
        },
      );
    }
    test('closing during pre-auth async boundary fails without auth', () async {
      final fixture = _Fixture((_, _) => _success('create'));
      final pending = fixture.client.live.sessions.create(
        _create(),
        abortTrigger: Completer<void>().future,
      );
      fixture.client.close();
      await expectLater(pending, throwsStateError);
      expect(fixture.auth.calls, 0);
      expect(fixture.shared.sends, 0);
    });
    test(
      'stream eager guard and delayed listen closed guard both apply',
      () async {
        final fixture = _Fixture((_, _) => _success('download'));
        final stream = fixture.client.live.sessions.downloadRecordingStream(
          _recordingId,
        );
        fixture.client.close();
        await expectLater(stream.toList(), throwsStateError);
        expect(
          () => fixture.client.live.sessions.downloadRecordingStream(
            _recordingId,
          ),
          throwsStateError,
        );
        expect(fixture.auth.calls, 0);
        expect(fixture.factoryCalls, 0);
      },
    );
  });

  group('Live HTTP exact statuses, shared raw errors and private parsing', () {
    for (final op in operations) {
      for (final status in [
        199,
        302,
        400,
        401,
        403,
        404,
        409,
        413,
        429,
        500,
        502,
        503,
        504,
      ]) {
        test(
          '${op.name} HTTP $status classified before success parse with full caller context',
          () async {
            final bytes = utf8.encode(
              jsonEncode({
                'error': {
                  'message': _private,
                  'type': 'PRIVATE-type',
                  'code': 'PRIVATE-code',
                  'param': 'PRIVATE-param',
                },
              }),
            );
            final fixture = _Fixture(
              (_, _) => http.StreamedResponse(
                Stream.value(bytes),
                status,
                headers: {
                  'content-type': 'application/json',
                  'x-request-id': _trace,
                  'retry-after': '9',
                  'x-private': _private,
                },
              ),
            );
            addTearDown(fixture.client.close);
            final error = await _failure(() => op.call(fixture, null));
            expect(error, isA<ApiException>());
            final api = error as ApiException;
            expect(api.statusCode, status);
            expect(api.message, _private);
            expect(api.type, 'PRIVATE-type');
            expect(api.code, 'PRIVATE-code');
            expect(api.param, 'PRIVATE-param');
            expect(api.requestId, _trace);
            if (api is RateLimitException) {
              expect(api.retryAfter, const Duration(seconds: 9));
            }
            if (api is InternalServerException) {
              expect(api.retryAfter, const Duration(seconds: 9));
            }
            expect(api.body!['error'], {
              'message': _private,
              'type': 'PRIVATE-type',
              'code': 'PRIVATE-code',
              'param': 'PRIVATE-param',
            });
            expect(api.toString(), isNot(contains('PRIVATE')));
            final cause = api.cause! as http.Response;
            expect(cause.bodyBytes, bytes);
            expect(cause.statusCode, status);
            expect(cause.headers['x-private'], _private);
            expect(
              cause.request!.url.queryParameters['token'],
              'PRIVATE-query',
            );
            expect(
              cause.request!.headers['x-request-id'],
              op.stream
                  ? fixture.owned.requests.single.headers['x-request-id']
                  : _trace,
            );
            expect((op.stream ? fixture.owned : fixture.shared).sends, 1);
            if (op.stream) expect(fixture.owned.closes, 1);
          },
        );
      }
      test(
        '${op.name} plain-text error honors charset and preserves original bytes',
        () async {
          final bytes = latin1.encode('PRIVATE café');
          final fixture = _Fixture(
            (_, _) => http.StreamedResponse(
              Stream.value(bytes),
              500,
              headers: {
                'content-type': 'text/plain; charset=iso-8859-1',
                'x-request-id': _trace,
              },
            ),
          );
          addTearDown(fixture.client.close);
          final error =
              await _failure(() => op.call(fixture, null)) as ApiException;
          expect(error.message, 'PRIVATE café');
          expect((error.cause! as http.Response).bodyBytes, bytes);
          expect(error.toString(), isNot(contains('PRIVATE')));
        },
      );
      test(
        '${op.name} noncanonical success status fails contextually',
        () async {
          final fixture = _Fixture(
            (_, _) => http.StreamedResponse(
              Stream.value(<int>[]),
              202,
              headers: {'content-type': 'audio/wav'},
            ),
          );
          addTearDown(fixture.client.close);
          await expectLater(
            op.call(fixture, null),
            throwsA(
              isA<ParseException>()
                  .having(
                    (e) => e.toString(),
                    'safe',
                    isNot(contains('PRIVATE')),
                  )
                  .having(
                    (e) => e.cause,
                    'HTTP cause',
                    isA<http.BaseResponse>(),
                  ),
            ),
          );
        },
      );
    }
    for (final op in operations.where(
      (op) => const ['accept', 'reject', 'refer', 'hangup'].contains(op.name),
    )) {
      test(
        '${op.name} empty 200 enforced without silent ignored private body',
        () async {
          final fixture = _Fixture(
            (_, _) =>
                http.StreamedResponse(Stream.value(utf8.encode(_private)), 200),
          );
          addTearDown(fixture.client.close);
          final error =
              await _failure(() => op.call(fixture, null)) as ParseException;
          expect(error.responseBody, _private);
          expect(error.toString(), isNot(contains('PRIVATE')));
        },
      );
    }
    for (final action in ['create', 'fork']) {
      for (final body in [
        'PRIVATE invalid JSON',
        '[]',
        '{"session":null,"transport":{"type":"webrtc","sdp":"PRIVATE"}}',
        '{"session":{"id":"PRIVATE"},"transport":{"type":"webrtc","sdp":1}}',
        '{"session":{"id":"PRIVATE"},"transport":{"type":"webrtc","sdp":""}}',
      ]) {
        test(
          '$action malformed known JSON safely contextual with raw body retained',
          () async {
            final fixture = _Fixture(
              (_, _) => http.StreamedResponse(
                Stream.value(utf8.encode(body)),
                201,
                headers: {'content-type': 'application/json'},
              ),
            );
            addTearDown(fixture.client.close);
            final error =
                await _failure(
                      () => action == 'create'
                          ? fixture.client.live.sessions.create(_create())
                          : fixture.client.live.sessions.fork(
                              _id,
                              LiveForkRequest(transport: _offer()),
                            ),
                    )
                    as ParseException;
            expect(error.responseBody, body);
            expect(error.toString(), isNot(contains('PRIVATE')));
            expect(error.cause, isA<FormatException>());
            expect((error.cause! as FormatException).source, isNull);
          },
        );
      }
    }
    test('create future response data remains immutable and private', () async {
      final json = {
        'session': {
          'id': _id,
          'PRIVATE-new-key': [_private],
        },
        'transport': {
          'type': 'sip',
          'PRIVATE-new-key': {'sdp': _private},
        },
        'PRIVATE-extra': {
          'credentials': [_private],
        },
      };
      final fixture = _Fixture((_, _) => _json(json, 201));
      addTearDown(fixture.client.close);
      final result = await fixture.client.live.sessions.create(
        _create(sip: true),
      );
      expect(result.toJson(), json);
      expect(result.toString(), isNot(contains('PRIVATE')));
      expect(
        () => (result.rawJson['PRIVATE-extra'] as Map)['credentials'] =
            <dynamic>[],
        throwsUnsupportedError,
      );
    });
    for (final streamed in [false, true]) {
      for (final media in [
        null,
        'application/json',
        'text/event-stream',
        'application/octet-stream',
        'audio/mpeg',
      ]) {
        test(
          'download ${streamed ? 'stream' : 'buffer'} mode mismatch safely rejects media $media',
          () async {
            final fixture = _Fixture(
              (_, _) => http.StreamedResponse(
                Stream.value(_wav()),
                200,
                headers: {'content-type': ?media},
              ),
            );
            addTearDown(fixture.client.close);
            await expectLater(
              _download(fixture, _recordingId, streamed),
              throwsA(
                isA<ParseException>().having(
                  (e) => e.toString(),
                  'safe',
                  isNot(contains('PRIVATE')),
                ),
              ),
            );
            if (streamed) expect(fixture.owned.closes, 1);
          },
        );
      }
    }
  });

  group('Live SIP conservative shared POST retry policy', () {
    for (final unit in ['a', 'é', '🚀']) {
      for (final delta in [-1, 0, 1]) {
        test(
          'public SIP exact UTF-8 JSON 1 MiB boundary $delta with $unit admitted before auth',
          () async {
            final fixture = _Fixture((_, _) => _success('create sip'));
            addTearDown(fixture.client.close);
            final prototype = _create(sip: true).copyWith(
              session: LiveMediaSessionCreateParams(
                model: 'gpt-live-1',
                instructions: '',
              ),
            );
            final target = LiveSessionCreateRequest.maxSipRequestBytes + delta;
            final padding =
                target - utf8.encode(jsonEncode(prototype.toJson())).length;
            final width = utf8.encode(unit).length;
            final instructions =
                unit * (padding ~/ width) + 'a' * (padding % width);
            final operation = Future.sync(
              () => fixture.client.live.sessions.create(
                prototype.copyWith(
                  session: prototype.session.copyWith(
                    instructions: instructions,
                  ),
                ),
              ),
            );
            if (delta <= 0) {
              await operation;
              expect(fixture.shared.bodies.single.length, target);
              expect(
                (jsonDecode(utf8.decode(fixture.shared.bodies.single))
                    as Map<String, dynamic>)['session'],
                prototype.session.copyWith(instructions: instructions).toJson(),
              );
              expect(fixture.shared.sends, 1);
            } else {
              await expectLater(operation, throwsA(_safeFormat));
              expect(fixture.auth.calls, 0);
              expect(fixture.shared.sends, 0);
              expect(fixture.factoryCalls, 0);
            }
          },
        );
      }
    }
    test('public WebRTC body over 1 MiB retains separate admission', () async {
      final fixture = _Fixture((_, _) => _success('create'));
      addTearDown(fixture.client.close);
      final sdp = 'a' * (LiveSessionCreateRequest.maxSipRequestBytes + 1);
      await fixture.client.live.sessions.create(
        _create().copyWith(transport: LiveWebRTCTransport(sdp: sdp)),
      );
      expect(
        fixture.shared.bodies.single.length,
        greaterThan(LiveSessionCreateRequest.maxSipRequestBytes),
      );
      expect(fixture.shared.sends, 1);
    });
    for (final failure in ['client', 'timeout', '500', '502', '503', '504']) {
      test(
        'outbound SIP ambiguous $failure exactly one attempt despite maxRetries',
        () async {
          final original = http.ClientException(
            _private,
            Uri.parse('https://PRIVATE.invalid/private'),
          );
          final fixture = _Fixture(
            (_, _) {
              if (failure == 'client') throw original;
              if (failure == 'timeout') {
                return Completer<http.StreamedResponse>().future;
              }
              return http.StreamedResponse(
                Stream.value(utf8.encode(_private)),
                int.parse(failure),
                headers: {'content-type': 'text/plain'},
              );
            },
            maxRetries: 4,
            timeout: const Duration(milliseconds: 30),
          );
          addTearDown(fixture.client.close);
          final error = await _failure(
            () => fixture.client.live.sessions.create(_create(sip: true)),
          );
          expect(fixture.shared.sends, 1);
          expect(fixture.factoryCalls, 0);
          expect(
            fixture.shared.requests.single.headers['x-client-request-id'],
            _clientTrace,
          );
          expect(error.toString(), isNot(contains('PRIVATE')));
          if (failure == 'client') {
            final connection = error as ConnectionException;
            expect(connection.message, _private);
            expect(connection.url, original.uri.toString());
            expect(connection.cause, same(original));
          } else if (failure == 'timeout') {
            expect(error, isA<RequestTimeoutException>());
          } else {
            expect((error as ApiException).statusCode, int.parse(failure));
          }
        },
      );
    }
    test(
      'transient rejected SIP 429 retains eligible shared retry policy',
      () async {
        late _Fixture fixture;
        fixture = _Fixture(
          (_, _) => fixture.shared.sends == 1
              ? _json({
                  'error': {'message': _private, 'type': 'rate_limit_error'},
                }, 429)
              : _success('create sip'),
          maxRetries: 2,
        );
        addTearDown(fixture.client.close);
        final result = await fixture.client.live.sessions.create(
          _create(sip: true),
        );
        expect(result.transport.type, 'sip');
        expect(fixture.shared.sends, 2);
        expect(fixture.shared.bodies[0], fixture.shared.bodies[1]);
        expect(
          fixture.shared.requests[0].headers['x-request-id'],
          fixture.shared.requests[1].headers['x-request-id'],
        );
      },
    );
    for (final code in ['insufficient_quota', 'project_spend_limit_exceeded']) {
      test('permanent SIP quota $code is never replayed', () async {
        final fixture = _Fixture(
          (_, _) => _json({
            'error': {'message': _private, 'code': code},
          }, 429),
          maxRetries: 3,
        );
        addTearDown(fixture.client.close);
        await expectLater(
          fixture.client.live.sessions.create(_create(sip: true)),
          throwsA(isA<RateLimitException>()),
        );
        expect(fixture.shared.sends, 1);
      });
    }
    test('abort during rejected429 wait stops policy without replay', () async {
      final abort = Completer<void>();
      final fixture = _Fixture(
        (_, _) => _json(
          {
            'error': {'message': _private},
          },
          429,
          headers: {'retry-after-ms': '100'},
        ),
        maxRetries: 2,
        initialDelay: const Duration(milliseconds: 100),
      );
      addTearDown(fixture.client.close);
      final expectation = expectLater(
        fixture.client.live.sessions.create(
          _create(sip: true),
          abortTrigger: abort.future,
        ),
        throwsA(
          isA<AbortedException>()
              .having((e) => e.correlationId, 'caller trace', _trace)
              .having((e) => e.toString(), 'safe', isNot(contains('PRIVATE'))),
        ),
      );
      await fixture.shared.sent.future;
      abort.complete();
      await expectation;
      expect(fixture.shared.sends, 1);
    });
  });

  group('Live recording owned stream lifecycle', () {
    for (final sse in [false, true]) {
      test(
        'shared byte extraction preserves original Speech ${sse ? 'SSE' : 'bytes'} ClientException contract',
        () async {
          final original = http.ClientException(
            _private,
            Uri.parse('https://PRIVATE.invalid/private'),
          );
          final fixture = _Fixture((_, _) => throw original, maxRetries: 3);
          addTearDown(fixture.client.close);
          const request = SpeechRequest(
            model: 'tts-1',
            input: _private,
            voice: SpeechVoice.alloy,
          );
          final result = sse
              ? fixture.client.audio.speech.createStream(request).toList()
              : fixture.client.audio.speech.createByteStream(request).toList();
          await expectLater(result, throwsA(same(original)));
          expect(fixture.owned.sends, 1);
          expect(fixture.owned.closes, 1);
          expect(fixture.shared.closes, 0);
        },
      );
    }
    test(
      'injected HTTP client without factory stays isolated and borrowed for downloads',
      () async {
        final mock = _Transport((_, _) => _success('download'));
        final client = OpenAIClient(
          config: const OpenAIConfig(
            baseUrl: 'https://fixture.invalid/v1',
            authProvider: ApiKeyProvider('PRIVATE-key'),
          ),
          httpClient: mock,
        );
        addTearDown(client.close);
        final chunks = await client.live.sessions
            .downloadRecordingStream(_recordingId)
            .toList();
        expect(chunks.expand((chunk) => chunk).toList(), _wav());
        expect(mock.sends, 1);
        expect(mock.requests.single.url.host, 'fixture.invalid');
        expect(mock.requests.single.headers['accept'], 'audio/wav');
        expect(
          mock.requests.single.headers.containsKey('content-type'),
          isFalse,
        );
        expect(mock.closes, 0);
        client.close();
        expect(mock.closes, 0);
        mock.close();
      },
    );
    for (final status in [429, 503]) {
      test(
        'owned recording stream HTTP$status preserves retry hint without automatic replay',
        () async {
          final fixture = _Fixture(
            (_, _) => _json(
              {
                'error': {'message': _private},
              },
              status,
              headers: {'retry-after': '1'},
            ),
            maxRetries: 3,
          );
          addTearDown(fixture.client.close);
          final error =
              await _failure(
                    () => fixture.client.live.sessions
                        .downloadRecordingStream(_recordingId)
                        .toList(),
                  )
                  as ApiException;
          if (error is RateLimitException) {
            expect(error.retryAfter, const Duration(seconds: 1));
          }
          if (error is InternalServerException) {
            expect(error.retryAfter, const Duration(seconds: 1));
          }
          expect(fixture.owned.sends, 1);
          expect(fixture.owned.closes, 1);
        },
      );
    }
    test(
      'chunked stereo WAV stays untouched and successful audio never replays',
      () async {
        final fixture = _Fixture(
          (_, _) => http.StreamedResponse(
            Stream.fromIterable([_wav().sublist(0, 10), _wav().sublist(10)]),
            200,
            headers: {'content-type': 'Audio/Wav; fixture=PRIVATE'},
          ),
          maxRetries: 3,
        );
        addTearDown(fixture.client.close);
        final chunks = await fixture.client.live.sessions
            .downloadRecordingStream(_recordingId)
            .toList();
        expect(chunks.map((c) => c.length), [10, _wav().length - 10]);
        expect(chunks.expand((c) => c).toList(), _wav());
        expect(fixture.owned.sends, 1);
        expect(fixture.owned.closes, 1);
        expect(fixture.shared.closes, 0);
      },
    );
    for (final duringBody in [false, true]) {
      test(
        'stream ${duringBody ? 'body idle' : 'pending headers'} timeout closes once and never replays',
        () async {
          final body = StreamController<List<int>>();
          final fixture = _Fixture(
            (_, _) => duringBody
                ? http.StreamedResponse(
                    body.stream,
                    200,
                    headers: {'content-type': 'audio/wav'},
                  )
                : Completer<http.StreamedResponse>().future,
            timeout: const Duration(milliseconds: 30),
            maxRetries: 3,
          );
          addTearDown(fixture.client.close);
          await expectLater(
            fixture.client.live.sessions
                .downloadRecordingStream(_recordingId)
                .toList(),
            throwsA(isA<RequestTimeoutException>()),
          );
          if (duringBody) await body.close();
          expect(fixture.owned.sends, 1);
          expect(fixture.owned.closes, 1);
          expect(fixture.shared.closes, 0);
        },
      );
    }
    test(
      'pause suspends idle timeout and resumes original chunk delivery',
      () async {
        final body = StreamController<List<int>>();
        final fixture = _Fixture(
          (_, _) => http.StreamedResponse(
            body.stream,
            200,
            headers: {'content-type': 'audio/wav'},
          ),
          timeout: const Duration(milliseconds: 30),
        );
        addTearDown(fixture.client.close);
        final chunks = <Uint8List>[];
        final errors = <Object>[];
        final done = Completer<void>();
        final subscription = fixture.client.live.sessions
            .downloadRecordingStream(_recordingId)
            .listen(chunks.add, onError: errors.add, onDone: done.complete);
        await fixture.owned.sent.future;
        subscription.pause();
        await Future<void>.delayed(const Duration(milliseconds: 70));
        expect(fixture.owned.closes, 0);
        body.add(_wav());
        subscription.resume();
        await body.close();
        await done.future;
        await subscription.cancel();
        expect(errors, isEmpty);
        expect(chunks.single, _wav());
        expect(fixture.owned.closes, 1);
      },
    );
    test(
      'subscription cancel before pending headers releases owned client and late body',
      () async {
        final headers = Completer<http.StreamedResponse>();
        var bodyCancelled = 0;
        final body = StreamController<List<int>>(
          onCancel: () => bodyCancelled++,
        );
        final fixture = _Fixture((_, _) => headers.future);
        addTearDown(fixture.client.close);
        final subscription = fixture.client.live.sessions
            .downloadRecordingStream(_recordingId)
            .listen((_) {}, onError: (Object _) {});
        await fixture.owned.sent.future;
        await subscription.cancel();
        expect(fixture.owned.closes, 1);
        headers.complete(
          http.StreamedResponse(
            body.stream,
            200,
            headers: {'content-type': 'audio/wav'},
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(bodyCancelled, 1);
        expect(fixture.owned.closes, 1);
        await body.close();
      },
    );
    test(
      'subscription cancel after first audio releases one request and stops audio',
      () async {
        var cancelled = 0;
        final body = StreamController<List<int>>(onCancel: () => cancelled++);
        final fixture = _Fixture(
          (_, _) => http.StreamedResponse(
            body.stream,
            200,
            headers: {'content-type': 'audio/wav'},
          ),
          maxRetries: 3,
        );
        addTearDown(fixture.client.close);
        final first = Completer<Uint8List>();
        final subscription = fixture.client.live.sessions
            .downloadRecordingStream(_recordingId)
            .listen(first.complete, onError: (Object _) {});
        await fixture.owned.sent.future;
        body.add(_wav());
        expect(await first.future, _wav());
        await subscription.cancel();
        expect(cancelled, 1);
        expect(fixture.owned.closes, 1);
        expect(fixture.owned.sends, 1);
        await body.close();
      },
    );
    test(
      'borrowed identical factory client is never closed by stream cancellation',
      () async {
        final headers = Completer<http.StreamedResponse>();
        final fixture = _Fixture((_, _) => headers.future, borrowFactory: true);
        addTearDown(fixture.client.close);
        final subscription = fixture.client.live.sessions
            .downloadRecordingStream(_recordingId)
            .listen((_) {}, onError: (Object _) {});
        await fixture.shared.sent.future;
        await subscription.cancel();
        expect(fixture.shared.closes, 0);
        expect(fixture.factoryCalls, 1);
        headers.complete(_success('download'));
      },
    );
    test(
      'factory failure is contextual and does not dispatch or close shared client',
      () async {
        final fixture = _Fixture(
          (_, _) => _success('download'),
          failFactory: true,
        );
        addTearDown(fixture.client.close);
        await expectLater(
          fixture.client.live.sessions
              .downloadRecordingStream(_recordingId)
              .toList(),
          throwsStateError,
        );
        expect(fixture.factoryCalls, 1);
        expect(fixture.shared.sends, 0);
        expect(fixture.shared.closes, 0);
      },
    );
    for (final duringBody in [false, true]) {
      test(
        'stream ClientException ${duringBody ? 'after first chunk' : 'before headers'} retains raw cause privately',
        () async {
          final original = http.ClientException(
            _private,
            Uri.parse('https://PRIVATE.invalid/private'),
          );
          final body = StreamController<List<int>>();
          final fixture = _Fixture((_, _) {
            if (!duringBody) throw original;
            return http.StreamedResponse(
              body.stream,
              200,
              headers: {'content-type': 'audio/wav'},
            );
          }, maxRetries: 3);
          addTearDown(fixture.client.close);
          final result = fixture.client.live.sessions
              .downloadRecordingStream(_recordingId)
              .toList();
          final expectation = expectLater(
            result,
            throwsA(
              isA<ConnectionException>()
                  .having((e) => e.message, 'raw message', _private)
                  .having((e) => e.cause, 'raw cause', same(original))
                  .having(
                    (e) => e.toString(),
                    'safe',
                    isNot(contains('PRIVATE')),
                  ),
            ),
          );
          if (duringBody) {
            await fixture.owned.sent.future;
            body
              ..add(_wav())
              ..addError(original);
          }
          await expectation;
          if (duringBody) await body.close();
          expect(fixture.owned.sends, 1);
          expect(fixture.owned.closes, 1);
          expect(fixture.shared.closes, 0);
        },
      );
    }
  });

  group('Live default and enabled diagnostics protect private context', () {
    for (final op in operations) {
      for (final outcome in ['success', 'http error', 'connection error']) {
        test(
          '${op.name} FINEST $outcome preserves caller context and private logs',
          () async {
            final records = await _captureLogs(() async {
              final fixture = _Fixture((_, _) {
                if (outcome == 'connection error') {
                  throw http.ClientException(
                    _private,
                    Uri.parse('https://PRIVATE.invalid/private'),
                  );
                }
                if (outcome == 'http error') {
                  return _json({
                    'error': {
                      'message': _private,
                      'type': _private,
                      'code': _private,
                      'param': _private,
                    },
                  }, 500);
                }
                return _success(op.name);
              }, logLevel: Level.FINEST);
              addTearDown(fixture.client.close);
              if (outcome == 'success') {
                await op.call(fixture, null);
              } else {
                final error = await _failure(() => op.call(fixture, null));
                expect(error.toString(), isNot(contains('PRIVATE')));
                if (error is ApiException) expect(error.message, _private);
                if (error is ConnectionException) {
                  expect(error.message, _private);
                }
              }
            });
            for (final record in records) {
              expect(
                '${record.message} ${record.error} ${record.stackTrace}',
                isNot(contains('PRIVATE')),
              );
            }
          },
        );
      }
    }
  });
}

LiveWebRTCTransport _offer() => LiveWebRTCTransport(sdp: _private);
LiveSessionCreateRequest _create({bool sip = false}) =>
    LiveSessionCreateRequest(
      session: LiveMediaSessionCreateParams(
        model: 'gpt-live-1',
        instructions: _private,
      ),
      transport: sip
          ? LiveSIPTransport(
              destination: '+14155550123',
              trunk: LiveSIPTrunk(
                providerUrl: 'sips:sip.example.com:5061',
                auth: LiveSIPTrunkAuth(username: _private, password: _private),
                callerNumber: '+14155550100',
              ),
            )
          : _offer(),
    );
LiveCallAcceptRequest _accept() => LiveCallAcceptRequest(
  session: LiveCallAcceptSession(model: 'gpt-live-1', instructions: _private),
);

Future<Object?> _control(
  _Fixture fixture,
  String action,
  String id, {
  Future<void>? abortTrigger,
}) async {
  final sessions = fixture.client.live.sessions;
  switch (action) {
    case 'accept':
      await sessions.accept(id, _accept(), abortTrigger: abortTrigger);
    case 'reject':
      await sessions.reject(
        id,
        LiveCallRejectRequest(statusCode: 486),
        abortTrigger: abortTrigger,
      );
    case 'refer':
      await sessions.refer(
        id,
        LiveCallReferRequest(targetUri: 'sip:PRIVATE@example.com'),
        abortTrigger: abortTrigger,
      );
    case 'hangup':
      await sessions.hangup(id, abortTrigger: abortTrigger);
    case 'fork':
      return sessions.fork(
        id,
        LiveForkRequest(transport: _offer()),
        abortTrigger: abortTrigger,
      );
    default:
      throw StateError('Unknown fixture action');
  }
  return null;
}

Future<Object?> _download(
  _Fixture fixture,
  String id,
  bool streamed, {
  Future<void>? abortTrigger,
}) async => streamed
    ? await fixture.client.live.sessions
          .downloadRecordingStream(id, abortTrigger: abortTrigger)
          .toList()
    : await fixture.client.live.sessions.downloadRecording(
        id,
        abortTrigger: abortTrigger,
      );

List<_Operation> _operations() => [
  _Operation(
    'create',
    (f, a) => f.client.live.sessions.create(_create(), abortTrigger: a),
    body: _create().toJson(),
    successStatus: 201,
  ),
  _Operation(
    'create sip',
    (f, a) =>
        f.client.live.sessions.create(_create(sip: true), abortTrigger: a),
    body: _create(sip: true).toJson(),
    successStatus: 201,
  ),
  for (final action in ['accept', 'reject', 'refer', 'hangup', 'fork'])
    _Operation(
      action,
      (f, a) => _control(f, action, _id, abortTrigger: a),
      action: action,
      successStatus: action == 'fork' ? 201 : 200,
      body: switch (action) {
        'accept' => _accept().toJson(),
        'reject' => {'status_code': 486},
        'refer' => {'target_uri': 'sip:PRIVATE@example.com'},
        'fork' => LiveForkRequest(transport: _offer()).toJson(),
        _ => null,
      },
    ),
  _Operation(
    'download',
    (f, a) => _download(f, _recordingId, false, abortTrigger: a),
    method: 'GET',
    action: 'content',
    recording: true,
  ),
  _Operation(
    'download stream',
    (f, a) => _download(f, _recordingId, true, abortTrigger: a),
    method: 'GET',
    action: 'content',
    recording: true,
    stream: true,
  ),
];

http.StreamedResponse _success(String operation) {
  if (operation == 'create' || operation == 'create sip') {
    return _json({
      'session': {'id': _id},
      'transport': {
        'type': operation == 'create sip' ? 'sip' : 'webrtc',
        if (operation == 'create') 'sdp': _private,
      },
    }, 201);
  }
  if (operation == 'fork') {
    return _json({
      'session': {'id': 'PRIVATE-new-session'},
      'transport': {'type': 'webrtc', 'sdp': _private},
    }, 201);
  }
  if (operation.startsWith('download')) {
    return http.StreamedResponse(
      Stream.value(_wav()),
      200,
      headers: {'content-type': 'audio/wav'},
    );
  }
  return http.StreamedResponse(Stream.value(<int>[]), 200);
}

http.StreamedResponse _json(
  Map<String, dynamic> json,
  int status, {
  Map<String, String> headers = const {},
}) => http.StreamedResponse(
  Stream.value(utf8.encode(jsonEncode(json))),
  status,
  headers: {'content-type': 'application/json', ...headers},
);
List<int> _wav() => [
  ...ascii.encode('RIFF'),
  40,
  0,
  0,
  0,
  ...ascii.encode('WAVEfmt '),
  16,
  0,
  0,
  0,
  1,
  0,
  2,
  0,
  128,
  187,
  0,
  0,
  0,
  238,
  2,
  0,
  4,
  0,
  16,
  0,
  ...ascii.encode('data'),
  4,
  0,
  0,
  0,
  0,
  128,
  255,
  127,
];

Future<Object> _failure(Future<Object?> Function() action) async {
  try {
    await action();
  } catch (error) {
    return error;
  }
  throw StateError('Fixture expected failure');
}

final TypeMatcher<FormatException> _safeFormat = isA<FormatException>()
    .having((e) => e.toString(), 'safe', isNot(contains('PRIVATE')))
    .having((e) => e.source, 'source', isNull);

class _Operation {
  _Operation(
    this.name,
    this.call, {
    this.method = 'POST',
    this.action,
    this.body,
    this.recording = false,
    this.stream = false,
    this.successStatus = 200,
  });
  final String name;
  final Future<Object?> Function(_Fixture, Future<void>?) call;
  final String method;
  final String? action;
  final Map<String, dynamic>? body;
  final bool recording;
  final bool stream;
  final int successStatus;
}

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return {
      'Authorization': 'Bearer PRIVATE-key',
      'X-Request-ID': _trace,
      'X-Client-Request-ID': _clientTrace,
      'Accept': 'application/PRIVATE-xml',
      'content-type': 'text/PRIVATE-plain; charset=PRIVATE-charset',
    };
  }
}

class _Transport extends http.BaseClient {
  _Transport(this.handler);
  final FutureOr<http.StreamedResponse> Function(http.BaseRequest, List<int>)
  handler;
  final requests = <http.BaseRequest>[];
  final bodies = <List<int>>[];
  final sent = Completer<void>();
  int sends = 0;
  int closes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sends++;
    requests.add(request);
    final body = await request.finalize().toBytes();
    bodies.add(body);
    if (!sent.isCompleted) sent.complete();
    return handler(request, body);
  }

  @override
  void close() => closes++;
}

class _Fixture {
  _Fixture(
    FutureOr<http.StreamedResponse> Function(http.BaseRequest, List<int>)
    handler, {
    int maxRetries = 0,
    Duration timeout = const Duration(minutes: 1),
    Duration initialDelay = const Duration(milliseconds: 1),
    Level? logLevel,
    bool borrowFactory = false,
    bool failFactory = false,
  }) {
    shared = _Transport(handler);
    owned = _Transport(handler);
    client = OpenAIClient(
      config: OpenAIConfig(
        authProvider: auth,
        baseUrl: _base,
        timeout: timeout,
        project: 'PRIVATE-project',
        defaultHeaders: const {'x-fixture': 'PRIVATE-header'},
        retryPolicy: RetryPolicy(
          maxRetries: maxRetries,
          initialDelay: initialDelay,
          maxDelay: initialDelay * 2,
          jitter: 0,
        ),
        logLevel: logLevel,
      ),
      httpClient: shared,
      streamClientFactory: () {
        factoryCalls++;
        if (failFactory) throw StateError('Fixture factory failed');
        return borrowFactory ? shared : owned;
      },
    );
  }
  final auth = _Auth();
  late final _Transport shared;
  late final _Transport owned;
  late final OpenAIClient client;
  int factoryCalls = 0;
}

Future<List<LogRecord>> _captureLogs(Future<void> Function() action) async {
  final hierarchy = hierarchicalLoggingEnabled;
  hierarchicalLoggingEnabled = true;
  final rootLevel = Logger.root.level;
  final clientLevel = Logger('OpenAIClient').level;
  Logger.root.level = Level.ALL;
  final records = <LogRecord>[];
  final subscription = Logger.root.onRecord.listen(records.add);
  try {
    await action();
  } finally {
    await subscription.cancel();
    Logger.root.level = rootLevel;
    Logger('OpenAIClient').level = clientLevel;
    hierarchicalLoggingEnabled = hierarchy;
  }
  return records;
}
