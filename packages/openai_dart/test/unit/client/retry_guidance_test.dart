import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpDate;

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const permanentCodes = [
    'credit_balance_exhausted',
    'organization_spend_limit_exceeded',
    'project_spend_limit_exceeded',
    'organization_usage_limit_exceeded',
    'insufficient_quota',
  ];
  group('Permanent quota responses (RETRY-01)', () {
    for (final code in permanentCodes) {
      test(
        'POST429 $code returns a complete typed error without replay',
        () async {
          await _ControlledTimers().run((timers) async {
            var sends = 0;
            final body = _errorJson(code: code);
            final transport = MockClient((request) async {
              sends++;
              _expectRequest(request, 'POST');
              return _failure(body, 429, {'retry-after-ms': '1.501'});
            });
            final client = _client(transport);
            try {
              final result = _Result(_call(client, 'POST'));
              await timers.flush();
              expect(result.done, isTrue);
              expect(result.error, isA<RateLimitException>());
              final error = result.error! as RateLimitException;
              expect(error.code, code);
              expect(error.type, 'rate_limit_error');
              expect(error.param, 'fixture');
              expect(error.body, body);
              expect(error.requestId, 'req_fixture');
              expect(error.retryAfter, const Duration(microseconds: 1501));
              expect(sends, 1);
              expect(timers.pending, isEmpty);
              await result.settled;
            } finally {
              client.close();
              transport.close();
            }
          });
        },
      );
    }
    for (final error in <Map<String, dynamic>>[
      {
        'code': 'unknown',
        'type': 'insufficient_quota',
        'message': 'quota',
        'param': null,
      },
      {
        'code': 'insufficient_quota',
        'type': false,
        'message': <String, dynamic>{},
        'param': 7,
      },
      {
        'code': 7,
        'type': 'insufficient_quota',
        'message': <Object>[],
        'param': false,
      },
    ]) {
      test(
        'classification ignores malformed unrelated members: ${error['code']}/${error['type']}',
        () async {
          await _ControlledTimers().run((timers) async {
            var sends = 0;
            final transport = MockClient((request) async {
              sends++;
              return _failure({'error': error}, 429, {});
            });
            final client = _client(transport);
            try {
              final result = _Result(_call(client, 'POST'));
              await timers.flush();
              expect(result.done, isTrue);
              expect(result.error, isA<RateLimitException>());
              final parsed = result.error! as RateLimitException;
              expect(
                parsed.code,
                error['code'] is String ? error['code'] : null,
              );
              expect(
                parsed.type,
                error['type'] is String ? error['type'] : null,
              );
              expect(sends, 1);
              expect(timers.pending, isEmpty);
              await result.settled;
            } finally {
              client.close();
              transport.close();
            }
          });
        },
      );
    }
  });

  group('Transient/provider fallback (RETRY-02)', () {
    for (final body in [
      jsonEncode(_errorJson(code: 'slow_down')),
      jsonEncode(_errorJson(code: 'future_rate_limit')),
      'insufficient_quota organization_spend_limit_exceeded',
      '',
      '{malformed',
      '[]',
      'null',
      '{}',
      '{"error":null}',
      '{"error":"insufficient_quota"}',
      '{"error":{"code":7,"type":false}}',
      '{"error":{"code":"INSUFFICIENT_QUOTA"}}',
      '{"error":{"code":"prefix_insufficient_quota_suffix"}}',
      '{"error":{"message":"insufficient_quota","details":{"code":"insufficient_quota"}}}',
      '{"code":"insufficient_quota","type":"insufficient_quota"}',
    ]) {
      test('POST429 retains status fallback for $body', () async {
        await _ControlledTimers().run((timers) async {
          var sends = 0;
          String? firstBody;
          String? firstRequestId;
          final transport = MockClient((request) async {
            sends++;
            _expectRequest(request, 'POST');
            if (sends == 1) {
              firstBody = request.body;
              firstRequestId = request.headers['x-request-id'];
              return http.Response(body, 429);
            }
            expect(request.body, firstBody);
            expect(request.headers['x-request-id'], firstRequestId);
            return _success('POST');
          });
          final client = _client(transport);
          try {
            final result = _Result(_call(client, 'POST'));
            await timers.flush();
            expect(sends, 1);
            expect(result.done, isFalse);
            expect(timers.nextDelay, const Duration(milliseconds: 1));
            await timers.advance(const Duration(milliseconds: 1));
            expect(sends, 2);
            expect(result.error, isNull);
            expect(result.done, isTrue);
            _expectSuccessValue(result, 'POST');
            await result.settled;
          } finally {
            client.close();
            transport.close();
          }
        });
      });
    }
    for (final status in [408, 409]) {
      test('$status does not become retryable', () async {
        await _ControlledTimers().run((timers) async {
          var sends = 0;
          final transport = MockClient((request) async {
            sends++;
            return _failure(_errorJson(), status, {});
          });
          final client = _client(transport);
          try {
            final result = _Result(_call(client, 'GET'));
            await timers.flush();
            expect(result.done, isTrue);
            expect(result.error, isA<ApiException>());
            expect(sends, 1);
            expect(timers.pending, isEmpty);
            await result.settled;
          } finally {
            client.close();
            transport.close();
          }
        });
      });
    }
  });

  final hints = <String, (Map<String, String>, Duration, Duration)>{
    'integer seconds': (
      {'retry-after': '1'},
      const Duration(seconds: 1),
      const Duration(seconds: 1),
    ),
    'fractional seconds': (
      {'retry-after': '0.0015'},
      const Duration(microseconds: 1500),
      const Duration(milliseconds: 2),
    ),
    'fractional milliseconds': (
      {'retry-after-ms': '1.5'},
      const Duration(microseconds: 1500),
      const Duration(milliseconds: 2),
    ),
    'fractional ms not exactly representable': (
      {'retry-after-ms': '1.501'},
      const Duration(microseconds: 1501),
      const Duration(milliseconds: 2),
    ),
    'ms precedence': (
      {'retry-after-ms': '1.5', 'retry-after': '45'},
      const Duration(microseconds: 1500),
      const Duration(milliseconds: 2),
    ),
    'invalid ms falls back': (
      {'retry-after-ms': '-1', 'retry-after': '0.001501'},
      const Duration(microseconds: 1501),
      const Duration(milliseconds: 2),
    ),
    'nonfinite ms falls back': (
      {'retry-after-ms': 'NaN', 'retry-after': '0.0015'},
      const Duration(microseconds: 1500),
      const Duration(milliseconds: 2),
    ),
    'submicrosecond ceil plus initial minimum': (
      {'retry-after': '0.0000001'},
      const Duration(microseconds: 1),
      const Duration(milliseconds: 1),
    ),
    'zero preserves initial minimum': (
      {'retry-after': '0'},
      Duration.zero,
      const Duration(milliseconds: 1),
    ),
    'past HTTP date preserves initial minimum': (
      {'retry-after': 'Wed, 21 Oct 2015 07:28:00 GMT'},
      Duration.zero,
      const Duration(milliseconds: 1),
    ),
  };
  group('Complete hints and timer rounding (RETRY-03/06)', () {
    for (final withAbort in [false, true]) {
      for (final entry in hints.entries) {
        test('${entry.key} withAbort=$withAbort cannot replay early', () async {
          await _ControlledTimers().run((timers) async {
            var sends = 0;
            final transport = MockClient((request) async {
              sends++;
              return sends == 1
                  ? _failure(_errorJson(code: 'slow_down'), 429, entry.value.$1)
                  : _success('POST');
            });
            final client = _client(
              transport,
              maxDelay: const Duration(seconds: 2),
            );
            final abort = withAbort ? Completer<void>().future : null;
            try {
              final result = _Result(_call(client, 'POST', abort: abort));
              await timers.flush();
              expect(sends, 1);
              expect(result.done, isFalse);
              expect(timers.nextDelay, entry.value.$3);
              expect(timers.nextDelay, greaterThanOrEqualTo(entry.value.$2));
              await timers.advance(
                entry.value.$3 - const Duration(milliseconds: 1),
              );
              expect(sends, 1);
              expect(result.done, isFalse);
              await timers.advance(const Duration(milliseconds: 1));
              expect(sends, 2);
              expect(result.done, isTrue);
              expect(result.error, isNull);
              _expectSuccessValue(result, 'POST');
              await result.settled;
            } finally {
              client.close();
              transport.close();
            }
          });
        });
      }
    }
    for (final header in <Map<String, String>>[
      {'retry-after': '0.0020001'},
      {'retry-after-ms': '2.0001'},
    ]) {
      test('above-bound complete hint $header returns promptly', () async {
        await _ControlledTimers().run((timers) async {
          var sends = 0;
          final transport = MockClient((request) async {
            sends++;
            return _failure(_errorJson(), 429, header);
          });
          final client = _client(
            transport,
            maxDelay: const Duration(milliseconds: 1),
          );
          try {
            final result = _Result(_call(client, 'POST'));
            await timers.flush();
            expect(result.done, isTrue);
            expect(sends, 1);
            expect(timers.pending, isEmpty);
            expect(
              (result.error! as RateLimitException).retryAfter,
              const Duration(microseconds: 2001),
            );
            await result.settled;
          } finally {
            client.close();
            transport.close();
          }
        });
      });
    }
    test('exact twice-max boundary remains eligible', () async {
      await _ControlledTimers().run((timers) async {
        var sends = 0;
        final transport = MockClient((request) async {
          sends++;
          return sends == 1
              ? _failure(_errorJson(), 429, {'retry-after-ms': '2'})
              : _success('POST');
        });
        final client = _client(
          transport,
          maxDelay: const Duration(milliseconds: 1),
        );
        try {
          final result = _Result(_call(client, 'POST'));
          await timers.flush();
          expect(timers.nextDelay, const Duration(milliseconds: 2));
          await timers.advance(const Duration(milliseconds: 1));
          expect(sends, 1);
          await timers.advance(const Duration(milliseconds: 1));
          expect(result.done, isTrue);
          expect(result.error, isNull);
          expect(sends, 2);
          _expectSuccessValue(result, 'POST');
          await result.settled;
        } finally {
          client.close();
          transport.close();
        }
      });
    });
    test('HTTP date delay stays complete and rounds upward', () async {
      await _ControlledTimers().run((timers) async {
        final before = DateTime.now().toUtc();
        final date = HttpDate.parse(
          HttpDate.format(before.add(const Duration(seconds: 3))),
        );
        var sends = 0;
        final transport = MockClient((request) async {
          sends++;
          return sends == 1
              ? _failure(_errorJson(), 429, {
                  'Retry-After': HttpDate.format(date),
                })
              : _success('POST');
        });
        final client = _client(transport, maxDelay: const Duration(seconds: 5));
        try {
          final result = _Result(_call(client, 'POST'));
          await timers.flush();
          final after = DateTime.now().toUtc();
          final delay = timers.nextDelay;
          expect(delay, greaterThanOrEqualTo(date.difference(after)));
          expect(
            delay,
            lessThanOrEqualTo(
              date.difference(before) + const Duration(milliseconds: 1),
            ),
          );
          await timers.advance(delay - const Duration(milliseconds: 1));
          expect(sends, 1);
          await timers.advance(const Duration(milliseconds: 1));
          expect(result.done, isTrue);
          expect(result.error, isNull);
          expect(sends, 2);
          _expectSuccessValue(result, 'POST');
          await result.settled;
        } finally {
          client.close();
          transport.close();
        }
      });
    });
    test(
      'fractional hint jitter does not add beyond whole-millisecond headroom',
      () async {
        await _ControlledTimers().run((timers) async {
          var sends = 0;
          final transport = MockClient((request) async {
            sends++;
            return sends == 1
                ? _failure(_errorJson(), 429, {'retry-after-ms': '9.5'})
                : _success('POST');
          });
          final client = _client(
            transport,
            maxDelay: const Duration(milliseconds: 10),
            jitter: 1,
          );
          try {
            final result = _Result(_call(client, 'POST'));
            await timers.flush();
            expect(timers.nextDelay, const Duration(milliseconds: 10));
            await timers.advance(const Duration(milliseconds: 9));
            expect(sends, 1);
            await timers.advance(const Duration(milliseconds: 1));
            expect(sends, 2);
            expect(result.error, isNull);
            expect(result.done, isTrue);
            _expectSuccessValue(result, 'POST');
            await result.settled;
          } finally {
            client.close();
            transport.close();
          }
        });
      },
    );
  });

  group('Verb/retry budget/cancellation boundaries (RETRY-02/04)', () {
    for (final method in ['GET', 'POST']) {
      test('$method 503 keeps the existing verb policy', () async {
        await _ControlledTimers().run((timers) async {
          var sends = 0;
          final transport = MockClient((request) async {
            sends++;
            _expectRequest(request, method);
            return sends == 1
                ? _failure(
                    _errorJson(
                      code: 'server_is_overloaded',
                      type: 'server_error',
                    ),
                    503,
                    {'retry-after-ms': '1.501'},
                  )
                : _success(method);
          });
          final client = _client(transport);
          try {
            final result = _Result(_call(client, method));
            await timers.flush();
            expect(sends, 1);
            if (method == 'GET') {
              expect(result.done, isFalse);
              await timers.advance(const Duration(milliseconds: 1));
              expect(sends, 1);
              await timers.advance(const Duration(milliseconds: 1));
              expect(sends, 2);
              expect(result.error, isNull);
              expect(result.done, isTrue);
              _expectSuccessValue(result, method);
            } else {
              expect(result.done, isTrue);
              expect(timers.pending, isEmpty);
              final error = result.error! as InternalServerException;
              expect(error.code, 'server_is_overloaded');
              expect(error.retryAfter, const Duration(microseconds: 1501));
            }
            await result.settled;
          } finally {
            client.close();
            transport.close();
          }
        });
      });
    }
    for (final status in [429, 503]) {
      for (final maxRetries in [0, 2]) {
        test('$status exposes exact hints with budget=$maxRetries', () async {
          await _ControlledTimers().run((timers) async {
            var sends = 0;
            final transport = MockClient((request) async {
              sends++;
              return _failure(_errorJson(), status, {
                'retry-after-ms': '1.501',
              });
            });
            final client = _client(transport, retries: maxRetries);
            try {
              final result = _Result(
                _call(client, status == 429 ? 'POST' : 'GET'),
              );
              await timers.flush();
              for (var retry = 0; retry < maxRetries; retry++) {
                expect(result.done, isFalse);
                await timers.advance(const Duration(milliseconds: 2));
              }
              expect(result.done, isTrue);
              expect(sends, maxRetries + 1);
              expect(timers.pending, isEmpty);
              if (status == 429) {
                expect(
                  (result.error! as RateLimitException).retryAfter,
                  const Duration(microseconds: 1501),
                );
              }
              if (status == 503) {
                expect(
                  (result.error! as InternalServerException).retryAfter,
                  const Duration(microseconds: 1501),
                );
              }
              await result.settled;
            } finally {
              client.close();
              transport.close();
            }
          });
        });
      }
    }
    test(
      'abort during server delay cancels immediately without replay',
      () async {
        await _ControlledTimers().run((timers) async {
          var sends = 0;
          final transport = MockClient((request) async {
            sends++;
            return _failure(_errorJson(), 429, {'retry-after': '1'});
          });
          final client = _client(
            transport,
            maxDelay: const Duration(seconds: 2),
          );
          final abort = Completer<void>();
          try {
            final result = _Result(_call(client, 'POST', abort: abort.future));
            await timers.flush();
            expect(sends, 1);
            expect(result.done, isFalse);
            abort.complete();
            await timers.flush();
            expect(result.done, isTrue);
            expect(result.error, isA<AbortedException>());
            expect(
              (result.error! as AbortedException).stage,
              AbortionStage.beforeRequest,
            );
            expect(sends, 1);
            await timers.advance(const Duration(seconds: 2));
            expect(sends, 1);
            await result.settled;
          } finally {
            client.close();
            transport.close();
          }
        });
      },
    );
  });
}

