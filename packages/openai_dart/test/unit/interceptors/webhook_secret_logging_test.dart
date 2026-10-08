import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/utils/webhooks/signing_secret_redaction.dart';
import 'package:test/test.dart';

Map<String, dynamic> _endpoint(String secret) => {
  'object': 'webhook_endpoint',
  'id': 'whe_synthetic',
  'created_at': 1,
  'name': 'synthetic',
  'url': 'https://receiver.example/webhooks',
  'event_types': ['response.completed'],
  'signing_secret_hint': null,
  'signing_secret': secret,
};

void main() {
  late List<String> records;
  late Level oldLevel;
  late bool oldHierarchical;
  setUp(() {
    records = [];
    oldHierarchical = hierarchicalLoggingEnabled;
    hierarchicalLoggingEnabled = true;
    oldLevel = Logger.root.level;
    Logger.root.level = Level.ALL;
    final subscription = Logger.root.onRecord.listen(
      (record) => records.add(record.message),
    );
    addTearDown(subscription.cancel);
  });
  tearDown(() {
    Logger.root.level = oldLevel;
    hierarchicalLoggingEnabled = oldHierarchical;
  });

  for (final secret in [
    '',
    'Q',
    'synthetic_signing_secret',
    'opaque/raw-looking/value',
    'quote"line\nsynthetic',
  ]) {
    test(
      'public create redacts structurally and keeps exact secret (${secret.length})',
      () async {
        final original = jsonEncode(_endpoint(secret));
        final transport = MockClient(
          (request) async => http.Response(original, 200),
        );
        final client = OpenAIClient(
          config: const OpenAIConfig(logLevel: Level.FINEST),
          httpClient: transport,
        );
        addTearDown(client.close);
        addTearDown(transport.close);
        final result = await client.webhooks.create(
          WebhookEndpointCreateRequest(
            name: 'synthetic',
            url: 'https://receiver.example/webhooks',
            eventTypes: const [WebhookEventType.responseCompleted],
          ),
        );
        expect(result.signingSecret, secret);
        expect(result.toJson(), _endpoint(secret));
        expect(result.toString(), contains('signingSecret: [redacted]'));
        final responseBody = records
            .where((record) => record.startsWith('  Body: '))
            .last;
        final logged =
            jsonDecode(responseBody.substring('  Body: '.length))
                as Map<String, dynamic>;
        expect(logged['signing_secret'], '[REDACTED]');
        expect(logged['signing_secret_hint'], isNull);
        expect(logged['object'], 'webhook_endpoint');
        expect(original, jsonEncode(_endpoint(secret)));
      },
    );
  }

  test(
    'redaction happens before truncation, response identity/body unchanged',
    () async {
      const secret = 'SYNTHETIC_SECRET_BEFORE_TRUNCATION';
      final original = http.Response(
        jsonEncode({'signing_secret': secret, 'tail': 'tail'}),
        200,
      );
      final logger = LoggingInterceptor(
        logger: Logger('redaction'),
        logResponseBody: true,
        maxBodyLength: 40,
      );
      final result = await logger.intercept(
        RequestContext(
          request: http.Request(
            'POST',
            Uri.parse('https://example.test/webhook_endpoints'),
          ),
        ),
        (_) => Future.value(original),
      );
      expect(result, same(original));
      expect(jsonDecode(result.body), {
        'signing_secret': secret,
        'tail': 'tail',
      });
      final body = records.lastWhere((record) => record.startsWith('  Body: '));
      expect(body, contains('[REDACTED]'));
      expect(body, isNot(contains('SYNTHETIC')));
      expect(body, contains('(truncated)'));
    },
  );

  test('nested and escaped JSON keys redact without mutating raw response', () {
    const body =
        r'{"items":[{"signing\u005fsecret":"SYNTHETIC_NESTED","echo":"SYNTHETIC_NESTED"}],"message":"kept"}';
    final redacted =
        jsonDecode(redactWebhookSigningSecretBody(body))
            as Map<String, dynamic>;
    expect(redacted['items'], [
      {'signing_secret': '[REDACTED]', 'echo': '[REDACTED]'},
    ]);
    expect(redacted['message'], 'kept');
    expect(body, contains('SYNTHETIC_NESTED'));
  });

  for (final error in [
    {'signing_secret': 'SYNTHETIC_ERROR_SECRET', 'message': <String>[]},
    {
      'error': {
        'signing_secret': 'SYNTHETIC_ERROR_SECRET',
        'message': <String>[],
      },
    },
    {'signing_secret': 'SYNTHETIC_ERROR_SECRET'},
    {
      'signing_secret': 'SYNTHETIC_ERROR_SECRET',
      'error': {
        'message': 'Rejected SYNTHETIC_ERROR_SECRET',
        'type': 'SYNTHETIC_ERROR_SECRET',
        'param': 'SYNTHETIC_ERROR_SECRET',
        'code': 'SYNTHETIC_ERROR_SECRET',
      },
    },
  ]) {
    test(
      'public structured error diagnostics safe (${jsonEncode(error).length})',
      () async {
        final transport = MockClient(
          (request) async => http.Response(jsonEncode(error), 400),
        );
        final client = OpenAIClient(
          config: const OpenAIConfig(
            logLevel: Level.FINEST,
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        addTearDown(transport.close);
        try {
          await client.webhooks.rotateSecret('whe_synthetic');
          fail('Expected typed API error');
        } on ApiException catch (failure) {
          expect(failure.body, error);
          expect(failure.toString(), isNot(contains('SYNTHETIC_ERROR_SECRET')));
          expect(failure.message, isNot(contains('SYNTHETIC_ERROR_SECRET')));
          expect(records.join('\n'), isNot(contains('SYNTHETIC_ERROR_SECRET')));
        }
      },
    );
  }

  for (final body in [
    'SYNTHETIC_RAW_SECRET',
    '"SYNTHETIC_RAW_SECRET"',
    '["SYNTHETIC_RAW_SECRET"]',
    '{"signing_secret":"SYNTHETIC_RAW_SECRET"',
  ]) {
    for (final status in [200, 400]) {
      test(
        'malformed secret-bearing response safe ($status/${body.length})',
        () async {
          final transport = MockClient(
            (request) async => http.Response(body, status),
          );
          final client = OpenAIClient(
            config: const OpenAIConfig(
              logLevel: Level.FINEST,
              retryPolicy: RetryPolicy(maxRetries: 0),
            ),
            httpClient: transport,
          );
          addTearDown(client.close);
          addTearDown(transport.close);
          try {
            await client.webhooks.rotateSecret('whe_synthetic');
            fail('Expected safe failure');
          } on FormatException catch (error) {
            expect(status, 200);
            expect(error.source, isNull);
            expect(error.toString(), isNot(contains('SYNTHETIC_RAW_SECRET')));
          } on ApiException catch (error) {
            expect(status, 400);
            expect(error.toString(), isNot(contains('SYNTHETIC_RAW_SECRET')));
          }
          expect(records.join('\n'), isNot(contains('SYNTHETIC_RAW_SECRET')));
        },
      );
    }
  }

  test(
    'raw error metadata and structured quota classification remain intact',
    () async {
      const secret = '_';
      const error = {
        'signing_secret': secret,
        'error': {
          'message': 'Quota exceeded',
          'type': 'insufficient_quota',
          'code': 'insufficient_quota',
          'param': 'input_value',
        },
      };
      var requests = 0;
      final transport = MockClient((request) async {
        requests++;
        return http.Response(jsonEncode(error), 429);
      });
      final client = OpenAIClient(
        config: const OpenAIConfig(logLevel: Level.FINEST),
        httpClient: transport,
      );
      addTearDown(client.close);
      addTearDown(transport.close);
      try {
        await client.webhooks.rotateSecret('whe_synthetic');
        fail('Expected quota error');
      } on RateLimitException catch (failure) {
        expect(failure.code, 'insufficient_quota');
        expect(failure.type, 'insufficient_quota');
        expect(failure.param, 'input_value');
        expect(failure.body, error);
        expect(requests, 1);
      }
      const direct = ApiException(
        statusCode: 418,
        message: 'Rejected SYNTHETIC_META',
        type: 'SYNTHETIC_META',
        code: 'SYNTHETIC_META',
        param: 'SYNTHETIC_META',
        body: {'signing_secret': 'SYNTHETIC_META'},
      );
      expect(direct.toString(), isNot(contains('SYNTHETIC_META')));
      expect(direct.code, 'SYNTHETIC_META');
      expect(direct.type, 'SYNTHETIC_META');
      expect(direct.param, 'SYNTHETIC_META');
    },
  );

  test(
    'public diagnostics tolerate cyclic and shared raw exception bodies',
    () {
      final shared = <String, dynamic>{'signing_secret': 'SYNTHETIC_CYCLE'};
      final body = <String, dynamic>{'first': shared, 'second': shared};
      final cycle = <Object?>[body];
      body['cycle'] = cycle;
      cycle.add(cycle);
      final error = ApiException(
        statusCode: 418,
        message: 'Rejected SYNTHETIC_CYCLE',
        code: 'SYNTHETIC_CYCLE',
        body: body,
      );
      expect(error.toString(), isNot(contains('SYNTHETIC_CYCLE')));
      expect(error.body, same(body));
      expect(body['cycle'], same(cycle));
      expect(error.code, 'SYNTHETIC_CYCLE');
    },
  );

  test(
    'unrelated body formatting, errors and request diagnostics stay unchanged',
    () async {
      const body = ' { "message" : "ordinary error" } ';
      expect(redactWebhookSigningSecretBody(body), body);
      expect(
        redactWebhookSigningSecretBody('ordinary non-JSON'),
        'ordinary non-JSON',
      );
      final response = http.Response('ordinary non-JSON', 400);
      const interceptor = ErrorInterceptor();
      await expectLater(
        interceptor.intercept(
          RequestContext(
            request: http.Request(
              'GET',
              Uri.parse('https://example.test/models'),
            ),
          ),
          (_) => Future.value(response),
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'ordinary non-JSON',
          ),
        ),
      );
    },
  );
}
