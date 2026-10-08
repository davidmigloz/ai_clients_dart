import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const Map<String, Object?> _delta = {
  'type': 'speech.audio.delta',
  'audio': 'AP+AQQ==',
};
const Map<String, Object?> _done = {
  'type': 'speech.audio.done',
  'usage': {'input_tokens': 3, 'output_tokens': 6, 'total_tokens': 9},
};
const _request = SpeechRequest(
  model: 'future-speech-model',
  input: 'Hello, world!',
  voice: SpeechVoice.alloy,
);

typedef _SpeechCall =
    Future<void> Function(
      OpenAIClient client,
      SpeechRequest request,
      Future<void>? abort,
    );

void main() {
  final calls = <String, _SpeechCall>{
    'buffered': (client, request, abort) async {
      await client.audio.speech.create(request, abortTrigger: abort);
    },
    'bytes': (client, request, abort) => client.audio.speech
        .createByteStream(request, abortTrigger: abort)
        .drain<void>(),
    'SSE': (client, request, abort) => client.audio.speech
        .createStream(request, abortTrigger: abort)
        .drain<void>(),
  };

  group('Speech public media modes', () {
    for (final format in SpeechResponseFormat.values) {
      for (final mode in ['buffered', 'bytes']) {
        test('$mode preserves every byte of ${format.toJson()}', () async {
          final expected = [0, 255, 128, 13, 10, 0, 65];
          final fixture = _Fixture(
            (_) => _response([
              expected.sublist(0, 2),
              expected.sublist(2, 5),
              expected.sublist(5),
            ], contentType: 'audio/${format.toJson()}'),
          );
          addTearDown(fixture.client.close);
          final request = _request.copyWith(responseFormat: format);
          final bytes = mode == 'buffered'
              ? await fixture.client.audio.speech.create(request)
              : (await fixture.client.audio.speech
                        .createByteStream(request)
                        .toList())
                    .expand((chunk) => chunk)
                    .toList();
          expect(bytes, orderedEquals(expected));
          final transport = mode == 'buffered'
              ? fixture.borrowed
              : fixture.owned;
          expect(transport.sends, 1);
          final sent = transport.requests.single as http.Request;
          expect(sent.method, 'POST');
          expect(
            sent.url.toString(),
            'https://fixture.invalid/proxy/v1/audio/speech',
          );
          expect(sent.headers['accept'], 'application/octet-stream');
          expect(sent.headers['content-type'], contains('application/json'));
          expect(sent.headers['authorization'], 'Bearer fixture-credential');
          expect(sent.headers['openai-organization'], 'org-fixture');
          expect(sent.headers['openai-project'], 'project-fixture');
          expect(sent.headers['x-fixture'], 'present');
          expect(jsonDecode(sent.body), {
            'model': 'future-speech-model',
            'input': 'Hello, world!',
            'voice': 'alloy',
            'response_format': format.toJson(),
            'stream_format': 'audio',
          });
          expect(fixture.borrowed.closes, 0);
          expect(fixture.owned.closes, mode == 'bytes' ? 1 : 0);
        });
      }
    }

    for (final voice in [
      const AudioVoice.named('future-voice'),
      const AudioVoice.custom('voice-fixture'),
    ]) {
      test('SSE forwards typed $voice and all optional fields', () async {
        final fixture = _Fixture((_) => _sseResponse([_delta, _done]));
        addTearDown(fixture.client.close);
        final request = _request.copyWith(
          voice: voice,
          instructions: 'Speak gently.',
          responseFormat: SpeechResponseFormat.pcm,
          speed: 0.25,
          streamFormat: SpeechStreamFormat.sse,
        );
        final events = await fixture.client.audio.speech
            .createStream(request)
            .toList();
        expect(events, hasLength(2));
        expect(events.first, isA<SpeechAudioDeltaEvent>());
        expect(events.last, isA<SpeechAudioDoneEvent>());
        final sent = fixture.owned.requests.single as http.Request;
        expect(sent.headers['accept'], 'text/event-stream');
        expect(jsonDecode(sent.body), {
          'model': 'future-speech-model',
          'input': 'Hello, world!',
          'voice': voice is CustomAudioVoice
              ? {'id': 'voice-fixture'}
              : 'future-voice',
          'instructions': 'Speak gently.',
          'response_format': 'pcm',
          'speed': 0.25,
          'stream_format': 'sse',
        });
        expect(fixture.factoryCalls, 1);
        expect(fixture.owned.closes, 1);
        expect(fixture.borrowed.sends, 0);
        expect(fixture.borrowed.closes, 0);
      });
    }

    for (final mode in calls.entries) {
      test('${mode.key} rejects incompatible media before auth', () async {
        final fixture = _Fixture((_) => _sseResponse([_done]));
        addTearDown(fixture.client.close);
        final request = _request.copyWith(
          streamFormat: mode.key == 'SSE'
              ? SpeechStreamFormat.audio
              : SpeechStreamFormat.sse,
        );
        await expectLater(
          Future<void>.sync(() => mode.value(fixture.client, request, null)),
          throwsArgumentError,
        );
        _expectNoDispatch(fixture);
      });
      for (final invalid in {
        'NaN speed': _uncheckedRequest(speed: double.nan),
        'high speed': _uncheckedRequest(speed: 4.01),
        'long input': _uncheckedRequest(input: 'a' * 4097),
        'long instructions': _uncheckedRequest(instructions: 'a' * 4097),
        'caller voice extras': _uncheckedRequest(voice: const _InvalidVoice()),
      }.entries) {
        test(
          '${mode.key} validates requests before auth: ${invalid.key}',
          () async {
            final fixture = _Fixture((_) => _sseResponse([_done]));
            addTearDown(fixture.client.close);
            await expectLater(
              Future<void>.sync(
                () => mode.value(fixture.client, invalid.value, null),
              ),
              throwsFormatException,
            );
            _expectNoDispatch(fixture);
          },
        );
      }
      test('${mode.key} aborts before auth/factory/send', () async {
        final abort = Completer<void>()..complete();
        await Future<void>.value();
        final fixture = _Fixture((_) => _sseResponse([_done]));
        addTearDown(fixture.client.close);
        await expectLater(
          Future<void>.sync(
            () => mode.value(fixture.client, _request, abort.future),
          ),
          throwsA(isA<AbortedException>()),
        );
        _expectNoDispatch(fixture);
      });
    }

    for (final mode in ['bytes', 'SSE']) {
      test('$mode rejects a closed client before subscription', () {
        final fixture = _Fixture((_) => _sseResponse([_done]));
        fixture.client.close();
        expect(
          () => mode == 'bytes'
              ? fixture.client.audio.speech.createByteStream(_request)
              : fixture.client.audio.speech.createStream(_request),
          throwsStateError,
        );
        _expectNoDispatch(fixture);
      });
    }

    test('explicit audio mode remains valid for buffered and bytes', () async {
      final fixture = _Fixture(
        (_) => _response([
          [0, 1, 2],
        ]),
      );
      addTearDown(fixture.client.close);
      final request = _request.copyWith(streamFormat: SpeechStreamFormat.audio);
      expect(await fixture.client.audio.speech.create(request), [0, 1, 2]);
      expect(
        await fixture.client.audio.speech.createByteStream(request).toList(),
        [
          Uint8List.fromList([0, 1, 2]),
        ],
      );
    });
  });

  group('Speech configured headers preserve selected media', () {
    final configurations = <String, Map<String, String>>{
      'lowercase': {'accept': 'application/json', 'content-type': 'text/plain'},
      'uppercase': {'ACCEPT': 'text/html', 'CONTENT-TYPE': 'text/plain'},
      'duplicate mixed case': {
        'Accept': 'text/html',
        'aCcEpT': 'text/plain',
        'accept': 'application/xml',
        'Content-Type': 'text/plain',
        'cOnTeNt-TyPe': 'audio/mpeg',
        'content-type': 'text/markdown',
      },
    };
    for (final configuration in configurations.entries) {
      for (final mode in calls.entries) {
        test(
          '${mode.key} forces actual mode after ${configuration.key} defaults',
          () async {
            final original = Map<String, String>.of(configuration.value);
            final fixture = _Fixture(
              (_) => mode.key == 'SSE'
                  ? _sseResponse([_done])
                  : _response([
                      [0, 1],
                    ]),
              defaultHeaders: configuration.value,
            );
            addTearDown(fixture.client.close);
            await mode.value(fixture.client, _request, null);
            final sent =
                (mode.key == 'buffered' ? fixture.borrowed : fixture.owned)
                    .requests
                    .single;
            expect(
              sent.headers['accept'],
              mode.key == 'SSE'
                  ? 'text/event-stream'
                  : 'application/octet-stream',
            );
            expect(sent.headers['content-type'], contains('application/json'));
            expect(
              sent.headers.keys.where((key) => key.toLowerCase() == 'accept'),
              hasLength(1),
            );
            expect(
              sent.headers.keys.where(
                (key) => key.toLowerCase() == 'content-type',
              ),
              hasLength(1),
            );
            expect(configuration.value, original);
            expect(fixture.borrowed.sends + fixture.owned.sends, 1);
            expect(fixture.borrowed.closes, 0);
            expect(fixture.owned.closes, mode.key == 'buffered' ? 0 : 1);
          },
        );
      }
    }
  });

  for (final mode in calls.entries) {
    test(
      '${mode.key} preserves credentials while overriding provider media headers',
      () async {
        final provider = _ConflictingMediaAuth();
        final fixture = _Fixture(
          (_) => mode.key == 'SSE'
              ? _sseResponse([_done])
              : _response([
                  [0, 1],
                ]),
          authProvider: provider,
        );
        addTearDown(fixture.client.close);
        final request = _request.copyWith(
          input: 'Unicode header fixture 🍕🦊',
          instructions: 'Speak quietly ☀️',
        );
        await mode.value(fixture.client, request, null);
        final sent = (mode.key == 'buffered' ? fixture.borrowed : fixture.owned)
            .requests
            .single;
        expect(
          sent.headers['accept'],
          mode.key == 'SSE' ? 'text/event-stream' : 'application/octet-stream',
        );
        expect(sent.headers['content-type'], contains('application/json'));
        expect(sent.headers['authorization'], 'Bearer fixture-credential');
        expect(provider.calls, greaterThan(0));
        expect(
          (jsonDecode((sent as http.Request).body)
              as Map<String, dynamic>)['input'],
          request.input,
        );
        expect(
          (jsonDecode(sent.body) as Map<String, dynamic>)['instructions'],
          request.instructions,
        );
        expect(
          provider.lastHeaders['Content-Type'],
          'text/plain; charset=unknown-fixture-charset',
        );
        expect(
          provider.lastHeaders['content-type'],
          'text/plain; charset=iso-8859-1',
        );
        expect(provider.lastHeaders['accept'], 'text/plain');
        expect(fixture.borrowed.sends + fixture.owned.sends, 1);
        expect(fixture.borrowed.closes, 0);
        expect(fixture.owned.closes, mode.key == 'buffered' ? 0 : 1);
      },
    );
  }

  group('Speech SSE public parser', () {
    test(
      'single-byte UTF-8 and CRLF chunks preserve events and future JSON',
      () async {
        const future = {
          'type': 'speech.future',
          'metadata': {
            'caption': 'private 🍕',
            'items': [1, null, true],
          },
        };
        final wire =
            ': keep-alive\r\n\r\n'
            'event: speech.audio.delta\r\n'
            'data: ${jsonEncode(_delta)}\r\n\r\n'
            'data: ${jsonEncode(future)}\r\n\r\n'
            'data: ${jsonEncode(_done)}\r\n\r\n'
            'data: [DONE]\r\n\r\n';
        final fixture = _Fixture(
          (_) => _response(
            utf8.encode(wire).map((byte) => [byte]),
            contentType: 'text/event-stream; charset=utf-8',
          ),
        );
        addTearDown(fixture.client.close);
        final events = await fixture.client.audio.speech
            .createStream(_request)
            .toList();
        expect(events, hasLength(3));
        final delta = events[0] as SpeechAudioDeltaEvent;
        expect(delta.audio, 'AP+AQQ==');
        expect(delta.decodeAudio(), [0, 255, 128, 65]);
        expect(events[1], isA<SpeechUnknownEvent>());
        expect(events[1].toJson(), future);
        final done = events[2] as SpeechAudioDoneEvent;
        expect(done.usage.inputTokens, 3);
        expect(done.usage.outputTokens, 6);
        expect(done.usage.totalTokens, 9);
        expect(fixture.owned.sends, 1);
        expect(fixture.owned.closes, 1);
      },
    );

    test('valid final event at EOF needs no invented DONE sentinel', () async {
      final fixture = _Fixture(
        (_) => _response([
          utf8.encode('data: ${jsonEncode(_done)}'),
        ], contentType: 'text/event-stream'),
      );
      addTearDown(fixture.client.close);
      final events = await fixture.client.audio.speech
          .createStream(_request)
          .toList();
      expect(events.single, isA<SpeechAudioDoneEvent>());
      expect(fixture.owned.closes, 1);
    });

    for (final owns in [true, false]) {
      test(
        'done ends held-open SSE, ignores queued/late bytes and preserves ownership ($owns)',
        () async {
          final source = StreamController<List<int>>();
          final cancelled = Completer<void>();
          var cancellationCount = 0;
          source.onCancel = () {
            cancellationCount++;
            if (!cancelled.isCompleted) cancelled.complete();
          };
          final sent = Completer<void>();
          final fixture = _Fixture((_) {
            sent.complete();
            return http.StreamedResponse(
              source.stream,
              200,
              headers: {'content-type': 'text/event-stream'},
            );
          }, ownsStream: owns);
          addTearDown(fixture.client.close);
          final result = fixture.client.audio.speech
              .createStream(_request)
              .toList();
          await sent.future;
          source.add(
            utf8.encode(
              'data: ${jsonEncode(_delta)}\n\n'
              'data: ${jsonEncode(_done)}\n\n'
              'data: {"error":{"message":"queued after terminal"}}\n\n'
              'data: not JSON after terminal\n\n',
            ),
          );
          try {
            final events = await result.timeout(const Duration(seconds: 2));
            expect(events, hasLength(2));
            expect(events.first, isA<SpeechAudioDeltaEvent>());
            expect(events.last, isA<SpeechAudioDoneEvent>());
            expect((events.last as SpeechAudioDoneEvent).usage.totalTokens, 9);
            await cancelled.future.timeout(const Duration(seconds: 2));
            expect(cancellationCount, 1);
            expect(fixture.owned.closes, owns ? 1 : 0);
            expect(fixture.borrowed.closes, 0);
            source.add(
              utf8.encode('event: error\ndata: late after terminal\n\n'),
            );
            await Future<void>.value();
            expect(events, hasLength(2));
            expect(fixture.borrowed.sends + fixture.owned.sends, 1);
          } finally {
            await source.close();
          }
          fixture.client.close();
          expect(fixture.borrowed.closes, 0);
          expect(fixture.owned.closes, owns ? 1 : 0);
        },
      );
    }

    for (final data in [
      '',
      ': comment only\n\n',
      'data: [DONE]\n\n',
      'data: ${jsonEncode(_delta)}\n\n',
      'data: ${jsonEncode(_delta)}\n\ndata: [DONE]\n\n',
      'data: {"type":"speech.future"}\n\n',
    ]) {
      test(
        'incomplete SSE fails rather than invent completion: $data',
        () async {
          final fixture = _Fixture(
            (_) => _response([
              utf8.encode(data),
            ], contentType: 'text/event-stream'),
          );
          addTearDown(fixture.client.close);
          await expectLater(
            fixture.client.audio.speech.createStream(_request).toList(),
            throwsA(isA<StreamException>()),
          );
          expect(fixture.owned.sends, 1);
          expect(fixture.owned.closes, 1);
        },
      );
    }

    for (final malformed in [
      'not JSON private-speech-data',
      '[]',
      '{"audio":"private-speech-data"}',
      '{"type":4,"audio":"private-speech-data"}',
      '{"type":"speech.audio.delta","audio":4,"private":"private-speech-data"}',
      '{"type":"speech.audio.done","usage":{"input_tokens":3,"output_tokens":6.5,"total_tokens":9},"private":"private-speech-data"}',
    ]) {
      test(
        'malformed known SSE is contextual and private: $malformed',
        () async {
          final fixture = _Fixture(
            (_) => _response([
              utf8.encode('data: $malformed\n\n'),
            ], contentType: 'text/event-stream'),
          );
          addTearDown(fixture.client.close);
          final error = await _errorOf(
            fixture.client.audio.speech.createStream(_request).toList(),
          );
          expect(error, isA<ParseException>());
          final parse = error as ParseException;
          expect(parse.message, contains('speech'));
          expect(parse.toString(), isNot(contains('private-speech-data')));
          expect(
            parse.cause?.toString(),
            isNot(contains('private-speech-data')),
          );
          expect(parse.responseBody, malformed);
          expect(fixture.owned.closes, 1);
        },
      );
    }

    for (final inline in [
      'data: {"error":{"message":"fixture inline failure","code":"overloaded"}}\n\n',
      'event: error\ndata: fixture inline failure\n\n',
      'event: error\ndata: {"message":"fixture inline failure"}\n\n',
    ]) {
      test(
        'inline failure after audio is exposed without replay: $inline',
        () async {
          final fixture = _Fixture(
            (_) => _response([
              utf8.encode('data: ${jsonEncode(_delta)}\n\n'),
              utf8.encode(inline),
            ], contentType: 'text/event-stream'),
          );
          addTearDown(fixture.client.close);
          final seen = <SpeechStreamEvent>[];
          await expectLater(
            fixture.client.audio.speech.createStream(_request).map((event) {
              seen.add(event);
              return event;
            }).toList(),
            throwsA(isA<StreamException>()),
          );
          expect(seen.single, isA<SpeechAudioDeltaEvent>());
          expect(fixture.owned.sends, 1);
          expect(fixture.factoryCalls, 1);
          expect(fixture.owned.closes, 1);
        },
      );
    }
  });

  group('Speech pre-data HTTP failures', () {
    for (final mode in calls.entries) {
      for (final status in [302, 400, 401, 403, 429, 503]) {
        for (final structured in [true, false]) {
          test(
            '${mode.key} exposes $status error and retry context ($structured)',
            () async {
              const errorJson = {
                'error': {
                  'message': 'fixture failure',
                  'type': 'server_error',
                  'code': 'overloaded',
                  'param': 'input',
                },
              };
              final fixture = _Fixture(
                (_) => _response(
                  [
                    utf8.encode(
                      structured
                          ? jsonEncode(errorJson)
                          : 'fixture plain failure',
                    ),
                  ],
                  status: status,
                  contentType: structured ? 'application/json' : 'text/plain',
                  headers: {
                    'retry-after-ms': '1.2345',
                    'x-request-id': 'req-fixture',
                  },
                ),
                retryPolicy: mode.key == 'buffered'
                    ? const RetryPolicy(maxRetries: 0)
                    : const RetryPolicy(
                        maxRetries: 3,
                        initialDelay: Duration.zero,
                        maxDelay: Duration.zero,
                        jitter: 0,
                      ),
              );
              addTearDown(fixture.client.close);
              final error = await _errorOf(
                mode.value(fixture.client, _request, null),
              );
              expect(error, isA<ApiException>());
              final api = error as ApiException;
              expect(api.statusCode, status);
              expect(api.requestId, 'req-fixture');
              expect(
                api.message,
                structured ? 'fixture failure' : 'fixture plain failure',
              );
              expect(api.body, structured ? errorJson : null);
              expect(api.code, structured ? 'overloaded' : null);
              expect(api.param, structured ? 'input' : null);
              expect(api.cause, isA<http.Response>());
              final original = api.cause! as http.Response;
              expect(original.statusCode, status);
              expect(original.headers['x-request-id'], 'req-fixture');
              expect(original.headers['retry-after-ms'], '1.2345');
              expect(
                original.bodyBytes,
                utf8.encode(
                  structured ? jsonEncode(errorJson) : 'fixture plain failure',
                ),
              );
              final retry = switch (api) {
                RateLimitException() => api.retryAfter,
                InternalServerException() => api.retryAfter,
                _ => null,
              };
              if (status == 429 || status == 503) {
                expect(retry, const Duration(microseconds: 1235));
              }
              expect(fixture.borrowed.sends + fixture.owned.sends, 1);
              expect(fixture.borrowed.closes, 0);
              expect(fixture.owned.closes, mode.key == 'buffered' ? 0 : 1);
            },
          );
        }
      }
    }
  });

  for (final mode in calls.entries) {
    test(
      '${mode.key} preserves malformed UTF-8 HTTP failure and original bytes',
      () async {
        const input = 'private-malformed-input';
        const instructions = 'private-malformed-instructions';
        const voiceId = 'voice-private-malformed';
        final errorBytes = [
          255,
          254,
          ...utf8.encode('$input | $instructions | $voiceId'),
        ];
        final fixture = _Fixture(
          (_) => _response(
            [errorBytes],
            status: 400,
            contentType: 'application/json; charset=utf-8',
            headers: {
              'x-request-id': 'req-malformed-utf8',
              'x-fixture-response': 'retained',
            },
          ),
        );
        addTearDown(fixture.client.close);
        const request = SpeechRequest(
          model: 'future-speech-model',
          input: input,
          instructions: instructions,
          voice: AudioVoice.custom(voiceId),
        );
        final error = await _errorOf(mode.value(fixture.client, request, null));
        expect(error, isA<BadRequestException>());
        final api = error as ApiException;
        expect(api.statusCode, 400);
        expect(api.requestId, 'req-malformed-utf8');
        expect(api.body, isNull);
        expect(api.message, utf8.decode(errorBytes, allowMalformed: true));
        final cause = api.cause! as http.Response;
        expect(cause.bodyBytes, orderedEquals(errorBytes));
        expect(cause.headers['x-fixture-response'], 'retained');
        expect(cause.request, isA<http.Request>());
        for (final private in [
          input,
          instructions,
          voiceId,
          'fixture-credential',
        ]) {
          expect(api.toString(), isNot(contains(private)));
        }
        expect(fixture.borrowed.sends + fixture.owned.sends, 1);
        expect(fixture.borrowed.closes, 0);
        expect(fixture.owned.closes, mode.key == 'buffered' ? 0 : 1);
      },
    );
  }

  for (final mode in calls.entries) {
    test(
      '${mode.key} respects declared Latin1 HTTP error text and original bytes',
      () async {
        const text = 'Erreur française: café';
        final bytes = latin1.encode(text);
        final fixture = _Fixture(
          (_) => _response(
            [bytes],
            status: 400,
            contentType: 'text/plain; charset=iso-8859-1',
            headers: {
              'x-request-id': 'req-latin1',
              'x-fixture-response': 'retained',
            },
          ),
        );
        addTearDown(fixture.client.close);
        final failure = await _errorOf(
          mode.value(fixture.client, _request, null),
        );
        expect(failure, isA<BadRequestException>());
        final error = failure as ApiException;
        expect(error.statusCode, 400);
        expect(error.requestId, 'req-latin1');
        expect(error.message, text);
        expect(error.body, isNull);
        final original = error.cause! as http.Response;
        expect(original.body, text);
        expect(original.bodyBytes, orderedEquals(bytes));
        expect(original.headers['x-fixture-response'], 'retained');
        expect(fixture.borrowed.sends + fixture.owned.sends, 1);
        expect(fixture.borrowed.closes, 0);
        expect(fixture.owned.closes, mode.key == 'buffered' ? 0 : 1);
      },
    );
  }

  group('Speech buffered diagnostics privacy', () {
    const input = 'private-input-🍕';
    const instructions = 'private-instructions-🦊';
    const voiceId = 'voice-private-fixture';
    const privateRequest = SpeechRequest(
      model: 'future-speech-model',
      input: input,
      instructions: instructions,
      voice: AudioVoice.custom(voiceId),
    );
    test(
      'FINEST logging preserves successful bytes without rendering private text/audio',
      () async {
        const audio = 'private-audio-fixture';
        final bytes = utf8.encode(audio);
        final logs = await _captureLogs(() async {
          final fixture = _Fixture(
            (_) => _response([bytes]),
            logLevel: Level.FINEST,
          );
          try {
            expect(
              await fixture.client.audio.speech.create(privateRequest),
              orderedEquals(bytes),
            );
            expect(fixture.borrowed.sends, 1);
            expect(fixture.borrowed.closes, 0);
            final sent = fixture.borrowed.requests.single as http.Request;
            expect(
              (jsonDecode(sent.body) as Map<String, dynamic>)['input'],
              input,
            );
          } finally {
            fixture.client.close();
          }
        });
        expect(logs, isNotEmpty);
        final diagnostic = logs
            .map((record) => '${record.message} ${record.error ?? ''}')
            .join('\n');
        for (final secret in [input, instructions, voiceId, audio]) {
          expect(diagnostic, isNot(contains(secret)));
          expect(
            diagnostic,
            isNot(
              contains(
                jsonEncode(secret).substring(1, jsonEncode(secret).length - 1),
              ),
            ),
          );
        }
      },
    );

    for (final shape in ['string message', 'malformed message', 'plain text']) {
      test(
        'FINEST/default error diagnostics redact provider echo ($shape)',
        () async {
          const message = '$input | $instructions | $voiceId';
          final errorBody = shape == 'plain text'
              ? message
              : jsonEncode({
                  'error': {
                    'message': shape == 'malformed message'
                        ? {'echo': message}
                        : message,
                    'type': 'invalid_request_error',
                    'code': 'bad_input',
                  },
                });
          late ApiException failure;
          final logs = await _captureLogs(() async {
            final fixture = _Fixture(
              (_) => _response(
                [utf8.encode(errorBody)],
                status: 400,
                contentType: shape == 'plain text'
                    ? 'text/plain; charset=utf-8'
                    : 'application/json',
              ),
              logLevel: Level.FINEST,
            );
            try {
              final error = await _errorOf(
                fixture.client.audio.speech.create(privateRequest),
              );
              expect(error, isA<BadRequestException>());
              failure = error as ApiException;
              expect(
                failure.message,
                shape == 'string message' ? message : errorBody,
              );
              expect(
                failure.body,
                shape == 'plain text' ? null : jsonDecode(errorBody),
              );
              final original = failure.cause! as http.Response;
              expect(original.bodyBytes, utf8.encode(errorBody));
              expect(original.request, isA<http.Request>());
              expect(fixture.borrowed.sends, 1);
            } finally {
              fixture.client.close();
            }
          });
          expect(logs, isNotEmpty);
          final diagnostic =
              '$failure\n${logs.map((record) => '${record.message} ${record.error ?? ''}').join('\n')}';
          for (final secret in [input, instructions, voiceId]) {
            expect(diagnostic, isNot(contains(secret)));
          }
        },
      );
    }
  });

  group('Speech stream lifetime at public seams', () {
    for (final mode in ['bytes', 'SSE']) {
      for (final owns in [true, false]) {
        test(
          '$mode cancellation closes only owned transports ($owns)',
          () async {
            final source = StreamController<List<int>>();
            final cancelled = Completer<void>();
            source.onCancel = () {
              if (!cancelled.isCompleted) cancelled.complete();
            };
            final sent = Completer<void>();
            final fixture = _Fixture((_) {
              sent.complete();
              return http.StreamedResponse(
                source.stream,
                200,
                headers: {
                  'content-type': mode == 'SSE'
                      ? 'text/event-stream'
                      : 'audio/pcm',
                },
              );
            }, ownsStream: owns);
            addTearDown(fixture.client.close);
            final stream = mode == 'SSE'
                ? fixture.client.audio.speech.createStream(_request)
                : fixture.client.audio.speech.createByteStream(_request);
            final first = Completer<void>();
            final subscription = stream.listen((_) {
              if (!first.isCompleted) first.complete();
            });
            await sent.future;
            source.add(
              mode == 'SSE'
                  ? utf8.encode('data: ${jsonEncode(_delta)}\n\n')
                  : [0, 1, 255],
            );
            await first.future;
            await subscription.cancel();
            await cancelled.future;
            await source.close();
            expect(fixture.owned.closes, owns ? 1 : 0);
            expect(fixture.borrowed.closes, 0);
            fixture.client.close();
            expect(fixture.borrowed.closes, 0);
          },
        );
      }
      test('$mode midstream abort terminates once without replay', () async {
        final source = StreamController<List<int>>();
        final sent = Completer<void>();
        final abort = Completer<void>();
        final fixture = _Fixture((_) {
          sent.complete();
          return http.StreamedResponse(
            source.stream,
            200,
            headers: {
              'content-type': mode == 'SSE' ? 'text/event-stream' : 'audio/pcm',
            },
          );
        });
        addTearDown(fixture.client.close);
        final first = Completer<void>();
        final stream = mode == 'SSE'
            ? fixture.client.audio.speech.createStream(
                _request,
                abortTrigger: abort.future,
              )
            : fixture.client.audio.speech.createByteStream(
                _request,
                abortTrigger: abort.future,
              );
        final result = stream.map((event) {
          if (!first.isCompleted) first.complete();
          return event;
        }).toList();
        final failure = _errorOf(result);
        await sent.future;
        source.add(
          mode == 'SSE'
              ? utf8.encode('data: ${jsonEncode(_delta)}\n\n')
              : [0, 1, 255],
        );
        await first.future;
        abort.complete();
        expect(await failure, isA<AbortedException>());
        await source.close();
        expect(fixture.owned.sends, 1);
        expect(fixture.owned.closes, 1);
        expect(fixture.borrowed.closes, 0);
      });
      test('$mode transport failure after output never retries', () async {
        final source = StreamController<List<int>>();
        final sent = Completer<void>();
        final fixture = _Fixture(
          (_) {
            sent.complete();
            return http.StreamedResponse(
              source.stream,
              200,
              headers: {
                'content-type': mode == 'SSE'
                    ? 'text/event-stream'
                    : 'audio/pcm',
              },
            );
          },
          retryPolicy: const RetryPolicy(
            maxRetries: 3,
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
            jitter: 0,
          ),
        );
        addTearDown(fixture.client.close);
        final seen = Completer<void>();
        final stream = mode == 'SSE'
            ? fixture.client.audio.speech.createStream(_request)
            : fixture.client.audio.speech.createByteStream(_request);
        final failure = _errorOf(
          stream.map((event) {
            if (!seen.isCompleted) seen.complete();
            return event;
          }).toList(),
        );
        await sent.future;
        source.add(
          mode == 'SSE'
              ? utf8.encode('data: ${jsonEncode(_delta)}\n\n')
              : [0, 1, 255],
        );
        await seen.future;
        source.addError(http.ClientException('fixture transport failure'));
        await failure;
        await source.close();
        expect(fixture.owned.sends, 1);
        expect(fixture.owned.closes, 1);
        expect(fixture.borrowed.closes, 0);
      });
    }

    for (final mode in ['bytes', 'SSE']) {
      test(
        '$mode pending-header cancellation closes ownership immediately',
        () async {
          final deadlines = <Timer>[];
          await runZoned<Future<void>>(
            () async {
              final sent = Completer<void>();
              final response = Completer<http.StreamedResponse>();
              final lateBody = StreamController<List<int>>();
              final lateCancelled = Completer<void>();
              var lateCancellationCount = 0;
              lateBody.onCancel = () {
                lateCancellationCount++;
                if (!lateCancelled.isCompleted) lateCancelled.complete();
              };
              final fixture = _Fixture((_) {
                sent.complete();
                return response.future;
              });
              addTearDown(fixture.client.close);
              final stream = mode == 'SSE'
                  ? fixture.client.audio.speech.createStream(_request)
                  : fixture.client.audio.speech.createByteStream(_request);
              final subscription = stream.listen(
                (_) {},
                onError: (Object _) {},
              );
              await sent.future;
              final cancellation = subscription.cancel();
              try {
                await fixture.owned.closed.future.timeout(
                  const Duration(seconds: 2),
                );
                await cancellation.timeout(const Duration(seconds: 2));
                expect(deadlines, isNotEmpty);
                expect(
                  deadlines.every((timer) => !timer.isActive),
                  isTrue,
                  reason:
                      'Cancel must retire the pending-send timeout before late headers arrive',
                );
                expect(fixture.owned.closes, 1);
                expect(fixture.borrowed.closes, 0);
              } finally {
                response.complete(
                  http.StreamedResponse(
                    lateBody.stream,
                    200,
                    headers: {
                      'content-type': mode == 'SSE'
                          ? 'text/event-stream'
                          : 'audio/pcm',
                    },
                  ),
                );
                await cancellation;
                await lateCancelled.future.timeout(const Duration(seconds: 2));
                await lateBody.close();
              }
              expect(lateCancellationCount, 1);
              expect(fixture.owned.closes, 1);
              expect(fixture.owned.sends, 1);
            },
            zoneSpecification: ZoneSpecification(
              createTimer: (self, parent, zone, duration, callback) {
                final timer = parent.createTimer(zone, duration, callback);
                if (duration == const Duration(minutes: 10)) {
                  deadlines.add(timer);
                }
                return timer;
              },
            ),
          );
        },
      );

      test(
        '$mode pending-header abort emits once and closes ownership',
        () async {
          final sent = Completer<void>();
          final response = Completer<http.StreamedResponse>();
          final abort = Completer<void>();
          final fixture = _Fixture((_) {
            sent.complete();
            return response.future;
          });
          addTearDown(fixture.client.close);
          final stream = mode == 'SSE'
              ? fixture.client.audio.speech.createStream(
                  _request,
                  abortTrigger: abort.future,
                )
              : fixture.client.audio.speech.createByteStream(
                  _request,
                  abortTrigger: abort.future,
                );
          final failure = _errorOf(stream.toList());
          await sent.future;
          abort.complete();
          try {
            expect(
              await failure.timeout(const Duration(seconds: 2)),
              isA<AbortedException>(),
            );
            expect(fixture.owned.closes, 1);
            expect(fixture.borrowed.closes, 0);
          } finally {
            response.complete(
              mode == 'SSE' ? _sseResponse([_done]) : _response(const []),
            );
          }
          expect(fixture.owned.sends, 1);
          expect(fixture.owned.closes, 1);
        },
      );

      test(
        '$mode early transport failure releases owned client without retry',
        () async {
          final fixture = _Fixture(
            (_) => Future<http.StreamedResponse>.error(
              http.ClientException('fixture send failure'),
            ),
            retryPolicy: const RetryPolicy(
              maxRetries: 3,
              initialDelay: Duration.zero,
              maxDelay: Duration.zero,
              jitter: 0,
            ),
          );
          addTearDown(fixture.client.close);
          final stream = mode == 'SSE'
              ? fixture.client.audio.speech.createStream(_request)
              : fixture.client.audio.speech.createByteStream(_request);
          await _errorOf(stream.toList());
          expect(fixture.owned.sends, 1);
          expect(fixture.owned.closes, 1);
          expect(fixture.borrowed.closes, 0);
        },
      );

      test(
        '$mode normal EOF never closes a borrowed injected client',
        () async {
          final fixture = _Fixture(
            (_) => mode == 'SSE'
                ? _sseResponse([_done])
                : _response([
                    [1, 2],
                  ]),
            ownsStream: false,
          );
          await (mode == 'SSE'
                  ? fixture.client.audio.speech.createStream(_request)
                  : fixture.client.audio.speech.createByteStream(_request))
              .drain<void>();
          expect(fixture.borrowed.sends, 1);
          expect(fixture.borrowed.closes, 0);
          expect(fixture.factoryCalls, 0);
          fixture.client.close();
          expect(fixture.borrowed.closes, 0);
        },
      );
    }

    for (final mode in ['bytes', 'SSE']) {
      for (final outcome in [
        'success',
        'HTTP error',
        'source error',
        'cancel',
      ]) {
        test('$mode preserves $outcome when owned close throws', () async {
          final unhandled = await _captureUnhandled(() async {
            final sent = Completer<void>();
            final source = StreamController<List<int>>();
            final original = StateError('original source failure');
            final fixture = _Fixture((_) {
              sent.complete();
              if (outcome == 'success') {
                return mode == 'SSE'
                    ? _sseResponse([_delta, _done])
                    : _response([
                        [0, 1],
                        [255],
                      ]);
              }
              if (outcome == 'HTTP error') {
                return _response(
                  [
                    utf8.encode(
                      '{"error":{"message":"original HTTP failure","code":"fixture_failure"}}',
                    ),
                  ],
                  status: 400,
                  contentType: 'application/json',
                  headers: {'x-request-id': 'req-original-failure'},
                );
              }
              return http.StreamedResponse(
                source.stream,
                200,
                headers: {
                  'content-type': mode == 'SSE'
                      ? 'text/event-stream'
                      : 'audio/pcm',
                },
              );
            }, throwingClose: true);
            try {
              final stream = mode == 'SSE'
                  ? fixture.client.audio.speech.createStream(_request)
                  : fixture.client.audio.speech.createByteStream(_request);
              if (outcome == 'cancel') {
                final first = Completer<void>();
                final subscription = stream.listen((_) {
                  if (!first.isCompleted) first.complete();
                });
                await sent.future;
                source.add(
                  mode == 'SSE'
                      ? utf8.encode('data: ${jsonEncode(_delta)}\n\n')
                      : [0, 1],
                );
                await first.future;
                await subscription.cancel().timeout(const Duration(seconds: 2));
              } else if (outcome == 'source error') {
                final first = Completer<void>();
                final result = stream.map((event) {
                  if (!first.isCompleted) first.complete();
                  return event;
                }).toList();
                final failure = _errorOf(result);
                await sent.future;
                source.add(
                  mode == 'SSE'
                      ? utf8.encode('data: ${jsonEncode(_delta)}\n\n')
                      : [0, 1],
                );
                await first.future;
                source.addError(original);
                expect(
                  await failure.timeout(const Duration(seconds: 2)),
                  same(original),
                );
              } else if (outcome == 'HTTP error') {
                final failure = await _errorOf(
                  stream.toList(),
                ).timeout(const Duration(seconds: 2));
                expect(failure, isA<BadRequestException>());
                final api = failure as ApiException;
                expect(api.message, 'original HTTP failure');
                expect(api.code, 'fixture_failure');
                expect(api.requestId, 'req-original-failure');
              } else {
                final events = await stream.toList().timeout(
                  const Duration(seconds: 2),
                );
                expect(events, hasLength(2));
                if (mode == 'SSE') {
                  expect(events.last, isA<SpeechAudioDoneEvent>());
                }
              }
              expect(fixture.owned.sends, 1);
              expect(fixture.owned.closes, 1);
              expect(fixture.borrowed.closes, 0);
            } finally {
              fixture.client.close();
              if (outcome == 'source error' || outcome == 'cancel') {
                await source.close();
              }
            }
          });
          expect(
            unhandled,
            isEmpty,
            reason:
                'Teardown failure must not escape or replace the caller outcome',
          );
        });
      }
    }

    test(
      'canceling one concurrent byte stream leaves the other usable',
      () async {
        final sources = [
          StreamController<List<int>>(),
          StreamController<List<int>>(),
        ];
        final transports = <_Transport>[];
        final sent = [Completer<void>(), Completer<void>()];
        final borrowed = _Transport(
          (_) => _response([
            [99],
          ]),
        );
        final client = OpenAIClient(
          config: _config(_CountingAuth()),
          httpClient: borrowed,
          streamClientFactory: () {
            final index = transports.length;
            final transport = _Transport((_) {
              sent[index].complete();
              return http.StreamedResponse(sources[index].stream, 200);
            });
            transports.add(transport);
            return transport;
          },
        );
        addTearDown(client.close);
        final first = Completer<void>();
        final subscription = client.audio.speech
            .createByteStream(_request)
            .listen((_) {
              if (!first.isCompleted) first.complete();
            });
        final second = client.audio.speech.createByteStream(_request).toList();
        await Future.wait(sent.map((c) => c.future));
        sources[0].add([1]);
        await first.future;
        await subscription.cancel();
        sources[1].add([2, 3]);
        await sources[1].close();
        expect((await second).expand((bytes) => bytes), [2, 3]);
        await sources[0].close();
        expect(transports.map((t) => t.sends), [1, 1]);
        expect(transports.map((t) => t.closes), [1, 1]);
        expect(borrowed.sends, 0);
        expect(borrowed.closes, 0);
      },
    );
  });
}