OpenAIClient _client(
  http.Client transport, {
  int retries = 1,
  Duration maxDelay = const Duration(milliseconds: 10),
  double jitter = 0,
}) => OpenAIClient(
  config: OpenAIConfig(
    authProvider: const ApiKeyProvider('sk-fixture'),
    baseUrl: 'https://api.example.invalid/v1',
    retryPolicy: RetryPolicy(
      maxRetries: retries,
      initialDelay: const Duration(milliseconds: 1),
      maxDelay: maxDelay,
      jitter: jitter,
    ),
  ),
  httpClient: transport,
);

Future<Object?> _call(
  OpenAIClient client,
  String method, {
  Future<void>? abort,
}) => method == 'GET'
    ? client.models.list()
    : client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'fixture-model',
          messages: [ChatMessage.user('Hello')],
        ),
        abortTrigger: abort,
      );

void _expectSuccessValue(_Result result, String method) {
  if (method == 'GET') {
    expect(result.value, isA<ModelList>());
    expect((result.value! as ModelList).data, isEmpty);
  } else {
    expect(result.value, isA<ChatCompletion>());
    expect((result.value! as ChatCompletion).text, 'ok');
  }
}

void _expectRequest(http.Request request, String method) {
  expect(request.method, method);
  expect(
    request.url.path,
    method == 'GET' ? '/v1/models' : '/v1/chat/completions',
  );
  expect(request.headers['authorization'], 'Bearer sk-fixture');
  expect(request.url.queryParameters, isEmpty);
  if (method == 'POST') {
    expect(jsonDecode(request.body), {
      'model': 'fixture-model',
      'messages': [
        {'role': 'user', 'content': 'Hello'},
      ],
    });
  }
}

