@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TranscriptionsResource', () {
    late http.Request captured;

    MistralClient clientReturning(
      String body, {
      Map<String, String> headers = const {'content-type': 'application/json'},
    }) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(body, 200, headers: headers);
      });
      addTearDown(mockClient.close);
      return MistralClient(
        config: const MistralConfig(
          authProvider: ApiKeyProvider('test-key'),
          defaultHeaders: {'accept': '*/*'},
        ),
        httpClient: mockClient,
      );
    }

    String capturedBody() => utf8.decode(captured.bodyBytes);

    int partCount(String name) =>
        RegExp('name="$name"').allMatches(capturedBody()).length;

    const transcription = '{"object":"transcription","text":"hello world"}';

    for (final (name, source) in const [
      ('file ID', TranscriptionRequest(file: 'file-123')),
      ('URL', TranscriptionRequest(fileUrl: 'https://example.com/audio.mp3')),
      (
        'bytes',
        TranscriptionRequest(fileBytes: [0, 128, 255], fileName: 'clip.wav'),
      ),
    ]) {
      test('create retries a rate-limited request using $name', () async {
        final attempts = <http.Request>[];
        final mockClient = MockClient((request) async {
          attempts.add(request);
          if (attempts.length == 1) {
            return http.Response('{"message":"rate limited"}', 429);
          }
          return http.Response(transcription, 200);
        });
        addTearDown(mockClient.close);
        final client = MistralClient(
          config: const MistralConfig(
            authProvider: ApiKeyProvider('test-key'),
            retryPolicy: RetryPolicy(
              maxRetries: 1,
              initialDelay: Duration.zero,
              maxDelay: Duration.zero,
              jitter: 0,
            ),
          ),
          httpClient: mockClient,
        );
        addTearDown(client.close);

        final response = await client.audio.transcriptions.create(
          request: source.copyWith(contextBias: ['Mistral', 'Voxtral']),
        );

        expect(response.text, 'hello world');
        expect(attempts, hasLength(2));
        for (final attempt in attempts) {
          expect(attempt.headers['authorization'], 'Bearer test-key');
          expect(attempt.headers['x-request-id'], isNotEmpty);
          expect(
            attempt.headers['x-request-id'],
            attempts.first.headers['x-request-id'],
          );
          final boundary = attempt.headers['content-type']!.split(
            'boundary=',
          )[1];
          final body = latin1.decode(attempt.bodyBytes);
          expect(body, startsWith('--$boundary\r\n'));
          expect(body, endsWith('--$boundary--\r\n'));
          expect(RegExp('name="context_bias"').allMatches(body), hasLength(2));
          if (source.fileBytes != null) {
            expect(body, contains('name="file"; filename="clip.wav"'));
            expect(body, contains(latin1.decode(source.fileBytes!)));
          } else if (source.file != null) {
            expect(body, contains('name="file_id"\r\n\r\n${source.file}\r\n'));
          } else {
            expect(
              body,
              contains('name="file_url"\r\n\r\n${source.fileUrl}\r\n'),
            );
          }
        }
      });
    }

    for (final (status, maxRetries, expectedAttempts) in const [
      (429, 0, 1),
      (429, 2, 3),
      (500, 2, 1),
    ]) {
      test(
        'create respects retry policy ($status, $maxRetries retries)',
        () async {
          var attempts = 0;
          final mockClient = MockClient((request) async {
            attempts++;
            return http.Response('{"message":"failed"}', status);
          });
          addTearDown(mockClient.close);
          final client = MistralClient(
            config: MistralConfig(
              retryPolicy: RetryPolicy(
                maxRetries: maxRetries,
                initialDelay: Duration.zero,
                maxDelay: Duration.zero,
                jitter: 0,
              ),
            ),
            httpClient: mockClient,
          );
          addTearDown(client.close);

          await expectLater(
            client.audio.transcriptions.create(
              request: const TranscriptionRequest(
                fileBytes: [0, 128, 255],
                fileName: 'clip.wav',
              ),
            ),
            throwsA(
              status == 429 ? isA<RateLimitException>() : isA<ApiException>(),
            ),
          );
          expect(attempts, expectedAttempts);
        },
      );
    }

    test('create sends audio bytes as a multipart file part', () async {
      final client = clientReturning(transcription);
      addTearDown(client.close);

      final response = await client.audio.transcriptions.create(
        request: const TranscriptionRequest(
          model: 'voxtral-mini-latest',
          fileBytes: [1, 2, 3],
          fileName: 'clip.wav',
          language: 'en',
          temperature: 0.2,
          diarize: true,
          timestampGranularities: true,
          contextBias: ['Mistral', 'Voxtral'],
        ),
      );

      expect(response.text, 'hello world');
      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/audio/transcriptions');
      expect(
        captured.headers['content-type'],
        startsWith('multipart/form-data; boundary='),
      );
      expect(captured.headers['Authorization'], 'Bearer test-key');
      expect(captured.headers['accept'], 'application/json');

      final body = capturedBody();
      expect(body, contains('name="file"; filename="clip.wav"'));
      expect(body, contains('name="model"\r\n\r\nvoxtral-mini-latest'));
      expect(body, contains('name="language"\r\n\r\nen'));
      expect(body, contains('name="temperature"\r\n\r\n0.2'));
      expect(body, contains('name="diarize"\r\n\r\ntrue'));
      expect(partCount('timestamp_granularities'), 2);
      expect(
        body,
        contains('name="timestamp_granularities"\r\n\r\nsegment\r\n'),
      );
      expect(body, contains('name="timestamp_granularities"\r\n\r\nword\r\n'));
      expect(partCount('context_bias'), 2);
      expect(body, contains('name="context_bias"\r\n\r\nMistral\r\n'));
      expect(body, contains('name="context_bias"\r\n\r\nVoxtral\r\n'));
      expect(partCount('file_id'), 0);
      expect(partCount('file_url'), 0);
      expect(partCount('stream'), 0);
    });

    test('create sends an uploaded file ID as the file_id field', () async {
      final client = clientReturning(transcription);
      addTearDown(client.close);

      await client.audio.transcriptions.create(
        request: const TranscriptionRequest(
          model: 'voxtral-mini-latest',
          file: 'file-123',
        ),
      );

      expect(capturedBody(), contains('name="file_id"\r\n\r\nfile-123'));
      expect(partCount('file'), 0);
    });

    test('create sends a URL as the file_url field', () async {
      final client = clientReturning(transcription);
      addTearDown(client.close);

      await client.audio.transcriptions.create(
        request: const TranscriptionRequest(
          model: 'voxtral-mini-latest',
          fileUrl: 'https://example.com/audio.mp3',
        ),
      );

      expect(
        capturedBody(),
        contains('name="file_url"\r\n\r\nhttps://example.com/audio.mp3'),
      );
    });

    test('create rejects a request without an audio source', () async {
      final client = clientReturning(transcription);
      addTearDown(client.close);

      await expectLater(
        client.audio.transcriptions.create(
          request: const TranscriptionRequest(model: 'voxtral-mini-latest'),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('create rejects a request with several audio sources', () async {
      final client = clientReturning(transcription);
      addTearDown(client.close);

      await expectLater(
        client.audio.transcriptions.create(
          request: const TranscriptionRequest(
            model: 'voxtral-mini-latest',
            file: 'file-123',
            fileUrl: 'https://example.com/audio.mp3',
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('create rejects bytes without a file name', () async {
      final client = clientReturning(transcription);
      addTearDown(client.close);

      await expectLater(
        client.audio.transcriptions.create(
          request: const TranscriptionRequest(
            model: 'voxtral-mini-latest',
            fileBytes: [1, 2, 3],
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('createStream sends stream=true and parses SSE events', () async {
      const sse =
          'data: {"type":"transcription.text.delta","text":"hel"}\n\n'
          'data: {"type":"transcription.text.delta","text":"lo"}\n\n'
          'data: [DONE]\n\n';
      final client = clientReturning(
        sse,
        headers: const {'content-type': 'text/event-stream'},
      );
      addTearDown(client.close);

      final events = await client.audio.transcriptions
          .createStream(
            request: const TranscriptionRequest(
              model: 'voxtral-mini-latest',
              fileBytes: [1, 2, 3],
              fileName: 'clip.wav',
            ),
          )
          .toList();

      expect(events.map((event) => event.text), ['hel', 'lo']);
      expect(
        captured.headers['content-type'],
        startsWith('multipart/form-data; boundary='),
      );
      expect(captured.headers['Authorization'], 'Bearer test-key');
      expect(captured.headers.containsKey('X-Request-ID'), isTrue);
      expect(captured.headers['accept'], 'text/event-stream');
      expect(capturedBody(), contains('name="stream"\r\n\r\ntrue'));
      expect(capturedBody(), contains('name="file"; filename="clip.wav"'));
    });
  });
}
