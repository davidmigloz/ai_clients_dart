@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'real HTTP client cannot follow a credential-bearing cross-origin redirect',
    () async {
      final source = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final target = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final raw = http.Client();
      var targetRequests = 0;
      String? bearer;
      final targetSubscription = target.listen((request) async {
        targetRequests++;
        request.response.write('{}');
        await request.response.close();
      });
      final sourceSubscription = source.listen((request) async {
        bearer = request.headers.value('authorization');
        expect(request.headers.value('openai-project'), isNull);
        expect(request.headers.value('openai-organization'), isNull);
        request.response.statusCode = HttpStatus.found;
        request.response.headers.set(
          'location',
          'http://127.0.0.1:${target.port}/steal',
        );
        await request.response.close();
      });
      final root = 'http://127.0.0.1:${source.port}/proxy/complete/root';
      final client = OpenAIClient(
        config: OpenAIConfig.vertex(
          provider: VertexProvider(
            baseUrl: root,
            tokenProvider: () => Future<String>.value('fixture-google-token'),
          ),
          retryPolicy: const RetryPolicy(maxRetries: 0),
        ),
        httpClient: raw,
      );
      try {
        final result = await client.interceptorChain.execute(
          http.Request('GET', Uri.parse('$root/responses/resp_fixture')),
        );
        expect(result.statusCode, HttpStatus.found);
        expect(bearer, 'Bearer fixture-google-token');
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(targetRequests, 0);
      } finally {
        client.close();
        raw.close();
        await sourceSubscription.cancel();
        await targetSubscription.cancel();
        await source.close(force: true);
        await target.close(force: true);
      }
    },
  );

  test(
    'real request header timeout cancels transport with no extra dispatch',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final raw = http.Client();
      var requests = 0;
      var tokens = 0;
      final subscription = server.listen((request) {
        requests++;
        // Hold response headers until the configured deadline cancels the client.
        unawaited(request.drain<void>());
      });
      final client = OpenAIClient(
        config: OpenAIConfig.vertex(
          provider: VertexProvider(
            baseUrl: 'http://127.0.0.1:${server.port}/v1',
            tokenProvider: () => 'token-${++tokens}',
          ),
          timeout: const Duration(milliseconds: 100),
          retryPolicy: const RetryPolicy(maxRetries: 0),
        ),
        httpClient: raw,
      );
      try {
        await expectLater(
          client.responses.create(
            const CreateResponseRequest(
              model: 'fixture',
              input: ResponseInput.text('offline fixture'),
            ),
          ),
          throwsA(isA<RequestTimeoutException>()),
        );
        expect(requests, 1);
        expect(tokens, 1);
      } finally {
        client.close();
        raw.close();
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );

  test(
    'real SSE cancellation keeps a borrowed pool usable for the next request',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final raw = http.Client();
      var requests = 0;
      final subscriptions = server.listen((request) async {
        requests++;
        await request.drain<void>();
        request.response.bufferOutput = false;
        request.response.headers.contentType = ContentType(
          'text',
          'event-stream',
        );
        request.response.write('data: {"type":"fixture"}\n\n');
        await request.response.flush();
        if (requests > 1) {
          request.response.write('data: [DONE]\n\n');
          await request.response.close();
        }
      });
      final client = OpenAIClient(
        config: OpenAIConfig.vertex(
          provider: VertexProvider(
            baseUrl: 'http://127.0.0.1:${server.port}/v1',
            tokenProvider: () => 'fixture-token',
          ),
          retryPolicy: const RetryPolicy(maxRetries: 0),
        ),
        httpClient: raw,
        streamClientFactory: () => raw,
      );
      try {
        const request = CreateResponseRequest(
          model: 'fixture',
          input: ResponseInput.text('offline'),
        );
        final first = await client.responses
            .createStream(request, abortTrigger: Completer<void>().future)
            .take(1)
            .toList();
        expect(first, hasLength(1));
        final second = await client.responses.createStream(request).toList();
        expect(second, hasLength(1));
        expect(requests, 2);
      } finally {
        client.close();
        raw.close();
        await subscriptions.cancel();
        await server.close(force: true);
      }
    },
  );
}
