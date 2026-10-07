import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final status in [429, 503]) {
    for (final headers in <Map<String, String>>[
      {'retry-after-ms': '1.2345', 'retry-after': '9'},
      {'retry-after-ms': 'NaN', 'retry-after': '1.2345671'},
      {'retry-after-ms': '-1', 'retry-after': '2'},
    ]) {
      test(
        'public JSON $status preserves complete hint and metadata: $headers',
        () async {
          var sends = 0;
          const body = {
            'error': {
              'message': 'Overloaded',
              'type': 'server_error',
              'code': 'overloaded',
              'param': 'model',
            },
          };
          final client = _client(
            MockClient((request) async {
              sends++;
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/chat/completions');
              return http.Response(
                jsonEncode(body),
                status,
                headers: {...headers, 'x-request-id': 'req-guidance'},
              );
            }),
          );
          addTearDown(client.close);
          final error = await _captureError(client);
          expect(
            error,
            status == 429
                ? isA<RateLimitException>()
                : isA<InternalServerException>(),
          );
          expect(error.statusCode, status);
          expect(error.message, 'Overloaded');
          expect(error.type, 'server_error');
          expect(error.code, 'overloaded');
          expect(error.param, 'model');
          expect(error.requestId, 'req-guidance');
          expect(error.body, body);
          final expected = headers['retry-after-ms'] == '1.2345'
              ? const Duration(microseconds: 1235)
              : headers['retry-after-ms'] == 'NaN'
              ? const Duration(microseconds: 1234568)
              : const Duration(seconds: 2);
          expect(_retryAfter(error), expected);
          expect(sends, 1);
        },
      );
    }

    for (final errorBody in <Map<String, dynamic>>[
      {
        'message': false,
        'type': 'insufficient_quota',
        'code': 'insufficient_quota',
        'param': 'model',
      },
      {
        'message': 'Failure',
        'type': 'server_error',
        'code': 'overloaded',
        'param': <Object>[],
      },
      {
        'message': 'Failure',
        'type': false,
        'code': 'overloaded',
        'param': 'model',
      },
      {
        'message': 'Failure',
        'type': 'server_error',
        'code': 1,
        'param': 'model',
      },
    ]) {
      test('JSON $status parses metadata independently: $errorBody', () async {
        final body = {'error': errorBody};
        final client = _client(
          MockClient(
            (_) async => http.Response(
              jsonEncode(body),
              status,
              headers: {
                'retry-after-ms': '0.0001',
                'x-request-id': 'req-malformed',
              },
            ),
          ),
        );
        addTearDown(client.close);
        final error = await _captureError(client);
        for (final key in ['type', 'code', 'param']) {
          final value = errorBody[key];
          final actual = switch (key) {
            'type' => error.type,
            'code' => error.code,
            _ => error.param,
          };
          expect(actual, value is String ? value : null);
        }
        expect(error.body, body);
        expect(error.requestId, 'req-malformed');
        expect(_retryAfter(error), const Duration(microseconds: 1));
      });
    }

    for (final body in ['not JSON', '', '[]', '{"error":false}']) {
      test(
        'JSON $status raw fallback retains typed status and hint: $body',
        () async {
          final client = _client(
            MockClient(
              (_) async => http.Response(
                body,
                status,
                headers: {'retry-after-ms': '1.5', 'x-request-id': 'req-raw'},
              ),
            ),
          );
          addTearDown(client.close);
          final error = await _captureError(client);
          expect(
            error,
            status == 429
                ? isA<RateLimitException>()
                : isA<InternalServerException>(),
          );
          expect(error.message, body.isEmpty ? 'HTTP $status error' : body);
          expect(error.requestId, 'req-raw');
          expect(_retryAfter(error), const Duration(microseconds: 1500));
          expect(
            error.body,
            body == '{"error":false}' ? {'error': false} : null,
          );
        },
      );
    }
  }
}

OpenAIClient _client(http.Client transport) => OpenAIClient(
  config: const OpenAIConfig(
    authProvider: ApiKeyProvider('sk-fixture'),
    retryPolicy: RetryPolicy(maxRetries: 0),
  ),
  httpClient: transport,
);

Future<ApiException> _captureError(OpenAIClient client) async {
  try {
    await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'fixture-model',
        messages: [ChatMessage.user('Hello')],
      ),
    );
    fail('Expected an API error');
  } on ApiException catch (error) {
    return error;
  }
}

Duration? _retryAfter(ApiException error) => switch (error) {
  RateLimitException() => error.retryAfter,
  InternalServerException() => error.retryAfter,
  _ => null,
};
