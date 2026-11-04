import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _name = 'PRIVATE voice café 🚀';
const _prompt =
    '  PRIVATE warm, conversational voice.\nKeep this exact spacing.  ';
const _hint = 'PRIVATE script hint: café 🌍';
const _id = 'PRIVATE voice/id%?café 🚀';
const _base = 'https://fixture.invalid/PRIVATE-proxy/v1';
const _trace = 'PRIVATE caller trace';

enum _Operation { promptJson, promptMultipart, audio, delete }

void main() {
  for (final encoding in [null, VoiceCreateEncoding.json]) {
    test(
      'prompt ${encoding?.name ?? 'inferred JSON'} preserves full JSON',
      () async {
        final fixture = _Fixture((_, _) => _success(_Operation.promptJson));
        addTearDown(fixture.client.close);
        final voice = await fixture.client.audio.voices.create(
          _promptRequest(),
          encoding: encoding,
        );
        final sent = fixture.transport.requests.single;
        expect(sent.method, 'POST');
        expect(sent.url.path, '/PRIVATE-proxy/v1/audio/voices');
        expect(sent.url.queryParametersAll, {
          'tenant': ['a', 'b'],
        });
        _expectHeaders(sent, multipart: false);
        expect(jsonDecode(utf8.decode(fixture.transport.bodies.single)), {
          'type': 'prompt',
          'name': _name,
          'prompt': _prompt,
          'script_hint': _hint,
          'model': 'future-voice-model',
        });
        expect(voice.id, _id);
        expect(voice.type, 'prompt');
        expect(voice.prompt, _prompt);
        expect(voice.toJson(), _voice());
        _expectBorrowed(fixture);
      },
    );
  }

  for (final encoding in VoiceCreateEncoding.values) {
    test('minimal prompt ${encoding.name} omits optional fields', () async {
      final fixture = _Fixture((_, _) => _success(_Operation.promptJson));
      addTearDown(fixture.client.close);
      await fixture.client.audio.voices.create(
        PromptVoiceCreateRequest(name: _name, prompt: _prompt),
        encoding: encoding,
      );
      final sent = fixture.transport.requests.single;
      final expected = {'type': 'prompt', 'name': _name, 'prompt': _prompt};
      if (encoding == VoiceCreateEncoding.json) {
        _expectHeaders(sent, multipart: false);
        expect(
          jsonDecode(utf8.decode(fixture.transport.bodies.single)),
          expected,
        );
      } else {
        _expectHeaders(sent, multipart: true);
        final parts = _parts(sent, fixture.transport.bodies.single);
        expect(parts.keys.toSet(), expected.keys.toSet());
        for (final entry in expected.entries) {
          expect(parts[entry.key]!.text, entry.value);
          expect(parts[entry.key]!.filename, isNull);
        }
      }
      _expectBorrowed(fixture);
    });
  }

  test(
    'multipart prompt contains only textual prompt fields and no audio',
    () async {
      final fixture = _Fixture((_, _) => _success(_Operation.promptMultipart));
      addTearDown(fixture.client.close);
      await fixture.client.audio.voices.create(
        _promptRequest(),
        encoding: VoiceCreateEncoding.multipart,
      );
      final sent = fixture.transport.requests.single;
      expect(sent.method, 'POST');
      expect(sent.url.path, '/PRIVATE-proxy/v1/audio/voices');
      _expectHeaders(sent, multipart: true);
      final parts = _parts(sent, fixture.transport.bodies.single);
      expect(parts.keys.toSet(), {
        'type',
        'name',
        'prompt',
        'script_hint',
        'model',
      });
      expect(parts.map((key, value) => MapEntry(key, value.text)), {
        'type': 'prompt',
        'name': _name,
        'prompt': _prompt,
        'script_hint': _hint,
        'model': 'future-voice-model',
      });
      expect(parts.values.every((part) => part.filename == null), isTrue);
      _expectBorrowed(fixture);
    },
  );

  for (final encoding in VoiceCreateEncoding.values) {
    test(
      'prompt ${encoding.name} does not invent missing response prompt',
      () async {
        final payload = _voice()..remove('prompt');
        final fixture = _Fixture((_, _) => _json(payload));
        addTearDown(fixture.client.close);
        final voice = await fixture.client.audio.voices.create(
          _promptRequest(),
          encoding: encoding,
        );
        expect(voice.type, 'prompt');
        expect(voice.prompt, isNull);
        expect(voice.toJson().containsKey('prompt'), isFalse);
      },
    );
  }

  for (final encoding in [null, VoiceCreateEncoding.multipart]) {
    test(
      'existing audio ${encoding?.name ?? 'inference'} remains multipart',
      () async {
        final fixture = _Fixture((_, _) => _success(_Operation.audio));
        addTearDown(fixture.client.close);
        final request = _audioRequest();
        final voice = await fixture.client.audio.voices.create(
          request,
          encoding: encoding,
        );
        final sent = fixture.transport.requests.single;
        _expectHeaders(sent, multipart: true);
        final parts = _parts(sent, fixture.transport.bodies.single);
        expect(parts.keys.toSet(), {'name', 'audio_sample', 'consent'});
        expect(parts['name']!.text, _name);
        expect(parts['consent']!.text, 'PRIVATE consent');
        expect(parts['audio_sample']!.bytes, [0, 255, 128, 13, 10]);
        expect(parts['audio_sample']!.filename, 'PRIVATE sample.wav');
        expect(
          parts['audio_sample']!.headers,
          contains('content-type: audio/wav'),
        );
        expect(voice.type, 'audio_sample');
        expect(voice.prompt, isNull);
        _expectBorrowed(fixture);
      },
    );
  }

  test(
    'audio JSON encoding fails before authentication and dispatch',
    () async {
      final fixture = _Fixture((_, _) => _success(_Operation.audio));
      addTearDown(fixture.client.close);
      await expectLater(
        fixture.client.audio.voices.create(
          _audioRequest(),
          encoding: VoiceCreateEncoding.json,
        ),
        throwsArgumentError,
      );
      expect(fixture.auth.calls, 0);
      expect(fixture.transport.requests, isEmpty);
      _expectBorrowed(fixture);
    },
  );

  for (final id in [
    _id,
    ' voice ',
    'opaque?query#fragment',
    'percent%2Fvalue',
  ]) {
    test('delete encodes opaque voice ID exactly once: $id', () async {
      final fixture = _Fixture((_, _) => _json(_deleted(id: id)));
      addTearDown(fixture.client.close);
      final deleted = await fixture.client.audio.voices.delete(id);
      final sent = fixture.transport.requests.single;
      expect(sent.method, 'DELETE');
      expect(
        sent.url.toString(),
        '$_base/audio/voices/${Uri.encodeComponent(id)}?tenant=a&tenant=b',
      );
      expect(sent.url.pathSegments.last, id);
      expect(sent.url.queryParametersAll, {
        'tenant': ['a', 'b'],
      });
      expect(sent.headers['accept'], 'application/json');
      expect(fixture.transport.bodies.single, isEmpty);
      expect(deleted.id, id);
      expect(deleted.object, 'audio.voice.deleted');
      expect(deleted.deleted, isTrue);
      expect(deleted.toJson(), _deleted(id: id));
      _expectBorrowed(fixture);
    });
  }

  for (final id in ['', '.', '..', '\uD800', '\uDC00']) {
    test(
      'delete rejects unsafe path ID before auth: ${id.codeUnits}',
      () async {
        final fixture = _Fixture((_, _) => _success(_Operation.delete));
        addTearDown(fixture.client.close);
        await expectLater(
          fixture.client.audio.voices.delete(id),
          throwsArgumentError,
        );
        expect(fixture.auth.calls, 0);
        expect(fixture.transport.requests, isEmpty);
        _expectBorrowed(fixture);
      },
    );
  }

  test('delete preserves a false deletion result', () async {
    final payload = _deleted()..['deleted'] = false;
    final fixture = _Fixture((_, _) => _json(payload));
    addTearDown(fixture.client.close);
    final deleted = await fixture.client.audio.voices.delete(_id);
    expect(deleted.deleted, isFalse);
    expect(deleted.toJson(), payload);
  });

  for (final operation in _Operation.values) {
    group('${operation.name} shared lifecycle and diagnostics', () {
      test('closed client rejects before auth or dispatch', () async {
        final fixture = _Fixture((_, _) => _success(operation));
        fixture.client.close();
        await expectLater(_invoke(fixture.client, operation), throwsStateError);
        expect(fixture.auth.calls, 0);
        expect(fixture.transport.requests, isEmpty);
        _expectBorrowed(fixture);
      });

      for (final fails in [false, true]) {
        test('precompleted abort failure=$fails rejects before auth', () async {
          final fixture = _Fixture((_, _) => _success(operation));
          addTearDown(fixture.client.close);
          final abort = Completer<void>();
          if (fails) {
            abort.completeError(StateError('PRIVATE abort'));
          } else {
            abort.complete();
          }
          await expectLater(
            _invoke(fixture.client, operation, abort: abort.future),
            throwsA(isA<AbortedException>()),
          );
          expect(fixture.auth.calls, 0);
          expect(fixture.transport.requests, isEmpty);
          _expectBorrowed(fixture);
        });
      }

      test('pending-header cancellation reaches the HTTP transport', () async {
        final fixture = _Fixture((request, _) async {
          expect(request, isA<http.Abortable>());
          final nativeAbort = (request as http.Abortable).abortTrigger;
          expect(nativeAbort, isNotNull);
          await nativeAbort;
          throw http.RequestAbortedException(request.url);
        }, maxRetries: 2);
        addTearDown(fixture.client.close);
        final abort = Completer<void>();
        final result = _invoke(fixture.client, operation, abort: abort.future);
        await fixture.transport.sent.future;
        abort.complete();
        final error = await _failure(result);
        expect(error, isA<AbortedException>());
        expect(
          (error as AbortedException).cause,
          isA<http.RequestAbortedException>(),
        );
        expect(error.correlationId, _trace);
        expect(error.toString(), isNot(contains('PRIVATE')));
        expect(fixture.transport.requests, hasLength(1));
        _expectBorrowed(fixture);
      });

      test(
        'mid-body abort cancels the reader without closing borrowed client',
        () async {
          final ready = Completer<void>();
          final cancelled = Completer<void>();
          final body = StreamController<List<int>>(
            onListen: ready.complete,
            onCancel: cancelled.complete,
          );
          final fixture = _Fixture((request, _) {
            expect(request, isA<http.Abortable>());
            final nativeAbort = (request as http.Abortable).abortTrigger!;
            unawaited(
              nativeAbort.then(
                (_) => body.addError(http.RequestAbortedException(request.url)),
              ),
            );
            return http.StreamedResponse(body.stream, 200);
          }, maxRetries: 2);
          addTearDown(fixture.client.close);
          final abort = Completer<void>();
          final result = _invoke(
            fixture.client,
            operation,
            abort: abort.future,
          );
          await ready.future;
          body.add(utf8.encode('PRIVATE partial body'));
          abort.complete();
          final error = await _failure(result);
          expect(error, isA<AbortedException>());
          expect(error.toString(), isNot(contains('PRIVATE')));
          await cancelled.future.timeout(const Duration(seconds: 1));
          expect(fixture.transport.requests, hasLength(1));
          _expectBorrowed(fixture);
          await body.close();
        },
      );

      test(
        'header timeout keeps borrowed transport and respects retry admission',
        () async {
          final headers = Completer<http.StreamedResponse>();
          final fixture = _Fixture(
            (_, _) => headers.future,
            timeout: const Duration(milliseconds: 20),
            maxRetries: operation == _Operation.delete ? 0 : 2,
          );
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(fixture.client, operation));
          expect(error, isA<RequestTimeoutException>());
          expect(error.toString(), isNot(contains('PRIVATE')));
          expect(fixture.transport.requests, hasLength(1));
          _expectBorrowed(fixture);
          headers.complete(_success(operation));
        },
      );

      for (final status in [302, 400, 401, 403, 404, 409, 422, 429, 503]) {
        test(
          'HTTP $status retains caller context with safe diagnostics',
          () async {
            final payload = {
              'error': {
                'message': _prompt,
                'type': 'PRIVATE type',
                'code': 'PRIVATE code',
                'param': _name,
              },
            };
            final fixture = _Fixture(
              (_, _) => _json(
                payload,
                status: status,
                headers: {'x-request-id': _trace},
              ),
            );
            addTearDown(fixture.client.close);
            final error = await _failure(_invoke(fixture.client, operation));
            expect(error, isA<ApiException>());
            final api = error as ApiException;
            expect(api.statusCode, status);
            expect(api.message, _prompt);
            expect(api.requestId, _trace);
            expect(api.body, payload);
            expect(
              (api.cause! as http.Response).bodyBytes,
              utf8.encode(jsonEncode(payload)),
            );
            expect(api.toString(), isNot(contains('PRIVATE')));
            expect(fixture.transport.requests, hasLength(1));
            _expectBorrowed(fixture);
          },
        );
      }

      for (final body in [
        'PRIVATE non-JSON',
        '[]',
        '{"object":"PRIVATE invalid"}',
      ]) {
        test('malformed response $body retains raw body safely', () async {
          final fixture = _Fixture((_, _) => _response(utf8.encode(body)));
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(fixture.client, operation));
          expect(error, isA<ParseException>());
          final parse = error as ParseException;
          expect(parse.responseBody, body);
          expect(
            '${parse.message} ${parse.cause} $parse',
            isNot(contains('PRIVATE')),
          );
          _expectBorrowed(fixture);
        });
      }

      for (final status in [429, 503]) {
        test(
          'retry policy HTTP $status preserves create-once/delete-retry distinction',
          () async {
            late final _Fixture fixture;
            fixture = _Fixture(
              (_, _) => fixture.transport.requests.length == 1
                  ? _json({
                      'error': {'message': 'retryable'},
                    }, status: status)
                  : _success(operation),
              maxRetries: 1,
            );
            addTearDown(fixture.client.close);
            if (operation == _Operation.delete) {
              await _invoke(fixture.client, operation);
              expect(fixture.transport.requests, hasLength(2));
            } else {
              await expectLater(
                _invoke(fixture.client, operation),
                throwsA(isA<ApiException>()),
              );
              expect(fixture.transport.requests, hasLength(1));
            }
            _expectBorrowed(fixture);
          },
        );
      }

      test('uncertain connection failure never replays creation', () async {
        late final _Fixture fixture;
        http.ClientException? original;
        fixture = _Fixture((request, _) {
          if (fixture.transport.requests.length == 1) {
            original = http.ClientException(
              'PRIVATE connection failure',
              request.url,
            );
            throw original!;
          }
          return _success(operation);
        }, maxRetries: 1);
        addTearDown(fixture.client.close);
        if (operation == _Operation.delete) {
          await _invoke(fixture.client, operation);
          expect(fixture.transport.requests, hasLength(2));
        } else {
          final error = await _failure(_invoke(fixture.client, operation));
          expect(error, isA<ConnectionException>());
          expect((error as ConnectionException).cause, same(original));
          expect(error.toString(), isNot(contains('PRIVATE')));
          expect(fixture.transport.requests, hasLength(1));
        }
        _expectBorrowed(fixture);
      });

      for (final outcome in ['success', 'error', 'malformed']) {
        test(
          'FINEST $outcome logs redact prompts, IDs, URL and headers',
          () async {
            final records = await _captureLogs(() async {
              final fixture = _Fixture(
                (_, _) => switch (outcome) {
                  'success' => _success(operation),
                  'error' => _json({
                    'error': {'message': _prompt},
                  }, status: 400),
                  _ => _response(utf8.encode('PRIVATE malformed')),
                },
                logLevel: Level.FINEST,
              );
              addTearDown(fixture.client.close);
              if (outcome == 'success') {
                await _invoke(fixture.client, operation);
              } else {
                final error = await _failure(
                  _invoke(fixture.client, operation),
                );
                expect(error.toString(), isNot(contains('PRIVATE')));
              }
              _expectBorrowed(fixture);
            });
            final text = records
                .map(
                  (record) =>
                      '${record.message} ${record.error} ${record.stackTrace}',
                )
                .join('\n');
            expect(text, isNot(contains('PRIVATE')));
            expect(text, isNot(contains(Uri.encodeComponent(_id))));
            expect(text, isNot(contains('fixture-credential')));
          },
        );
      }
    });
  }
}

