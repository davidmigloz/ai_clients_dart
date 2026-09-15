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
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    String capturedBody() => utf8.decode(captured.bodyBytes);

    int partCount(String name) =>
        RegExp('name="$name"').allMatches(capturedBody()).length;

    const transcription = '{"object":"transcription","text":"hello world"}';

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

      final body = capturedBody();
      expect(body, contains('name="file"; filename="clip.wav"'));
      expect(body, contains('name="model"\r\n\r\nvoxtral-mini-latest'));
      expect(body, contains('name="language"\r\n\r\nen'));
      expect(body, contains('name="temperature"\r\n\r\n0.2'));
      expect(body, contains('name="diarize"\r\n\r\ntrue'));
      expect(partCount('timestamp_granularities'), 2);
      expect(partCount('context_bias'), 2);
      expect(body, contains('Mistral'));
      expect(body, contains('Voxtral'));
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
          'data: {"type":"text_delta","text":"hel"}\n\n'
          'data: {"type":"text_delta","text":"lo"}\n\n'
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
      expect(capturedBody(), contains('name="stream"\r\n\r\ntrue'));
      expect(capturedBody(), contains('name="file"; filename="clip.wav"'));
    });
  });
}