void _expectNoDispatch(_Fixture fixture) {
  expect(fixture.auth.calls, 0);
  expect(fixture.factoryCalls, 0);
  expect(fixture.borrowed.sends, 0);
  expect(fixture.owned.sends, 0);
  expect(fixture.owned.closes, 0);
}

Future<Object> _errorOf<T>(Future<T> future) async {
  try {
    await future;
  } catch (error) {
    return error;
  }
  throw StateError('Expected fixture operation to fail.');
}

http.StreamedResponse _response(
  Iterable<List<int>> chunks, {
  int status = 200,
  String contentType = 'application/octet-stream',
  Map<String, String> headers = const {},
}) => http.StreamedResponse(
  Stream.fromIterable(chunks),
  status,
  headers: {'content-type': contentType, ...headers},
);

http.StreamedResponse _sseResponse(List<Map<String, Object?>> events) =>
    _response(
      events.map((event) => utf8.encode('data: ${jsonEncode(event)}\n\n')),
      contentType: 'text/event-stream',
    );

OpenAIConfig _config(
  AuthProvider auth, {
  RetryPolicy retryPolicy = const RetryPolicy(maxRetries: 0),
  Level? logLevel,
  Map<String, String> defaultHeaders = const {
    'x-fixture': 'present',
    'Accept': 'application/json',
  },
}) => OpenAIConfig(
  authProvider: auth,
  baseUrl: 'https://fixture.invalid/proxy/v1',
  organization: 'org-fixture',
  project: 'project-fixture',
  defaultHeaders: defaultHeaders,
  retryPolicy: retryPolicy,
  logLevel: logLevel,
);

