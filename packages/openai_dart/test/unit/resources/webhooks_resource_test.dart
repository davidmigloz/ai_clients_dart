import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import 'webhook_verifier_vectors.dart';

const _secret = 'whsec_RdvaYFYUXuIFuEbvZHwMfYFhUf7aMYjYcmM24+Aj40c=';
const _tolerance = Duration(days: 36500);
final Map<String, Object> _golden = verifierVectors['official']!;
final _body = _golden['body']! as String;
final _headers = <String, String>{
  'webhook-id': _golden['id']! as String,
  'webhook-timestamp': _golden['timestamp']! as String,
  'webhook-signature': 'v1,${_golden['signature']}',
};

class _UnusedAuth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    throw StateError('Authentication must not be requested');
  }
}

class _SensitiveValue {
  @override
  String toString() => 'SECRET_INVALID_VALUE';
}

void main() {
  group('Public webhook resource', () {
    for (final closeFirst in [false, true]) {
      test('all methods are local with closed=$closeFirst', () {
        var requests = 0;
        final auth = _UnusedAuth();
        final transport = MockClient((request) {
          requests++;
          throw StateError('HTTP must not be requested');
        });
        final client = OpenAIClient(
          config: OpenAIConfig(authProvider: auth, webhookSecret: _secret),
          httpClient: transport,
        );
        addTearDown(transport.close);
        if (closeFirst) client.close();
        final webhooks = client.webhooks;
        expect(identical(webhooks, client.webhooks), isTrue);
        webhooks
          ..verifySignature(_body, _headers, tolerance: _tolerance)
          ..verifySignatureBytes(
            utf8.encode(_body),
            _headers,
            tolerance: _tolerance,
          );
        final textEvent = webhooks.unwrap(
          _body,
          _headers,
          tolerance: _tolerance,
        );
        final byteEvent = webhooks.unwrapBytes(
          utf8.encode(_body),
          _headers,
          tolerance: _tolerance,
        );
        expect(textEvent, isA<ResponseCompletedWebhookEvent>());
        expect(byteEvent, textEvent);
        expect(textEvent.hashCode, byteEvent.hashCode);
        expect(
          (textEvent as ResponseCompletedWebhookEvent).data.id,
          'resp_123',
        );
        expect(requests, 0);
        expect(auth.calls, 0);
        client.close();
      });
    }

    test('unconfigured and closed client accepts per-call secret', () {
      final client = OpenAIClient()..close();
      expect(
        client.webhooks.unwrap(
          _body,
          _headers,
          secret: _secret,
          tolerance: _tolerance,
        ),
        isA<ResponseCompletedWebhookEvent>(),
      );
    });

    test('override, null fallback and empty override remain distinct', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(webhookSecret: _secret),
      );
      addTearDown(client.close);
      client.webhooks.verifySignature(
        _body,
        _headers,
        secret: null,
        tolerance: _tolerance,
      );
      expect(
        () => client.webhooks.verifySignature(
          _body,
          _headers,
          secret: '',
          tolerance: _tolerance,
        ),
        throwsArgumentError,
      );
      expect(
        () => client.webhooks.verifySignature(
          _body,
          _headers,
          secret: 'wrong',
          tolerance: _tolerance,
        ),
        throwsA(isA<InvalidWebhookSignatureException>()),
      );
      final overrideClient = OpenAIClient(
        config: const OpenAIConfig(webhookSecret: 'wrong'),
      );
      addTearDown(overrideClient.close);
      overrideClient.webhooks.verifySignatureBytes(
        utf8.encode(_body),
        _headers,
        secret: _secret,
        tolerance: _tolerance,
      );
    });

    test('tampered non-JSON bytes fail before parsing', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(webhookSecret: _secret),
      );
      addTearDown(client.close);
      expect(
        () => client.webhooks.unwrapBytes(
          [255, 254],
          _headers,
          tolerance: _tolerance,
        ),
        throwsA(isA<InvalidWebhookSignatureException>()),
      );
    });

    test('configured secret is never sent with an API request', () async {
      final transport = MockClient((request) async {
        expect(request.headers.values, isNot(contains(_secret)));
        expect(request.body, isNot(contains(_secret)));
        expect(request.url.toString(), isNot(contains(_secret)));
        return http.Response('{"object":"list","data":[]}', 200);
      });
      final client = OpenAIClient(
        config: const OpenAIConfig(webhookSecret: _secret),
        httpClient: transport,
      );
      addTearDown(client.close);
      addTearDown(transport.close);
      await client.models.list();
    });

    test('real-time signature with arbitrary future event dispatches', () {
      const body = '{"type":"video.future","data":{"value":1}}';
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();
      final signature = base64.encode(
        Hmac(
          sha256,
          base64.decode(_secret.substring(6)),
        ).convert(utf8.encode('delivery.$timestamp.$body')).bytes,
      );
      final client = OpenAIClient(
        config: const OpenAIConfig(webhookSecret: _secret),
      );
      addTearDown(client.close);
      final event = client.webhooks.unwrap(body, {
        'webhook-id': 'delivery',
        'webhook-timestamp': timestamp,
        'webhook-signature': 'v1,$signature',
      });
      expect(event, isA<UnknownWebhookEvent>());
      expect(event.toJson(), jsonDecode(body));
    });
  });

  group('Webhook configuration', () {
    test('secret preserve, replace, clear and value equality', () {
      const original = OpenAIConfig(webhookSecret: 'sensitive-one');
      expect(original.copyWith(), original);
      expect(original.copyWith().hashCode, original.hashCode);
      expect(original.copyWith(webhookSecret: null), const OpenAIConfig());
      expect(
        original.copyWith(webhookSecret: ''),
        const OpenAIConfig(webhookSecret: ''),
      );
      expect(
        original.copyWith(webhookSecret: 'sensitive-two'),
        const OpenAIConfig(webhookSecret: 'sensitive-two'),
      );
      expect(
        original,
        isNot(const OpenAIConfig(webhookSecret: 'sensitive-two')),
      );
      expect(original.toString(), isNot(contains('sensitive-one')));
      expect(const OpenAIConfig().toString(), contains('not configured'));
    });
    test('copying secret preserves all existing configuration', () {
      final auth = _UnusedAuth();
      final original = OpenAIConfig(
        authProvider: auth,
        baseUrl: 'https://example.test/v1',
        timeout: const Duration(seconds: 11),
        connectTimeout: const Duration(seconds: 12),
        retryPolicy: const RetryPolicy(maxRetries: 2),
        logLevel: Level.FINE,
        defaultHeaders: const {'x-a': 'a', 'x-b': 'b'},
        apiVersion: 'version',
        organization: 'org',
        project: 'project',
        webhookSecret: 'one',
      );
      final replaced = original.copyWith(webhookSecret: 'two');
      expect(replaced.copyWith(webhookSecret: 'one'), original);
      expect(replaced.authProvider, same(auth));
      expect(
        original.copyWith(defaultHeaders: {'x-b': 'b', 'x-a': 'a'}),
        original,
      );
      expect(
        original.copyWith(defaultHeaders: {'x-b': 'b', 'x-a': 'a'}).hashCode,
        original.hashCode,
      );
    });
    test('invalid copy secret never formats its value', () {
      try {
        const OpenAIConfig().copyWith(webhookSecret: _SensitiveValue());
        fail('Expected safe ArgumentError');
      } on ArgumentError catch (error) {
        expect(error.invalidValue, isNull);
        expect(error.toString(), isNot(contains('SECRET_INVALID_VALUE')));
      }
    });
  });
}
