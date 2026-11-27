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
      expect(captured.headers.containsKey('X-Request-ID'), isFalse);
      expect(
        captured.headers['content-type'],
        startsWith('multipart/form-data; boundary='),
      );

      final body = latin1.decode(captured.bodyBytes);
      expect(body, contains('name="file"; filename="clip.wav"'));
      expect(body, contains(latin1.decode([0, 128, 255])));
      expect(body, contains('name="purpose"\r\n\r\naudio\r\n'));
    });

    test(
      'upload sends expiry, visibility, MIME and agentic safety purpose',
      () async {
        final client = clientReturning(
          '{"id":"file-123","object":"file","bytes":null,"created_at":1,'
          '"filename":"sample.jsonl","purpose":"agentic_safety",'
          '"sample_type":"instruct","source":"upload","visibility":"user"}',
        );
        addTearDown(client.close);

        final file = await client.files.upload(
          bytes: [123, 125],
          fileName: 'sample.jsonl',
          purpose: FilePurpose.agenticSafety,
          expiry: 48,
          visibility: FileVisibility.user,
          mimeType: 'application/jsonl',
        );

        expect(file.purpose, FilePurpose.agenticSafety);
        expect(file.bytes, isNull);
        expect(file.visibility, FileVisibility.user);
        final body = latin1.decode(captured.bodyBytes);
        expect(body, contains('name="purpose"\r\n\r\nagentic_safety'));
        expect(body, contains('name="expiry"\r\n\r\n48'));
        expect(body, contains('name="visibility"\r\n\r\nuser'));
        expect(body, contains('content-type: application/jsonl'));
      },
    );

    test('upload can omit optional multipart fields', () async {
      final client = clientReturning(fileJson);
      addTearDown(client.close);

      await client.files.upload(bytes: [1], fileName: 'clip.wav');

      final body = latin1.decode(captured.bodyBytes);
      expect(body, isNot(contains('name="purpose"')));
      expect(body, isNot(contains('name="expiry"')));
      expect(body, isNot(contains('name="visibility"')));
    });

    test('lists filtered pages using repeated query parameters', () async {
      final client = clientReturning('{"object":"list","data":[$fileJson]}');
      addTearDown(client.close);

      final list = await client.files.list(
        page: 3,
        pageSize: 2,
        includeTotal: false,
        purpose: FilePurpose.batch,
        sampleTypes: ['batch_request', 'batch_result'],
        sources: ['upload', 'repository'],
        search: 'sample',
        mimeTypes: ['application/jsonl', 'application/json'],
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/files');
      expect(captured.url.queryParametersAll, {
        'page': ['3'],
        'page_size': ['2'],
        'include_total': ['false'],
        'purpose': ['batch'],
        'sample_type': ['batch_request', 'batch_result'],
        'source': ['upload', 'repository'],
        'search': ['sample'],
        'mimetypes': ['application/jsonl', 'application/json'],
      });
      expect(list.data.single.id, 'file-123');
      expect(list.total, isNull);
    });

    test(
      'requests signed URLs with GET and whole-hour query parameters',
      () async {
        final client = clientReturning('{"url":"https://example.test/signed"}');
        addTearDown(client.close);

        final signed = await client.files.getSignedUrl(
          fileId: 'file-123',
          expiryHours: 2,
        );

        expect(captured.method, 'GET');
        expect(captured.url.path, '/v1/files/file-123/url');
        expect(captured.url.queryParameters, {'expiry': '2'});
        expect(captured.bodyBytes, isEmpty);
        expect(signed.url, 'https://example.test/signed');

        await client.files.getSignedUrl(fileId: 'file-123', expiresIn: 5400);
        expect(captured.url.queryParameters, {'expiry': '2'});

        await client.files.getSignedUrl(fileId: 'file-123');
        expect(captured.url.queryParameters, isEmpty);
      },
    );

    test('downloads actual bytes with the binary accept header', () async {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response.bytes([0, 128, 255], 200);
      });
      addTearDown(mockClient.close);
      final client = MistralClient(
        config: const MistralConfig(
          defaultHeaders: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        httpClient: mockClient,
      );
      addTearDown(client.close);

      final bytes = await client.files.download(fileId: 'file-123');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/files/file-123/content');
      expect(captured.headers['accept'], 'application/octet-stream');
      expect(captured.headers, isNot(contains('content-type')));
      expect(bytes, [0, 128, 255]);
    });

    test('returns minimal deletion confirmation', () async {
      final client = clientReturning(
        '{"id":"file-123","object":"file","deleted":true}',
      );
      addTearDown(client.close);

      final deleted = await client.files.delete(fileId: 'file-123');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/v1/files/file-123');
      expect(deleted.id, 'file-123');
      expect(deleted.deleted, isTrue);
      expect(deleted.bytes, isNull);
    });

    for (final sendRequestIdHeader in [false, true]) {
      test('upload replays binary data after a rate limit '
          '(sendRequestIdHeader: $sendRequestIdHeader)', () async {
        final attempts = <http.Request>[];
        final mockClient = MockClient((request) async {
          attempts.add(request);
          return attempts.length == 1
              ? http.Response('{"message":"rate limited"}', 429)
              : http.Response(fileJson, 200);
        });
        addTearDown(mockClient.close);
        final client = MistralClient(
          config: MistralConfig(
            authProvider: const ApiKeyProvider('test-key'),
            retryPolicy: const RetryPolicy(
              maxRetries: 1,
              initialDelay: Duration.zero,
              maxDelay: Duration.zero,
              jitter: 0,
            ),
            sendRequestIdHeader: sendRequestIdHeader,
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
          if (sendRequestIdHeader) {
            expect(attempt.headers['x-request-id'], isNotEmpty);
            expect(
              attempt.headers['x-request-id'],
              attempts.first.headers['x-request-id'],
            );
          } else {
            expect(attempt.headers, isNot(contains('x-request-id')));
          }
          final boundary = attempt.headers['content-type']!.split(
            'boundary=',
          )[1];
          final body = latin1.decode(attempt.bodyBytes);
          expect(body, startsWith('--$boundary\r\n'));
          expect(body, endsWith('--$boundary--\r\n'));
          expect(body, contains('name="file"; filename="clip.wav"'));
          expect(body, contains(latin1.decode([0, 128, 255])));
          expect(body, contains('name="purpose"\r\n\r\naudio\r\n'));
        }
      });
    }

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
