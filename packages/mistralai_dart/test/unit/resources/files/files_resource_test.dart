@TestOn('vm')
library;

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
        '"filename":"clip.wav","purpose":"audio"}';

    MistralClient clientReturning(String body, {int status = 200}) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          body,
          status,
          headers: {'content-type': 'application/json'},
        );
      });
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    test('upload goes through the interceptor chain with auth', () async {
      final client = clientReturning(fileJson);
      addTearDown(client.close);

      final file = await client.files.upload(
        bytes: [1, 2, 3],
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

      final body = utf8.decode(captured.bodyBytes);
      expect(body, contains('name="file"; filename="clip.wav"'));
      expect(body, contains('name="purpose"\r\n\r\naudio'));
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
