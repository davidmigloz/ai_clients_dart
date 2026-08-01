import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  TranscriptionRequest request({
    AudioResponseFormat? responseFormat,
    bool? stream,
  }) {
    return TranscriptionRequest(
      file: Uint8List.fromList([1, 2, 3, 4]),
      filename: 'audio.mp3',
      model: 'gpt-4o-transcribe',
      responseFormat: responseFormat,
      stream: stream,
    );
  }

  group('TranscriptionsResource.createStream', () {
    test('forces stream=true and yields typed SSE events', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final deltaLine = jsonEncode({
        'type': 'transcript.text.delta',
        'delta': 'Hello',
      });
      final doneLine = jsonEncode({
        'type': 'transcript.text.done',
        'text': 'Hello world',
        'usage': {
          'type': 'tokens',
          'input_tokens': 3,
          'output_tokens': 6,
          'total_tokens': 9,
        },
      });
      final segmentLine = jsonEncode({
        'type': 'transcript.text.segment',
        'id': 'seg_1',
        'start': 0.0,
        'end': 1.0,
        'text': 'Hello',
        'speaker': 'A',
      });

      final mockClient = MockClient.streaming((req, _) async {
        requestCompleter.complete(req);
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode('data: $segmentLine\n\n'),
            utf8.encode('data: $deltaLine\n\n'),
            utf8.encode('data: $doneLine\n\n'),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final events = await client.audio.transcriptions
          .createStream(request())
          .toList();

      expect(events, hasLength(3));
      expect(events[0], isA<TranscriptTextSegmentEvent>());
      expect(events[1], isA<TranscriptTextDeltaEvent>());
      expect(events[2], isA<TranscriptTextDoneEvent>());
      expect((events[2] as TranscriptTextDoneEvent).usage?.totalTokens, 9);

      final sent = await requestCompleter.future;
      expect(sent, isA<http.MultipartRequest>());
      final multipart = sent as http.MultipartRequest;
      expect(multipart.fields['stream'], 'true');
      expect(multipart.fields['model'], 'gpt-4o-transcribe');
      expect(sent.headers['Accept'], 'text/event-stream');
      // MultipartRequest.finalize() sets the boundary header under the
      // lowercase key.
      expect(sent.headers['content-type'], contains('multipart/form-data'));

      client.close();
    });

    test('forces stream=true even if request.stream was unset', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient.streaming((req, _) async {
        requestCompleter.complete(req);
        return http.StreamedResponse(
          Stream.fromIterable([utf8.encode('data: [DONE]\n\n')]),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.audio.transcriptions.createStream(request()).drain<void>();

      final sent = await requestCompleter.future as http.MultipartRequest;
      expect(sent.fields['stream'], 'true');

      client.close();
    });

    test('surfaces inline SSE error events', () async {
      final mockClient = MockClient.streaming((req, _) async {
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'event: error\ndata: {"error":{"message":"boom","type":"server_error"}}\n\n',
            ),
          ]),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await expectLater(
        client.audio.transcriptions.createStream(request()).toList(),
        throwsA(isA<StreamException>()),
      );

      client.close();
    });

    test('throws eagerly on a closed client (not on listen)', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: MockClient.streaming(
          (_, _) async =>
              http.StreamedResponse(const Stream<List<int>>.empty(), 200),
        ),
      )..close();

      expect(
        () => client.audio.transcriptions.createStream(request()),
        throwsStateError,
      );
    });

    test('accepts abortTrigger parameter (type-signature check)', () {
      void verify(OpenAIClient c) {
        // ignore: unused_local_variable
        final stream = c.audio.transcriptions.createStream(
          request(),
          abortTrigger: Completer<void>().future,
        );
      }

      // Compile-time check only.
      // ignore: unused_local_variable
      final _ = verify;
    });
  });

  group('TranscriptionsResource stream: true rejection', () {
    test('create() throws ArgumentError when request.stream is true', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );
      expect(
        () => client.audio.transcriptions.create(request(stream: true)),
        throwsArgumentError,
      );
      client.close();
    });

    test(
      'createVerbose() throws ArgumentError when request.stream is true',
      () {
        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: MockClient((_) async => http.Response('{}', 200)),
        );
        expect(
          () =>
              client.audio.transcriptions.createVerbose(request(stream: true)),
          throwsArgumentError,
        );
        client.close();
      },
    );

    test(
      'createDiarized() throws ArgumentError when request.stream is true',
      () {
        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: MockClient((_) async => http.Response('{}', 200)),
        );
        expect(
          () =>
              client.audio.transcriptions.createDiarized(request(stream: true)),
          throwsArgumentError,
        );
        client.close();
      },
    );

    test('createRaw() throws ArgumentError when request.stream is true', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: MockClient((_) async => http.Response('ok', 200)),
      );
      expect(
        () => client.audio.transcriptions.createRaw(
          request(responseFormat: AudioResponseFormat.srt, stream: true),
        ),
        throwsArgumentError,
      );
      client.close();
    });
  });

  group('TranscriptionsResource.create response format rejection', () {
    for (final format in [
      AudioResponseFormat.verboseJson,
      AudioResponseFormat.diarizedJson,
      AudioResponseFormat.text,
      AudioResponseFormat.srt,
      AudioResponseFormat.vtt,
    ]) {
      test('create() rejects responseFormat $format', () {
        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: MockClient((_) async => http.Response('{}', 200)),
        );
        expect(
          () => client.audio.transcriptions.create(
            request(responseFormat: format),
          ),
          throwsArgumentError,
        );
        client.close();
      });
    }

    test('create() accepts a null responseFormat', () async {
      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: MockClient(
          (_) async => http.Response('{"text":"hi"}', 200),
        ),
      );
      final response = await client.audio.transcriptions.create(request());
      expect(response.text, 'hi');
      client.close();
    });

    test('create() accepts responseFormat json', () async {
      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: MockClient(
          (_) async => http.Response('{"text":"hi"}', 200),
        ),
      );
      final response = await client.audio.transcriptions.create(
        request(responseFormat: AudioResponseFormat.json),
      );
      expect(response.text, 'hi');
      client.close();
    });
  });

  group('TranscriptionsResource.createDiarized', () {
    test('forces diarized_json and parses the response', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((req) async {
        requestCompleter.complete(req);
        return http.Response(
          '{"task":"transcribe","duration":1.0,"text":"hi",'
          '"segments":[{"type":"transcript.text.segment","id":"s1",'
          '"start":0.0,"end":1.0,"text":"hi","speaker":"A"}]}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final response = await client.audio.transcriptions.createDiarized(
        request(),
      );

      expect(response.segments.single.speaker, 'A');

      final sent = await requestCompleter.future;
      expect(sent.method, 'POST');
      expect(sent.url.path, endsWith('/audio/transcriptions'));
      // MockClient reads the multipart body eagerly, so the handler sees a
      // plain http.Request rather than the original MultipartRequest — use
      // the same scoped body-string match as audio_multipart_fields_test.
      expect(
        (sent as http.Request).body,
        contains('name="response_format"\r\n\r\ndiarized_json\r\n'),
      );

      client.close();
    });
  });

  group('TranscriptionsResource.createRaw', () {
    test('returns the raw response body for srt', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      const srtBody = '1\n00:00:00,000 --> 00:00:01,000\nHello\n\n';
      final mockClient = MockClient((req) async {
        requestCompleter.complete(req);
        return http.Response(srtBody, 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final result = await client.audio.transcriptions.createRaw(
        request(responseFormat: AudioResponseFormat.srt),
      );

      expect(result, srtBody);

      final sent = await requestCompleter.future as http.Request;
      expect(sent.body, contains('name="response_format"\r\n\r\nsrt\r\n'));

      client.close();
    });

    test('rejects formats other than text/srt/vtt', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: MockClient((_) async => http.Response('ok', 200)),
      );
      expect(
        () => client.audio.transcriptions.createRaw(
          request(responseFormat: AudioResponseFormat.json),
        ),
        throwsArgumentError,
      );
      expect(
        () => client.audio.transcriptions.createRaw(request()),
        throwsArgumentError,
      );
      client.close();
    });
  });
}