Map<String, dynamic> _errorJson({
  String code = 'slow_down',
  String type = 'rate_limit_error',
}) => {
  'error': {
    'message': 'fixture error',
    'code': code,
    'type': type,
    'param': 'fixture',
  },
};

http.Response _failure(
  Map<String, dynamic> body,
  int status,
  Map<String, String> headers,
) => http.Response(
  jsonEncode(body),
  status,
  headers: {
    ...headers,
    'x-request-id': 'req_fixture',
    'content-type': 'application/json',
  },
);

http.Response _success(String method) => http.Response(
  jsonEncode(
    method == 'GET'
        ? {'object': 'list', 'data': <Object>[]}
        : {
            'id': 'chatcmpl_fixture',
            'object': 'chat.completion',
            'created': 0,
            'model': 'fixture-model',
            'choices': [
              {
                'index': 0,
                'message': {'role': 'assistant', 'content': 'ok'},
                'finish_reason': 'stop',
                'logprobs': null,
              },
            ],
          },
  ),
  200,
  headers: {'content-type': 'application/json'},
);

class _Result {
  bool done = false;
  Object? value;
  Object? error;
  late final Future<void> settled;
  _Result(Future<Object?> future) {
    settled = future.then<void>(
      (result) {
        value = result;
        done = true;
      },
      onError: (Object caught, StackTrace stack) {
        error = caught;
        done = true;
      },
    );
  }
}