class _CountingAuth implements AuthProvider {
  int calls = 0;

  @override
  Map<String, String> getHeaders() {
    calls++;
    return const {'Authorization': 'Bearer fixture-credential'};
  }
}

class _Fixture {
  _Fixture(
    FutureOr<http.StreamedResponse> Function(http.BaseRequest) handler, {
    bool ownsStream = true,
    RetryPolicy retryPolicy = const RetryPolicy(maxRetries: 0),
    Level? logLevel,
    Map<String, String> defaultHeaders = const {
      'x-fixture': 'present',
      'Accept': 'application/json',
    },
    bool throwingClose = false,
    _CountingAuth? authProvider,
  }) : auth = authProvider ?? _CountingAuth() {
    borrowed = _Transport(handler);
    owned = _Transport(
      handler,
      closeError: throwingClose ? StateError('private cleanup failure') : null,
    );
    client = OpenAIClient(
      config: _config(
        auth,
        retryPolicy: retryPolicy,
        logLevel: logLevel,
        defaultHeaders: defaultHeaders,
      ),
      httpClient: borrowed,
      streamClientFactory: ownsStream
          ? () {
              factoryCalls++;
              return owned;
            }
          : null,
    );
  }

  final _CountingAuth auth;
  late final _Transport borrowed;
  late final _Transport owned;
  late final OpenAIClient client;
  int factoryCalls = 0;
}

