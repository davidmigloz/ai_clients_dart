@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final input in ['filePath', 'contentStream']) {
    test('upload retries $input without consuming the source again', () async {
      final directory = await Directory.systemTemp.createTemp(
        'mistral-upload-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final localFile = File('${directory.path}/clip.wav');
      await localFile.writeAsBytes([0, 128, 255]);
      var listens = 0;
      Stream<List<int>> source() async* {
        listens++;
        yield [0, 128];
        yield [255];
      }

      final attempts = <http.Request>[];
      final mockClient = MockClient((request) async {
        attempts.add(request);
        if (attempts.length == 1) {
          // File contents have already been buffered before transmission.
          await localFile.delete();
          return http.Response('{"message":"rate limited"}', 429);
        }
        return http.Response(
          '{"id":"file-123","object":"file","bytes":3,"created_at":1,'
          '"filename":"clip.wav","purpose":"audio",'
          '"sample_type":null,"source":"upload"}',
          200,
        );
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

      final uploaded = input == 'filePath'
          ? await client.files.upload(
              filePath: localFile.path,
              purpose: FilePurpose.audio,
            )
          : await client.files.upload(
              contentStream: source(),
              fileName: 'clip.wav',
              purpose: FilePurpose.audio,
            );

      expect(uploaded.id, 'file-123');
      expect(attempts, hasLength(2));
      expect(listens, input == 'contentStream' ? 1 : 0);
      for (final attempt in attempts) {
        expect(attempt.headers['authorization'], 'Bearer test-key');
        final body = latin1.decode(attempt.bodyBytes);
        expect(body, contains('name="file"; filename="clip.wav"'));
        expect(body, contains(latin1.decode([0, 128, 255])));
      }
    });
  }
}
