// ignore_for_file: avoid_print
/// Demonstrates retry hints and permanent quota handling using local fixtures.
///
/// Run: dart run example/retry_guidance_example.dart
/// No API key, network calls, or API charges are needed.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var overloadAttempts = 0;
  var quotaAttempts = 0;
  var longHintAttempts = 0;
  final transport = MockClient((request) async {
    if (request.method == 'GET' && request.url.path == '/v1/models') {
      if (++overloadAttempts == 1) {
        return _error(
          503,
          'service_unavailable_error',
          'server_is_overloaded',
          {'retry-after-ms': '10.5'},
        );
      }
      return http.Response(
        jsonEncode({'object': 'list', 'data': <Object>[]}),
        200,
      );
    }
    if (request.method == 'POST') {
      quotaAttempts++;
      return _error(429, 'insufficient_quota', 'project_spend_limit_exceeded', {
        'retry-after': '1',
      });
    }
    longHintAttempts++;
    return _error(503, 'service_unavailable_error', 'server_is_overloaded', {
      'retry-after': '3600',
    });
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('local-fixture'),
      retryPolicy: RetryPolicy(
        maxRetries: 2,
        initialDelay: Duration(milliseconds: 1),
        maxDelay: Duration(milliseconds: 20),
        jitter: 0,
      ),
    ),
    httpClient: transport,
  );
  try {
    await client.models.list();
    print('Transient GET overload recovered after $overloadAttempts attempts.');

    try {
      await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'local-fixture',
          messages: [ChatMessage.user('Hello')],
        ),
      );
    } on RateLimitException catch (error) {
      print('Quota error ${error.code}: $quotaAttempts attempt.');
      print('Update the project spend limit before trying again.');
      // retryAfter can exist on permanent errors; it does not make them transient.
    }

    try {
      await client.models.retrieve('long-hint');
    } on InternalServerException catch (error) {
      print('Long hint returned after $longHintAttempts attempt.');
      print('Full delay available to the application: ${error.retryAfter}.');
      // 3600s exceeds twice maxDelay. The client returns the original error
      // instead of shortening the hint and retrying early. Defer the operation.
    }
  } finally {
    client.close();
    transport.close();
  }
}

http.Response _error(
  int status,
  String type,
  String code,
  Map<String, String> headers,
) => http.Response(
  jsonEncode({
    'error': {
      'message': 'Local demonstration error',
      'type': type,
      'code': code,
      'param': null,
    },
  }),
  status,
  headers: headers,
);