PromptVoiceCreateRequest _promptRequest() => PromptVoiceCreateRequest(
  name: _name,
  prompt: _prompt,
  scriptHint: _hint,
  model: 'future-voice-model',
);
CustomVoiceCreateRequest _audioRequest() => CustomVoiceCreateRequest(
  name: _name,
  consent: 'PRIVATE consent',
  audioSample: Uint8List.fromList([0, 255, 128, 13, 10]),
  filename: 'PRIVATE sample.wav',
  audioSampleContentType: 'Audio/WAV; codecs=pcm',
);
Map<String, Object?> _voice({bool audio = false}) => {
  'object': 'audio.voice',
  'id': _id,
  'name': _name,
  'created_at': 1734220800,
  'type': audio ? 'audio_sample' : 'prompt',
  if (!audio) 'prompt': _prompt,
};
Map<String, Object?> _deleted({String id = _id}) => {
  'object': 'audio.voice.deleted',
  'id': id,
  'deleted': true,
};
Future<Object?> _invoke(
  OpenAIClient client,
  _Operation operation, {
  Future<void>? abort,
}) => Future<Object?>.sync(
  () => switch (operation) {
    _Operation.promptJson => client.audio.voices.create(
      _promptRequest(),
      abortTrigger: abort,
    ),
    _Operation.promptMultipart => client.audio.voices.create(
      _promptRequest(),
      encoding: VoiceCreateEncoding.multipart,
      abortTrigger: abort,
    ),
    _Operation.audio => client.audio.voices.create(
      _audioRequest(),
      abortTrigger: abort,
    ),
    _Operation.delete => client.audio.voices.delete(_id, abortTrigger: abort),
  },
);
void _expectHeaders(http.BaseRequest request, {required bool multipart}) {
  expect(request.headers['authorization'], 'Bearer fixture-credential');
  expect(request.headers['openai-project'], 'PRIVATE project');
  expect(request.headers['x-request-id'], _trace);
  expect(request.headers['accept'], 'application/json');
  final contentType = request.headers['content-type'];
  expect(
    contentType,
    multipart
        ? startsWith('multipart/form-data; boundary=')
        : startsWith('application/json'),
  );
}

