import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  const digest = 'sha256:0123456789abcdef';

  OllamaClient clientFor(MockClient transport, {OllamaConfig? config}) {
    final client = OllamaClient(
      config:
          config ?? const OllamaConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
      httpClient: transport,
    );
    addTearDown(client.close);
    return client;
  }

  test(
    'HEAD uses configured path/query/headers and returns true for an empty 200',
    () async {
      final client = clientFor(
        MockClient((request) async {
          expect(request.method, 'HEAD');
          expect(request.url.pathSegments, ['proxy', 'api', 'blobs', digest]);
          expect(request.url.queryParametersAll['token'], ['a', 'b']);
          expect(request.headers['x-custom'], 'value');
          expect(request.bodyBytes, isEmpty);
          return http.Response('', 200);
        }),
        config: const OllamaConfig(
          baseUrl: 'http://localhost:11434/proxy/?token=a&token=b',
          defaultHeaders: {'X-Custom': 'value'},
        ),
      );
      expect(await client.blobs.exists(digest: digest), isTrue);
    },
  );

  test('HEAD returns false only for 404', () async {
    final client = clientFor(MockClient((_) async => http.Response('', 404)));
    expect(await client.blobs.exists(digest: digest), isFalse);
  });

  for (final status in [400, 500]) {
    test('HEAD propagates $status', () async {
      final client = clientFor(
        MockClient((_) async => http.Response('{"error":"failed"}', status)),
      );
      await expectLater(
        client.blobs.exists(digest: digest),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }

  test('HEAD preserves authentication errors', () async {
    final client = clientFor(
      MockClient((_) async => http.Response('{"error":"auth"}', 401)),
    );
    await expectLater(
      client.blobs.exists(digest: digest),
      throwsA(isA<AuthenticationException>()),
    );
  });

  for (final status in [200, 201]) {
    test(
      'POST sends raw binary with auth and request ID; accepts empty $status',
      () async {
        final bytes = [0, 255, 254, 128, 13, 10, 195, 40];
        final client = clientFor(
          MockClient((request) async {
            expect(request.method, 'POST');
            expect(request.url.pathSegments.last, digest);
            expect(request.headers['content-type'], 'application/octet-stream');
            expect(request.headers['authorization'], 'Bearer test-key');
            expect(request.headers['x-request-id'], isNotEmpty);
            expect(request.bodyBytes, bytes);
            return http.Response('', status);
          }),
          config: const OllamaConfig(
            authProvider: BearerTokenProvider('test-key'),
            sendRequestIdHeader: true,
          ),
        );
        await client.blobs.create(digest: digest, bytes: bytes);
      },
    );
  }

  test(
    'binary body remains identical when transport retries a rate limit',
    () async {
      var attempts = 0;
      final bytes = [0, 255, 128, 254];
      final client = clientFor(
        MockClient((request) async {
          attempts++;
          expect(request.bodyBytes, bytes);
          expect(request.headers['authorization'], 'Bearer test-key');
          return http.Response('', attempts == 1 ? 429 : 201);
        }),
        config: const OllamaConfig(
          authProvider: BearerTokenProvider('test-key'),
          sendRequestIdHeader: true,
          retryPolicy: RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
            jitter: 0,
          ),
        ),
      );
      await client.blobs.create(digest: digest, bytes: bytes);
      expect(attempts, 2);
    },
  );

  test(
    'POST reports digest mismatch through the normal error envelope',
    () async {
      final client = clientFor(
        MockClient(
          (_) async => http.Response('{"error":"digest mismatch"}', 400),
        ),
      );
      await expectLater(
        client.blobs.create(digest: digest, bytes: [1]),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'digest mismatch',
          ),
        ),
      );
    },
  );

  test('closed client rejects both operations without sending', () async {
    final client = clientFor(
      MockClient((_) async => fail('Unexpected request')),
    )..close();
    await expectLater(
      client.blobs.exists(digest: digest),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      client.blobs.create(digest: digest, bytes: []),
      throwsA(isA<StateError>()),
    );
  });
}
