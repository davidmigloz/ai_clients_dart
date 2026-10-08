import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _privateName = 'PRIVATE consent name café 🚀';
const _privateId = 'PRIVATE-consent/id%?café';
const _privateCursor = 'PRIVATE-cursor/last%?café';
const _privateFilename = 'PRIVATE-recording.wav';
const _privateHeader = 'PRIVATE-header-value';
const _privateTraceId = 'PRIVATE-caller-trace-id';
const _privateRecording = 'PRIVATE-recording-bytes';
const _privateLanguage = 'x-PRIVATE-language';
const _collectionUrl = 'https://fixture.invalid/proxy/v1/audio/voice_consents';

enum _Operation {
  create,
  list,
  retrieve,
  update,
  delete;

  bool get collection => this == create || this == list;
  bool retriesHttp(int status) =>
      this != create && (this != update || status == 429);
  String get method => switch (this) {
    create || update => 'POST',
    list || retrieve => 'GET',
    delete => 'DELETE',
  };
}

void main() {
  group('Voice consent public routes and wire contract', () {
    test('audio and voice consent resources are cached', () {
      final fixture = _Fixture((_, _) => _success(_Operation.list));
      addTearDown(fixture.client.close);
      expect(fixture.client.audio, same(fixture.client.audio));
      expect(
        fixture.client.audio.voiceConsents,
        same(fixture.client.audio.voiceConsents),
      );
      expect(fixture.auth.calls, 0);
      expect(fixture.transport.sends, 0);
    });

    for (final operation in _Operation.values) {
      test(
        '${operation.name} uses exact route, method, auth and parser',
        () async {
          final fixture = _Fixture((_, _) => _success(operation));
          addTearDown(fixture.client.close);
          final result = await _invoke(operation, fixture.client);
          final sent = fixture.transport.requests.single;
          expect(sent.method, operation.method);
          expect(
            sent.url.toString(),
            operation.collection
                ? _collectionUrl
                : '$_collectionUrl/${Uri.encodeComponent(_privateId)}',
          );
          expect(sent.headers['authorization'], 'Bearer fixture-credential');
          expect(sent.headers['openai-project'], 'project-fixture');
          expect(sent.headers['x-fixture-private'], _privateHeader);
          expect(sent.headers['x-request-id'], _privateTraceId);
          expect(sent.headers['accept'], 'application/json');
          expect(fixture.auth.calls, greaterThan(0));
          expect(fixture.transport.sends, 1);
          expect(fixture.transport.closes, 0);
          switch (operation) {
            case _Operation.create:
              expect(
                sent.headers['content-type'],
                startsWith('multipart/form-data;'),
              );
              final parts = _parts(sent, fixture.transport.bodies.single);
              expect(parts.keys.toSet(), {'name', 'language', 'recording'});
              expect(_values(parts, 'name'), [_privateName]);
              expect(_values(parts, 'language'), [_privateLanguage]);
              expect(parts['recording']!.single.filename, _privateFilename);
              expect(parts['recording']!.single.contentType, 'audio/wav');
              expect(
                parts['recording']!.single.bytes,
                utf8.encode(_privateRecording),
              );
              expect((result! as VoiceConsent).toJson(), _consent());
            case _Operation.list:
              expect(sent.url.queryParameters, isEmpty);
              expect(fixture.transport.bodies.single, isEmpty);
              final page = result! as VoiceConsentList;
              expect(page.toJson(), _list());
              expect(page.data.single.toJson(), _consent());
              expect(page.hasMore, isTrue);
            case _Operation.retrieve:
              expect(fixture.transport.bodies.single, isEmpty);
              expect((result! as VoiceConsent).toJson(), _consent());
            case _Operation.update:
              expect(sent.headers['content-type'], 'application/json');
              expect(jsonDecode(utf8.decode(fixture.transport.bodies.single)), {
                'name': _privateName,
              });
              expect((result! as VoiceConsent).toJson(), _consent());
            case _Operation.delete:
              expect(fixture.transport.bodies.single, isEmpty);
              final deleted = result! as VoiceConsentDeleted;
              expect(deleted.deleted, isFalse);
              expect(deleted.toJson(), _deleted());
          }
        },
      );
    }

    for (final id in [
      'consent/as?query#hash%20',
      'café 🚀',
      '%2E%2E',
      'a/../b',
    ]) {
      for (final operation in [
        _Operation.retrieve,
        _Operation.update,
        _Operation.delete,
      ]) {
        test('${operation.name} encodes opaque ID once: $id', () async {
          final fixture = _Fixture((_, _) => _success(operation));
          addTearDown(fixture.client.close);
          await _invoke(operation, fixture.client, id: id);
          final encoded = Uri.encodeComponent(id);
          final url = fixture.transport.requests.single.url;
          expect(url.toString(), '$_collectionUrl/$encoded');
          expect(url.query, isEmpty);
          expect(url.fragment, isEmpty);
          expect(fixture.transport.sends, 1);
        });
      }
    }
    for (final id in ['', '.', '..']) {
      for (final operation in [
        _Operation.retrieve,
        _Operation.update,
        _Operation.delete,
      ]) {
        test(
          '${operation.name} rejects unsafe empty/dot ID before auth ($id)',
          () async {
            final fixture = _Fixture((_, _) => _success(operation));
            addTearDown(fixture.client.close);
            await expectLater(
              _invoke(operation, fixture.client, id: id),
              throwsArgumentError,
            );
            expect(fixture.auth.calls, 0);
            expect(fixture.transport.sends, 0);
          },
        );
      }
    }
  });

  group('Voice consent recording boundaries', () {
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
        'known ${entry.key} filename infers MIME without changing bytes',
        () async {
          final fixture = _Fixture((_, _) => _success(_Operation.create));
          addTearDown(fixture.client.close);
          await fixture.client.audio.voiceConsents.create(
            _create().copyWith(
              filename: 'recording.${entry.key}',
              recordingContentType: null,
            ),
          );
          final part = _parts(
            fixture.transport.requests.single,
            fixture.transport.bodies.single,
          )['recording']!.single;
          expect(part.contentType, entry.value);
          expect(part.bytes, utf8.encode(_privateRecording));
          expect(part.filename, 'recording.${entry.key}');
        },
      );
    }
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
      test('supported MIME $mime preserves bytes and filename', () async {
        final fixture = _Fixture((_, _) => _success(_Operation.create));
        addTearDown(fixture.client.close);
        final bytes = Uint8List.fromList([0, 255, 128, 13, 10, 65]);
        await fixture.client.audio.voiceConsents.create(
          _create().copyWith(
            recording: bytes,
            filename: 'opaque-original.bin',
            recordingContentType: mime,
          ),
        );
        final parts = _parts(
          fixture.transport.requests.single,
          fixture.transport.bodies.single,
        );
        expect(parts.keys.toSet(), {'name', 'recording', 'language'});
        expect(parts['recording']!.single.bytes, orderedEquals(bytes));
        expect(parts['recording']!.single.filename, 'opaque-original.bin');
        expect(parts['recording']!.single.contentType, mime);
        expect(parts.containsKey('recording_content_type'), isFalse);
      });
    }

    for (final mime in [
      'audio/webm;codecs=opus',
      'Audio/WEBM; codecs="opus"',
      'audio/ogg; codecs=opus',
      'audio/mp4; codecs="mp4a.40.2"',
    ]) {
      test(
        'browser MIME parameters normalize without changing recording: $mime',
        () async {
          final fixture = _Fixture((_, _) => _success(_Operation.create));
          addTearDown(fixture.client.close);
          final bytes = Uint8List.fromList([0, 255, 128, 13, 10, 65]);
          await fixture.client.audio.voiceConsents.create(
            _create().copyWith(recording: bytes, recordingContentType: mime),
          );
          final part = _parts(
            fixture.transport.requests.single,
            fixture.transport.bodies.single,
          )['recording']!.single;
          expect(part.contentType, mime.split(';').first.toLowerCase());
          expect(part.bytes, orderedEquals(bytes));
          expect(part.filename, _privateFilename);
        },
      );
    }

    for (final length in [10 * 1024 * 1024 - 1, 10 * 1024 * 1024]) {
      test('$length recording bytes are admitted without truncation', () async {
        final fixture = _Fixture((_, _) => _success(_Operation.create));
        addTearDown(fixture.client.close);
        final bytes = Uint8List(length)..[0] = 255;
        bytes[length - 1] = 128;
        await fixture.client.audio.voiceConsents.create(
          _create().copyWith(recording: bytes),
        );
        final part = _parts(
          fixture.transport.requests.single,
          fixture.transport.bodies.single,
        )['recording']!.single;
        expect(part.bytes, orderedEquals(bytes));
        expect(part.bytes.length, length);
        expect(fixture.transport.sends, 1);
      });
    }

    final badRequests = <String, VoiceConsentCreateRequest Function()>{
      'over 10 MiB': () =>
          _create().copyWith(recording: Uint8List(10 * 1024 * 1024 + 1)),
      'unsupported MIME': () =>
          _create().copyWith(recordingContentType: 'video/webm'),
      'unlisted MIME alias': () =>
          _create().copyWith(recordingContentType: 'audio/x-m4a'),
      'malformed MIME': () =>
          _create().copyWith(recordingContentType: 'PRIVATE invalid MIME'),
      'malformed MIME parameter': () => _create().copyWith(
        recordingContentType: 'audio/wav; PRIVATE invalid',
      ),
      'unknown filename without MIME': () => _create().copyWith(
        filename: 'PRIVATE-recording.unknown',
        recordingContentType: null,
      ),
    };
    for (final entry in badRequests.entries) {
      test('${entry.key} is rejected safely before authentication', () async {
        final fixture = _Fixture((_, _) => _success(_Operation.create));
        addTearDown(fixture.client.close);
        final error = await _failure(
          Future<void>.sync(() async {
            await fixture.client.audio.voiceConsents.create(entry.value());
          }),
        );
        expect(error, anyOf(isA<ArgumentError>(), isA<FormatException>()));
        expect(error.toString(), isNot(contains('PRIVATE')));
        expect(fixture.auth.calls, 0);
        expect(fixture.transport.sends, 0);
      });
    }

    test('open BCP 47 language is sent literally', () async {
      final fixture = _Fixture((_, _) => _success(_Operation.create));
      addTearDown(fixture.client.close);
      const language = 'zh-Hant-TW-x-custom';
      await fixture.client.audio.voiceConsents.create(
        _create().copyWith(language: language),
      );
      final parts = _parts(
        fixture.transport.requests.single,
        fixture.transport.bodies.single,
      );
      expect(_values(parts, 'language'), [language]);
    });
  });

  group('Voice consent explicit pagination', () {
    for (final limit in [null, 1, 20, 100]) {
      test('limit $limit and after remain exactly caller-controlled', () async {
        final fixture = _Fixture((_, _) => _success(_Operation.list));
        addTearDown(fixture.client.close);
        await fixture.client.audio.voiceConsents.list(
          limit: limit,
          after: _privateCursor,
        );
        expect(fixture.transport.requests.single.url.queryParameters, {
          'after': _privateCursor,
          if (limit != null) 'limit': '$limit',
        });
        expect(fixture.transport.sends, 1);
      });
    }
    for (final limit in [0, -1, 101]) {
      test('limit $limit fails before auth and dispatch', () async {
        final fixture = _Fixture((_, _) => _success(_Operation.list));
        addTearDown(fixture.client.close);
        await expectLater(
          fixture.client.audio.voiceConsents.list(limit: limit),
          throwsArgumentError,
        );
        expect(fixture.auth.calls, 0);
        expect(fixture.transport.sends, 0);
      });
    }
    test(
      'successive explicit pages never infer a cursor or iterate secretly',
      () async {
        var pages = 0;
        final fixture = _Fixture((_, _) {
          pages++;
          return _jsonResponse(
            _list(
              firstId: 'first-$pages',
              lastId: 'last-$pages',
              hasMore: true,
            ),
          );
        });
        addTearDown(fixture.client.close);
        final first = await fixture.client.audio.voiceConsents.list();
        expect(first.hasMore, isTrue);
        expect(first.lastId, 'last-1');
        expect(fixture.transport.sends, 1);
        final second = await fixture.client.audio.voiceConsents.list(
          after: 'caller-cursor',
          limit: 1,
        );
        expect(second.lastId, 'last-2');
        expect(fixture.transport.sends, 2);
        await fixture.client.audio.voiceConsents.list();
        expect(fixture.transport.sends, 3);
        expect(
          fixture.transport.requests
              .map((request) => request.url.queryParameters)
              .toList(),
          [
            <String, String>{},
            {'after': 'caller-cursor', 'limit': '1'},
            <String, String>{},
          ],
        );
      },
    );

    for (final cursorCase in ['absent', 'null', 'value']) {
      test(
        'received $cursorCase first_id and last_id remain distinct',
        () async {
          final body = <String, Object?>{
            'object': 'list',
            'data': [_consent()],
            'has_more': false,
            if (cursorCase != 'absent')
              'first_id': cursorCase == 'null' ? null : _privateId,
            if (cursorCase != 'absent')
              'last_id': cursorCase == 'null' ? null : _privateCursor,
          };
          final fixture = _Fixture((_, _) => _jsonResponse(body));
          addTearDown(fixture.client.close);
          final page = await fixture.client.audio.voiceConsents.list();
          expect(page.toJson(), body);
          expect(page.firstId, cursorCase == 'value' ? _privateId : null);
          expect(page.lastId, cursorCase == 'value' ? _privateCursor : null);
          expect(page.hasMore, isFalse);
          expect(fixture.transport.sends, 1);
        },
      );
    }
  });

  group('Voice consent optional cursor validation', () {
    for (final field in ['first_id', 'last_id']) {
      test(
        'malformed $field fails contextually through the public resource',
        () async {
          final payload = <String, Object?>{
            ..._list(),
            field: [_privateCursor],
          };
          final body = jsonEncode(payload);
          final fixture = _Fixture((_, _) => _response(utf8.encode(body)));
          addTearDown(fixture.client.close);
          final error = await _failure(
            fixture.client.audio.voiceConsents.list(),
          );
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
  });

  group('Voice consent preflight and cancellation', () {
    for (final operation in _Operation.values) {
      test('${operation.name} refuses a closed client before auth', () async {
        final fixture = _Fixture((_, _) => _success(operation));
        fixture.client.close();
        final calls = fixture.auth.calls;
        await expectLater(_invoke(operation, fixture.client), throwsStateError);
        expect(fixture.auth.calls, calls);
        expect(fixture.transport.sends, 0);
        expect(fixture.transport.closes, 0);
      });
      test('${operation.name} pre-abort prevents auth and dispatch', () async {
        final fixture = _Fixture((_, _) => _success(operation));
        addTearDown(fixture.client.close);
        final abort = Completer<void>()..complete();
        await expectLater(
          _invoke(operation, fixture.client, abort: abort.future),
          throwsA(isA<AbortedException>()),
        );
        expect(fixture.auth.calls, 0);
        expect(fixture.transport.sends, 0);
      });
      test(
        '${operation.name} native pending-header abort is not replayed',
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
          final result = _invoke(
            operation,
            fixture.client,
            abort: abort.future,
          );
          await fixture.transport.sent.future;
          abort.complete();
          final error = await _failure(result);
          expect(error, isA<AbortedException>());
          expect((error as AbortedException).correlationId, _privateTraceId);
          expect(error.toString(), isNot(contains('PRIVATE')));
          expect(fixture.transport.sends, 1);
          expect(fixture.transport.closes, 0);
        },
      );
      test(
        '${operation.name} native mid-body abort keeps borrowed transport',
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
              headers: const {
                'content-type': 'application/json; charset=utf-8',
              },
            );
          }, maxRetries: 3);
          addTearDown(fixture.client.close);
          final abort = Completer<void>();
          final result = _invoke(
            operation,
            fixture.client,
            abort: abort.future,
          );
          await ready.future;
          body.add(utf8.encode('partial $_privateRecording'));
          abort.complete();
          final error = await _failure(result);
          expect(error, isA<AbortedException>());
          expect((error as AbortedException).correlationId, _privateTraceId);
          expect(error.toString(), isNot(contains('PRIVATE')));
          expect(fixture.transport.sends, 1);
          expect(fixture.transport.closes, 0);
          await body.close();
        },
      );
    }
  });

  group('Voice consent conservative replay', () {
    for (final operation in _Operation.values) {
      for (final status in [429, 503]) {
        test(
          '${operation.name} HTTP$status ${operation.retriesHttp(status) ? 'uses shared safe retry' : 'is not replayed'}',
          () async {
            var calls = 0;
            final fixture = _Fixture((_, _) {
              calls++;
              return calls == 1
                  ? _jsonResponse({
                      'error': {
                        'message': _privateName,
                        'type': 'transient_error',
                      },
                    }, status: status)
                  : _success(operation);
            }, maxRetries: 1);
            addTearDown(fixture.client.close);
            if (!operation.retriesHttp(status)) {
              await expectLater(
                _invoke(operation, fixture.client),
                throwsA(isA<ApiException>()),
              );
              expect(fixture.transport.sends, 1);
            } else {
              await _invoke(operation, fixture.client);
              expect(fixture.transport.sends, 2);
              expect(
                fixture.transport.requests
                    .map((request) => request.url)
                    .toSet(),
                hasLength(1),
              );
            }
          },
        );
      }
    }
    for (final operation in _Operation.values) {
      test('${operation.name} permanent quota is never replayed', () async {
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
        final error = await _failure(_invoke(operation, fixture.client));
        expect(error, isA<RateLimitException>());
        expect((error as RateLimitException).code, 'insufficient_quota');
        expect(fixture.transport.sends, 1);
      });
      test(
        '${operation.name} connection failure follows shared idempotency and stays private',
        () async {
          var calls = 0;
          http.ClientException? original;
          final fixture = _Fixture((request, _) {
            calls++;
            if (calls == 1) {
              original = http.ClientException(_privateRecording, request.url);
              throw original!;
            }
            return _success(operation);
          }, maxRetries: 1);
          addTearDown(fixture.client.close);
          if (operation == _Operation.create ||
              operation == _Operation.update) {
            final error = await _failure(_invoke(operation, fixture.client));
            expect(error, isA<ConnectionException>());
            final connection = error as ConnectionException;
            expect(connection.message, _privateRecording);
            expect(connection.url, original!.uri.toString());
            expect(connection.cause, same(original));
            expect(error.toString(), isNot(contains('PRIVATE')));
            expect(fixture.transport.sends, 1);
          } else {
            await _invoke(operation, fixture.client);
            expect(fixture.transport.sends, 2);
          }
        },
      );
    }
  });

  group('Voice consent shared error context and privacy', () {
    for (final operation in _Operation.values) {
      for (final status in [302, 400, 401, 403, 404, 409, 422, 429, 503]) {
        test(
          '${operation.name} HTTP$status retains caller data with safe diagnostics',
          () async {
            final payload = {
              'error': {
                'message': _privateName,
                'type': _privateLanguage,
                'code': _privateCursor,
                'param': _privateFilename,
              },
            };
            final wire = utf8.encode(jsonEncode(payload));
            final fixture = _Fixture(
              (_, _) => _response(
                wire,
                status: status,
                headers: const {
                  'x-request-id': _privateId,
                  'retry-after': '3',
                  'x-fixture-private': _privateHeader,
                },
              ),
            );
            addTearDown(fixture.client.close);
            final error = await _failure(_invoke(operation, fixture.client));
            expect(error, isA<ApiException>());
            final api = error as ApiException;
            expect(api.statusCode, status);
            expect(api.message, _privateName);
            expect(api.type, _privateLanguage);
            expect(api.code, _privateCursor);
            expect(api.param, _privateFilename);
            expect(api.requestId, _privateId);
            expect(api.body, payload);
            expect(api.cause, isA<http.Response>());
            final raw = api.cause! as http.Response;
            expect(raw.bodyBytes, orderedEquals(wire));
            expect(raw.headers['x-fixture-private'], _privateHeader);
            expect(raw.headers['retry-after'], '3');
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
          '${operation.name} parse boundary keeps raw body and hides decoder data (${body.length})',
          () async {
            final fixture = _Fixture((_, _) => _response(utf8.encode(body)));
            addTearDown(fixture.client.close);
            final error = await _failure(_invoke(operation, fixture.client));
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
        '${operation.name} malformed UTF8 retains lossy caller context safely',
        () async {
          final bytes = [...utf8.encode(_privateName), 255];
          final fixture = _Fixture((_, _) => _response(bytes));
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(operation, fixture.client));
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
        '${operation.name} invalid UTF8 HTTP400 preserves original bytes and status',
        () async {
          final bytes = [...utf8.encode(_privateRecording), 255];
          final fixture = _Fixture(
            (_, _) => _response(
              bytes,
              status: 400,
              headers: const {'x-request-id': _privateId},
            ),
          );
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(operation, fixture.client));
          expect(error, isA<BadRequestException>());
          final api = error as ApiException;
          expect(api.statusCode, 400);
          expect(api.requestId, _privateId);
          expect((api.cause! as http.Response).bodyBytes, orderedEquals(bytes));
          expect(api.toString(), isNot(contains('PRIVATE')));
          expect(fixture.transport.sends, 1);
        },
      );

      for (final outcome in ['success', 'http-error', 'malformed']) {
        test(
          '${operation.name} FINEST $outcome hides consent URLs, headers and bodies',
          () async {
            final logs = await _captureLogs(() async {
              final fixture = _Fixture(
                (_, _) => switch (outcome) {
                  'success' => _success(
                    operation,
                    headers: const {'x-fixture-private': _privateHeader},
                  ),
                  'http-error' => _jsonResponse(
                    {
                      'error': {'message': _privateName},
                    },
                    status: 400,
                    headers: const {
                      'x-request-id': _privateId,
                      'x-fixture-private': _privateHeader,
                    },
                  ),
                  _ => _response(
                    utf8.encode('$_privateName $_privateRecording'),
                    headers: const {'x-fixture-private': _privateHeader},
                  ),
                },
                logLevel: Level.FINEST,
              );
              addTearDown(fixture.client.close);
              if (outcome == 'success') {
                final result = await _invoke(
                  operation,
                  fixture.client,
                  after: _privateCursor,
                );
                expect(result.toString(), isNot(contains('PRIVATE')));
              } else {
                final error = await _failure(
                  _invoke(operation, fixture.client, after: _privateCursor),
                );
                expect(
                  error,
                  anyOf(isA<ApiException>(), isA<ParseException>()),
                );
                expect(error.toString(), isNot(contains('PRIVATE')));
              }
            });
            final text = logs
                .map(
                  (record) =>
                      '${record.message} ${record.error} ${record.stackTrace}',
                )
                .join('\n');
            expect(text, isNot(contains('PRIVATE')));
            expect(text, isNot(contains(Uri.encodeComponent(_privateId))));
            expect(text, isNot(contains(Uri.encodeComponent(_privateCursor))));
            expect(text, isNot(contains('fixture-credential')));
          },
        );
      }
    }
  });

  group(
    'Voice consent canonical known-field validation through public parsers',
    () {
      final resources =
          <
            String,
            ({
              Map<String, Object?> body,
              Object Function(Map<String, dynamic>) parse,
            })
          >{
            'VoiceConsent': (body: _consent(), parse: VoiceConsent.fromJson),
            'VoiceConsentList': (
              body: _list(),
              parse: VoiceConsentList.fromJson,
            ),
            'VoiceConsentDeleted': (
              body: _deleted(),
              parse: VoiceConsentDeleted.fromJson,
            ),
          };
      for (final entry in resources.entries) {
        final required = entry.value.body.keys.where(
          (key) => key != 'first_id' && key != 'last_id',
        );
        for (final field in required) {
          for (final corruption in ['missing', 'null', 'wrong-type']) {
            test('${entry.key} rejects $corruption $field contextually', () {
              final body = <String, dynamic>{...entry.value.body};
              if (corruption == 'missing') {
                body.remove(field);
              } else {
                body[field] = corruption == 'null'
                    ? null
                    : <String, dynamic>{_privateName: true};
              }
              try {
                entry.value.parse(body);
                fail('Expected contextual model failure');
              } on FormatException catch (error) {
                expect(error.message, contains(field));
                expect(error.toString(), isNot(contains('PRIVATE')));
                expect(error.source, isNull);
              }
            });
          }
          test(
            '${entry.key} compatibility future metadata is immutable and receive-only',
            () {
              final children = <Object?>[
                1,
                <String, Object?>{'private': _privateRecording},
              ];
              final extra = <String, Object?>{'children': children};
              final body = <String, dynamic>{
                ...entry.value.body,
                'future': extra,
              };
              final model = entry.value.parse(body);
              final raw = switch (model) {
                final VoiceConsent value => value.rawJson,
                final VoiceConsentList value => value.rawJson,
                final VoiceConsentDeleted value => value.rawJson,
                _ => throw StateError('Unexpected canonical resource'),
              };
              final encoded = switch (model) {
                final VoiceConsent value => value.toJson(),
                final VoiceConsentList value => value.toJson(),
                final VoiceConsentDeleted value => value.toJson(),
                _ => throw StateError('Unexpected canonical resource'),
              };
              expect(encoded, body);
              extra['children'] = <Object?>[];
              children.clear();
              final future = raw['future'] as Map<String, dynamic>;
              expect(future['children'], [
                1,
                {'private': _privateRecording},
              ]);
              expect(() => raw['future'] = null, throwsUnsupportedError);
              expect(() => future['children'] = null, throwsUnsupportedError);
              expect(
                () => (future['children'] as List).clear(),
                throwsUnsupportedError,
              );
              expect(model.toString(), isNot(contains('PRIVATE')));
              expect(
                () => VoiceConsentUpdateRequest.fromJson(encoded),
                throwsFormatException,
              );
            },
          );
        }
      }
      test(
        'consent created_at rejects fractional numbers without rounding',
        () {
          expect(
            () => VoiceConsent.fromJson({..._consent(), 'created_at': 1.5}),
            throwsFormatException,
          );
        },
      );
      test('canonical fixed object values reject alternate strings', () {
        expect(
          () => VoiceConsent.fromJson({..._consent(), 'object': 'audio.voice'}),
          throwsFormatException,
        );
        expect(
          () => VoiceConsentList.fromJson({..._list(), 'object': 'other'}),
          throwsFormatException,
        );
        expect(
          () => VoiceConsentDeleted.fromJson({
            ..._deleted(),
            'object': 'audio.voice',
          }),
          throwsFormatException,
        );
      });
      test(
        'update writable shape requires name and rejects received extras before auth',
        () async {
          for (final body in <Map<String, dynamic>>[
            {},
            {'name': null},
            {
              'name': [_privateName],
            },
            {'name': _privateName, 'id': _privateId},
            {'name': _privateName, 'object': 'audio.voice_consent'},
            {'name': _privateName, 'future': _privateRecording},
            {'name': _privateName, _privateRecording: true},
          ]) {
            final fixture = _Fixture((_, _) => _success(_Operation.update));
            addTearDown(fixture.client.close);
            final error = await _failure(
              Future<void>.sync(() async {
                await fixture.client.audio.voiceConsents.update(
                  _privateId,
                  VoiceConsentUpdateRequest.fromJson(body),
                );
              }),
            );
            expect(error, isA<FormatException>());
            expect(error.toString(), isNot(contains('PRIVATE')));
            expect(fixture.auth.calls, 0);
            expect(fixture.transport.sends, 0);
          }
        },
      );
    },
  );
}

Map<String, Object?> _consent() => {
  'object': 'audio.voice_consent',
  'id': _privateId,
  'name': _privateName,
  'language': _privateLanguage,
  'created_at': 1734220800,
};
Map<String, Object?> _list({
  String? firstId = _privateId,
  String? lastId = _privateCursor,
  bool hasMore = true,
}) => {
  'object': 'list',
  'data': [_consent()],
  'first_id': firstId,
  'last_id': lastId,
  'has_more': hasMore,
};
Map<String, Object?> _deleted() => {
  'object': 'audio.voice_consent',
  'id': _privateId,
  'deleted': false,
};

VoiceConsentCreateRequest _create() => VoiceConsentCreateRequest(
  name: _privateName,
  recording: Uint8List.fromList(utf8.encode(_privateRecording)),
  filename: _privateFilename,
  language: _privateLanguage,
  recordingContentType: 'audio/wav',
);

Future<Object?> _invoke(
  _Operation operation,
  OpenAIClient client, {
  String id = _privateId,
  String? after,
  Future<void>? abort,
}) => Future<Object?>.sync(
  () => switch (operation) {
    _Operation.create => client.audio.voiceConsents.create(
      _create(),
      abortTrigger: abort,
    ),
    _Operation.list => client.audio.voiceConsents.list(
      after: after,
      abortTrigger: abort,
    ),
    _Operation.retrieve => client.audio.voiceConsents.retrieve(
      id,
      abortTrigger: abort,
    ),
    _Operation.update => client.audio.voiceConsents.update(
      id,
      const VoiceConsentUpdateRequest(name: _privateName),
      abortTrigger: abort,
    ),
    _Operation.delete => client.audio.voiceConsents.delete(
      id,
      abortTrigger: abort,
    ),
  },
);

http.StreamedResponse _success(
  _Operation operation, {
  Map<String, String> headers = const {},
}) => _jsonResponse(switch (operation) {
  _Operation.list => _list(),
  _Operation.delete => _deleted(),
  _ => _consent(),
}, headers: headers);
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
      'Authorization': 'Bearer fixture-credential',
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
  }) {
    transport = _Transport(handler);
    client = OpenAIClient(
      config: OpenAIConfig(
        authProvider: auth,
        baseUrl: 'https://fixture.invalid/proxy/v1',
        project: 'project-fixture',
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
    );
  }
  final auth = _Auth();
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