void _expectBorrowed(_Fixture fixture) {
  expect(fixture.transport.closes, 0);
  expect(fixture.factoryCalls, 0);
}

http.StreamedResponse _success(_Operation operation) => _json(
  operation == _Operation.delete
      ? _deleted()
      : _voice(audio: operation == _Operation.audio),
);
http.StreamedResponse _json(
  Map<String, Object?> body, {
  int status = 200,
  Map<String, String> headers = const {},
}) =>
    _response(utf8.encode(jsonEncode(body)), status: status, headers: headers);
http.StreamedResponse _response(
  List<int> body, {
  int status = 200,
  Map<String, String> headers = const {},
}) => http.StreamedResponse(
  Stream.value(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8', ...headers},
);
Future<Object> _failure(Future<Object?> result) async {
  try {
    await result;
  } catch (error) {
    return error;
  }
  throw StateError('Expected fixture failure.');
}

class _Part {
  _Part(this.headers, this.bytes);
  final String headers;
  final List<int> bytes;
  String get text => utf8.decode(bytes);
  String? get filename =>
      RegExp(r'filename="([^"]*)"').firstMatch(headers)?.group(1);
}

Map<String, _Part> _parts(http.BaseRequest request, List<int> body) {
  final boundary = RegExp(
    r'boundary=([^; ]+)',
  ).firstMatch(request.headers['content-type']!)!.group(1)!;
  final parts = <String, _Part>{};
  for (final raw in latin1.decode(body).split('--$boundary').skip(1)) {
    if (raw.startsWith('--')) break;
    final separator = raw.indexOf('\r\n\r\n');
    final headers = raw.substring(2, separator);
    final name = RegExp(r'name="([^"]*)"').firstMatch(headers)!.group(1)!;
    expect(
      parts.containsKey(name),
      isFalse,
      reason: 'No duplicate multipart fields',
    );
    parts[name] = _Part(
      headers,
      latin1.encode(raw.substring(separator + 4, raw.length - 2)),
    );
  }
  return parts;
}

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return const {
      'Authorization': 'Bearer fixture-credential',
      'X-Request-ID': _trace,
      'Content-Type': 'text/PRIVATE-wrong',
      'Accept': 'application/PRIVATE-wrong',
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
  int closes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
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
    Level? logLevel,
    Duration timeout = const Duration(minutes: 1),
  }) {
    transport = _Transport(handler);
    client = OpenAIClient(
      config: OpenAIConfig(
        authProvider: auth,
        baseUrl: '$_base?tenant=a&tenant=b',
        project: 'PRIVATE project',
        defaultHeaders: const {
          'Content-Type': 'text/PRIVATE-default',
          'Accept': 'application/PRIVATE-default',
        },
        retryPolicy: RetryPolicy(
          maxRetries: maxRetries,
          initialDelay: const Duration(milliseconds: 1),
          maxDelay: const Duration(milliseconds: 5),
          jitter: 0,
        ),
        logLevel: logLevel,
        timeout: timeout,
      ),
      httpClient: transport,
      streamClientFactory: () {
        factoryCalls++;
        throw StateError('Unexpected stream allocation');
      },
    );
  }
  final auth = _Auth();
  late final _Transport transport;
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