class _Transport extends http.BaseClient {
  _Transport(this.handler, {this.closeError});

  final Error? closeError;

  final FutureOr<http.StreamedResponse> Function(http.BaseRequest) handler;
  final requests = <http.BaseRequest>[];
  int sends = 0;
  int closes = 0;
  final closed = Completer<void>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sends++;
    requests.add(request);
    return handler(request);
  }

  @override
  void close() {
    closes++;
    if (!closed.isCompleted) closed.complete();
    if (closeError case final error?) throw error;
  }
}

Future<List<LogRecord>> _captureLogs(Future<void> Function() action) async {
  final hierarchy = hierarchicalLoggingEnabled;
  hierarchicalLoggingEnabled = true;
  final level = Logger.root.level;
  final clientLevel = Logger('OpenAIClient').level;
  Logger.root.level = Level.ALL;
  final records = <LogRecord>[];
  final subscription = Logger.root.onRecord.listen(records.add);
  try {
    await action();
  } finally {
    await subscription.cancel();
    Logger.root.level = level;
    Logger('OpenAIClient').level = clientLevel;
    hierarchicalLoggingEnabled = hierarchy;
  }
  return records;
}

class _InvalidVoice implements AudioVoice {
  const _InvalidVoice();

  @override
  Map<String, dynamic> toJson() => {'id': 'voice-fixture', 'extra': true};
}

