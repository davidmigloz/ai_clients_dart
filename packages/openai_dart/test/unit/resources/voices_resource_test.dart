import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _privateName = 'PRIVATE voice name café 🚀';
const _privateId = 'PRIVATE-voice/id%?café';
const _privateConsent = 'PRIVATE-consent/id%?café';
const _privateFilename = 'PRIVATE-sample.wav';
const _privateHeader = 'PRIVATE-header-value';
const _privateTraceId = 'PRIVATE-caller-trace-id';
const _privateSample = 'PRIVATE-sample-bytes';
const _collectionUrl = 'https://fixture.invalid/PRIVATE-proxy/v1/audio/voices';

void main() {
  group('Custom voice public creation and multipart contract', () {
    test('audio and voices resources are cached without dispatch', () {
      final fixture = _Fixture((_, _) => _success());
      addTearDown(fixture.client.close);
      expect(fixture.client.audio, same(fixture.client.audio));
      expect(fixture.client.audio.voices, same(fixture.client.audio.voices));
      expect(fixture.auth.calls, 0);
      expect(fixture.transport.sends, 0);
    });
    for (final type in [null, 'audio_sample']) {
      test(
        'type $type uses one exact POST and only canonical multipart parts',
        () async {
          final fixture = _Fixture((_, _) => _success());
          addTearDown(fixture.client.close);
          final request = _create().copyWith(type: type);
          final voice = await fixture.client.audio.voices.create(request);
          final sent = fixture.transport.requests.single;
          expect(sent.method, 'POST');
          expect(sent.url.toString(), _collectionUrl);
          expect(sent.url.queryParameters, isEmpty);
          expect(sent.headers['authorization'], 'Bearer PRIVATE-credential');
          expect(sent.headers['openai-project'], 'PRIVATE-project');
          expect(sent.headers['x-fixture-private'], _privateHeader);
          expect(sent.headers['x-request-id'], _privateTraceId);
          expect(sent.headers['accept'], 'application/json');
          expect(
            sent.headers['content-type'],
            startsWith('multipart/form-data; boundary='),
          );
          final parts = _parts(sent, fixture.transport.bodies.single);
          expect(parts.keys.toSet(), {
            'name',
            'audio_sample',
            'consent',
            if (type != null) 'type',
          });
          expect(_values(parts, 'name'), [_privateName]);
          expect(_values(parts, 'consent'), [_privateConsent]);
          expect(
            _values(parts, 'type'),
            type == null ? <String>[] : ['audio_sample'],
          );
          expect(parts['audio_sample']!.single.filename, _privateFilename);
          expect(parts['audio_sample']!.single.contentType, 'audio/wav');
          expect(
            parts['audio_sample']!.single.bytes,
            utf8.encode(_privateSample),
          );
          expect(parts.containsKey('prompt'), isFalse);
          expect(parts.containsKey('audio_sample_content_type'), isFalse);
          expect(voice.toJson(), _voice());
          expect(voice.object, 'audio.voice');
          expect(voice.type, 'audio_sample');
          expect(voice.id, _privateId);
          expect(voice.name, _privateName);
          expect(voice.createdAt, 1734220800);
          expect(AudioVoice.custom(voice.id).toJson(), {'id': _privateId});
          expect(fixture.transport.sends, 1);
          expect(fixture.auth.calls, greaterThan(0));
          expect(fixture.transport.closes, 0);
          expect(fixture.factoryCalls, 0);
        },
      );
    }
    for (final consent in [
      '',
      '.',
      '..',
      'open/raw?opaque#id%20',
      '  consent  ',
      'café 🚀',
    ]) {
      test(
        'consent metadata remains literal with no path-ID grammar: $consent',
        () async {
          final fixture = _Fixture((_, _) => _success());
          addTearDown(fixture.client.close);
          await fixture.client.audio.voices.create(
            _create().copyWith(consent: consent),
          );
          final parts = _parts(
            fixture.transport.requests.single,
            fixture.transport.bodies.single,
          );
          expect(_values(parts, 'consent'), [consent]);
          expect(
            fixture.transport.requests.single.url.toString(),
            _collectionUrl,
          );
          expect(fixture.transport.sends, 1);
        },
      );
    }
    test(
      'media headers select multipart/JSON despite auth header conflicts',
      () async {
        final provider = _ConflictingAuth();
        final fixture = _Fixture((_, _) => _success(), authProvider: provider);
        addTearDown(fixture.client.close);
        await fixture.client.audio.voices.create(_create());
        final sent = fixture.transport.requests.single;
        expect(sent.headers['accept'], 'application/json');
        expect(
          sent.headers['content-type'],
          startsWith('multipart/form-data; boundary='),
        );
        expect(provider.lastHeaders['Accept'], 'application/PRIVATE-xml');
        expect(
          provider.lastHeaders['content-type'],
          'text/PRIVATE-plain; charset=PRIVATE-charset',
        );
        expect(
          _parts(
            sent,
            fixture.transport.bodies.single,
          )['audio_sample']!.single.bytes,
          utf8.encode(_privateSample),
        );
      },
    );
  });

  group('Custom voice upload and Unicode boundaries', () {
    for (final mime in [
      'audio/mpeg',
      'audio/wav',
      'audio/x-wav',
      'audio/ogg',
      'audio/aac',
      'audio/flac',
      'audio/webm',
      'audio/mp4',
    ]) {
      test(
        'supported MIME $mime retains original view, bytes and filename',
        () async {
          final fixture = _Fixture((_, _) => _success());
          addTearDown(fixture.client.close);
          final buffer = Uint8List.fromList([99, 0, 255, 128, 13, 10, 65, 98]);
          final view = Uint8List.sublistView(buffer, 1, 7);
          final expected = List<int>.from(view);
          final request = _create().copyWith(
            audioSample: view,
            filename: 'original.opaque',
            audioSampleContentType: mime,
          );
          buffer.fillRange(0, buffer.length, 42);
          await fixture.client.audio.voices.create(request);
          final parts = _parts(
            fixture.transport.requests.single,
            fixture.transport.bodies.single,
          );
          final sample = parts['audio_sample']!.single;
          expect(sample.bytes, orderedEquals(expected));
          expect(sample.filename, 'original.opaque');
          expect(sample.contentType, mime);
          expect(parts.keys.toSet(), {'name', 'audio_sample', 'consent'});
        },
      );
    }
    for (final entry in const {
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'ogg': 'audio/ogg',
      'aac': 'audio/aac',
      'flac': 'audio/flac',
      'webm': 'audio/webm',
      'mp4': 'audio/mp4',
    }.entries) {
      test(
        'recognized ${entry.key} filename supplies omitted MIME metadata',
        () async {
          final fixture = _Fixture((_, _) => _success());
          addTearDown(fixture.client.close);
          await fixture.client.audio.voices.create(
            _create().copyWith(
              filename: 'sample.${entry.key.toUpperCase()}',
              audioSampleContentType: null,
            ),
          );
          final sample = _parts(
            fixture.transport.requests.single,
            fixture.transport.bodies.single,
          )['audio_sample']!.single;
          expect(sample.contentType, entry.value);
          expect(sample.filename, 'sample.${entry.key.toUpperCase()}');
          expect(sample.bytes, utf8.encode(_privateSample));
        },
      );
    }
    for (final mime in [
      'audio/webm;codecs=opus',
      'Audio/WEBM; codecs="opus"',
      'audio/ogg; codecs=opus',
      'audio/mp4; codecs="mp4a.40.2"',
    ]) {
      test('browser MIME $mime normalizes without transcoding', () async {
        final fixture = _Fixture((_, _) => _success());
        addTearDown(fixture.client.close);
        await fixture.client.audio.voices.create(
          _create().copyWith(audioSampleContentType: mime),
        );
        final sample = _parts(
          fixture.transport.requests.single,
          fixture.transport.bodies.single,
        )['audio_sample']!.single;
        expect(sample.contentType, mime.split(';').first.toLowerCase());
        expect(sample.bytes, utf8.encode(_privateSample));
        expect(sample.filename, _privateFilename);
      });
    }
    for (final length in [10 * 1024 * 1024 - 1, 10 * 1024 * 1024]) {
      test(
        '$length sample bytes reach the file part without truncation',
        () async {
          final fixture = _Fixture((_, _) => _success());
          addTearDown(fixture.client.close);
          final bytes = Uint8List(length)..[0] = 255;
          bytes[length - 1] = 128;
          await fixture.client.audio.voices.create(
            _create().copyWith(audioSample: bytes),
          );
          final sample = _parts(
            fixture.transport.requests.single,
            fixture.transport.bodies.single,
          )['audio_sample']!.single;
          expect(sample.bytes, orderedEquals(bytes));
          expect(sample.bytes.length, length);
          expect(fixture.transport.sends, 1);
        },
      );
    }
    for (final name in [
      'a',
      ' ',
      '🚀',
      List.filled(256, 'a').join(),
      List.filled(256, '🚀').join(),
      List.filled(128, 'e\u0301').join(),
    ]) {
      test(
        'name with ${name.runes.length} Unicode code points is admitted exactly',
        () async {
          final fixture = _Fixture((_, _) => _success());
          addTearDown(fixture.client.close);
          await fixture.client.audio.voices.create(
            _create().copyWith(name: name),
          );
          final parts = _parts(
            fixture.transport.requests.single,
            fixture.transport.bodies.single,
          );
          expect(_values(parts, 'name'), [name]);
          expect(fixture.transport.sends, 1);
        },
      );
    }
    for (final length in [0, 3]) {
      test(
        'synthetic $length-byte sample has no invented duration/token checks',
        () async {
          final fixture = _Fixture((_, _) => _success());
          addTearDown(fixture.client.close);
          await fixture.client.audio.voices.create(
            _create().copyWith(audioSample: Uint8List(length)),
          );
          expect(
            _parts(
              fixture.transport.requests.single,
              fixture.transport.bodies.single,
            )['audio_sample']!.single.bytes.length,
            length,
          );
          expect(fixture.transport.sends, 1);
        },
      );
    }
    final badRequests = <String, CustomVoiceCreateRequest Function()>{
      'empty name': () => _create().copyWith(name: ''),
      '257 ASCII code points': () =>
          _create().copyWith(name: List.filled(257, 'a').join()),
      '257 astral code points': () =>
          _create().copyWith(name: List.filled(257, '🚀').join()),
      '258 combining code points': () =>
          _create().copyWith(name: List.filled(129, 'e\u0301').join()),
      'removed text prompt type': () => _create().copyWith(type: 'text_prompt'),
      'unknown type': () => _create().copyWith(type: 'PRIVATE-unknown-type'),
      'empty type': () => _create().copyWith(type: ''),
      'invalid type copy shape': () =>
          _create().copyWith(type: <String>[_privateName]),
      'over 10 MiB': () =>
          _create().copyWith(audioSample: Uint8List(10 * 1024 * 1024 + 1)),
      'unsupported MIME': () =>
          _create().copyWith(audioSampleContentType: 'video/webm'),
      'unlisted MIME alias': () =>
          _create().copyWith(audioSampleContentType: 'audio/x-m4a'),
      'malformed MIME': () =>
          _create().copyWith(audioSampleContentType: 'PRIVATE invalid MIME'),
      'malformed MIME parameter': () => _create().copyWith(
        audioSampleContentType: 'audio/wav; PRIVATE invalid',
      ),
      'unknown extension without MIME': () => _create().copyWith(
        filename: 'PRIVATE-sample.opaque',
        audioSampleContentType: null,
      ),
      'bare extension is no filename extension': () =>
          _create().copyWith(filename: 'wav', audioSampleContentType: null),
      'invalid MIME copy shape': () =>
          _create().copyWith(audioSampleContentType: <String>[_privateName]),
    };
    for (final entry in badRequests.entries) {
      test(
        '${entry.key} fails safely before authentication or dispatch',
        () async {
          final fixture = _Fixture((_, _) => _success());
          addTearDown(fixture.client.close);
          final error = await _failure(
            Future<void>.sync(() async {
              await fixture.client.audio.voices.create(entry.value());
            }),
          );
          expect(error, anyOf(isA<FormatException>(), isA<ArgumentError>()));
          expect(error.toString(), isNot(contains('PRIVATE')));
          expect(fixture.auth.calls, 0);
          expect(fixture.transport.sends, 0);
          expect(fixture.factoryCalls, 0);
        },
      );
    }
  });

  group('Custom voice shared lifecycle, abort and no replay', () {
    test('closed client fails before auth and send', () async {
      final fixture = _Fixture((_, _) => _success());
      fixture.client.close();
      await expectLater(_invoke(fixture.client), throwsStateError);
      expect(fixture.auth.calls, 0);
      expect(fixture.transport.sends, 0);
      expect(fixture.transport.closes, 0);
      expect(fixture.factoryCalls, 0);
    });
    for (final abortWithError in [false, true]) {
      test(
        'precompleted abort error=$abortWithError does no authentication or upload',
        () async {
          final fixture = _Fixture((_, _) => _success());
          addTearDown(fixture.client.close);
          final abort = Completer<void>();
          if (abortWithError) {
            abort.completeError(StateError(_privateSample));
          } else {
            abort.complete();
          }
          await expectLater(
            _invoke(fixture.client, abort: abort.future),
            throwsA(isA<AbortedException>()),
          );
          expect(fixture.auth.calls, 0);
          expect(fixture.transport.sends, 0);
          expect(fixture.factoryCalls, 0);
        },
      );
    }
    test(
      'native pending-header abort retains caller trace/cause and borrowed transport',
      () async {
        final fixture = _Fixture((request, _) async {
          expect(request, isA<http.Abortable>());
          final nativeAbort = (request as http.Abortable).abortTrigger;
          expect(nativeAbort, isNotNull);
          await nativeAbort;
          throw http.RequestAbortedException(request.url);
        }, maxRetries: 3);
        addTearDown(fixture.client.close);
        final abort = Completer<void>();
        final result = _invoke(fixture.client, abort: abort.future);
        await fixture.transport.sent.future;
        abort.complete();
        final error = await _failure(result);
        expect(error, isA<AbortedException>());
        final failure = error as AbortedException;
        expect(failure.correlationId, _privateTraceId);
        expect(failure.cause, isA<http.RequestAbortedException>());
        expect(failure.toString(), isNot(contains('PRIVATE')));
        expect(fixture.transport.sends, 1);
        expect(fixture.transport.closes, 0);
        expect(fixture.factoryCalls, 0);
      },
    );
    test(
      'native mid-body abort settles after headers without replay or transport close',
      () async {
        final ready = Completer<void>();
        final body = StreamController<List<int>>(onListen: ready.complete);
        final fixture = _Fixture((request, _) {
          expect(request, isA<http.Abortable>());
          final nativeAbort = (request as http.Abortable).abortTrigger;
          expect(nativeAbort, isNotNull);
          unawaited(
            nativeAbort!.then(
              (_) => body.addError(http.RequestAbortedException(request.url)),
            ),
          );
          return http.StreamedResponse(
            body.stream,
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          );
        }, maxRetries: 3);
        addTearDown(fixture.client.close);
        final abort = Completer<void>();
        final result = _invoke(fixture.client, abort: abort.future);
        await ready.future;
        body.add(utf8.encode('partial $_privateSample'));
        abort.complete();
        final error = await _failure(result);
        expect(error, isA<AbortedException>());
        final failure = error as AbortedException;
        expect(failure.correlationId, _privateTraceId);
        expect(failure.cause, isA<http.RequestAbortedException>());
        expect(failure.toString(), isNot(contains('PRIVATE')));
        expect(fixture.transport.sends, 1);
        expect(fixture.transport.closes, 0);
        expect(fixture.factoryCalls, 0);
        await body.close();
      },
    );
    for (final status in [429, 503]) {
      test(
        'multipart HTTP$status is never replayed despite retry allowance',
        () async {
          final fixture = _Fixture(
            (_, _) => _jsonResponse({
              'error': {'message': _privateName, 'type': 'transient_error'},
            }, status: status),
            maxRetries: 3,
          );
          addTearDown(fixture.client.close);
          await expectLater(
            _invoke(fixture.client),
            throwsA(isA<ApiException>()),
          );
          expect(fixture.transport.sends, 1);
          expect(fixture.transport.closes, 0);
        },
      );
    }
    test('permanent quota cannot replay the sample', () async {
      final fixture = _Fixture(
        (_, _) => _jsonResponse({
          'error': {
            'message': _privateName,
            'type': 'insufficient_quota',
            'code': 'insufficient_quota',
          },
        }, status: 429),
        maxRetries: 3,
      );
      addTearDown(fixture.client.close);
      final error = await _failure(_invoke(fixture.client));
      expect(error, isA<RateLimitException>());
      expect((error as RateLimitException).code, 'insufficient_quota');
      expect(fixture.transport.sends, 1);
    });
    test(
      'connection failure retains raw caller data but never replays sample',
      () async {
        http.ClientException? original;
        final fixture = _Fixture((request, _) {
          original = http.ClientException(_privateSample, request.url);
          throw original!;
        }, maxRetries: 3);
        addTearDown(fixture.client.close);
        final error = await _failure(_invoke(fixture.client));
        expect(error, isA<ConnectionException>());
        final failure = error as ConnectionException;
        expect(failure.message, _privateSample);
        expect(failure.url, _collectionUrl);
        expect(failure.cause, same(original));
        expect(failure.toString(), isNot(contains('PRIVATE')));
        expect(fixture.transport.sends, 1);
        expect(fixture.transport.closes, 0);
      },
    );
    test(
      'timeout does not replay multipart or close borrowed transport',
      () async {
        final headers = Completer<http.StreamedResponse>();
        final fixture = _Fixture(
          (_, _) => headers.future,
          maxRetries: 3,
          timeout: const Duration(milliseconds: 20),
        );
        addTearDown(fixture.client.close);
        final error = await _failure(_invoke(fixture.client));
        expect(error, isA<RequestTimeoutException>());
        expect(error.toString(), isNot(contains('PRIVATE')));
        expect(fixture.transport.sends, 1);
        expect(fixture.transport.closes, 0);
        expect(fixture.factoryCalls, 0);
        headers.complete(_success());
      },
    );
  });

  group('Custom voice response and HTTP diagnostics', () {
    for (final status in [199, 302, 400, 401, 403, 404, 409, 422, 429, 503]) {
      test(
        'HTTP$status precedes JSON parsing and preserves exact caller context',
        () async {
          final payload = {
            'error': {
              'message': _privateName,
              'type': _privateSample,
              'code': _privateId,
              'param': _privateConsent,
            },
          };
          final bytes = utf8.encode(jsonEncode(payload));
          final fixture = _Fixture(
            (_, _) => _response(
              bytes,
              status: status,
              headers: const {
                'x-request-id': _privateTraceId,
                'retry-after': '3',
                'x-fixture-private': _privateHeader,
              },
            ),
          );
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(fixture.client));
          expect(error, isA<ApiException>());
          final api = error as ApiException;
          expect(api.statusCode, status);
          expect(api.message, _privateName);
          expect(api.type, _privateSample);
          expect(api.code, _privateId);
          expect(api.param, _privateConsent);
          expect(api.requestId, _privateTraceId);
          expect(api.body, payload);
          final original = api.cause! as http.Response;
          expect(original.bodyBytes, orderedEquals(bytes));
          expect(original.request!.url.toString(), _collectionUrl);
          expect(original.headers['x-fixture-private'], _privateHeader);
          expect(original.headers['retry-after'], '3');
          if (api is RateLimitException) {
            expect(api.retryAfter, const Duration(seconds: 3));
          }
          if (api is InternalServerException) {
            expect(api.retryAfter, const Duration(seconds: 3));
          }
          expect(api.toString(), isNot(contains('PRIVATE')));
          expect(fixture.transport.sends, 1);
        },
      );
    }
    for (final body in [
      'not JSON $_privateName',
      '["$_privateName"]',
      '{"object":"$_privateName"}',
    ]) {
      test(
        'malformed JSON keeps caller responseBody with safe decoder context (${body.length})',
        () async {
          final fixture = _Fixture((_, _) => _response(utf8.encode(body)));
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(fixture.client));
          expect(error, isA<ParseException>());
          final parse = error as ParseException;
          expect(parse.responseBody, body);
          expect(
            '${parse.message} ${parse.cause} $parse',
            isNot(contains('PRIVATE')),
          );
          expect(fixture.transport.sends, 1);
        },
      );
    }
    test(
      'invalid UTF8 success keeps lossy raw caller context with safe parse cause',
      () async {
        final bytes = [...utf8.encode(_privateSample), 255];
        final fixture = _Fixture((_, _) => _response(bytes));
        addTearDown(fixture.client.close);
        final error = await _failure(_invoke(fixture.client));
        expect(error, isA<ParseException>());
        final parse = error as ParseException;
        expect(parse.responseBody, utf8.decode(bytes, allowMalformed: true));
        expect(
          '${parse.message} ${parse.cause} $parse',
          isNot(contains('PRIVATE')),
        );
      },
    );
    test(
      'invalid UTF8 HTTP400 preserves original bytes/status before decoding',
      () async {
        final bytes = [...utf8.encode(_privateSample), 255];
        final fixture = _Fixture(
          (_, _) => _response(
            bytes,
            status: 400,
            headers: const {'x-request-id': _privateTraceId},
          ),
        );
        addTearDown(fixture.client.close);
        final error = await _failure(_invoke(fixture.client));
        expect(error, isA<BadRequestException>());
        final api = error as ApiException;
        expect(api.statusCode, 400);
        expect(api.requestId, _privateTraceId);
        expect((api.cause! as http.Response).bodyBytes, orderedEquals(bytes));
        expect(api.toString(), isNot(contains('PRIVATE')));
      },
    );
    for (final field in _voice().keys) {
      for (final corruption in ['missing', 'null', 'wrong-type']) {
        test(
          'malformed known $field/$corruption fails contextually through resource',
          () async {
            final payload = <String, dynamic>{..._voice()};
            if (corruption == 'missing') {
              payload.remove(field);
            } else {
              payload[field] = corruption == 'null'
                  ? null
                  : <String, dynamic>{_privateName: true};
            }
            final body = jsonEncode(payload);
            final fixture = _Fixture((_, _) => _response(utf8.encode(body)));
            addTearDown(fixture.client.close);
            final error = await _failure(_invoke(fixture.client));
            expect(error, isA<ParseException>());
            final parse = error as ParseException;
            expect(parse.message, contains(field));
            expect(parse.responseBody, body);
            expect(
              '${parse.message} ${parse.cause} $parse',
              isNot(contains('PRIVATE')),
            );
            expect(fixture.transport.sends, 1);
          },
        );
      }
    }
    for (final mutation in [
      <String, Object?>{'object': 'audio.voice_consent'},
      <String, Object?>{'type': 'text_prompt'},
      <String, Object?>{'type': 'PRIVATE-future-type'},
      <String, Object?>{'created_at': 1.5},
    ]) {
      test(
        'canonical fixed values and finite integer are strict: ${mutation.keys.single}',
        () async {
          final body = jsonEncode({..._voice(), ...mutation});
          final fixture = _Fixture((_, _) => _response(utf8.encode(body)));
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(fixture.client));
          expect(error, isA<ParseException>());
          final parse = error as ParseException;
          expect(parse.message, contains(mutation.keys.single));
          expect(parse.responseBody, body);
          expect(
            '${parse.message} ${parse.cause} $parse',
            isNot(contains('PRIVATE')),
          );
        },
      );
    }
    test('response name does not inherit creation bounds', () async {
      final fixture = _Fixture(
        (_, _) => _jsonResponse({..._voice(), 'name': ''}),
      );
      addTearDown(fixture.client.close);
      final voice = await fixture.client.audio.voices.create(_create());
      expect(voice.name, '');
      expect(voice.toJson()['name'], '');
    });
    test(
      'receive-only future extras remain immutable without changing canonical values',
      () async {
        final payload = <String, Object?>{
          ..._voice(),
          'future': {
            'values': [
              1,
              {'private': _privateSample},
            ],
          },
        };
        final fixture = _Fixture((_, _) => _jsonResponse(payload));
        addTearDown(fixture.client.close);
        final voice = await fixture.client.audio.voices.create(_create());
        expect(voice.toJson(), payload);
        expect(() => voice.rawJson['future'] = null, throwsUnsupportedError);
        final future = voice.rawJson['future'] as Map<String, dynamic>;
        expect(() => future['values'] = null, throwsUnsupportedError);
        expect(
          () => (future['values'] as List).clear(),
          throwsUnsupportedError,
        );
        expect(voice.toString(), isNot(contains('PRIVATE')));
        expect(voice.copyWith(name: 'Updated').toJson()['name'], 'Updated');
        expect(
          voice.copyWith(rawJson: const {}).toJson().keys.toSet(),
          _voice().keys.toSet(),
        );
      },
    );
    for (final outcome in [
      'success',
      'http-error',
      'malformed',
      'connection',
    ]) {
      test(
        'FINEST $outcome protects IDs/sample/consent/headers/URL and caller trace',
        () async {
          final logs = await _captureLogs(() async {
            final fixture = _Fixture(
              (request, _) => switch (outcome) {
                'success' => _success(
                  headers: const {'x-fixture-private': _privateHeader},
                ),
                'http-error' => _jsonResponse(
                  {
                    'error': {
                      'message': _privateName,
                      'param': _privateConsent,
                    },
                  },
                  status: 400,
                  headers: const {
                    'x-request-id': _privateTraceId,
                    'x-fixture-private': _privateHeader,
                  },
                ),
                'connection' => throw http.ClientException(
                  _privateSample,
                  request.url,
                ),
                _ => _response(
                  utf8.encode('$_privateName $_privateSample'),
                  headers: const {'x-fixture-private': _privateHeader},
                ),
              },
              logLevel: Level.FINEST,
            );
            addTearDown(fixture.client.close);
            if (outcome == 'success') {
              final voice = await fixture.client.audio.voices.create(_create());
              expect(voice.toString(), isNot(contains('PRIVATE')));
            } else {
              final error = await _failure(_invoke(fixture.client));
              expect(
                error,
                anyOf(
                  isA<ApiException>(),
                  isA<ParseException>(),
                  isA<ConnectionException>(),
                ),
              );
              expect(error.toString(), isNot(contains('PRIVATE')));
            }
          });
          final diagnostic = logs
              .map(
                (record) =>
                    '${record.message} ${record.error} ${record.stackTrace}',
              )
              .join('\n');
          expect(diagnostic, isNot(contains('PRIVATE')));
          expect(diagnostic, isNot(contains(_privateName)));
          expect(diagnostic, isNot(contains(Uri.encodeComponent(_privateId))));
        },
      );
    }
  });
}

