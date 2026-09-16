import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FilesResource', () {
    late http.Request captured;

    const fileJson =
        '{"id":"file-123","object":"file","bytes":3,"created_at":1,'
        '"filename":"clip.wav","purpose":"audio",'
        '"sample_type":null,"source":"upload"}';

    MistralClient clientReturning(String body, {int status = 200}) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          body,
          status,
          headers: {'content-type': 'application/json'},
        );
      });
      addTearDown(mockClient.close);
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    test('upload goes through the interceptor chain with auth', () async {
      final client = clientReturning(fileJson);
      addTearDown(client.close);

      final file = await client.files.upload(
        bytes: [0, 128, 255],
        fileName: 'clip.wav',
        purpose: FilePurpose.audio,
      );

      expect(file.id, 'file-123');
      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/files');
      expect(captured.headers['Authorization'], 'Bearer test-key');
      expect(captured.headers.containsKey('X-Request-ID'), isTrue);
      expect(
        captured.headers['content-type'],
        startsWith('multipart/form-data; boundary='),
      );

      final body = latin1.decode(captured.bodyBytes);
      expect(body, contains('name="file"; filename="clip.wav"'));
      expect(body, contains(latin1.decode([0, 128, 255])));
      expect(body, contains('name="purpose"\r\n\r\naudio\r\n'));
    });

    test('upload replays binary data after a rate limit', () async {
      final attempts = <http.Request>[];
      final mockClient = MockClient((request) async {
        attempts.add(request);
        return attempts.length == 1
            ? http.Response('{"message":"rate limited"}', 429)
            : http.Response(fileJson, 200);
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

      final file = await client.files.upload(
        bytes: [0, 128, 255],
        fileName: 'clip.wav',
        purpose: FilePurpose.audio,
      );

      expect(file.id, 'file-123');
      expect(attempts, hasLength(2));
      for (final attempt in attempts) {
        expect(attempt.headers['authorization'], 'Bearer test-key');
        expect(attempt.headers['x-request-id'], isNotEmpty);
        expect(
          attempt.headers['x-request-id'],
          attempts.first.headers['x-request-id'],
        );
        final boundary = attempt.headers['content-type']!.split('boundary=')[1];
        final body = latin1.decode(attempt.bodyBytes);
        expect(body, startsWith('--$boundary\r\n'));
        expect(body, endsWith('--$boundary--\r\n'));
        expect(body, contains('name="file"; filename="clip.wav"'));
        expect(body, contains(latin1.decode([0, 128, 255])));
        expect(body, contains('name="purpose"\r\n\r\naudio\r\n'));
      }
    });

    test('upload preserves an explicit authorization header', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer override-key');
        return http.Response(fileJson, 200);
      });
      addTearDown(mockClient.close);
      final client = MistralClient(
        config: const MistralConfig(
          authProvider: ApiKeyProvider('test-key'),
          defaultHeaders: {'authorization': 'Bearer override-key'},
        ),
        httpClient: mockClient,
      );
      addTearDown(client.close);

      final file = await client.files.upload(
        bytes: [0, 128, 255],
        fileName: 'clip.wav',
        purpose: FilePurpose.audio,
      );
      expect(file.id, 'file-123');
    });

    test('upload maps a 401 response to AuthenticationException', () async {
      final client = clientReturning('{"message":"Unauthorized"}', status: 401);
      addTearDown(client.close);

      await expectLater(
        client.files.upload(
          bytes: [1, 2, 3],
          fileName: 'clip.wav',
          purpose: FilePurpose.audio,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('upload rejects a call without exactly one input', () async {
      final client = clientReturning(fileJson);
      addTearDown(client.close);

      await expectLater(
        client.files.upload(purpose: FilePurpose.audio),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        client.files.upload(bytes: [1], purpose: FilePurpose.audio),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
