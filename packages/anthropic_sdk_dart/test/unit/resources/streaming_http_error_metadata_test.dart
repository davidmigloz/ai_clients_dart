import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  for (final method in ['POST', 'GET', 'JSONL', 'TYPED']) {
    for (final status in [401, 429, 503]) {
      test('$method $status preserves safe server response metadata', () async {
        var requests = 0;
        final mock = MockClient((request) async {
          requests++;
          expect(request.headers['x-request-id'], 'client-correlation');
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return http.Response(
            jsonEncode({
              'type': 'error',
              'error': {'type': 'fixture_error', 'message': 'fixture'},
            }),
            status,
            headers: {
              'ReQuEsT-Id': 'server-request',
              'Retry-After': '17',
              'X-Secret': 'private-response',
              'Set-Cookie': 'private-cookie',
            },
          );
        });
        final client = AnthropicClient(
          config: const AnthropicConfig(
            authProvider: ApiKeyProvider('fixture-key'),
            retryPolicy: RetryPolicy(maxRetries: 0),
            defaultHeaders: {'X-Request-ID': 'client-correlation'},
          ),
          httpClient: mock,
        );
        addTearDown(client.close);
        final stream = switch (method) {
          'POST' => client.messages.postStream(
            '/v1/messages',
            body: const {'stream': true},
          ),
          'GET' => client.messages.getStream('/v1/messages'),
          'TYPED' => client.messages.createStream(
            MessageCreateRequest(
              model: 'fixture',
              maxTokens: 1,
              messages: [InputMessage.user('Hi')],
            ),
          ),
          _ => client.messages.getJsonlStream('/v1/messages'),
        };
        try {
          await stream.toList();
          fail('Expected HTTP error');
        } on ApiException catch (error) {
          expect(error.statusCode, status);
          expect(
            error,
            status == 401
                ? isA<AuthenticationException>()
                : status == 429
                ? isA<RateLimitException>()
                : isA<ApiException>(),
          );
          expect(error.requestId, 'server-request');
          expect(error.requestMetadata, isNull);
          expect(error.responseMetadata!.headers, {
            'request-id': 'server-request',
            'retry-after': '17',
          });
          expect(error.responseMetadata!.bodyExcerpt, isEmpty);
          expect(
            error.responseMetadata!.latency,
            greaterThanOrEqualTo(const Duration(milliseconds: 10)),
          );
          expect(error.details, ['fixture_error']);
          if (error is RateLimitException) {
            final wait = error.retryAfter!.difference(DateTime.now());
            expect(wait, greaterThan(const Duration(seconds: 14)));
            expect(wait, lessThanOrEqualTo(const Duration(seconds: 17)));
          }
        }
        expect(requests, 1);
      });
    }
  }
  test(
    'missing server request ID is not replaced with local correlation',
    () async {
      final mock = MockClient((_) async => http.Response('{}', 503));
      final client = AnthropicClient(
        config: const AnthropicConfig(
          defaultHeaders: {'X-Request-ID': 'local'},
        ),
        httpClient: mock,
      );
      addTearDown(client.close);
      await expectLater(
        client.messages.getStream('/v1/messages').toList(),
        throwsA(
          isA<ApiException>().having((e) => e.requestId, 'requestId', isNull),
        ),
      );
    },
  );
  test(
    'request ID getter reads existing non-stream metadata case-insensitively',
    () {
      const error = ApiException(
        statusCode: 503,
        message: 'error',
        responseMetadata: ResponseMetadata(
          statusCode: 503,
          headers: {'ReQuEsT-Id': 'server'},
          bodyExcerpt: '',
          latency: Duration.zero,
        ),
      );
      expect(error.requestId, 'server');
      expect(
        const ApiException(statusCode: 503, message: 'error').requestId,
        isNull,
      );
    },
  );
  test(
    'non-stream resource exposes request ID through existing response metadata',
    () async {
      final mock = MockClient(
        (_) async => http.Response(
          '{"type":"error","error":{"type":"fixture_error","message":"fixture"}}',
          400,
          headers: {'Request-Id': 'server'},
        ),
      );
      final client = AnthropicClient(
        config: const AnthropicConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
        httpClient: mock,
      );
      addTearDown(client.close);
      await expectLater(
        client.messages.create(
          MessageCreateRequest(
            model: 'fixture',
            maxTokens: 1,
            messages: [InputMessage.user('Hi')],
          ),
        ),
        throwsA(
          isA<ApiException>().having((e) => e.requestId, 'requestId', 'server'),
        ),
      );
    },
  );
  test('retry-after permits surrounding HTTP whitespace', () async {
    final mock = MockClient(
      (_) async => http.Response(
        '{}',
        429,
        headers: {'request-id': 'server', 'retry-after': ' 17 '},
      ),
    );
    final client = AnthropicClient(httpClient: mock);
    addTearDown(client.close);
    await expectLater(
      client.messages.getStream('/v1/messages').toList(),
      throwsA(
        isA<RateLimitException>().having(
          (e) => e.retryAfter,
          'retryAfter',
          isNotNull,
        ),
      ),
    );
  });
  for (final header in [
    'invalid',
    '-1',
    '9000000000000',
    '9223372036854775807',
    '999999999999999999999999999999',
  ]) {
    test('invalid retry-after is safe: $header', () async {
      final mock = MockClient(
        (_) async => http.Response(
          '{"type":"error","error":{"type":"rate_limit_error","message":"limited"}}',
          429,
          headers: {'request-id': 'server-id', 'retry-after': header},
        ),
      );
      final client = AnthropicClient(
        config: const AnthropicConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
        httpClient: mock,
      );
      addTearDown(client.close);
      await expectLater(
        client.messages
            .postStream('/v1/messages', body: const {})
            .toList()
            .timeout(const Duration(seconds: 1)),
        throwsA(
          isA<RateLimitException>()
              .having((e) => e.requestId, 'requestId', 'server-id')
              .having((e) => e.retryAfter, 'retryAfter', isNull),
        ),
      );
    });
  }
}
