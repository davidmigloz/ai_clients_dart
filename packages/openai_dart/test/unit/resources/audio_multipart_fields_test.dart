import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Audio Multipart Fields', () {
    test(
      'timestamp_granularities are sent as bracket-repeated fields',
      () async {
        String? requestBody;

        final mockClient = MockClient((request) async {
          // Capture the raw request body to analyze its multipart structure
          requestBody = request.body;
          return http.Response(
            '{"task":"transcribe","language":"en","duration":1.0,"text":"Hello",'
            '"words":[{"word":"Hello","start":0.0,"end":0.5}],'
            '"segments":[{"id":0,"seek":0,"start":0.0,"end":1.0,'
            '"text":"Hello","tokens":[],"temperature":0.0,"avg_logprob":0.0,'
            '"compression_ratio":0.0,"no_speech_prob":0.0}]}',
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        await client.audio.transcriptions.createVerbose(
          TranscriptionRequest(
            file: Uint8List.fromList([1, 2, 3, 4]),
            filename: 'audio.mp3',
            model: 'whisper-1',
            timestampGranularities: const [
              TimestampGranularity.word,
              TimestampGranularity.segment,
            ],
          ),
        );

        expect(requestBody, isNotNull);

        // OpenAI's documented wire format for array parameters is the same
        // key repeated with a `[]` suffix (no index), per the `qs`-style
        // convention used by openai-python's multipart serializer:
        // Content-Disposition: form-data; name="timestamp_granularities[]"
        // (note: no filename attribute - that's what makes it a field, not a
        // file, even though it's sent via MultipartFile.fromString).
        expect(
          requestBody,
          contains('name="timestamp_granularities[]"\r\n\r\nword\r\n'),
        );
        expect(
          requestBody,
          contains('name="timestamp_granularities[]"\r\n\r\nsegment\r\n'),
        );

        // Verify the old indexed format is gone.
        expect(requestBody, isNot(contains('timestamp_granularities[0]')));
        expect(requestBody, isNot(contains('timestamp_granularities[1]')));

        // Verify they are NOT sent as file parts (file parts have a filename
        // attribute in their Content-Disposition header).
        expect(
          requestBody,
          isNot(contains('name="timestamp_granularities[]"; filename=')),
          reason:
              'Granularities should not be sent as file parts with filename',
        );

        client.close();
      },
    );

    test('transcription without granularities works correctly', () async {
      String? requestBody;

      final mockClient = MockClient((request) async {
        requestBody = request.body;
        return http.Response('{"text":"Hello"}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.audio.transcriptions.create(
        TranscriptionRequest(
          file: Uint8List.fromList([1, 2, 3, 4]),
          filename: 'audio.mp3',
          model: 'whisper-1',
        ),
      );

      expect(requestBody, isNotNull);

      // Verify no timestamp_granularities fields
      expect(requestBody, isNot(contains('timestamp_granularities')));

      client.close();
    });

    test('single granularity is sent correctly', () async {
      String? requestBody;

      final mockClient = MockClient((request) async {
        requestBody = request.body;
        return http.Response(
          '{"task":"transcribe","language":"en","duration":1.0,"text":"Hello",'
          '"words":[{"word":"Hello","start":0.0,"end":0.5}]}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.audio.transcriptions.createVerbose(
        TranscriptionRequest(
          file: Uint8List.fromList([1, 2, 3, 4]),
          filename: 'audio.mp3',
          model: 'whisper-1',
          timestampGranularities: const [TimestampGranularity.word],
        ),
      );

      expect(requestBody, isNotNull);

      // Verify single granularity is sent as a bracket-repeated field.
      expect(
        requestBody,
        contains('name="timestamp_granularities[]"\r\n\r\nword\r\n'),
      );

      // Only one occurrence.
      expect('timestamp_granularities[]'.allMatches(requestBody!).length, 1);

      client.close();
    });

    test('keywords are sent as bracket-repeated fields', () async {
      String? requestBody;

      final mockClient = MockClient((request) async {
        requestBody = request.body;
        return http.Response('{"text":"Hello"}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.audio.transcriptions.create(
        TranscriptionRequest(
          file: Uint8List.fromList([1, 2, 3, 4]),
          filename: 'audio.mp3',
          model: 'gpt-4o-transcribe',
          keywords: const ['openai', 'dart'],
        ),
      );

      expect(requestBody, contains('name="keywords[]"\r\n\r\nopenai\r\n'));
      expect(requestBody, contains('name="keywords[]"\r\n\r\ndart\r\n'));

      client.close();
    });

    test('languages are sent as bracket-repeated fields', () async {
      String? requestBody;

      final mockClient = MockClient((request) async {
        requestBody = request.body;
        return http.Response('{"text":"Hello"}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.audio.transcriptions.create(
        TranscriptionRequest(
          file: Uint8List.fromList([1, 2, 3, 4]),
          filename: 'audio.mp3',
          model: 'gpt-4o-transcribe',
          languages: const ['en', 'es'],
        ),
      );

      expect(requestBody, contains('name="languages[]"\r\n\r\nen\r\n'));
      expect(requestBody, contains('name="languages[]"\r\n\r\nes\r\n'));

      client.close();
    });

    test('include is sent as bracket-repeated fields', () async {
      String? requestBody;

      final mockClient = MockClient((request) async {
        requestBody = request.body;
        return http.Response('{"text":"Hello"}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.audio.transcriptions.create(
        TranscriptionRequest(
          file: Uint8List.fromList([1, 2, 3, 4]),
          filename: 'audio.mp3',
          model: 'gpt-4o-transcribe',
          include: const [TranscriptionInclude.logprobs],
        ),
      );

      expect(requestBody, contains('name="include[]"\r\n\r\nlogprobs\r\n'));

      client.close();
    });

    test(
      'known speaker names/references are sent as bracket-repeated fields',
      () async {
        String? requestBody;

        final mockClient = MockClient((request) async {
          requestBody = request.body;
          return http.Response(
            '{"task":"transcribe","duration":1.0,"text":"Hi","segments":[]}',
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        await client.audio.transcriptions.createDiarized(
          TranscriptionRequest(
            file: Uint8List.fromList([1, 2, 3, 4]),
            filename: 'call.mp3',
            model: 'gpt-4o-transcribe-diarize',
            knownSpeakerNames: const ['agent', 'customer'],
            knownSpeakerReferences: const [
              'data:audio/wav;base64,AAAA',
              'data:audio/wav;base64,BBBB',
            ],
          ),
        );

        expect(
          requestBody,
          contains('name="known_speaker_names[]"\r\n\r\nagent\r\n'),
        );
        expect(
          requestBody,
          contains('name="known_speaker_names[]"\r\n\r\ncustomer\r\n'),
        );
        expect(
          requestBody,
          contains(
            'name="known_speaker_references[]"\r\n\r\ndata:audio/wav;base64,AAAA\r\n',
          ),
        );
        expect(
          requestBody,
          contains(
            'name="known_speaker_references[]"\r\n\r\ndata:audio/wav;base64,BBBB\r\n',
          ),
        );

        client.close();
      },
    );

    test('chunking_strategy auto is sent as a single plain field', () async {
      String? requestBody;

      final mockClient = MockClient((request) async {
        requestBody = request.body;
        return http.Response('{"text":"Hello"}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.audio.transcriptions.create(
        TranscriptionRequest(
          file: Uint8List.fromList([1, 2, 3, 4]),
          filename: 'audio.mp3',
          model: 'gpt-4o-transcribe',
          chunkingStrategy: const TranscriptionChunkingStrategy.auto(),
        ),
      );

      expect(requestBody, contains('name="chunking_strategy"\r\n\r\nauto\r\n'));
      expect(requestBody, isNot(contains('chunking_strategy[')));

      client.close();
    });

    test(
      'chunking_strategy server_vad is sent as bracket-per-property fields',
      () async {
        String? requestBody;

        final mockClient = MockClient((request) async {
          requestBody = request.body;
          return http.Response('{"text":"Hello"}', 200);
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        await client.audio.transcriptions.create(
          TranscriptionRequest(
            file: Uint8List.fromList([1, 2, 3, 4]),
            filename: 'audio.mp3',
            model: 'gpt-4o-transcribe',
            chunkingStrategy: const TranscriptionChunkingStrategy.serverVad(
              TranscriptionVadConfig(
                prefixPaddingMs: 250,
                silenceDurationMs: 150,
                threshold: 0.6,
              ),
            ),
          ),
        );

        expect(
          requestBody,
          contains('name="chunking_strategy[type]"\r\n\r\nserver_vad\r\n'),
        );
        expect(
          requestBody,
          contains(
            'name="chunking_strategy[prefix_padding_ms]"\r\n\r\n250\r\n',
          ),
        );
        expect(
          requestBody,
          contains(
            'name="chunking_strategy[silence_duration_ms]"\r\n\r\n150\r\n',
          ),
        );
        expect(
          requestBody,
          contains('name="chunking_strategy[threshold]"\r\n\r\n0.6\r\n'),
        );
        expect(requestBody, isNot(contains('name="chunking_strategy"\r\n')));

        client.close();
      },
    );

    test('chunking_strategy server_vad omits unset optional fields', () async {
      String? requestBody;

      final mockClient = MockClient((request) async {
        requestBody = request.body;
        return http.Response('{"text":"Hello"}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.audio.transcriptions.create(
        TranscriptionRequest(
          file: Uint8List.fromList([1, 2, 3, 4]),
          filename: 'audio.mp3',
          model: 'gpt-4o-transcribe',
          chunkingStrategy: const TranscriptionChunkingStrategy.serverVad(
            TranscriptionVadConfig(),
          ),
        ),
      );

      expect(
        requestBody,
        contains('name="chunking_strategy[type]"\r\n\r\nserver_vad\r\n'),
      );
      expect(
        requestBody,
        isNot(contains('chunking_strategy[prefix_padding_ms]')),
      );
      expect(
        requestBody,
        isNot(contains('chunking_strategy[silence_duration_ms]')),
      );
      expect(requestBody, isNot(contains('chunking_strategy[threshold]')));

      client.close();
    });
  });
}