Map<String, Object?> _voice() => {
  'object': 'audio.voice',
  'id': _privateId,
  'name': _privateName,
  'type': 'audio_sample',
  'created_at': 1734220800,
};
CustomVoiceCreateRequest _create() => CustomVoiceCreateRequest(
  name: _privateName,
  audioSample: Uint8List.fromList(utf8.encode(_privateSample)),
  filename: _privateFilename,
  consent: _privateConsent,
  audioSampleContentType: 'audio/wav',
);
Future<Object?> _invoke(OpenAIClient client, {Future<void>? abort}) =>
    Future<Object?>.sync(
      () => client.audio.voices.create(_create(), abortTrigger: abort),
    );
http.StreamedResponse _success({Map<String, String> headers = const {}}) =>
    _jsonResponse(_voice(), headers: headers);
http.StreamedResponse _jsonResponse(
  Map<String, Object?> data, {
  int status = 200,
  Map<String, String> headers = const {},
}) =>
    _response(utf8.encode(jsonEncode(data)), status: status, headers: headers);
http.StreamedResponse _response(
  List<int> bytes, {
  int status = 200,
  Map<String, String> headers = const {},
}) => http.StreamedResponse(
  Stream.value(bytes),
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
  String? get contentType => RegExp(
    r'content-type: ([^\r\n]*)',
    caseSensitive: false,
  ).firstMatch(headers)?.group(1);
}

