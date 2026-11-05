import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

const _deadline = Duration(seconds: 2);
const _speech = SpeechRequest(model: 'phonon', input: 'Hello');

class _StreamClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest) handle;
  int closeCount = 0;
  _StreamClient(this.handle);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      handle(request);

  @override
  void close() => closeCount++;
}

class _DelayedAuth implements AuthProvider {
  final started = Completer<void>();
  final credentials = Completer<AuthCredentials>();

  @override
  Future<AuthCredentials> getCredentials() {
    started.complete();
    return credentials.future;
  }
}

void main() {
  OllamaClient clientFor(http.Client transport, {OllamaConfig? config}) {
    final client = OllamaClient(
      httpClient: transport,
      config:
          config ?? const OllamaConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
    );
    addTearDown(client.close);
    return client;
  }

  test(
    'speech preserves binary response, proxy URL, auth and JSON fields',
    () async {
      final bytes = [82, 73, 70, 70, 0, 255, 128, 254];
      final client = clientFor(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/proxy/v1/audio/speech');
          expect(request.url.queryParametersAll['token'], ['a', 'b']);
          expect(request.headers['authorization'], 'Bearer test-key');
          expect(request.headers['x-request-id'], isNotEmpty);
          expect(
            request.headers['content-type'],
            startsWith('application/json'),
          );
          expect(request.headers['accept'], '*/*');
          expect(jsonDecode(request.body), {
            'model': 'phonon',
            'input': 'Hello',
          });
          return http.Response.bytes(
            bytes,
            200,
            headers: {'content-type': 'audio/wav'},
          );
        }),
        config: const OllamaConfig(
          baseUrl: 'http://localhost:11434/proxy/?token=a&token=b',
          authProvider: BearerTokenProvider('test-key'),
          sendRequestIdHeader: true,
        ),
      );
      expect(await client.audio.createSpeech(request: _speech), bytes);
    },
  );

  for (final status in [400, 401, 429]) {
    test('speech maps OpenAI error envelope with status $status', () async {
      final client = clientFor(
        MockClient(
          (_) async => http.Response(
            '{"error":{"message":"speech failed","type":"invalid_request_error","code":$status}}',
            status,
          ),
        ),
      );
      final matcher = status == 401
          ? isA<AuthenticationException>()
          : status == 429
          ? isA<RateLimitException>()
          : isA<ApiException>();
      await expectLater(
        client.audio.createSpeech(request: _speech),
        throwsA(matcher.having((e) => e.message, 'message', 'speech failed')),
      );
      await expectLater(
        client.audio.createSpeechStream(request: _speech).toList(),
        throwsA(matcher.having((e) => e.message, 'message', 'speech failed')),
      );
    });
  }

  test(
    'speech streaming delivers first binary chunk before completion',
    () async {
      final body = StreamController<List<int>>();
      final first = Completer<List<int>>();
      final client = clientFor(
        _StreamClient((request) async {
          expect(request.url.path, '/v1/audio/speech');
          expect(request.headers['authorization'], 'Bearer key');
          return http.StreamedResponse(body.stream, 200);
        }),
        config: const OllamaConfig(authProvider: BearerTokenProvider('key')),
      );
      final result = client.audio.createSpeechStream(request: _speech).map((
        chunk,
      ) {
        if (!first.isCompleted) first.complete(chunk);
        return chunk;
      }).toList();
      body.add([0, 255, 128]);
      expect(await first.future.timeout(_deadline), [0, 255, 128]);
      body.add([254, 13]);
      await body.close();
      expect(await result, [
        [0, 255, 128],
        [254, 13],
      ]);
    },
  );

  for (final translation in [false, true]) {
    test(
      '${translation ? 'translation' : 'transcription'} sends binary multipart and preserves metadata',
      () async {
        final audio = AudioFile(
          bytes: const [0, 255, 128, 254],
          filename: 'voice.wav',
        );
        final client = clientFor(
          MockClient((request) async {
            expect(
              request.url.path,
              '/v1/audio/${translation ? 'translations' : 'transcriptions'}',
            );
            expect(
              request.headers['content-type'],
              startsWith('multipart/form-data; boundary='),
            );
            expect(request.headers['authorization'], 'Bearer key');
            final body = latin1.decode(request.bodyBytes);
            expect(body, contains('name="file"; filename="voice.wav"'));
            expect(body, contains(latin1.decode(audio.bytes)));
            expect(body, contains('name="stream"\r\n\r\nfalse'));
            expect(body, contains('name="language"\r\n\r\nfr'));
            expect(
              body,
              contains('name="response_format"\r\n\r\nverbose_json'),
            );
            if (translation) {
              expect(body, contains('name="to_language"\r\n\r\nde'));
            }
            return http.Response(
              '{"task":"${translation ? 'translate' : 'transcribe'}","language":"german","duration":2,"text":"Hallo","segments":[{"id":0,"start":0,"end":2,"text":"Hallo"}]}',
              200,
            );
          }),
          config: const OllamaConfig(authProvider: BearerTokenProvider('key')),
        );
        final response = translation
            ? await client.audio.createTranslation(
                request: TranslationRequest(
                  model: 'audio',
                  file: audio,
                  language: 'fr',
                  toLanguage: 'de',
                  responseFormat: AudioTextResponseFormat.verboseJson,
                  stream: true,
                ),
              )
            : await client.audio.createTranscription(
                request: TranscriptionRequest(
                  model: 'audio',
                  file: audio,
                  language: 'fr',
                  responseFormat: AudioTextResponseFormat.verboseJson,
                  stream: true,
                ),
              );
        expect(response.text, 'Hallo');
        expect(response.duration, 2);
        expect(response.segments!.single.end, 2);
      },
    );
  }

  test(
    'multipart defaults are omitted and UTF-8 text response is decoded',
    () async {
      final client = clientFor(
        MockClient((request) async {
          final body = latin1.decode(request.bodyBytes);
          expect(body, isNot(contains('name="language"')));
          expect(body, isNot(contains('name="to_language"')));
          expect(body, isNot(contains('name="temperature"')));
          return http.Response.bytes(
            utf8.encode('Café 中文'),
            200,
            headers: {'content-type': 'text/plain'},
          );
        }),
      );
      final response = await client.audio.createTranscription(
        request: TranscriptionRequest(
          model: 'audio',
          file: AudioFile(bytes: const [0]),
          responseFormat: AudioTextResponseFormat.text,
        ),
      );
      expect(response.text, 'Café 中文');
      expect(response.segments, isNull);
    },
  );

  test(
    'multipart body survives authentication, request ID and retry',
    () async {
      var attempts = 0;
      List<int>? firstBody;
      final client = clientFor(
        MockClient((request) async {
          attempts++;
          firstBody ??= request.bodyBytes;
          expect(request.bodyBytes, firstBody);
          expect(request.headers['x-request-id'], isNotEmpty);
          expect(request.headers['authorization'], 'Bearer key');
          return http.Response(
            attempts == 1 ? '' : '{"text":"Hello"}',
            attempts == 1 ? 429 : 200,
          );
        }),
        config: const OllamaConfig(
          authProvider: BearerTokenProvider('key'),
          sendRequestIdHeader: true,
          retryPolicy: RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
            jitter: 0,
          ),
        ),
      );
      expect(
        (await client.audio.createTranscription(
          request: TranscriptionRequest(
            model: 'audio',
            file: AudioFile(bytes: const [0, 255, 128]),
          ),
        )).text,
        'Hello',
      );
      expect(attempts, 2);
    },
  );

  for (final translation in [false, true]) {
    test(
      'SSE ${translation ? 'translation' : 'transcription'} preserves fragmented Unicode and multiline data',
      () async {
        final wire = utf8.encode(
          ': keepalive\r\n\r\ndata: {"type":"transcript.text.delta",\r\ndata: "delta":"Café"}\r\n\r\ndata: {"type":"transcript.text.done","text":"Café"}\r\n\r\n',
        );
        final client = clientFor(
          _StreamClient((request) async {
            final body = latin1.decode(await request.finalize().toBytes());
            expect(body, contains('name="stream"\r\n\r\ntrue'));
            expect(request.headers['accept'], 'text/event-stream');
            return http.StreamedResponse(
              Stream.fromIterable(wire.map((byte) => [byte])),
              200,
            );
          }),
        );
        final file = AudioFile(bytes: const [0, 255]);
        final stream = translation
            ? client.audio.createTranslationStream(
                request: TranslationRequest(model: 'audio', file: file),
              )
            : client.audio.createTranscriptionStream(
                request: TranscriptionRequest(model: 'audio', file: file),
              );
        expect(await stream.toList(), [
          const TranscriptTextDelta(delta: 'Café'),
          const TranscriptTextDone(text: 'Café'),
        ]);
      },
    );
  }

  test('SSE final event without trailing separator is flushed', () async {
    final client = clientFor(
      _StreamClient(
        (_) async => http.StreamedResponse(
          Stream.value(
            utf8.encode('data: {"type":"transcript.text.done","text":"Hello"}'),
          ),
          200,
        ),
      ),
    );
    expect(
      await client.audio
          .createTranscriptionStream(
            request: TranscriptionRequest(
              model: 'audio',
              file: AudioFile(bytes: const [0]),
            ),
          )
          .toList(),
      [const TranscriptTextDone(text: 'Hello')],
    );
  });

  test(
    'inline SSE errors terminate the stream and preserve their message',
    () async {
      final client = clientFor(
        _StreamClient(
          (_) async => http.StreamedResponse(
            Stream.value(
              utf8.encode(
                'data: {"error":{"message":"transcription failed","code":500}}\n\n',
              ),
            ),
            200,
          ),
        ),
      );
      await expectLater(
        client.audio
            .createTranscriptionStream(
              request: TranscriptionRequest(
                model: 'audio',
                file: AudioFile(bytes: const [0]),
              ),
            )
            .toList(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.message,
            'message',
            'transcription failed',
          ),
        ),
      );
    },
  );

  for (final transcription in [false, true]) {
    test(
      '${transcription ? 'SSE' : 'speech'} cancel reaches stalled transport without closing borrowed client',
      () async {
        final sent = Completer<http.BaseRequest>();
        final response = Completer<http.StreamedResponse>();
        final canceled = Completer<void>();
        final body = StreamController<List<int>>(onCancel: canceled.complete);
        final transport = _StreamClient((request) {
          sent.complete(request);
          return response.future;
        });
        final client = clientFor(transport);
        final stream = transcription
            ? client.audio.createTranscriptionStream(
                request: TranscriptionRequest(
                  model: 'audio',
                  file: AudioFile(bytes: const [0]),
                ),
              )
            : client.audio.createSpeechStream(request: _speech);
        final subscription = stream.listen((_) {});
        final request = await sent.future;
        await subscription.cancel().timeout(_deadline);
        await (request as http.Abortable).abortTrigger!.timeout(_deadline);
        response.complete(http.StreamedResponse(body.stream, 200));
        await canceled.future.timeout(_deadline);
        await body.close();
        expect(transport.closeCount, 0);
      },
    );

    test(
      '${transcription ? 'SSE' : 'speech'} abort during stalled response releases body',
      () async {
        final started = Completer<void>();
        final canceled = Completer<void>();
        final body = StreamController<List<int>>(
          onListen: started.complete,
          onCancel: canceled.complete,
        );
        final abort = Completer<void>();
        final client = clientFor(
          _StreamClient((_) async => http.StreamedResponse(body.stream, 200)),
        );
        final stream = transcription
            ? client.audio.createTranscriptionStream(
                request: TranscriptionRequest(
                  model: 'audio',
                  file: AudioFile(bytes: const [0]),
                ),
                abortTrigger: abort.future,
              )
            : client.audio.createSpeechStream(
                request: _speech,
                abortTrigger: abort.future,
              );
        final result = stream.toList();
        final check = expectLater(result, throwsA(isA<AbortedException>()));
        await started.future.timeout(_deadline);
        abort.complete();
        await check.timeout(_deadline);
        await canceled.future.timeout(_deadline);
        await body.close();
      },
    );
  }

  test(
    'speech abort while credentials are pending prevents transport request',
    () async {
      final auth = _DelayedAuth();
      final abort = Completer<void>();
      final client = clientFor(
        MockClient((_) async => fail('Unexpected request')),
        config: OllamaConfig(authProvider: auth),
      );
      final check = expectLater(
        client.audio
            .createSpeechStream(request: _speech, abortTrigger: abort.future)
            .toList(),
        throwsA(isA<AbortedException>()),
      );
      await auth.started.future;
      abort.complete();
      await check.timeout(_deadline);
      auth.credentials.complete(const BearerTokenCredentials('key'));
    },
  );

  test('SSE done event releases an otherwise idle response body', () async {
    final started = Completer<void>();
    final canceled = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: started.complete,
      onCancel: canceled.complete,
    );
    final client = clientFor(
      _StreamClient((_) async => http.StreamedResponse(body.stream, 200)),
    );
    final result = client.audio
        .createTranscriptionStream(
          request: TranscriptionRequest(
            model: 'audio',
            file: AudioFile(bytes: const [0]),
          ),
        )
        .toList();
    await started.future.timeout(_deadline);
    body.add(
      utf8.encode('data: {"type":"transcript.text.done","text":"Hello"}\n\n'),
    );
    expect(await result.timeout(_deadline), [
      const TranscriptTextDone(text: 'Hello'),
    ]);
    await canceled.future.timeout(_deadline);
    await body.close();
  });

  test('buffered speech forwards the abort trigger to the transport', () async {
    final abort = Completer<void>();
    final sent = Completer<void>();
    final client = clientFor(
      _StreamClient((request) async {
        sent.complete();
        await (request as http.Abortable).abortTrigger;
        throw http.RequestAbortedException(request.url);
      }),
    );
    final check = expectLater(
      client.audio.createSpeech(request: _speech, abortTrigger: abort.future),
      throwsA(isA<AbortedException>()),
    );
    await sent.future;
    abort.complete();
    await check.timeout(_deadline);
  });

  test('closed client rejects buffered and streaming audio methods', () async {
    final client = clientFor(
      MockClient((_) async => fail('Unexpected request')),
    )..close();
    await expectLater(
      client.audio.createSpeech(request: _speech),
      throwsStateError,
    );
    expect(
      () => client.audio.createSpeechStream(request: _speech),
      throwsStateError,
    );
    final request = TranscriptionRequest(
      model: 'audio',
      file: AudioFile(bytes: const [0]),
    );
    await expectLater(
      client.audio.createTranscription(request: request),
      throwsStateError,
    );
    expect(
      () => client.audio.createTranscriptionStream(request: request),
      throwsStateError,
    );
  });
}