SpeechRequest _uncheckedRequest({
  String? input,
  String? instructions,
  double? speed,
  AudioVoice? voice,
}) => SpeechRequest(
  model: _request.model,
  input: input ?? _request.input,
  voice: voice ?? _request.voice,
  instructions: instructions,
  speed: speed,
);

Future<List<Object>> _captureUnhandled(Future<void> Function() action) async {
  final errors = <Object>[];
  final finished = Completer<void>();
  unawaited(
    runZonedGuarded<Future<void>>(() async {
      try {
        await action();
        await Future<void>.delayed(Duration.zero);
        finished.complete();
      } catch (error, stackTrace) {
        finished.completeError(error, stackTrace);
      }
    }, (error, stackTrace) => errors.add(error)),
  );
  await finished.future.timeout(const Duration(seconds: 5));
  return errors;
}

class _ConflictingMediaAuth extends _CountingAuth {
  late Map<String, String> lastHeaders;

  @override
  Map<String, String> getHeaders() {
    lastHeaders = {
      ...super.getHeaders(),
      'aCcEpT': 'application/xml',
      'accept': 'text/plain',
      'Content-Type': 'text/plain; charset=unknown-fixture-charset',
      'content-type': 'text/plain; charset=iso-8859-1',
    };
    return lastHeaders;
  }
}