Map<String, List<_Part>> _parts(http.BaseRequest request, List<int> body) {
  final boundary = RegExp(
    r'boundary=([^; ]+)',
  ).firstMatch(request.headers['content-type']!)!.group(1)!;
  final parts = <String, List<_Part>>{};
  for (final raw in latin1.decode(body).split('--$boundary').skip(1)) {
    if (raw.startsWith('--')) break;
    final separator = raw.indexOf('\r\n\r\n');
    final headers = raw.substring(2, separator);
    final name = RegExp(r'name="([^"]*)"').firstMatch(headers)!.group(1)!;
    final value = raw.substring(separator + 4, raw.length - 2);
    parts.putIfAbsent(name, () => []).add(_Part(headers, latin1.encode(value)));
  }
  return parts;
}

List<String> _values(Map<String, List<_Part>> parts, String name) =>
    parts[name]?.map((part) => part.text).toList() ?? [];

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return const {
      'Authorization': 'Bearer PRIVATE-credential',
      'X-Request-ID': _privateTraceId,
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
    Level? logLevel,
    Duration timeout = const Duration(minutes: 1),
    _Auth? authProvider,
  }) {
    transport = _Transport(handler);
    client = OpenAIClient(
      config: OpenAIConfig(
        authProvider: authProvider ?? auth,
        baseUrl: 'https://fixture.invalid/PRIVATE-proxy/v1',
        timeout: timeout,
        project: 'PRIVATE-project',
        defaultHeaders: const {
          'x-fixture-private': _privateHeader,
          'X-Request-ID': _privateTraceId,
        },
        retryPolicy: RetryPolicy(
          maxRetries: maxRetries,
          initialDelay: const Duration(milliseconds: 1),
          maxDelay: const Duration(milliseconds: 5),
          jitter: 0,
        ),
        logLevel: logLevel,
      ),
      httpClient: transport,
      streamClientFactory: () {
        factoryCalls++;
        throw StateError('Unexpected streaming allocation');
      },
    );
  }
  final auth = _Auth();
  int factoryCalls = 0;
  late final _Transport transport;
  late final OpenAIClient client;
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

class _ConflictingAuth extends _Auth {
  late Map<String, String> lastHeaders;
  @override
  Map<String, String> getHeaders() {
    lastHeaders = {
      ...super.getHeaders(),
      'Accept': 'application/PRIVATE-xml',
      'content-type': 'text/PRIVATE-plain; charset=PRIVATE-charset',
    };
    return lastHeaders;
  }
}