// Test-only timers reproduce Dart's millisecond timer resolution. Public HTTP
// transport and microtasks run normally; delays advance only when requested.
class _ControlledTimers {
  Duration elapsed = Duration.zero;
  final List<_ControlledTimer> _timers = [];
  List<_ControlledTimer> get pending =>
      _timers.where((timer) => timer.isActive).toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));
  Duration get nextDelay => pending.first.deadline - elapsed;

  Future<void> run(Future<void> Function(_ControlledTimers timers) action) =>
      runZoned(
        () => action(this),
        zoneSpecification: ZoneSpecification(
          createTimer: (self, parent, zone, duration, callback) {
            final timer = _ControlledTimer(
              elapsed + Duration(milliseconds: duration.inMilliseconds),
              zone.bindCallbackGuarded(callback),
            );
            _timers.add(timer);
            return timer;
          },
        ),
      );

  Future<void> flush() async {
    for (var i = 0; i < 100; i++) {
      await Future<void>.value();
    }
    while (pending.isNotEmpty && pending.first.deadline <= elapsed) {
      pending.first.fire();
      for (var i = 0; i < 100; i++) {
        await Future<void>.value();
      }
    }
  }

  Future<void> advance(Duration duration) async {
    final target = elapsed + duration;
    await flush();
    while (pending.isNotEmpty && pending.first.deadline <= target) {
      elapsed = pending.first.deadline;
      pending.first.fire();
      await flush();
    }
    elapsed = target;
    await flush();
  }
}

class _ControlledTimer implements Timer {
  final Duration deadline;
  final void Function() _callback;
  bool _active = true;
  int _tick = 0;
  _ControlledTimer(this.deadline, this._callback);
  @override
  bool get isActive => _active;
  @override
  int get tick => _tick;
  @override
  void cancel() => _active = false;
  void fire() {
    if (!_active) return;
    _active = false;
    _tick = 1;
    _callback();
  }
}
