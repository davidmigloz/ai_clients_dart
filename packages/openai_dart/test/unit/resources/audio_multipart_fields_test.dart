import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Audio Multipart Fields', () {
    test('timestamp_granularities are sent as form fields not file parts', () async {
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
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
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

      // Verify timestamp_granularities fields are present with indexed keys
      // In multipart form data, fields appear as:
      // Content-Disposition: form-data; name="timestamp_granularities[0]"
      // (note: no filename attribute - that's what makes it a field, not a file)
      expect(requestBody, contains('name="timestamp_granularities[0]"'));
      expect(requestBody, contains('name="timestamp_granularities[1]"'));
      expect(requestBody, contains('\r\nword\r\n'));
      expect(requestBody, contains('\r\nsegment\r\n'));

      // Verify they are NOT sent as file parts (file parts have filename attribute)
      // Old incorrect format: Content-Disposition: form-data; name="timestamp_granularities[]"; filename="..."
      expect(
        requestBody,
        isNot(contains('name="timestamp_granularities[]"; filename=')),
        reason: 'Granularities should not be sent as file parts with filename',
      );

      client.close();
    });

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

      // Verify single granularity is sent as field
      expect(requestBody, contains('name="timestamp_granularities[0]"'));
      expect(requestBody, contains('\r\nword\r\n'));

      // No second granularity
      expect(requestBody, isNot(contains('timestamp_granularities[1]')));

      client.close();
    });
  });
}
